# Неконтролируемая retry-логика

## Applies to
- `loop` с retry без ограничения количества попыток
- Retry без exponential backoff - фиксированный интервал
- Отсутствие jitter - все клиенты ретраят одновременно (thundering herd)
- Retry на non-retryable ошибки (400 Bad Request)

## Why this is bad
- Бесконечный retry при постоянной ошибке - бесконечный цикл
- Retry без backoff - DDoS собственного сервиса
- Без jitter - все клиенты ретраят одновременно после outage (thundering herd)
- Retry на 400/401/403 - бесполезно, ошибка клиента не исправится повтором

## Bad Example

```rust
use std::time::Duration;

async fn fetch_with_retry(client: &reqwest::Client, url: &str) -> Result<String, Error> {
    // Бесконечный цикл - если сервер всегда отвечает 500, зависнет навсегда
    loop {
        match client.get(url).send().await {
            Ok(response) if response.status().is_success() => {
                return response.text().await.map_err(Error::from);
            }
            Ok(_) => {
                // Фиксированный интервал - нет backoff
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
            Err(_) => {
                // Retry на любую ошибку, включая DNS resolution failure
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        }
    }
}

// Retry на не-retryable ошибки
async fn create_user_with_retry(
    client: &reqwest::Client,
    user: &NewUser,
) -> Result<User, Error> {
    for _ in 0..5 {
        match client.post("/users").json(user).send().await {
            Ok(r) if r.status().is_success() => return r.json().await.map_err(Error::from),
            // Retry на 400 Bad Request - бесполезно, данные не изменятся
            Ok(_) | Err(_) => {
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        }
    }
    Err(Error::MaxRetriesExceeded)
}
```

## Good Example

```rust
use std::time::Duration;
use rand::Rng;

struct RetryConfig {
    max_retries: u32,
    initial_delay: Duration,
    max_delay: Duration,
    backoff_factor: f64,
}

impl Default for RetryConfig {
    fn default() -> RetryConfig {
        RetryConfig {
            max_retries: 3,
            initial_delay: Duration::from_millis(100),
            max_delay: Duration::from_secs(30),
            backoff_factor: 2.0,
        }
    }
}

fn is_retryable_status(status: reqwest::StatusCode) -> bool {
    status.is_server_error()
        || status == reqwest::StatusCode::TOO_MANY_REQUESTS
        || status == reqwest::StatusCode::REQUEST_TIMEOUT
}

fn is_retryable_error(error: &reqwest::Error) -> bool {
    error.is_timeout() || error.is_connect()
}

fn delay_with_jitter(base: Duration) -> Duration {
    let jitter = rand::thread_rng().gen_range(0.0..0.5);
    base.mul_f64(1.0 + jitter)
}

async fn fetch_with_retry(
    client: &reqwest::Client,
    url: &str,
    config: &RetryConfig,
) -> Result<String, Error> {
    let mut delay = config.initial_delay;

    for attempt in 0..=config.max_retries {
        match client.get(url).send().await {
            Ok(response) if response.status().is_success() => {
                return response.text().await.map_err(Error::from);
            }
            Ok(response) if !is_retryable_status(response.status()) => {
                // Non-retryable - не повторяем
                return Err(Error::NonRetryable(response.status()));
            }
            Ok(response) => {
                tracing::warn!(
                    attempt,
                    status = %response.status(),
                    "retryable HTTP ошибка"
                );
            }
            Err(ref e) if !is_retryable_error(e) => {
                return Err(Error::NonRetryable(e.to_string().into()));
            }
            Err(ref e) => {
                tracing::warn!(attempt, error = %e, "retryable сетевая ошибка");
            }
        }

        if attempt < config.max_retries {
            let jittered_delay = delay_with_jitter(delay);
            tracing::debug!(?jittered_delay, "ожидание перед следующей попыткой");
            tokio::time::sleep(jittered_delay).await;
            delay = delay
                .mul_f64(config.backoff_factor)
                .min(config.max_delay);
        }
    }

    Err(Error::MaxRetriesExceeded {
        attempts: config.max_retries + 1,
    })
}
```

### Вариант с backon crate

```rust
use backon::{ExponentialBuilder, Retryable};

async fn fetch_data(client: &reqwest::Client, url: &str) -> Result<String, reqwest::Error> {
    let response = client.get(url).send().await?.error_for_status()?;
    response.text().await
}

async fn fetch_with_backon(client: &reqwest::Client, url: &str) -> Result<String, reqwest::Error> {
    let backoff = ExponentialBuilder::default()
        .with_min_delay(Duration::from_millis(100))
        .with_max_delay(Duration::from_secs(30))
        .with_max_times(3)
        .with_jitter();

    (|| fetch_data(client, url))
        .retry(backoff)
        .await
}
```

### Формула exponential backoff с jitter

```
delay = min(max_delay, initial_delay * backoff_factor^attempt) * (1 + random(0, 0.5))
```

## What to look for in code review
- `loop` без `break` условия или лимита итераций в retry логике
- Фиксированный `sleep(Duration::from_secs(1))` - нет exponential backoff
- Отсутствие jitter - все клиенты ретраят одновременно
- Retry на 400, 401, 403, 404 - клиентские ошибки не исправятся повтором
- Отсутствие логирования попыток и финального отказа
- `for _ in 0..100` - слишком много попыток, нагрузка на сервер
