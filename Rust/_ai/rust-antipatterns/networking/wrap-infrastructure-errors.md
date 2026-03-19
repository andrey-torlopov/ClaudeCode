# reqwest::Error не отличим от бизнес-ошибки

## Applies to
- `reqwest::Error` пробрасывается напрямую через `?` без обертки
- Один тип ошибки для сетевых и бизнес-проблем
- Невозможно отличить таймаут от невалидных данных

## Why this is bad
- `reqwest::Error` не содержит бизнес-контекст (какой endpoint, какой запрос)
- Невозможно построить retry стратегию: таймаут стоит повторить, 400 Bad Request - нет
- Вызывающий код не может отличить "сеть упала" от "пользователь не найден"
- Логирование одинаковое для всех ошибок - сложно приоритизировать alerts

## Bad Example

```rust
use thiserror::Error;

// Один тип для всего - бесполезен для принятия решений
#[derive(Debug, Error)]
enum AppError {
    #[error("запрос не удался: {0}")]
    Request(#[from] reqwest::Error),
}

async fn get_user(client: &reqwest::Client, id: u64) -> Result<User, AppError> {
    let user: User = client
        .get(format!("https://api.example.com/users/{}", id))
        .send()
        .await? // таймаут? DNS? TLS?
        .json()
        .await?; // битый JSON? неверная схема?
    Ok(user)
}

// Вызывающий код не может принять решение
async fn handle_request(id: u64) {
    match get_user(&client, id).await {
        Ok(user) => process(user),
        Err(e) => {
            // Повторить? Показать 404? Показать 500?
            // Невозможно определить без downcast
            eprintln!("Error: {}", e);
        }
    }
}
```

## Good Example

```rust
use reqwest::StatusCode;
use thiserror::Error;

#[derive(Debug, Error)]
enum ApiError {
    /// Сетевая проблема - имеет смысл повторить
    #[error("сетевая ошибка: {message}")]
    Network {
        message: String,
        is_timeout: bool,
        is_connect: bool,
    },

    /// Сервер вернул ошибку - зависит от статуса
    #[error("HTTP {status}: {message}")]
    Server {
        status: StatusCode,
        message: String,
    },

    /// Ответ не удалось десериализовать - баг в клиенте или API
    #[error("ошибка десериализации: {0}")]
    Deserialization(String),

    /// Бизнес-ошибка - ресурс не найден
    #[error("ресурс не найден: {0}")]
    NotFound(String),
}

impl ApiError {
    fn from_reqwest(error: reqwest::Error) -> ApiError {
        ApiError::Network {
            message: error.to_string(),
            is_timeout: error.is_timeout(),
            is_connect: error.is_connect(),
        }
    }

    fn is_retryable(&self) -> bool {
        match self {
            ApiError::Network { .. } => true,
            ApiError::Server { status, .. } => {
                status.is_server_error() || *status == StatusCode::TOO_MANY_REQUESTS
            }
            ApiError::Deserialization(_) => false,
            ApiError::NotFound(_) => false,
        }
    }
}

async fn get_user(client: &reqwest::Client, id: u64) -> Result<User, ApiError> {
    let response = client
        .get(format!("https://api.example.com/users/{}", id))
        .send()
        .await
        .map_err(ApiError::from_reqwest)?;

    let status = response.status();

    if status == StatusCode::NOT_FOUND {
        return Err(ApiError::NotFound(format!("user {}", id)));
    }

    if !status.is_success() {
        let body = response.text().await.unwrap_or_default();
        return Err(ApiError::Server {
            status,
            message: body,
        });
    }

    let user: User = response.json().await.map_err(|e| {
        ApiError::Deserialization(e.to_string())
    })?;

    Ok(user)
}

// Вызывающий код - осмысленная обработка
async fn handle_request(client: &reqwest::Client, id: u64) {
    match get_user(client, id).await {
        Ok(user) => process(user),
        Err(ApiError::NotFound(_)) => show_404(),
        Err(ref e) if e.is_retryable() => retry_later(id),
        Err(e) => show_error(&e),
    }
}
```

## What to look for in code review
- `#[from] reqwest::Error` в enum без дополнительных вариантов
- `?` на reqwest вызовах без маппинга в бизнес-ошибку
- Один `Err` обработчик для всех типов ошибок
- Отсутствие `.is_timeout()`, `.is_connect()` проверок для retry решений
- Retry на все ошибки без разделения retryable / non-retryable
