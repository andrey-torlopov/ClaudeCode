---
name: doc-lint
description: Аудит качества документации — размер, структура, дубликаты между файлами, нарушения SSOT. Используй для контроля качества human-readable файлов, поиска дублирования и проверки структуры. Не используй для code review или анализа исходного кода.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /doc-lint — Аудит качества документации

Сканирует human-readable файлы проекта, ищет size issues, structural problems, duplicate blocks и нарушения SSOT.

## Когда использовать

- После изменений в `COMMON.md`, anchor-файлах и документации
- Перед разбиением больших `.md` файлов
- При подозрении на stale links и дублирование между документами

## Verbosity

- Таблицы и детальный анализ — только в артефакт.
- В чат — короткая сводка и путь к отчёту.

## Алгоритм

1. Собери inventory по `references/phases.md`.
2. Примени size и structure rules из `references/check-rules.md`.
3. Проверь дублирование и назначь SSOT owner для каждого кластера.
4. Отдельно проверь `COMMON.md` и anchor-файлы:
   - core rules живут в `COMMON.md`,
   - `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` должны оставаться короткими.
5. Найди broken links, stale dates, TODO/FIXME и wall-of-text.
6. Сохрани отчёт в `audit/doc-lint-report.md`.
7. Если есть безопасные исправления, создай `audit/safe-fix.sh`.

## Severity

| Severity | Что означает |
|----------|--------------|
| `CRITICAL` | broken links, exact duplicates, сильное превышение лимитов |
| `WARNING` | near-duplicates, wall-of-text, большие секции, anchor-файлы с копией SSOT |
| `INFO` | TODO, stale dates, formatting noise |

## Quality Gates

- Все файлы в scope найдены и посчитаны через `wc -l`.
- Каждый finding содержит severity, файл и конкретную рекомендацию.
- Для каждого кластера дубликатов назначен SSOT owner.
- Формулы показаны с числителем и знаменателем, если считаются метрики.

## Связанные файлы

- `references/check-rules.md`
- `references/phases.md`

## Завершение

```text
SKILL COMPLETE: /doc-lint
|- Артефакты: audit/doc-lint-report.md, audit/safe-fix.sh
|- Compilation: N/A
```
