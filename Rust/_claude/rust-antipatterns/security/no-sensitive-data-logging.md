# Sensitive Data в логах

## Applies to
- `tracing::info!()`, `tracing::debug!()`, `log::info!()` с PII полями
- `println!()` / `eprintln!()` с токенами, паролями, email
- `dbg!()` оставленный в production коде
- `#[derive(Debug)]` на struct с sensitive полями - автоматически выводит все

## Why this is bad
- PII в логах нарушает GDPR, CCPA и другие регуляции
- Токены/пароли в логах - вектор атаки при компрометации лог-системы
- `dbg!()` пишет в stderr - попадает в production логи
- `#[derive(Debug)]` на struct с токеном выводит токен при любом `{:?}` форматировании

## Bad Example

```rust
use tracing::info;

#[derive(Debug)] // Debug автоматически выведет token и password
struct UserCredentials {
    username: String,
    password: String,
    api_token: String,
}

async fn authenticate(creds: &UserCredentials) -> Result<Session, AuthError> {
    // PII в трейсинге
    info!("Authenticating user: {:?}", creds);

    let token = fetch_token(&creds.api_token).await?;

    // Токен в println
    println!("Got token: {}", token);

    // dbg! забытый после отладки
    let session = dbg!(create_session(token).await?);

    info!(
        user = %creds.username,
        token = %creds.api_token, // токен в structured logging
        "User authenticated"
    );

    Ok(session)
}

fn log_request(headers: &reqwest::header::HeaderMap) {
    // Authorization header в логах
    for (name, value) in headers.iter() {
        info!("Header: {} = {:?}", name, value);
    }
}
```

## Good Example

```rust
use secrecy::{ExposeSecret, SecretString};
use tracing::info;

// Ручная реализация Debug - маскировка sensitive полей
struct UserCredentials {
    username: String,
    password: SecretString,
    api_token: SecretString,
}

impl std::fmt::Debug for UserCredentials {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("UserCredentials")
            .field("username", &self.username)
            .field("password", &"[REDACTED]")
            .field("api_token", &"[REDACTED]")
            .finish()
    }
}

// #[instrument] с skip для sensitive полей
#[tracing::instrument(skip(creds))]
async fn authenticate(creds: &UserCredentials) -> Result<Session, AuthError> {
    info!(user = %creds.username, "Authenticating user");

    let token = fetch_token(creds.api_token.expose_secret()).await?;
    let session = create_session(token).await?;

    info!(user = %creds.username, "User authenticated successfully");
    Ok(session)
}

fn log_request(headers: &reqwest::header::HeaderMap) {
    // Список безопасных заголовков для логирования
    const SAFE_HEADERS: &[&str] = &["content-type", "accept", "user-agent"];

    for (name, value) in headers.iter() {
        if SAFE_HEADERS.contains(&name.as_str()) {
            info!("Header: {} = {:?}", name, value);
        } else {
            info!("Header: {} = [REDACTED]", name);
        }
    }
}
```

### Что использовать для маскировки

| Инструмент | Назначение |
|------------|-----------|
| `secrecy::SecretString` | Обертка, не реализует Display/Debug |
| `#[instrument(skip(field))]` | Пропуск полей в tracing spans |
| `impl Debug for T` вручную | Контроль вывода для sensitive struct |
| `tracing::field::Empty` | Placeholder для sensitive span полей |

## What to look for in code review
- `#[derive(Debug)]` на struct с полями `token`, `password`, `secret`, `key`, `credential`
- `dbg!()` вызовы - должны быть удалены перед merge
- `println!()` / `eprintln!()` - в production используй tracing/log
- `info!(..., token = ...)` или `debug!("{:?}", credentials)` - sensitive данные в логах
- `#[instrument]` без `skip` для параметров с sensitive данными
- `format!("{:?}", error)` где error может содержать connection strings или токены
