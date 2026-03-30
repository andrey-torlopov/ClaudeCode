# reqwest::Client не настроен

## Applies to
- `reqwest::Client::new()` без настроек через `ClientBuilder`
- Дефолтные таймауты (отсутствуют в reqwest по умолчанию - бесконечное ожидание)
- Отсутствие connection pool настроек

## Why this is bad
- `Client::new()` не имеет таймаута по умолчанию - запрос может висеть вечно
- Дефолтный connection pool может исчерпать ресурсы при высокой нагрузке
- Нет User-Agent - некоторые API блокируют запросы без него
- Нет redirect policy - по умолчанию следует до 10 редиректов

## Bad Example

```rust
async fn make_request() -> Result<String, reqwest::Error> {
    let client = reqwest::Client::new(); // Все дефолты

    // Нет таймаута - может висеть вечно
    let response = client
        .get("https://api.example.com/data")
        .send()
        .await?;

    response.text().await
}

// Или еще хуже - новый клиент на каждый запрос
async fn fetch_users() -> Result<Vec<User>, reqwest::Error> {
    reqwest::get("https://api.example.com/users") // новый Client каждый раз
        .await?
        .json()
        .await
}
```

## Good Example

```rust
use std::time::Duration;
use reqwest::header::{HeaderMap, HeaderValue, ACCEPT, USER_AGENT};

fn build_http_client() -> Result<reqwest::Client, reqwest::Error> {
    let mut default_headers = HeaderMap::new();
    default_headers.insert(ACCEPT, HeaderValue::from_static("application/json"));
    default_headers.insert(
        USER_AGENT,
        HeaderValue::from_static("my-service/1.0"),
    );

    reqwest::Client::builder()
        .timeout(Duration::from_secs(30))
        .connect_timeout(Duration::from_secs(5))
        .pool_max_idle_per_host(10)
        .pool_idle_timeout(Duration::from_secs(90))
        .redirect(reqwest::redirect::Policy::limited(5))
        .default_headers(default_headers)
        .build()
}

// Один клиент на все время жизни приложения
struct ApiClient {
    http: reqwest::Client,
    base_url: String,
}

impl ApiClient {
    fn new(base_url: &str) -> Result<ApiClient, reqwest::Error> {
        let http = build_http_client()?;
        Ok(ApiClient {
            http,
            base_url: base_url.to_owned(),
        })
    }

    async fn fetch_users(&self) -> Result<Vec<User>, ApiError> {
        let users: Vec<User> = self
            .http
            .get(format!("{}/users", self.base_url))
            .send()
            .await?
            .json()
            .await?;

        Ok(users)
    }
}
```

### Рекомендуемые настройки

| Параметр | Значение | Зачем |
|----------|---------|-------|
| `timeout` | 30s | Общий таймаут запроса |
| `connect_timeout` | 5s | Таймаут установки TCP соединения |
| `pool_max_idle_per_host` | 10 | Лимит idle соединений на хост |
| `pool_idle_timeout` | 90s | Время жизни idle соединения |
| `redirect::Policy::limited(5)` | 5 | Максимум редиректов |
| `default_headers` | Accept, User-Agent | Заголовки по умолчанию |

## What to look for in code review
- `reqwest::Client::new()` без `ClientBuilder`
- Отсутствие `.timeout()` - нет защиты от зависших запросов
- `reqwest::get()` - создает новый Client каждый раз (нет connection pooling)
- Создание `Client` внутри цикла или на каждый запрос
- Отсутствие `connect_timeout` отдельно от общего `timeout`
