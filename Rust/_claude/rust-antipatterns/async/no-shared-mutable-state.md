# Shared mutable state без синхронизации

## Applies to
- `static mut` переменные
- `lazy_static!` / `once_cell::Lazy` без `Mutex` или `RwLock` для мутабельных данных
- Глобальное состояние, разделяемое между async задачами без синхронизации

## Why this is bad
- `static mut` - unsafe и data race при concurrent доступе (undefined behavior)
- `lazy_static!` с `RefCell` внутри - паника при concurrent borrow
- Без синхронизации данные могут быть прочитаны в inconsistent состоянии
- Компилятор Rust не может гарантировать safety для unsynchronized shared state

## Bad Example

```rust
// static mut - undefined behavior при concurrent доступе
static mut REQUEST_COUNT: u64 = 0;

async fn handle_request() {
    unsafe {
        REQUEST_COUNT += 1; // Data race!
    }
}

// lazy_static без Mutex - нельзя мутировать
use std::collections::HashMap;

lazy_static::lazy_static! {
    static ref CACHE: HashMap<String, String> = HashMap::new();
}

async fn update_cache(key: String, value: String) {
    // Не скомпилируется: CACHE immutable
    // CACHE.insert(key, value);

    // "Решение" через RefCell - паника при concurrent доступе
    // RefCell не Send, не будет работать в async
}

// UnsafeCell без синхронизации
use std::cell::UnsafeCell;

struct SharedState {
    data: UnsafeCell<Vec<String>>,
}

unsafe impl Sync for SharedState {} // Ложная гарантия!
```

## Good Example

```rust
use std::collections::HashMap;
use std::sync::{Arc, OnceLock};
use tokio::sync::{Mutex, RwLock};
use std::sync::atomic::{AtomicU64, Ordering};

// Атомарные счетчики - lock-free
static REQUEST_COUNT: AtomicU64 = AtomicU64::new(0);

async fn handle_request() {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
}

// OnceLock для однократной инициализации (immutable после init)
static CONFIG: OnceLock<AppConfig> = OnceLock::new();

fn init_config(config: AppConfig) {
    CONFIG.set(config).expect("CONFIG уже инициализирован");
}

fn get_config() -> &'static AppConfig {
    CONFIG.get().expect("CONFIG не инициализирован - вызови init_config() в main()")
}

// RwLock для кэша - много читателей, редкие записи
struct Cache {
    data: Arc<RwLock<HashMap<String, String>>>,
}

impl Cache {
    fn new() -> Cache {
        Cache {
            data: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    async fn get(&self, key: &str) -> Option<String> {
        let data = self.data.read().await;
        data.get(key).cloned()
    }

    async fn set(&self, key: String, value: String) {
        let mut data = self.data.write().await;
        data.insert(key, value);
    }
}

// Channels для передачи данных между задачами
use tokio::sync::mpsc;

struct EventProcessor {
    sender: mpsc::Sender<Event>,
}

impl EventProcessor {
    fn new() -> (EventProcessor, mpsc::Receiver<Event>) {
        let (sender, receiver) = mpsc::channel(100);
        (EventProcessor { sender }, receiver)
    }

    async fn emit(&self, event: Event) {
        let _ = self.sender.send(event).await;
    }
}
```

### Выбор примитива синхронизации

| Примитив | Когда использовать |
|----------|-------------------|
| `AtomicU64` / `AtomicBool` | Простые счетчики, флаги |
| `OnceLock` | Однократная инициализация (конфиг, logger) |
| `Arc<Mutex<T>>` | Мутабельный shared state с короткими блокировками |
| `Arc<RwLock<T>>` | Много читателей, редкие записи (кэш) |
| `mpsc::channel` | Передача данных между задачами (producer-consumer) |
| `watch::channel` | Одно значение, много подписчиков (config reload) |
| `DashMap` | Concurrent HashMap без глобального лока |

## What to look for in code review
- `static mut` - всегда красный флаг, заменить на атомики или OnceLock
- `lazy_static!` с мутабельными типами без синхронизации
- `Arc<RefCell<T>>` - RefCell не Sync, не работает в многопоточном коде
- `std::sync::Mutex` в async коде, если lock держится через .await - заменить на `tokio::sync::Mutex`
- Отсутствие `Arc` при шаринге данных между tokio::spawn задачами
