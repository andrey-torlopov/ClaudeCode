# Swift Project

Этот файл — входная точка для Claude-совместимых рантаймов.

## Read Order

1. Прочитай `COMMON.md` — это SSOT для правил и базового контекста.
2. Прочитай `.ai/setup_context.md` — там карта `.ai/` слоя.
3. Подключай `.ai/dev_agent.md`, `.ai/agents/*.md`, `.ai/skills/*/SKILL.md` и `.ai/patterns/_index.md` только по необходимости.

## Runtime Notes

- Не копируй core rules в этот файл: они живут в `COMMON.md`.
- Для повседневной разработки используй `.ai/dev_agent.md`.
- Для review и аудита используй `.ai/agents/auditor.md`.
