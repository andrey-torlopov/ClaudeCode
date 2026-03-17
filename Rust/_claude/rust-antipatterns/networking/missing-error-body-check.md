# Проверка только HTTP-кода без бизнес-ошибки

## Applies to
- Проверка `response.status().is_success()` без парсинга error body
- API, которые возвращают 200 OK с бизнес-ошибкой в теле
- Потеря информации из error response при обработке не-2xx статусов

## Why this is bad
- Многие API возвращают structured error в теле (code, message, details)
- HTTP 400 с `{"error": "invalid_email"}` превращается в безликое "Bad Request"
- Невозможно отличить "неверный формат" от "пользователь не найден" без парсинга тела
- Retry логика не может принять решение без знания бизнес-ошибки

## Bad Example

```rust
async fn create_user(client: &reqwest::Client, user: &NewUser) -> Result<User, ApiError> {
    let response = client
        .post("https://api.example.com/users")
        .json(user)
        .send()
        .await?;

    // Проверяем только HTTP статус - теряем error details
    if !response.status().is_success() {
        return Err(ApiError::HttpError(response.status()));
    }

    let user: User = response.json().await?;
    Ok(user)
}

// Или используем error_for_status() - теряет тело ответа
async fn fetch_order(client: &reqwest::Client, id: u64) -> Result<Order, reqwest::Error> {
    client
        .get(format!("https://api.example.com/orders/{}", id))
        .send()
        .await?
        .error_for_status()? // Тело ошибки потеряно навсегда
        .json()
        .await
}
```

## Good Example

```rust
use reqwest::StatusCode;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct ApiErrorBody {
    error: String,
    message: String,
    #[serde(default)]
    details: Vec<String>,
}

#[derive(Debug, thiserror::Error)]
enum ApiError {
    #[error("HTTP {status}: {error} - {message}")]
    ApiResponse {
        status: StatusCode,
        error: String,
        message: String,
        details: Vec<String>,
    },

    #[error("HTTP {status}: невозможно прочитать тело ошибки")]
    UnreadableError {
        status: StatusCode,
        raw_body: String,
    },

    #[error("ошибка сети: {0}")]
    Network(#[from] reqwest::Error),
}

impl ApiError {
    fn is_retryable(&self) -> bool {
        match self {
            ApiError::ApiResponse { status, .. } => {
                status.is_server_error() || *status == StatusCode::TOO_MANY_REQUESTS
            }
            ApiError::Network(e) => e.is_timeout() || e.is_connect(),
            _ => false,
        }
    }
}

async fn create_user(client: &reqwest::Client, user: &NewUser) -> Result<User, ApiError> {
    let response = client
        .post("https://api.example.com/users")
        .json(user)
        .send()
        .await?;

    if !response.status().is_success() {
        let status = response.status();
        let body_text = response.text().await.unwrap_or_default();

        // Пытаемся десериализовать structured error
        return match serde_json::from_str::<ApiErrorBody>(&body_text) {
            Ok(error_body) => Err(ApiError::ApiResponse {
                status,
                error: error_body.error,
                message: error_body.message,
                details: error_body.details,
            }),
            Err(_) => Err(ApiError::UnreadableError {
                status,
                raw_body: body_text,
            }),
        };
    }

    let user: User = response.json().await?;
    Ok(user)
}
```

## What to look for in code review
- `response.error_for_status()?` - тело ответа потеряно, остается только статус
- `if !status.is_success() { return Err(...) }` без чтения body
- `Err(ApiError::HttpError(status))` - только статус-код, без сообщения
- Отсутствие `ApiErrorBody` или аналогичной структуры для парсинга ошибок API
- Retry логика, которая повторяет запрос без анализа причины отказа
