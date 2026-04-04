# Swift Agents Entry

Этот файл — входная точка для agent runtimes, которые автоматически ищут `AGENTS.md`.

## Read Order

1. `COMMON.md` — SSOT для правил и общих ограничений.
2. `_ai/setup_context.md` — карта рантайма и доступных слоёв.
3. `_ai/dev_agent.md` — базовая роль и лёгкая маршрутизация.

## Available Layers

- `_ai/agents/sdet.md` — компактная роль для реализации кода и тестов.
- `_ai/agents/auditor.md` — компактная роль для review и аудита.
- `_ai/skills/*/SKILL.md` — специализированные сценарии.
- `_ai/patterns/_index.md` — lazy-load каталог паттернов.

Не дублируй правила из `COMMON.md` в этом файле.
