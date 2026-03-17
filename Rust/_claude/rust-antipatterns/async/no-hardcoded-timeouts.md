# Magic numbers в таймаутах

## Applies to
- `Duration::from_secs(30)` захардкоженные в production коде
- Разные таймауты для CI и локальной разработки без возможности конфигурации
- Числовые литералы без объяснения выбора значения

## Why this is bad
- Magic number `30` не объясняет "почему 30, а не 10 или 60?"
- В CI таймауты часто нужны больше (медленные runners), локально - меньше
- Изменение таймаута требует поиска по всему коду и перекомпиляции
- Разные среды (dev, staging, production) могут требовать разных значений
- Flaky тесты из-за таймаутов, подобранных под конкретную машину

## Bad Example

```rust
use std::time::Duration;

async fn fetch_with_retry(client: &reqwest::Client, url: &str) -> Result<String, Error> {
    let response = tokio::time::timeout(
        Duration::from_secs(30), // Почему 30?
        client.get(url).send(),
    )
    .await??;

    response.text().await.map_err(Error::from)
}

async fn wait_for_service(addr: &str) -> Result<(), Error> {
    for _ in 0..10 { // Почему 10 попыток?
        if check_health(addr).await.is_ok() {
            return Ok(());
        }
        tokio::time::sleep(Duration::from_millis(500)).await; // Почему 500ms?
    }
    Err(Error::ServiceUnavailable)
}

#[tokio::test]
async fn test_slow_operation() {
    let result = tokio::time::timeout(
        Duration::from_secs(5), // Падает в CI, работает локально
        slow_operation(),
    )
    .await;

    assert!(result.is_ok());
}
```

## Good Example

```rust
use std::time::Duration;

/// Конфигурация таймаутов приложения
struct TimeoutConfig {
    /// Таймаут HTTP запроса
    http_request: Duration,
    /// Таймаут ожидания сервиса при старте
    service_ready: Duration,
    /// Интервал между проверками health check
    health_check_interval: Duration,
    /// Максимальное количество попыток health check
    health_check_max_retries: u32,
}

impl TimeoutConfig {
    fn from_env() -> TimeoutConfig {
        TimeoutConfig {
            http_request: Duration::from_secs(
                env_or_default("HTTP_TIMEOUT_SECS", 30),
            ),
            service_ready: Duration::from_secs(
                env_or_default("SERVICE_READY_TIMEOUT_SECS", 60),
            ),
            health_check_interval: Duration::from_millis(
                env_or_default("HEALTH_CHECK_INTERVAL_MS", 500),
            ),
            health_check_max_retries: env_or_default("HEALTH_CHECK_MAX_RETRIES", 10),
        }
    }
}

fn env_or_default(key: &str, default: u64) -> u64 {
    std::env::var(key)
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(default)
}

async fn fetch_with_retry(
    client: &reqwest::Client,
    url: &str,
    config: &TimeoutConfig,
) -> Result<String, Error> {
    let response = tokio::time::timeout(
        config.http_request,
        client.get(url).send(),
    )
    .await??;

    response.text().await.map_err(Error::from)
}

async fn wait_for_service(addr: &str, config: &TimeoutConfig) -> Result<(), Error> {
    for attempt in 0..config.health_check_max_retries {
        if check_health(addr).await.is_ok() {
            return Ok(());
        }
        tracing::debug!(attempt, "сервис не готов, повтор");
        tokio::time::sleep(config.health_check_interval).await;
    }
    Err(Error::ServiceUnavailable)
}

// Тесты: увеличенные таймауты для CI
#[cfg(test)]
mod tests {
    use super::*;

    fn test_timeout() -> Duration {
        // CI=true увеличивает таймаут в 3 раза
        let base = Duration::from_secs(5);
        if std::env::var("CI").is_ok() {
            base * 3
        } else {
            base
        }
    }

    #[tokio::test]
    async fn test_slow_operation() {
        let result = tokio::time::timeout(
            test_timeout(),
            slow_operation(),
        )
        .await;

        assert!(result.is_ok(), "операция должна завершиться в отведенное время");
    }
}
```

## What to look for in code review
- `Duration::from_secs(N)` / `Duration::from_millis(N)` inline без именованной константы
- Разные числовые значения для одного и того же таймаута в разных местах
- Таймауты в тестах без учета CI environment
- Отсутствие конфигурации через env vars или config файл
- `0..10` magic number в retry циклах
