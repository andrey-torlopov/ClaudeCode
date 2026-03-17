# reqwest::get() inline без shared client

## Applies to
- `reqwest::get(url)` вызовы напрямую без shared `Client`
- Создание нового `reqwest::Client` на каждый запрос
- HTTP вызовы разбросанные по всему коду без абстракции

## Why this is bad
- `reqwest::get()` создает новый `Client` каждый раз - нет connection pooling
- TLS handshake на каждый запрос (дорого: ~100-300ms)
- Невозможно добавить middleware (retry, tracing, auth) в одном месте
- Невозможно подменить HTTP клиент в тестах

## Bad Example

```rust
async fn fetch_user(id: u64) -> Result<User, reqwest::Error> {
    // Новый Client на каждый вызов
    reqwest::get(format!("https://api.example.com/users/{}", id))
        .await?
        .json()
        .await
}

async fn fetch_orders(user_id: u64) -> Result<Vec<Order>, reqwest::Error> {
    // Еще один новый Client
    reqwest::get(format!("https://api.example.com/users/{}/orders", user_id))
        .await?
        .json()
        .await
}

async fn create_payment(payment: &Payment) -> Result<Receipt, reqwest::Error> {
    // И еще один - дублирование настроек
    let client = reqwest::Client::new();
    client
        .post("https://api.example.com/payments")
        .json(payment)
        .send()
        .await?
        .json()
        .await
}
```

## Good Example

```rust
use reqwest::Client;
use std::time::Duration;

/// HTTP клиент приложения с настроенным connection pool и middleware
struct ApiClient {
    http: Client,
    base_url: String,
}

impl ApiClient {
    fn new(base_url: &str) -> Result<ApiClient, reqwest::Error> {
        let http = Client::builder()
            .timeout(Duration::from_secs(30))
            .connect_timeout(Duration::from_secs(5))
            .pool_max_idle_per_host(10)
            .build()?;

        Ok(ApiClient {
            http,
            base_url: base_url.to_owned(),
        })
    }

    async fn fetch_user(&self, id: u64) -> Result<User, ApiError> {
        self.get(&format!("/users/{}", id)).await
    }

    async fn fetch_orders(&self, user_id: u64) -> Result<Vec<Order>, ApiError> {
        self.get(&format!("/users/{}/orders", user_id)).await
    }

    async fn create_payment(&self, payment: &Payment) -> Result<Receipt, ApiError> {
        let response = self
            .http
            .post(format!("{}/payments", self.base_url))
            .json(payment)
            .send()
            .await?;

        self.handle_response(response).await
    }

    /// Общий метод GET с обработкой ошибок
    async fn get<T: serde::de::DeserializeOwned>(&self, path: &str) -> Result<T, ApiError> {
        let response = self
            .http
            .get(format!("{}{}", self.base_url, path))
            .send()
            .await?;

        self.handle_response(response).await
    }

    async fn handle_response<T: serde::de::DeserializeOwned>(
        &self,
        response: reqwest::Response,
    ) -> Result<T, ApiError> {
        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await.unwrap_or_default();
            return Err(ApiError::HttpError { status, body });
        }
        let data = response.json::<T>().await?;
        Ok(data)
    }
}

// Тестирование - можно подменить через trait
#[cfg(test)]
mod tests {
    use super::*;
    use wiremock::{MockServer, Mock, ResponseTemplate};
    use wiremock::matchers::method;

    #[tokio::test]
    async fn test_fetch_user() {
        let mock_server = MockServer::start().await;

        Mock::given(method("GET"))
            .respond_with(ResponseTemplate::new(200).set_body_json(serde_json::json!({
                "id": 1,
                "name": "Test User"
            })))
            .mount(&mock_server)
            .await;

        let client = ApiClient::new(&mock_server.uri()).unwrap();
        let user = client.fetch_user(1).await.unwrap();
        assert_eq!(user.name, "Test User");
    }
}
```

## What to look for in code review
- `reqwest::get()` вызовы - всегда создают новый Client
- `reqwest::Client::new()` внутри функции, а не shared
- URL базовый адрес повторяется в каждом вызове (нет base_url)
- Одинаковые заголовки (auth, content-type) добавляются в каждом запросе
- Нет единой точки обработки ошибок HTTP
