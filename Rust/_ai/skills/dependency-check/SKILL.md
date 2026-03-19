---
name: dependency-check
description: Анализирует Cargo-зависимости Rust-проекта на актуальность, конфликты и здоровье. Используй перед обновлением зависимостей или для аудита текущего состояния. Не используй для анализа кода - для этого /rust-review.
allowed-tools: "Read Write Glob Grep Bash(cargo*) Bash(curl*) Bash(wc*)"
context: fork
---

# /dependency-check - Анализ Cargo-зависимостей

<purpose>
Анализ зависимостей Rust-проекта: версии, конфликты, актуальность, уязвимости. Помогает принять решение об обновлении зависимостей.
</purpose>

## Когда использовать

- Перед обновлением зависимостей
- Периодический аудит "здоровья" зависимостей
- При добавлении новой зависимости (проверка совместимости)
- Оценка tech debt в зависимостях
- Проверка безопасности (cargo audit)

## Когда НЕ использовать

- Анализ кода проекта (используй `/rust-review`)
- Разведка репо (используй `/repo-scout`)

## Входные данные

- Путь к проекту с Cargo.toml (или текущая директория)

---

## Verbosity Protocol

**Tools first:** Анализируй молча. В чат - только сводка + путь к отчету.

---

## Алгоритм

### Шаг 1: Discovery

1. Найди и прочитай `Cargo.toml` (корневой и workspace members, если есть)
2. Найди и прочитай `Cargo.lock` (если есть)
3. Проверь наличие `.cargo/config.toml` (registry, patches, замены)

Если Cargo.toml не найден -> сообщи пользователю и заверши.

### Шаг 2: Dependency Inventory

Для каждой зависимости извлеки:
- Название крейта
- Указанная версия / path / git
- Resolved версия (из Cargo.lock)
- Секция (`[dependencies]`, `[dev-dependencies]`, `[build-dependencies]`)
- Включенные feature flags

Классифицируй по категориям:
- **Async Runtime:** tokio, async-std, smol, etc.
- **Serialization:** serde, serde_json, bincode, toml, etc.
- **Web:** reqwest, hyper, axum, actix-web, warp, etc.
- **Database:** sqlx, diesel, sea-orm, rusqlite, etc.
- **CLI:** clap, structopt, dialoguer, indicatif, etc.
- **Testing:** criterion, proptest, rstest, mockall, etc.
- **Logging:** tracing, log, env_logger, tracing-subscriber, etc.
- **Crypto:** ring, rustls, sha2, aes, etc.
- **Error Handling:** thiserror, anyhow, eyre, miette, etc.
- **Utilities:** rand, chrono, uuid, regex, itertools, etc.

### Шаг 3: Version Analysis

Для каждой зависимости:
1. Определи тип version constraint:
   - Exact (`=1.0.0`) -> жесткая привязка, риск
   - Caret (`^1.0.0` или `1.0.0`) -> стандарт, SemVer-совместимо
   - Tilde (`~1.0.0`) -> минорные обновления
   - Wildcard (`1.*`) -> широкий диапазон
   - Path (`path = "../crate"`) -> локальная зависимость
   - Git (`git = "https://..."`) -> нестабильно

2. Отметь потенциальные проблемы:
   - Git-based зависимости -> WARNING
   - Exact version -> INFO
   - Wildcard -> WARNING
   - Path без workspace -> INFO

### Шаг 4: Security Audit

1. Выполни `cargo audit` (если установлен) для проверки по RustSec Advisory Database
2. Зафиксируй найденные уязвимости:
   - CVE-идентификатор (если есть)
   - Severity (low/medium/high/critical)
   - Затронутый крейт и версия
   - Рекомендуемая версия для исправления

Если cargo-audit не установлен -> отметь в отчете как рекомендацию к установке.

### Шаг 5: Feature Flags Analysis

Для каждой зависимости с явно указанными features:
1. Проверь, что `default-features = false` используется осознанно
2. Найди крейты с избыточными features (включены, но не используются в коде)
3. Найди потенциально полезные features, которые не включены

### Шаг 6: Health Assessment

Для каждой зависимости оцени "здоровье" (без обращения к сети, только на основе данных Cargo.toml/lock):

| Индикатор | Оценка |
|-----------|--------|
| Version constraint type | Strict/Flexible/Unstable |
| Секция использования | Core/Dev/Build |
| Количество transitive dependencies | Low/Medium/High |
| Feature flags | Minimal/Default/Full |

### Шаг 7: Conflict Detection

1. Проверь нет ли дублирования крейтов разных major-версий в Cargo.lock
2. Найди потенциальные конфликты версий (transitive dependencies)
3. Проверь workspace-wide version alignment (если workspace)
4. Проверь `[patch]` и `[replace]` секции на необходимость

### Шаг 8: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/dependency-check-report.md`.

---

## Формат отчета

```markdown
# Dependency Check Report

> Project: {name}
> Package Manager: Cargo
> Зависимостей: {N} (core: {X}, dev: {Y}, build: {Z})
> Дата: {YYYY-MM-DD}

## Summary

| Метрика | Значение |
|---------|----------|
| Всего зависимостей | {N} |
| Core dependencies | {N} |
| Dev dependencies | {N} |
| Build dependencies | {N} |
| Git-based (нестабильные) | {N} |
| Exact version (жесткие) | {N} |
| Уязвимости (cargo audit) | {N} |
| Warnings | {N} |

## Dependencies Inventory

| # | Крейт | Версия | Constraint | Features | Категория | Статус |
|---|-------|--------|-----------|----------|-----------|--------|
| 1 | {name} | {version} | {caret/exact/git/path} | {features} | {Async/Web/...} | {OK/WARNING} |

## Security Audit

| # | Крейт | Версия | Advisory | Severity | Исправление |
|---|-------|--------|---------|----------|-------------|

## Feature Flags

| # | Крейт | Включенные features | default-features | Замечание |
|---|-------|-------------------|-----------------|-----------|

## Warnings

| # | Крейт | Проблема | Рекомендация |
|---|-------|---------|--------------|

## Категории

### Async Runtime ({N})
{список}

### Serialization ({N})
{список}

### Web ({N})
{список}

### Database ({N})
{список}

### CLI ({N})
{список}

### Testing ({N})
{список}

### Logging ({N})
{список}

### Crypto ({N})
{список}

### Error Handling ({N})
{список}

### Utilities ({N})
{список}

## Рекомендации

{Конкретные рекомендации по обновлению/замене зависимостей}
```

---

## Quality Gates

- [ ] Cargo.toml прочитан и распарсен
- [ ] Все зависимости каталогизированы
- [ ] Каждая зависимость классифицирована по категории
- [ ] Feature flags проанализированы
- [ ] cargo audit выполнен (или отмечена необходимость установки)
- [ ] Warnings имеют конкретную рекомендацию
- [ ] Нет placeholder-ов в отчете

## Завершение

```
SKILL COMPLETE: /dependency-check
|- Артефакты: {путь к отчету}
|- Зависимостей: {N} (core: {X}, dev: {Y}, build: {Z})
|- Уязвимостей: {N}
|- Warnings: {N}
```
