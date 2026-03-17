# Нет проверки security headers

## Applies to
- HTTP ответы без проверки security заголовков
- API клиенты, которые не валидируют HSTS, Certificate Pinning
- Серверный код (axum, actix-web), который не устанавливает защитные заголовки

## Why this is bad
- Без HSTS клиент может быть перенаправлен на HTTP (downgrade attack)
- Без X-Content-Type-Options браузер может выполнить MIME sniffing
- Без CSP возможен XSS через встраиваемый контент
- Без X-Frame-Options возможен clickjacking

## Bad Example

```rust
// Сервер: axum handler без security headers
use axum::{routing::get, Router, Json};

async fn get_data() -> Json<Data> {
    // Ответ без security headers
    Json(Data { value: 42 })
}

fn create_router() -> Router {
    Router::new()
        .route("/api/data", get(get_data))
    // Нет middleware для security headers
}

// Клиент: не проверяет security headers ответа
async fn fetch_sensitive_data(client: &reqwest::Client) -> Result<SensitiveData, Error> {
    let response = client
        .get("https://api.example.com/sensitive")
        .send()
        .await?;

    // Не проверяем Strict-Transport-Security
    // Не проверяем что соединение действительно HTTPS

    response.json().await.map_err(Error::from)
}
```

## Good Example

```rust
// Сервер: middleware для security headers
use axum::{
    routing::get,
    Router,
    middleware::{self, Next},
    response::Response,
    http::{Request, header::HeaderValue},
};

async fn security_headers_middleware<B>(
    request: Request<B>,
    next: Next<B>,
) -> Response {
    let mut response = next.run(request).await;
    let headers = response.headers_mut();

    headers.insert(
        "Strict-Transport-Security",
        HeaderValue::from_static("max-age=63072000; includeSubDomains; preload"),
    );
    headers.insert(
        "X-Content-Type-Options",
        HeaderValue::from_static("nosniff"),
    );
    headers.insert(
        "X-Frame-Options",
        HeaderValue::from_static("DENY"),
    );
    headers.insert(
        "Content-Security-Policy",
        HeaderValue::from_static("default-src 'self'"),
    );
    headers.insert(
        "X-XSS-Protection",
        HeaderValue::from_static("1; mode=block"),
    );
    headers.insert(
        "Referrer-Policy",
        HeaderValue::from_static("strict-origin-when-cross-origin"),
    );

    response
}

fn create_router() -> Router {
    Router::new()
        .route("/api/data", get(get_data))
        .layer(middleware::from_fn(security_headers_middleware))
}

// Клиент: проверка HSTS и TLS
async fn fetch_sensitive_data(client: &reqwest::Client, url: &str) -> Result<SensitiveData, ApiError> {
    // Убеждаемся что URL использует HTTPS
    if !url.starts_with("https://") {
        return Err(ApiError::InsecureConnection(url.to_owned()));
    }

    let response = client.get(url).send().await?;

    // Проверяем наличие HSTS заголовка для sensitive endpoints
    if response.headers().get("strict-transport-security").is_none() {
        tracing::warn!(url = %url, "HSTS заголовок отсутствует в ответе");
    }

    response.json().await.map_err(ApiError::from)
}
```

### Обязательные security headers для HTTP серверов

| Заголовок | Значение | Защита от |
|-----------|---------|-----------|
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains` | Downgrade attacks |
| `X-Content-Type-Options` | `nosniff` | MIME sniffing |
| `X-Frame-Options` | `DENY` | Clickjacking |
| `Content-Security-Policy` | `default-src 'self'` | XSS |
| `X-XSS-Protection` | `1; mode=block` | Reflected XSS (legacy) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Information leakage |

## What to look for in code review
- HTTP серверы (axum, actix-web) без middleware для security headers
- API клиенты, обращающиеся к sensitive endpoints без проверки HTTPS
- Конфигурация reqwest::Client с `.danger_accept_invalid_certs(true)`
- Отсутствие HSTS в production конфигурации
- Тестовые `.danger_accept_invalid_certs(true)` попавшие в production код
