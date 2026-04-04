# Rust Project

Этот файл — входная точка для Claude-совместимых рантаймов.

## Read Order

1. Прочитай `COMMON.md` — это SSOT для правил и базового контекста.
2. Прочитай `_ai/setup_context.md` — там карта `_ai/` слоя.
3. Подключай `_ai/dev_agent.md`, `_ai/agents/*.md`, `_ai/skills/*/SKILL.md` и `_ai/patterns/_index.md` только по необходимости.

## Runtime Notes

- Не копируй core rules в этот файл: они живут в `COMMON.md`.
- Для повседневной разработки используй `_ai/dev_agent.md`.
- Для review и аудита используй `_ai/agents/auditor.md`.
