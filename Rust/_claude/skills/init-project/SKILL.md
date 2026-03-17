---
name: init-project
description: Генерирует CLAUDE.md для Rust проекта - сканирует репозиторий, анализирует tech stack, создает онбординг-документ. Используй для нового проекта без CLAUDE.md или настройки AI-assisted workflow. Не используй если CLAUDE.md уже настроен - редактируй вручную.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор CLAUDE.md для Rust

<purpose>
Автоматическое создание CLAUDE.md (онбординг AI в проект) на основе анализа Rust репозитория.
</purpose>

## Когда использовать

- Новый Rust проект без CLAUDE.md
- Миграция существующего проекта на AI-assisted workflow
- Стандартизация CLAUDE.md по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

---

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
   - `src/` -> основной код (lib.rs, main.rs, модули)
   - `tests/` -> интеграционные тесты
   - `benches/` -> бенчмарки
   - `examples/` -> примеры использования
   - Workspace members (вложенные crate-ы)

3. **Конфигурации:**
   - `rustfmt.toml` -> rustfmt
   - `clippy.toml` -> Clippy
   - `.cargo/config.toml` -> Cargo aliases, target config
   - `deny.toml` -> cargo-deny

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `Dockerfile` -> Docker

### Обработка ошибок Шага 1

**Cargo.toml не найден** -> Спроси пользователя:

```
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (Library / Binary / Workspace)
- Async runtime: (tokio / async-std / нет)
- Основной фреймворк: (axum / actix-web / clap / нет)
```

**CI/CD-конфиги отсутствуют** -> Пропусти секцию CI в CLAUDE.md, отметь как TODO.

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

### Шаг 3: Генерация CLAUDE.md

Прочитай и используй шаблон из `references/claude-md-template.md`.

Заполни все placeholder-ы `[xxx]` данными из Шагов 1-2.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным зависимостям
- [ ] Commands работают (проверь наличие Cargo.toml)
- [ ] Structure отражает реальные папки
- [ ] Нет placeholder-ов вида `[xxx]` или TODO в финальном файле

## Вывод

Сохрани результат в `CLAUDE.md` в корне проекта.

## Пример диалога

```
User: /init-project

AI: Сканирую проект...

Найдено:
- Cargo.toml -> edition 2021, MSRV 1.75
- Зависимости: tokio, axum, sqlx, serde, tracing
- Async Runtime: tokio
- Web Framework: axum
- Database: sqlx (PostgreSQL)
- Тесты: #[test] + #[tokio::test], 12 тестовых модулей

Генерирую CLAUDE.md...

[Показывает сгенерированный файл]

Сохранить в ./CLAUDE.md? (y/n)
```

## Связанные файлы

- Шаблон: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
