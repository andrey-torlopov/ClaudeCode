# Blocking I/O в async runtime

## Applies to
- `std::thread::sleep()` в async функциях
- `std::fs::read()` / `std::fs::write()` в async контексте
- `std::net::TcpStream` вместо `tokio::net::TcpStream`
- Любые synchronous I/O операции внутри async fn

## Why this is bad
- Tokio runtime использует ограниченный пул потоков (по умолчанию = число CPU cores)
- Blocking вызов занимает поток runtime целиком - другие задачи не выполняются
- При достаточном количестве blocking вызовов - deadlock всего runtime
- `std::thread::sleep(Duration::from_secs(1))` блокирует поток, tokio::time::sleep - нет
- `std::fs` выполняет системный вызов synchronously - thread заблокирован до завершения I/O

## Bad Example

```rust
use std::fs;
use std::thread;
use std::time::Duration;

async fn process_file(path: &str) -> Result<String, std::io::Error> {
    // Блокирует async runtime thread
    let content = fs::read_to_string(path)?;

    // Блокирует async runtime thread на 1 секунду
    thread::sleep(Duration::from_secs(1));

    Ok(content.to_uppercase())
}

async fn connect_to_service(addr: &str) -> Result<Vec<u8>, std::io::Error> {
    use std::io::Read;
    use std::net::TcpStream;

    // Blocking TCP connect и read
    let mut stream = TcpStream::connect(addr)?;
    let mut buf = Vec::new();
    stream.read_to_end(&mut buf)?;

    Ok(buf)
}

async fn batch_process(paths: &[String]) -> Vec<String> {
    let mut results = Vec::new();
    for path in paths {
        // Каждая итерация блокирует runtime thread
        let content = fs::read_to_string(path).unwrap_or_default();
        results.push(content);
    }
    results
}
```

## Good Example

```rust
use std::time::Duration;
use tokio::fs;
use tokio::time;

async fn process_file(path: &str) -> Result<String, std::io::Error> {
    // tokio::fs - async file I/O
    let content = fs::read_to_string(path).await?;

    // tokio::time::sleep - не блокирует поток
    time::sleep(Duration::from_secs(1)).await;

    Ok(content.to_uppercase())
}

async fn connect_to_service(addr: &str) -> Result<Vec<u8>, std::io::Error> {
    use tokio::io::AsyncReadExt;
    use tokio::net::TcpStream;

    // Async TCP connect и read
    let mut stream = TcpStream::connect(addr).await?;
    let mut buf = Vec::new();
    stream.read_to_end(&mut buf).await?;

    Ok(buf)
}

// Когда async альтернативы нет - spawn_blocking
async fn compute_hash(data: Vec<u8>) -> String {
    // CPU-intensive работа выносится в blocking thread pool
    tokio::task::spawn_blocking(move || {
        use sha2::{Sha256, Digest};
        let hash = Sha256::digest(&data);
        format!("{:x}", hash)
    })
    .await
    .expect("spawn_blocking не должен паниковать")
}

// Batch с concurrency через async
async fn batch_process(paths: &[String]) -> Vec<String> {
    let mut handles = Vec::new();
    for path in paths {
        let path = path.clone();
        handles.push(tokio::spawn(async move {
            fs::read_to_string(&path).await.unwrap_or_default()
        }));
    }

    let mut results = Vec::new();
    for handle in handles {
        results.push(handle.await.unwrap_or_default());
    }
    results
}
```

### Таблица замен

| Blocking (std) | Async (tokio) | Назначение |
|---------------|--------------|-----------|
| `std::thread::sleep` | `tokio::time::sleep` | Пауза |
| `std::fs::read` | `tokio::fs::read` | Чтение файла |
| `std::fs::write` | `tokio::fs::write` | Запись файла |
| `std::net::TcpStream` | `tokio::net::TcpStream` | TCP соединение |
| `std::net::UdpSocket` | `tokio::net::UdpSocket` | UDP сокет |
| CPU-intensive код | `tokio::task::spawn_blocking` | Вычисления |
| `std::sync::Mutex` | `tokio::sync::Mutex` | Mutex в async (если lock держится через .await) |

## What to look for in code review
- `std::thread::sleep` в async fn - заменить на `tokio::time::sleep`
- `std::fs::` вызовы внутри async fn - заменить на `tokio::fs::`
- `std::net::` вместо `tokio::net::` в async контексте
- `std::sync::Mutex` в async коде, если lock держится через .await point
- Отсутствие `spawn_blocking` для CPU-intensive операций (хеширование, сжатие, парсинг)
- `reqwest::blocking::` в async контексте - паника в tokio runtime
