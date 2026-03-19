---
name: rust-review
description: Глубокий code review Rust-кода с фокусом на ownership, unsafe, concurrency, error handling и Rust conventions. Используй для ревью модулей, PR или отдельных файлов. Не используй для анализа зависимостей - для этого /dependency-check.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /rust-review - Глубокий Rust Code Review

<purpose>
Структурированный code review Rust-кода по чек-листу: ownership & safety, concurrency, conventions, error handling, performance, architecture. Результат - отчет с приоритизированными findings.
</purpose>

## Когда использовать

- Ревью модуля/файла перед мержем
- Аудит качества кода после рефакторинга
- Поиск потенциальных проблем в существующем коде
- Глубокий анализ конкретного аспекта (concurrency, ownership)

## Когда НЕ использовать

- Быстрый review diff (используй команду `/short_review`)
- Анализ зависимостей (используй `/dependency-check`)
- Разведка нового репо (используй `/repo-scout`)

## Входные данные

| Параметр | Обязательность | Описание |
|----------|:--------------:|----------|
| Scope | Обязательно | Путь к файлу, модулю или директории |
| Focus | Опционально | Конкретный аспект: ownership, concurrency, architecture, all |

По умолчанию Focus = all.

---

## Verbosity Protocol

**SILENT MODE:** Весь analysis идет в артефакт, не в чат.

**В чат:** Только финальная сводка + путь к отчету.

**Tools first:** Read -> analyze -> report, без промежуточных комментариев.

---

## Алгоритм

### Шаг 1: Scope Discovery

1. Определи файлы для ревью:
   - Если указан файл -> один файл
   - Если указана директория -> все .rs файлы в ней (без tests/)
   - Если указан модуль -> src/{module}/**/*.rs

2. Прочитай CLAUDE.md (если есть) для понимания конвенций проекта.

3. Подсчитай объем: `wc -l` для каждого файла.

### Шаг 2: Ownership & Safety Review

Прочитай `references/rust-checklist.md` секция "Ownership & Safety".

Для каждого файла проверь:
- **unsafe блоки:** наличие `// SAFETY:` комментария-обоснования
- **unwrap/expect:** `.unwrap()` в production (не тестах)
- **Raw pointers:** `*const T` / `*mut T` использование
- **mem::transmute / mem::forget:** опасные операции с памятью
- **Rc/Arc циклы:** `Rc<RefCell<T>>` без Weak для разрыва
- **Clone в hot path:** избыточные `.clone()` вместо borrowing
- **Lifetime annotations:** корректность и необходимость

### Шаг 3: Concurrency Review

Прочитай `references/concurrency-rules.md`.

Для каждого файла проверь:
- **Send+Sync:** типы, передаваемые между потоками, реализуют Send+Sync?
- **Blocking in async:** `std::thread::sleep`, `std::fs`, `std::net` в async fn
- **Mutex в async:** `std::sync::Mutex` в async контексте (нужен `tokio::sync::Mutex`)
- **Deadlocks:** вложенные lock(), порядок захвата мьютексов
- **static mut:** использование без unsafe
- **unsafe impl Send/Sync:** обоснованность
- **Structured concurrency:** `tokio::spawn` россыпь вместо `JoinSet`

### Шаг 4: Rust Conventions Review

Для каждого файла проверь:
- **let vs let mut:** mut где можно обойтись без
- **Early return:** вложенные if let вместо let-else
- **Naming:** snake_case для fn/variables, CamelCase для types/traits
- **Visibility:** `pub` где достаточно `pub(crate)`
- **Derive macros:** отсутствие Debug, Clone, PartialEq на публичных типах
- **Clippy warnings:** код вызывающий clippy warnings
- **Return expression:** explicit `return` в конце функции

### Шаг 5: Error Handling Review

Для каждого файла проверь:
- **Result vs Option:** Option для ошибочных состояний вместо Result
- **Пустой Err(_):** match/if let на Result с игнорированием ошибки
- **.ok() без логирования:** потеря информации об ошибке
- **Error types:** `Box<dyn Error>` вместо typed error (thiserror)
- **? operator:** корректность chaining
- **panic!/unreachable!:** использование в production (не тестах)

### Шаг 6: Architecture Review

Для каждого файла проверь:
- **Responsibility:** файл/модуль делает слишком много (>300 строк impl - повод задуматься)
- **Dependencies:** жесткие зависимости вместо traits
- **Module design:** pub(crate) boundaries, re-exports
- **Trait design:** object safety, суперtraits, blanket implementations

### Шаг 7: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/rust-review-report.md`.

---

## Severity Model

| Severity | Критерии |
|----------|----------|
| **BLOCKER** | Panic в production: unwrap, static mut, data race, UB в unsafe |
| **CRITICAL** | Баг при определенных условиях: deadlock potential, blocking in async, missing error handling |
| **WARNING** | Нарушение конвенций, потенциальный tech debt |
| **INFO** | Стилистика, мелкие улучшения |

---

## Формат отчета

```markdown
# Rust Review Report

> Scope: {path}
> Файлов: {N} | Строк: {M}
> Дата: {YYYY-MM-DD}

## Summary

| Severity | Количество |
|----------|:----------:|
| BLOCKER | {N} |
| CRITICAL | {N} |
| WARNING | {N} |
| INFO | {N} |

## Findings

### BLOCKER

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### CRITICAL

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### WARNING

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### INFO

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|
```

---

## Quality Gates

- [ ] Все файлы в scope прочитаны
- [ ] Каждый finding имеет severity + файл:строка + рекомендацию
- [ ] Нет false positives (контекст проверен)
- [ ] BLOCKER/CRITICAL findings имеют конкретный пример кода

## Завершение

```
SKILL COMPLETE: /rust-review
|- Артефакты: {путь к отчету}
|- Scope: {N} файлов, {M} строк
|- Findings: {B} BLOCKER, {C} CRITICAL, {W} WARNING, {I} INFO
```

## Связанные файлы

- Чек-лист: `references/rust-checklist.md`
- Concurrency: `references/concurrency-rules.md`
