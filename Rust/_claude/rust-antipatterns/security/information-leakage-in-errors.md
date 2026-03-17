# Утечка данных через error Display

## Applies to
- `impl Display for Error` с internal details
- `format!("{:?}", error)` отдающий Debug представление пользователю
- HTTP ответы с полным текстом ошибки
- Backtrace и panic messages в production ответах

## Why this is bad
- Внутренние ошибки (SQL queries, connection strings, file paths) раскрывают архитектуру
- `Debug` impl может содержать sensitive поля, stack trace, memory addresses
- Пользователю нужно понятное сообщение, а не `SqliteError: no such column: users.password_hash`
- Backtrace в production ответе раскрывает внутреннюю структуру приложения

## Bad Example

```rust
use axum::{response::IntoResponse, http::StatusCode};

#[derive(Debug, thiserror::Error)]
enum AppError {
    #[error("database error: {0}")] // SQL текст утечет в Display
    Database(#[from] sqlx::Error),

    #[error("failed to connect to redis at {host}:{port}: {source}")]
    Redis {
        host: String,   // внутренний хост утечет
        port: u16,       // внутренний порт утечет
        source: redis::RedisError,
    },

    #[error("authentication failed for user {username} with token {token}")]
    AuthFailed {
        username: String,
        token: String, // токен в Display!
    },
}

// Ошибка целиком уходит пользователю
impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let body = format!("{}", self); // Display с internal details
        (StatusCode::INTERNAL_SERVER_ERROR, body).into_response()
    }
}

// Debug в логах клиента
async fn handler() -> Result<String, AppError> {
    let data = db_query().await.map_err(|e| {
        // Полный Debug с backtrace
        eprintln!("Error: {:?}", e);
        e
    })?;
    Ok(data)
}
```

## Good Example

```rust
use axum::{response::IntoResponse, http::StatusCode, Json};
use serde::Serialize;
use tracing::error;
use uuid::Uuid;

#[derive(Debug, thiserror::Error)]
enum AppError {
    #[error("database error")]
    Database(#[from] sqlx::Error),

    #[error("cache connection error")]
    Redis {
        host: String,
        port: u16,
        source: redis::RedisError,
    },

    #[error("authentication failed")]
    AuthFailed { username: String },
}

#[derive(Serialize)]
struct ErrorResponse {
    error_id: String,
    message: String,
}

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let error_id = Uuid::new_v4().to_string();

        // Подробности - только во внутренние логи
        error!(
            error_id = %error_id,
            error = ?self,
            "Request failed"
        );

        // Пользователю - generic сообщение + ID для поддержки
        let (status, message) = match &self {
            AppError::Database(_) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Внутренняя ошибка сервера".to_owned(),
            ),
            AppError::Redis { .. } => (
                StatusCode::SERVICE_UNAVAILABLE,
                "Сервис временно недоступен".to_owned(),
            ),
            AppError::AuthFailed { .. } => (
                StatusCode::UNAUTHORIZED,
                "Неверные учетные данные".to_owned(),
            ),
        };

        let body = ErrorResponse {
            error_id,
            message,
        };

        (status, Json(body)).into_response()
    }
}
```

### Правило двух уровней

| Уровень | Что показываем | Где |
|---------|---------------|-----|
| Пользователь | Generic message + error_id | HTTP response body |
| Разработчик | Полный Debug + context | tracing/log (internal) |

## What to look for in code review
- `format!("{}", error)` или `error.to_string()` в HTTP ответах
- `format!("{:?}", error)` - Debug impl может содержать больше данных чем Display
- `#[error("...{source}")]` в thiserror - вложенная ошибка утекает в Display
- Connection strings, хосты, порты, пути к файлам в `#[error()]` сообщениях
- `.backtrace()` или `RUST_BACKTRACE=1` в production конфигурации
- Panic handler, который отдает panic message клиенту
