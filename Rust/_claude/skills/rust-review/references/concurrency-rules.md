# Rust Concurrency Rules

## Send + Sync Traits

### Что это

| Trait | Значение | Auto-implement |
|-------|----------|----------------|
| `Send` | Тип можно передавать между потоками (move ownership) | Да, если все поля Send |
| `Sync` | На тип можно ссылаться из нескольких потоков (&T: Send) | Да, если все поля Sync |

### Типы НЕ реализующие Send/Sync

| Тип | Send | Sync | Почему |
|-----|:----:|:----:|--------|
| `Rc<T>` | нет | нет | Reference count без атомарности |
| `Cell<T>` | да | нет | Interior mutability без синхронизации |
| `RefCell<T>` | да | нет | Runtime borrow checking не потокобезопасно |
| `*const T`, `*mut T` | нет | нет | Raw pointers |
| `MutexGuard<T>` | да | да | Но нельзя передать между потоками на некоторых ОС |

### unsafe impl Send/Sync

Допустимо ТОЛЬКО с комментарием-обоснованием:
```rust
// SAFETY: внутреннее состояние защищено через std::sync::Mutex,
// все методы синхронизированы, нет data races
unsafe impl Send for MyType {}
unsafe impl Sync for MyType {}
```

Без комментария - CRITICAL.

## Async Runtime (tokio)

### tokio::spawn vs spawn_blocking

| Ситуация | Правильно | Неправильно |
|----------|-----------|-------------|
| Async I/O (network, tokio::fs) | `tokio::spawn(async { ... })` | `std::thread::spawn` |
| CPU-bound вычисления | `tokio::task::spawn_blocking(\|\| { ... })` | `tokio::spawn` (блокирует worker) |
| Sync I/O (std::fs, database) | `tokio::task::spawn_blocking` | Прямой вызов в async fn |
| Параллельные async задачи | `tokio::join!` / `JoinSet` | Массив `tokio::spawn` без join |

### Structured concurrency

| Ситуация | Правильно | Неправильно |
|----------|-----------|-------------|
| 2-3 параллельных запроса | `tokio::join!(a, b, c)` | `tokio::spawn` + `tokio::spawn` |
| N параллельных задач | `JoinSet` | `Vec<JoinHandle>` + ручной join |
| Последовательные шаги | `let a = step1().await; step2(a).await;` | Callback chain |
| Таймаут | `tokio::time::timeout(dur, fut)` | `tokio::select!` с sleep |

### tokio::select! правила

```rust
// Правильно: все ветки владеют данными или используют &mut
tokio::select! {
    result = async_operation() => handle(result),
    _ = tokio::time::sleep(timeout) => handle_timeout(),
}

// Неправильно: shared mutable state между ветками
// select! может отменить одну из веток - данные могут быть в inconsistent state
```

### Mutex в async

| Ситуация | Правильно | Неправильно |
|----------|-----------|-------------|
| Lock удерживается через .await | `tokio::sync::Mutex` | `std::sync::Mutex` (блокирует worker) |
| Lock кратковременный (без .await) | `std::sync::Mutex` (быстрее) | `tokio::sync::Mutex` (overhead) |
| Read-heavy workload | `tokio::sync::RwLock` | `tokio::sync::Mutex` |

## Shared State Patterns

### Arc<Mutex<T>> - базовый паттерн

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

let state = Arc::new(Mutex::new(AppState::default()));

// Клонируем Arc для каждого потока
let state_clone = state.clone();
tokio::spawn(async move {
    let mut guard = state_clone.lock().await;
    guard.counter += 1;
});
```

### Channels - message passing (предпочтительнее)

| Тип | Когда |
|-----|-------|
| `tokio::sync::mpsc` | Много producer -> один consumer |
| `tokio::sync::oneshot` | Один запрос - один ответ |
| `tokio::sync::broadcast` | Один producer -> много consumer |
| `tokio::sync::watch` | Последнее значение для всех подписчиков |

```rust
// Предпочтительнее Arc<Mutex<T>> когда можно
let (tx, mut rx) = tokio::sync::mpsc::channel(32);

tokio::spawn(async move {
    tx.send(Event::UserCreated { id: 42 }).await.ok();
});

while let Some(event) = rx.recv().await {
    handle_event(event);
}
```

### Concurrent collections

- `dashmap::DashMap` - concurrent HashMap (вместо `Arc<Mutex<HashMap>>`)
- `crossbeam::queue::SegQueue` - lock-free queue

## Deadlock Prevention

### Lock ordering

```rust
// Неправильно: deadlock potential
// Thread 1: lock(a) -> lock(b)
// Thread 2: lock(b) -> lock(a)

// Правильно: всегда одинаковый порядок
// Thread 1: lock(a) -> lock(b)
// Thread 2: lock(a) -> lock(b)
```

### Try-lock patterns

```rust
// Если deadlock возможен - используй try_lock
match mutex.try_lock() {
    Ok(guard) => { /* работаем с данными */ },
    Err(_) => { /* mutex занят, обработай */ },
}
```

## Blocking in Async

### Запрещено в async fn

| Операция | Проблема | Замена |
|----------|----------|--------|
| `std::thread::sleep()` | Блокирует tokio worker | `tokio::time::sleep()` |
| `std::fs::read()` | Блокирует tokio worker | `tokio::fs::read()` |
| `std::net::TcpStream` | Блокирует tokio worker | `tokio::net::TcpStream` |
| CPU-heavy вычисления | Блокирует tokio worker | `spawn_blocking` |
| Sync database driver | Блокирует tokio worker | `spawn_blocking` или async driver (sqlx) |

### Паттерн spawn_blocking

```rust
// CPU-bound работа в async контексте
let result = tokio::task::spawn_blocking(move || {
    // sync/CPU-heavy код здесь
    compute_heavy_stuff(data)
}).await?;
```
