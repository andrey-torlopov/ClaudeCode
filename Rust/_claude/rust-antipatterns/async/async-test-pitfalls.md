# tokio::spawn в sync #[test]

## Applies to
- Использование `tokio::spawn` или `.await` в sync `#[test]` функциях
- Создание `tokio::runtime::Runtime` вручную в каждом тесте
- `block_on()` вместо `#[tokio::test]`

## Why this is bad
- `#[test]` без async runtime не может выполнить async код - паника при вызове .await
- Ручное создание `Runtime` - boilerplate, который легко сделать неправильно
- `Runtime::new()` в каждом тесте - создание нового thread pool на каждый тест
- `block_on()` внутри async context - deadlock

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // Ошибка: .await в sync тесте - не компилируется
    #[test]
    fn test_fetch_data() {
        let client = reqwest::Client::new();
        let data = client.get("https://example.com").send().await; // Ошибка компиляции
    }

    // Работает, но плохо: ручное создание Runtime
    #[test]
    fn test_with_manual_runtime() {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            let result = fetch_data().await;
            assert!(result.is_ok());
        });
    }

    // Работает, но плохо: current_thread runtime не совместим с tokio::spawn
    #[test]
    fn test_with_current_thread() {
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async {
            let handle = tokio::spawn(async {
                process_data().await
            });
            let result = handle.await.unwrap();
            assert!(result.is_ok());
        });
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // #[tokio::test] автоматически создает runtime
    #[tokio::test]
    async fn test_fetch_data() {
        let client = reqwest::Client::new();
        let result = fetch_data(&client).await;
        assert!(result.is_ok(), "данные должны быть получены");
    }

    // Для тестов с tokio::spawn - multi_thread flavor
    #[tokio::test(flavor = "multi_thread", worker_threads = 2)]
    async fn test_concurrent_processing() {
        let handle = tokio::spawn(async {
            process_data().await
        });
        let result = handle.await.unwrap();
        assert!(result.is_ok());
    }

    // current_thread - по умолчанию в #[tokio::test], достаточно для большинства тестов
    #[tokio::test]
    async fn test_sequential_operations() {
        let a = step_one().await;
        let b = step_two(a).await;
        assert_eq!(b.status, "completed");
    }

    // Контроль времени в тестах
    #[tokio::test]
    async fn test_with_timeout() {
        let result = tokio::time::timeout(
            std::time::Duration::from_secs(5),
            long_running_operation(),
        )
        .await;

        assert!(result.is_ok(), "операция должна завершиться за 5 секунд");
    }
}
```

### Выбор test runtime

| Атрибут | Когда использовать |
|---------|-------------------|
| `#[tokio::test]` | По умолчанию (current_thread) |
| `#[tokio::test(flavor = "multi_thread")]` | Тесты с tokio::spawn |
| `#[tokio::test(start_paused = true)]` | Тесты с таймерами (tokio::time::sleep) |

## What to look for in code review
- `Runtime::new()` или `Builder::new()` в тестах - используй `#[tokio::test]`
- `.block_on()` в тестовом коде - признак ручного runtime
- `#[test]` для async функций - не скомпилируется
- `tokio::spawn` в тесте с `#[tokio::test]` (current_thread) - может зависнуть без `yield`
- Отсутствие таймаута в async тестах - тест может висеть вечно
