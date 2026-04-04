---
name: swift-review
description: Глубокий code review Swift-кода с фокусом на memory safety, concurrency, Swift conventions и архитектуру. Используй для ревью модулей, PR или отдельных файлов. Не используй для анализа зависимостей - для этого /dependency-check.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /swift-review — Swift Code Review (light)

## Назначение

- Глубокий review Swift-кода: memory safety, concurrency, conventions, error handling, архитектура.
- Результат — отчёт с BLOCKER / CRITICAL / WARNING / INFO.

## Вход

- **Scope (обязательно):** файл / директория / модуль.
- **Focus (опционально):** `memory` / `concurrency` / `architecture` / `all` (по умолчанию).

## Verbosity & Loop Safety

- SILENT MODE: анализ идёт в отчёт, в чат — только короткая сводка + путь к файлу.
- Tools first: Read/Grep → анализ → отчёт, без описания шагов.
- Не перезапускай `/swift-review` из отчёта и не предлагай автоповтор; один запуск = один отчёт.

## Алгоритм (кратко)

1. Определи scope (файл / директория `.swift` без тестов / `Sources/{module}`), прочитай `COMMON.md`, посчитай строки.
2. **Memory Safety:** используй `references/swift-checklist.md` (retain cycles, force unwrap, `Type!`, unowned).
3. **Concurrency:** используй `references/concurrency-rules.md` (Sendable, `@MainActor`, data races, Task/actors).
4. **Conventions & Errors:** let/var, guard, value types, naming, Any/AnyObject, throws/try?/empty catch/Result.
5. **Architecture:** размер и ответственность файлов, слойность, SwiftUI-поля состояния.

## Severity & Отчёт

- BLOCKER / CRITICAL / WARNING / INFO — по критериям из чек-листов.
- Отчёт сохраняй в `audit/swift-review-report.md` (или путь пользователя) в табличном виде с файлами, строками и рекомендациями.

## Завершение

- Выведи финальный блок: `SKILL COMPLETE: /swift-review` + scope, количество findings и путь к отчёту.
