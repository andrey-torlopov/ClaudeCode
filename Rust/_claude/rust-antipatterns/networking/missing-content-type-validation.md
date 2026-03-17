# Content-Type не валидируется

## Applies to
- Вызов `.json::<T>()` без проверки Content-Type заголовка ответа
- Десериализация тела ответа без подтверждения формата
- API, которые могут вернуть HTML error page вместо JSON

## Why this is bad
- Сервер может вернуть HTML (502 от nginx, Cloudflare challenge) вместо JSON
- `.json()` на HTML дает непонятную ошибку десериализации, а не "неверный Content-Type"
- Сложно диагностировать: serde error "expected value at line 1 column 1" при получении HTML
- CDN/proxy могут подменить ответ (captcha, maintenance page)

## Bad Example

```rust
async fn fetch_data(client: &reqwest::Client, url: &str) -> Result<ApiResponse, Error> {
    let response = client.get(url).send().await?;

    // Сразу парсим как JSON - даже если сервер вернул HTML
    let data: ApiResponse = response.json().await?;
    Ok(data)
}

async fn post_data(client: &reqwest::Client, payload: &Payload) -> Result<Receipt, Error> {
    let response = client
        .post("https://api.example.com/process")
        .json(payload)
        .send()
        .await?;

    // Не проверяем что ответ вообще JSON
    response.json().await.map_err(Error::from)
}
```

## Good Example

```rust
use reqwest::header::CONTENT_TYPE;

#[derive(Debug, thiserror::Error)]
enum ApiError {
    #[error("неожиданный Content-Type: ожидался application/json, получен {0}")]
    UnexpectedContentType(String),
    #[error("HTTP ошибка: {0}")]
    Http(#[from] reqwest::Error),
    #[error("десериализация: {0}")]
    Deserialization(#[from] serde_json::Error),
}

fn validate_content_type(response: &reqwest::Response) -> Result<(), ApiError> {
    let content_type = response
        .headers()
        .get(CONTENT_TYPE)
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");

    if !content_type.contains("application/json") {
        return Err(ApiError::UnexpectedContentType(content_type.to_owned()));
    }
    Ok(())
}

async fn fetch_data(client: &reqwest::Client, url: &str) -> Result<ApiResponse, ApiError> {
    let response = client.get(url).send().await?;

    validate_content_type(&response)?;

    let data: ApiResponse = response.json().await?;
    Ok(data)
}

// Вариант с информативным сообщением при ошибке парсинга
async fn fetch_data_verbose(
    client: &reqwest::Client,
    url: &str,
) -> Result<ApiResponse, ApiError> {
    let response = client.get(url).send().await?;

    validate_content_type(&response)?;

    let body = response.text().await?;
    let data: ApiResponse = serde_json::from_str(&body).map_err(|e| {
        tracing::error!(
            body_preview = &body[..body.len().min(200)],
            "Не удалось десериализовать ответ"
        );
        ApiError::Deserialization(e)
    })?;

    Ok(data)
}
```

## What to look for in code review
- `.json::<T>()` вызов без предварительной проверки Content-Type
- Отсутствие обработки случая, когда сервер вернул не JSON (HTML, XML, plain text)
- Serde ошибки "expected value at line 1 column 1" в логах - вероятно парсится HTML
- API клиенты без generic middleware для валидации Content-Type
