# CLAUDE.md - Шаблон для Rust проекта

> **Назначение:** Wiki проекта для AI. Первый день нового сотрудника - какой стек, где что лежит, как собирать.

---

## Шаблон

```markdown
# [Project Name]

## Context
- **Project:** [Что разрабатываем - описание библиотеки/сервиса/утилиты]
- **Language:** Rust
- **Platform:** [Linux / macOS / cross-platform]
- **MSRV:** [1.75 / 1.80 / nightly / не указан]

## Tech Stack

| Категория | Технология |
|-----------|------------|
| Async Runtime | [tokio / async-std / smol / нет] |
| Serialization | [serde / manual / нет] |
| Web Framework | [axum / actix-web / warp / rocket / нет] |
| Database | [sqlx / diesel / sea-orm / rusqlite / нет] |
| CLI | [clap / structopt / argh / нет] |
| Error Handling | [thiserror+anyhow / eyre / custom] |
| Logging | [tracing / log+env_logger / slog] |
| Testing | [std #[test] / criterion / proptest / rstest] |
| Package Manager | Cargo |
| Linting | [clippy / rustfmt / cargo-deny] |

## Project Structure

```text
[Реальная структура проекта]
```

## Build & Run

| Действие | Команда |
|----------|---------|
| Build | `cargo build` |
| Test | `cargo test` |
| Lint | `cargo clippy -- -D warnings` |
| Format check | `cargo fmt --check` |
| Run | `cargo run` |

## Rust Conventions

- Используй `let` вместо `let mut` где возможно
- Предпочитай `&T` вместо `.clone()` где возможно
- Используй `Result<T, E>` с `?` operator для обработки ошибок
- Добавляй `#[derive(Debug, Clone, PartialEq)]` для публичных типов
- `thiserror` для ошибок библиотеки, `anyhow` для ошибок приложения
- Типы между потоками: `Send + Sync`
- `unsafe` только с `// SAFETY:` комментарием
- Clippy warnings как руководство к действию
- Предпочитай итераторы вместо циклов с индексами
- Используй `impl Trait` в аргументах для обобщенных функций
- Предпочитай `&str` над `&String` в параметрах
- Документируй публичный API с `///` doc-комментариями

## Naming

- Функции, переменные, модули: `snake_case`
- Типы, трейты, enum-ы: `CamelCase`
- Константы: `SCREAMING_SNAKE_CASE`
- Lifetime-ы: короткие (`'a`, `'b`), описательные для сложных случаев (`'conn`)
- Crate names: `kebab-case` в Cargo.toml, `snake_case` в use

## Safety Protocols

FORBIDDEN: `git reset --hard`, `git clean -fd`, удаление веток
MANDATORY: Backup перед деструктивными операциями
```

---

## Расположение файла

```
project-root/
└── CLAUDE.md    # В корне проекта
```
