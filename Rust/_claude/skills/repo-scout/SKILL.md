---
name: repo-scout
description: Сканирует Rust репозиторий, каталогизирует структуру проекта, зависимости, архитектуру и тестовое покрытие. Используй при входе в новый репо для понимания кодовой базы. Не используй для code review - для этого /rust-review.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*)"
context: fork
---

# /repo-scout - Разведка Rust-репозитория

<purpose>
Глубокое сканирование Rust репозитория -> структурированный отчет о проекте, зависимостях, архитектуре и текущем покрытии тестами. Дает полную картину проекта перед началом работы.
</purpose>

## Когда использовать

- Первый вход в новый Rust-репозиторий
- Перед `/init-project` - для понимания проекта
- Периодический аудит: "что изменилось в проекте?"
- Онбординг в существующий проект

## Когда НЕ использовать

- Code review (используй `/rust-review`)
- Анализ зависимостей (используй `/dependency-check`)

## Входные данные

- Путь к репозиторию (или текущая директория)
- Не требует CLAUDE.md или других AI-файлов
- Может быть **первым шагом** в новом репо

## Verbosity Protocol

**Structured Output Priority:** Весь analysis идет в артефакт, не в чат.

**Chat output:** Только Summary table + "Отчет: audit/repo-scout-report.md".

**Tools first:** Grep -> table -> report, без "Now I will grep...". Read -> analyze -> report, без "The file shows...".

**Фазы 1-5:** Silent execution. **Фаза 6:** Только Summary + путь к отчету.

---

## Алгоритм

### Фаза 1: Project Structure Scan

**Цель:** Определить тип проекта, билд-систему, структуру директорий.

1. Проверь наличие project-файлов:
   ```
   Cargo.toml, Cargo.lock, build.rs, .cargo/config.toml, rust-toolchain.toml
   ```

2. Извлеки из Cargo.toml:
   - Название пакета (package.name)
   - Edition (2018 / 2021)
   - MSRV (rust-version)
   - Тип: lib / bin / оба
   - Dependencies, dev-dependencies, build-dependencies
   - Features
   - Workspace members (если [workspace])

3. Определи структуру:
   ```
   Glob: src/**/*.rs -> основные модули
   Glob: tests/**/*.rs -> интеграционные тесты
   Glob: benches/**/*.rs -> бенчмарки
   Glob: examples/**/*.rs -> примеры
   Glob: build.rs -> build script
   ```

4. Если workspace - проанализируй workspace members:
   ```
   Glob: */Cargo.toml -> member crates
   ```

5. Подсчитай размер:
   ```
   Количество .rs файлов в src/
   Количество тестовых .rs файлов (tests/ + #[cfg(test)] модули)
   Количество бенчмарков
   ```

### Фаза 2: Dependencies Analysis

**Цель:** Каталогизировать все зависимости из Cargo.

#### 2.1 Production Dependencies

Из Cargo.toml секция `[dependencies]`:
- Список всех crate-ов с версиями
- Классификация по категориям:
  - **async-runtime:** tokio, async-std, smol
  - **serialization:** serde, serde_json, bincode, postcard
  - **web-framework:** axum, actix-web, warp, rocket
  - **database:** sqlx, diesel, sea-orm, rusqlite
  - **CLI:** clap, structopt, argh
  - **testing:** (dev-deps) criterion, proptest, rstest, mockall
  - **logging:** tracing, log, env_logger, slog
  - **error-handling:** thiserror, anyhow, eyre, color-eyre
  - **crypto:** ring, rustls, openssl

#### 2.2 Dev Dependencies

Из Cargo.toml секция `[dev-dependencies]`:
- Тестовые фреймворки и утилиты

#### 2.3 Build Dependencies

Из Cargo.toml секция `[build-dependencies]`:
- Code generation, proc-macro зависимости

**Итого:** общее количество зависимостей с разбивкой.

### Фаза 3: Architecture Discovery

**Цель:** Определить архитектурные паттерны проекта.

Полный справочник паттернов: `references/rust-patterns.md`.

1. **Web Framework:**
   ```
   Grep: use axum -> axum
   Grep: use actix_web -> actix-web
   Grep: use warp -> warp
   Grep: use rocket -> rocket
   ```

2. **Serialization:**
   ```
   Grep: use serde -> serde
   Grep: #\[derive\(.*Serialize.*\)\] -> serde derive
   ```

3. **Async Runtime:**
   ```
   Grep: #\[tokio::main\] -> tokio
   Grep: use async_std -> async-std
   Grep: use smol -> smol
   ```

4. **Database:**
   ```
   Grep: use sqlx -> sqlx
   Grep: use diesel -> diesel
   Grep: use sea_orm -> sea-orm
   Grep: use rusqlite -> rusqlite
   ```

5. **Error Handling:**
   ```
   Grep: use thiserror -> thiserror
   Grep: use anyhow -> anyhow
   Grep: use eyre -> eyre
   ```

6. **Concurrency:**
   ```
   Grep: use tokio -> tokio (async)
   Grep: use rayon -> rayon (data parallelism)
   Grep: use crossbeam -> crossbeam (lock-free)
   Grep: Arc<Mutex -> std mutex
   Grep: use parking_lot -> parking_lot
   ```

7. **CLI:**
   ```
   Grep: use clap -> clap
   Grep: #\[derive\(Parser\)\] -> clap derive
   Grep: use structopt -> structopt
   ```

### Фаза 4: Test Coverage Analysis

**Цель:** Оценить текущее тестовое покрытие.

1. Найди тестовые модули:
   ```
   Grep: #\[cfg\(test\)\] -> inline test modules
   Grep: #\[test\] -> unit tests
   Grep: #\[tokio::test\] -> async tests
   Glob: tests/**/*.rs -> integration tests
   ```

2. Классифицируй:
   - **Unit:** `#[test]` внутри `#[cfg(test)]` модулей в src/
   - **Integration:** файлы в `tests/` директории
   - **Doc tests:** `///` с code blocks в публичных функциях
   - **Benchmarks:** файлы в `benches/`, criterion
   - **Property tests:** `proptest!`, `#[proptest]`

3. Определи тестовые зависимости:
   ```
   Grep в Cargo.toml: criterion -> benchmarks
   Grep в Cargo.toml: proptest -> property tests
   Grep в Cargo.toml: rstest -> parametrized tests
   Grep в Cargo.toml: mockall -> mocking
   Grep в Cargo.toml: wiremock -> HTTP mocking
   ```

### Фаза 5: Infrastructure Scan

**Цель:** Понять инфраструктурный контекст.

1. **CI/CD:**
   ```
   Glob: .github/workflows/*.yml -> GitHub Actions
   Glob: .gitlab-ci.yml -> GitLab CI
   Glob: Jenkinsfile -> Jenkins
   ```

2. **Linting/Formatting:**
   ```
   Glob: clippy.toml -> Clippy configuration
   Glob: rustfmt.toml -> rustfmt configuration
   Glob: .cargo/config.toml -> Cargo configuration
   Glob: deny.toml -> cargo-deny configuration
   Glob: rust-toolchain.toml -> Rust version pinning
   ```

3. **Code Generation:**
   ```
   Glob: build.rs -> build scripts
   Grep: proc_macro -> procedural macros
   Glob: **/src/*_generated.rs -> generated code
   ```

4. **AI Setup:**
   ```
   Glob: CLAUDE.md -> Claude Code
   Glob: .claude/** -> Claude config
   Glob: .cursor/rules/*.mdc -> Cursor IDE
   Glob: .github/copilot-instructions.md -> Copilot
   Glob: AGENTS.md -> Agents
   ```

5. **Containerization:**
   ```
   Glob: Dockerfile -> Docker
   Glob: .dockerignore -> Docker ignore
   Glob: docker-compose*.yml -> Docker Compose
   ```

### Фаза 6: Report Generation

Собери отчет и сохрани в `audit/repo-scout-report.md`. Используй шаблон из `references/report-template.md`.

**Обязательные секции:**
1. Project Profile (name, edition, MSRV, type, dependencies count)
2. Module Structure (crates, source/test files)
3. Dependencies Catalog (production/dev/build с классификацией)
4. Architecture Summary (web framework, serialization, async runtime, database, concurrency)
5. Test Coverage (unit/integration/doc tests/benchmarks/property tests)
6. Infrastructure (CI/CD, linting, AI setup)
7. Readiness Assessment (strengths + areas for improvement + next step)

## Quality Gates

- [ ] Cargo.toml найден и проанализирован
- [ ] Все зависимости каталогизированы
- [ ] Архитектурные паттерны определены
- [ ] Тестовое покрытие оценено
- [ ] Нет placeholder-ов `{xxx}` в финальном отчете
- [ ] Readiness Assessment заполнен

## Self-Check

- [ ] **Completeness:** Все 7 секций заполнены?
- [ ] **Accuracy:** Количества файлов верифицированы?
- [ ] **No Hallucinations:** Каждый найденный паттерн подтвержден Grep-ом?
- [ ] **Readiness:** Оценка обоснована данными?

## Завершение

```
SKILL COMPLETE: /repo-scout
|- Артефакты: audit/repo-scout-report.md
|- Compilation: N/A
|- Upstream: нет
|- Crates: {N} | Rust files: {M} | Tests: {K}
```

## Связанные файлы

- Паттерны Rust: `references/rust-patterns.md`
- Шаблон отчета: `references/report-template.md`
- Следующий шаг: `/init-project` (использует отчет как вход)
