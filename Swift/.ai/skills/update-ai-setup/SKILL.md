---
name: update-ai-setup
description: Сканирует AI-файлы проекта и обновляет реестр docs/ai-setup.md с актуальными данными. Используй после добавления или удаления core/anchor/skill файлов и при миграции AI-сетапа. Не используй для анализа кода или документации вне AI-слоя.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*) Bash(ls*)"
context: fork
---

# /update-ai-setup — Обновление реестра AI-конфигурации

Синхронизирует `docs/ai-setup.md` с реальным состоянием AI-файлов проекта.

## Когда использовать

- После изменения `COMMON.md`, anchor-файлов, agents, skills, commands, hooks или pattern index
- После добавления или удаления AI-файлов
- Перед ручным аудитом AI-сетапа

## Verbosity

- Детали инвентаризации и дельты — в документ.
- В чат — только краткий итог и путь к файлу.

## Алгоритм

1. Прочитай `docs/ai-setup.md`, а если файла нет — создай новый минимальный реестр.
2. Просканируй и посчитай строки через `wc -l` для:
   - `COMMON.md`
   - `CLAUDE.md`
   - `AGENTS.md`
   - `GEMINI.md`
   - `.ai/setup_context.md`
   - `.ai/dev_agent.md`
   - `.ai/agents/*.md`
   - `.ai/skills/*/SKILL.md`
   - `.ai/commands/*.md`
   - `.ai/patterns/_index.md`
   - `.ai/hooks/skill-lint.sh`
   - `docs/ai-setup.md`
3. Опционально проверь `.mcp.json`, `.cursor/`, `.github/copilot-instructions.md`, если они есть.
4. Сравни найденные файлы с текущим реестром и собери дельту:
   - `ADD`
   - `REMOVE`
   - `UPDATE_LINES`
   - `RENAME_OWNER`
5. Обнови `docs/ai-setup.md`:
   - core layer с `COMMON.md`
   - anchor layer с `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
   - runtime layer, skills, commands, patterns и hooks
6. Добавь changelog entry с текущей датой.

## Quality Gates

- Все пути из реестра существуют на диске.
- Счётчики строк совпадают с `wc -l`.
- `COMMON.md` отмечен как SSOT.
- Anchor-файлы перечислены отдельно от SSOT.
- Нет placeholder-ов в финальном документе.

## Завершение

```text
SKILL COMPLETE: /update-ai-setup
|- Артефакты: docs/ai-setup.md
|- Дельта: [+N / -N / ~N]
|- Quality Gates: PASS
```
