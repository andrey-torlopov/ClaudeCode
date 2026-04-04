---
name: skill-audit
description: Аудитирует AI-файлы проекта на раздутость, дублирование и stale references. Используй после изменений COMMON.md, anchor-файлов, agents и skills. Не используй для общего аудита документации — для этого /doc-lint.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /skill-audit

Аудитирует AI-инструкции на токен-стоимость, stale references и нарушения новой модели `COMMON.md -> anchor-files`.

## Когда использовать

- После изменения `COMMON.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
- После редактирования `agents/*.md`, `skills/*/SKILL.md`, `commands/*.md`
- При подозрении на дублирование core rules или process-theater

## Verbosity

- Анализ и таблицы — в отчёт.
- В чат — только краткая сводка и путь к артефакту.

## Проверки

1. **Inventory**
   - Собери scope через Glob.
   - Для каждого файла посчитай строки через `wc -l`.
2. **Size**
   - Сверь размеры с `doc-lint/references/check-rules.md`.
   - Отдельно проверь, что `COMMON.md` и anchor-файлы остаются короткими.
3. **SSOT model**
   - `COMMON.md` хранит core rules, verify-команды и общие conventions.
   - `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` содержат только entry instructions и ссылки.
4. **Stale references**
   - Найди ссылки на `CLAUDE.md` как на SSOT.
   - Найди `gardener`, `Protocol Injection`, `Escalation Protocol` и другие удалённые process-блоки.
   - Проверь битые относительные ссылки.
5. **Duplication**
   - Найди exact или near-duplicate блоки, копирующие `COMMON.md` в anchor-файлы, agents или skills.
   - Найди раздутые шаблоны, длинные decorative blocks и редко используемые inline-секции.
6. **Actions**
   - Для каждого finding дай конкретное действие: `MOVE`, `DELETE`, `SHRINK`, `RELINK`, `KEEP`.

## Severity

| Severity | Что означает |
|----------|--------------|
| `CRITICAL` | broken SSOT, битые ссылки, deleted-protocol references, exact duplicates >5 строк |
| `WARNING` | раздутые файлы, near-duplicates, anchor-файлы с дублированием core rules |
| `INFO` | декоративная многословность и кандидаты на вынос в `references/` |

## Отчёт

Сохрани результат в `audit/skill-audit-report.md`.

Минимальные секции отчёта:

- Inventory
- Findings by severity
- SSOT violations
- Recommended actions

## Завершение

```text
SKILL COMPLETE: /skill-audit
|- Артефакты: audit/skill-audit-report.md
|- Compilation: N/A
|- Findings: {N} CRITICAL, {N} WARNING, {N} INFO
```
