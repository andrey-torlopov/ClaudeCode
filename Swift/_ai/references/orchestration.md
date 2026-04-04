# Orchestration Reference

`COMMON.md` — SSOT. `CLAUDE.md`, `AGENTS.md` и `GEMINI.md` — только входные точки рантаймов.

## Routing

| Запрос | Кого использовать | Результат |
|--------|-------------------|-----------|
| Разработка, фиксы, рефакторинг | Self или `agents/sdet.md` | Код и тесты |
| Review, аудит, проверка рисков | `agents/auditor.md` | Findings и отчёт |
| Разведка репозитория | Self + `/repo-scout` | `audit/repo-scout-report.md` |
| Инициализация prompt pack | Self + `/init-project` | `COMMON.md` и anchor-файлы |
| Обновление реестра AI-файлов | Self + `/update-ai-setup` | `docs/ai-setup.md` |

## Guidelines

- Предпочитай прямую работу вместо сложного multi-agent pipeline.
- Передавай только нужный контекст: scope, ограничения и путь к артефакту.
- Если задача требует паттернов, сначала открой `_ai/patterns/_index.md`, а не весь каталог.

## Completion

Используй короткие блоки `SKILL COMPLETE` или `SKILL PARTIAL` с артефактом и статусом проверки.
