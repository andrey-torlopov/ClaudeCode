# Swift Agents Entry

Этот файл — входная точка для agent runtimes, которые автоматически ищут `AGENTS.md`.

## Read Order

1. `COMMON.md` — SSOT для правил и общих ограничений.
2. `.ai/setup_context.md` — карта рантайма и доступных слоёв.
3. `.ai/dev_agent.md` — базовая роль и лёгкая маршрутизация.

## Available Layers

- `.ai/agents/sdet.md` — компактная роль для реализации кода и тестов.
- `.ai/agents/auditor.md` — компактная роль для review и аудита.
- `.ai/skills/*/SKILL.md` — специализированные сценарии.
- `.ai/patterns/_index.md` — lazy-load каталог паттернов.

Не дублируй правила из `COMMON.md` в этом файле.
