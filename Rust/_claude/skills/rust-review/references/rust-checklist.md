# Rust Code Review Checklist

## Ownership & Safety

| # | Проверка | Severity | Grep-паттерн |
|---|---------|----------|-------------|
| O-1 | `.unwrap()` в production коде (не тестах) | CRITICAL | `\.unwrap\(\)` в src/ |
| O-2 | `unsafe` блок без `// SAFETY:` комментария | CRITICAL | `unsafe \{` без предшествующего SAFETY |
| O-3 | `mem::transmute` использование | BLOCKER | `mem::transmute` |
| O-4 | `mem::forget` без обоснования | CRITICAL | `mem::forget` |
| O-5 | `as *const` / `as *mut` raw pointer creation | WARNING | `as \*const\|as \*mut` |
| O-6 | `Rc<RefCell<T>>` без Weak для разрыва циклов | CRITICAL | `Rc<RefCell` |
| O-7 | `.clone()` в hot path без обоснования | WARNING | `\.clone\(\)` |
| O-8 | `'static` lifetime без необходимости | INFO | `'static` |

### Правила

- `unsafe` блоки: всегда комментарий `// SAFETY:` перед блоком с объяснением инварианта
- `.unwrap()` допустим: в тестах, в `build.rs`, после проверки `.is_some()`/`.is_ok()`
- `.expect("reason")` предпочтительнее `.unwrap()` - дает контекст при панике
- `Rc` - только для single-threaded графов; для multi-threaded - `Arc`
- `.clone()` допустим: для cheaply-clonable типов (Arc, &str -> String при необходимости ownership)

## Concurrency

Полные правила: `concurrency-rules.md`

| # | Проверка | Severity |
|---|---------|----------|
| C-1 | `static mut` использование | BLOCKER |
| C-2 | Blocking I/O в async контексте (`std::fs`, `std::net`, `std::thread::sleep` в async fn) | CRITICAL |
| C-3 | `std::sync::Mutex` в async контексте (нужен `tokio::sync::Mutex`) | CRITICAL |
| C-4 | `unsafe impl Send` / `unsafe impl Sync` без обоснования | CRITICAL |
| C-5 | Потенциальный deadlock (вложенные lock) | BLOCKER |
| C-6 | `tokio::spawn` россыпь вместо structured concurrency (JoinSet) | WARNING |
| C-7 | `Arc<Mutex<T>>` где достаточно channels (message passing) | INFO |
| C-8 | Mutex poisoning не обрабатывается | WARNING |

## Error Handling

| # | Проверка | Severity |
|---|---------|----------|
| E-1 | `panic!()` / `todo!()` в library коде | BLOCKER |
| E-2 | `.unwrap()` / `.expect()` в production (не тестах) | CRITICAL |
| E-3 | Пустой `Err(_) =>` в match | CRITICAL |
| E-4 | `.ok()` с потерей ошибки без логирования | WARNING |
| E-5 | `Box<dyn Error>` вместо typed error (thiserror) в library | WARNING |
| E-6 | `#[must_use]` отсутствует на Result-возвращающих публичных функциях | INFO |

## Rust Conventions

| # | Проверка | Severity |
|---|---------|----------|
| R-1 | `let mut` где достаточно `let` | WARNING |
| R-2 | Naming не по Rust conventions (snake_case fn, CamelCase types) | WARNING |
| R-3 | `pub` где достаточно `pub(crate)` | INFO |
| R-4 | Отсутствие `#[derive(Debug)]` на публичных типах | INFO |
| R-5 | Boolean без is_/has_/should_ префикса | INFO |
| R-6 | Explicit `return` в конце функции (вместо expression) | INFO |
| R-7 | `to_string()` где `into()` достаточно | INFO |
| R-8 | `String` в параметрах где достаточно `&str` | WARNING |

## Performance

| # | Проверка | Severity |
|---|---------|----------|
| P-1 | `.clone()` в цикле / hot path | WARNING |
| P-2 | `String` аллокации где достаточно `&str` | INFO |
| P-3 | `Vec` вместо `HashSet` для contains/поиска | INFO |
| P-4 | `.collect::<Vec<_>>()` промежуточный (можно iterator chain) | INFO |
| P-5 | `Box<dyn Trait>` где достаточно `impl Trait` (static dispatch) | INFO |

## Architecture

| # | Проверка | Severity |
|---|---------|----------|
| A-1 | Файл > 500 строк | WARNING |
| A-2 | impl блок > 300 строк | WARNING |
| A-3 | Функция > 50 строк | INFO |
| A-4 | Жесткая зависимость вместо trait | INFO |
| A-5 | `pub` API без doc-comments | WARNING |
| A-6 | Модуль без `mod.rs` / `lib.rs` документации | INFO |

## Testing

| # | Проверка | Severity |
|---|---------|----------|
| T-1 | `assert!` / `assert_eq!` без сообщения | WARNING |
| T-2 | `#[test]` функция > 50 строк | INFO |
| T-3 | `std::thread::sleep` в тестах вместо tokio::time | WARNING |
| T-4 | Hardcoded test data без генерации | WARNING |
| T-5 | Нет `#[cfg(test)]` модуля в файле с бизнес-логикой | INFO |
