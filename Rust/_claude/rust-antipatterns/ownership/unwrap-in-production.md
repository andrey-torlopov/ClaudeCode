# .unwrap() в production коде

## Applies to
- `.unwrap()` на `Option<T>` и `Result<T, E>` в не-тестовом коде
- `.expect()` без осмысленного сообщения
- Индексация массива `arr[i]` без проверки bounds (паника при out-of-range)

## Why this is bad
- `.unwrap()` вызывает panic при None/Err - краш в production
- Паника в async runtime (tokio) убивает задачу, но может оставить ресурсы в inconsistent state
- Нет контекста в сообщении паники - сложно диагностировать в production логах
- Нарушает контракт "recoverable errors" - паника не для бизнес-ошибок

## Bad Example

```rust
fn get_config_value(key: &str) -> String {
    std::env::var(key).unwrap()
}

fn find_user(users: &[User], id: u64) -> &User {
    users.iter().find(|u| u.id == id).unwrap()
}

async fn fetch_data(client: &reqwest::Client, url: &str) -> ApiResponse {
    let response = client.get(url).send().await.unwrap();
    response.json::<ApiResponse>().await.unwrap()
}

fn parse_port(input: &str) -> u16 {
    input.parse().unwrap()
}
```

## Good Example

```rust
use thiserror::Error;

#[derive(Debug, Error)]
enum AppError {
    #[error("отсутствует переменная окружения: {0}")]
    MissingEnvVar(String),
    #[error("пользователь с id {0} не найден")]
    UserNotFound(u64),
    #[error("ошибка HTTP запроса: {0}")]
    Http(#[from] reqwest::Error),
    #[error("некорректный порт: {0}")]
    InvalidPort(String),
}

fn get_config_value(key: &str) -> Result<String, AppError> {
    std::env::var(key).map_err(|_| AppError::MissingEnvVar(key.to_owned()))
}

fn find_user<'a>(users: &'a [User], id: u64) -> Result<&'a User, AppError> {
    users.iter().find(|u| u.id == id).ok_or(AppError::UserNotFound(id))
}

async fn fetch_data(
    client: &reqwest::Client,
    url: &str,
) -> Result<ApiResponse, AppError> {
    let response = client.get(url).send().await?;
    let data = response.json::<ApiResponse>().await?;
    Ok(data)
}

fn parse_port(input: &str) -> Result<u16, AppError> {
    input
        .parse()
        .map_err(|_| AppError::InvalidPort(input.to_owned()))
}
```

### Когда .expect() допустим

`.expect()` допустим, если невозможность значения доказуема:

```rust
// OK: regex гарантированно валидный (compile-time строка)
let re = regex::Regex::new(r"^\d{4}-\d{2}-\d{2}$")
    .expect("date regex is valid - это compile-time константа");

// OK: OnceLock::get() после гарантированной инициализации
static CONFIG: OnceLock<Config> = OnceLock::new();
// ... после init() ...
let cfg = CONFIG.get().expect("CONFIG инициализирован в main() до использования");
```

## What to look for in code review
- `.unwrap()` в любом файле вне `#[cfg(test)]` модулей
- `.expect("")` с пустым или бессмысленным сообщением ("failed", "error", "oops")
- Цепочки `.unwrap().unwrap()` - двойная паника
- `arr[index]` без предварительной проверки `index < arr.len()` - предпочитай `.get(index)`
- `HashMap::get().unwrap()` - используй `.get().ok_or()` или entry API
