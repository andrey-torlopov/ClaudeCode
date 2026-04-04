---
name: init-project
description: Генерирует стартовый prompt pack для Rust проекта: COMMON.md, anchor-файлы и минимальный AI-контекст. Используй для нового проекта или миграции на облегчённый AI workflow. Не используй если core context уже настроен и требуется только точечная правка.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор COMMON.md и anchor-файлов

Создаёт компактный prompt pack на основе структуры Rust репозитория.

## Когда использовать

- Новый Rust проект без `COMMON.md`
- Миграция существующего проекта на AI-assisted workflow
- Стандартизация prompt pack по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

## Алгоритм выполнения

### Шаг 1: Сканирование проекта

Найди и проанализируй:

1. **Project files:**
   - `Cargo.toml` -> edition, dependencies, features, workspace
   - `Cargo.lock` -> зафиксированные версии
   - `build.rs` -> build scripts
   - `.cargo/config.toml` -> Cargo configuration
   - `rust-toolchain.toml` -> pinned Rust version

2. **Структуру исходников:**
   - `src/` -> основной код
   - `tests/` -> интеграционные тесты
   - `benches/` -> бенчмарки
   - `examples/` -> примеры
   - workspace members

3. **Конфигурации:**
   - `rustfmt.toml` -> rustfmt
   - `clippy.toml` -> Clippy
   - `deny.toml` -> cargo-deny

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `Dockerfile` -> Docker

### Обработка ошибок Шага 1

**Cargo.toml не найден** -> Спроси пользователя:

```text
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (Library / Binary / Workspace)
- Async runtime: (tokio / async-std / нет)
- Основной фреймворк: (axum / actix-web / clap / нет)
```

**CI/CD-конфиги отсутствуют** -> Не выдумывай секцию CI. Оставь только подтверждённые данные.

### Шаг 2: Определение Tech Stack

На основе зависимостей и кода определи:

| Категория | Что искать |
|-----------|------------|
| Async Runtime | tokio / async-std / smol / none |
| Serialization | serde / manual |
| Web Framework | axum / actix-web / warp / rocket / none |
| Database | sqlx / diesel / sea-orm / rusqlite / none |
| CLI | clap / structopt / argh / none |
| Error Handling | thiserror+anyhow / eyre / custom |
| Logging | tracing / log+env_logger / slog |
| Testing | std #[test] / criterion / proptest / rstest |
| Linting | clippy / rustfmt |

### Шаг 3: Генерация core context

Прочитай и используй шаблон из `references/common-md-template.md`.

Сгенерируй:

- `COMMON.md` как SSOT
- `CLAUDE.md` как Claude anchor
- `AGENTS.md` как generic agent anchor
- `GEMINI.md` как Gemini anchor

Для `CLAUDE.md` используй `references/claude-md-template.md`.
`AGENTS.md` и `GEMINI.md` делай в том же стиле: короткий read-order и ссылка на `COMMON.md`.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным зависимостям
- [ ] Commands работают (проверь наличие Cargo.toml)
- [ ] `COMMON.md` остаётся компактным и без дублирующих таблиц
- [ ] Anchor-файлы не копируют core rules
- [ ] Нет placeholder-ов вида `[xxx]` в финальных файлах

## Вывод

Сохрани результат в корень проекта:

- `COMMON.md`
- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`

## Связанные файлы

- Шаблон SSOT: `references/common-md-template.md`
- Шаблон Claude anchor: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
