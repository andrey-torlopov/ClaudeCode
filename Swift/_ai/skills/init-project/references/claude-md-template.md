# CLAUDE.md - Anchor template

Используй этот шаблон только как короткий entry-файл. Все core rules должны жить в `COMMON.md`.

```markdown
# [Project Name]

Этот файл — входная точка для Claude-совместимых рантаймов.

## Read Order

1. Прочитай `COMMON.md` как SSOT.
2. Прочитай `_ai/setup_context.md` для карты AI-слоя.
3. Подключай роли, скиллы и паттерны только по необходимости.

## Runtime Notes

- Не копируй сюда build/test, core rules и большие таблицы.
- Для базовой роли используй `_ai/dev_agent.md`.
- Для review используй `_ai/agents/auditor.md`.
```
