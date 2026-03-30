# Project context
- Язык: Swift, Markdown
- Пакетный менеджер: SPM
- Комментарии и рассуждения пишем на русском языке

## AI-сетап
- Базовый промт и оркестратор: `_ai/dev_agent.md`.
- Роли агентов: `_ai/agents/`.
- Скиллы и команды: `_ai/skills/`, `_ai/commands/`; пост-хуки: `_ai/hooks/`.
- Паттерны и протоколы: `_ai/patterns/`, `_ai/protocols/`.

# Build & Run
- Сборка: `swift build`
- Тесты: `swift test`
- Линтер: рассмотреть SwiftLint (пока не настроен). Паттерны в `_ai/patterns/` покрывают то, что линтер не проверяет.

## Project Structure
```
.
├── CLAUDE.md
└── <Project>
    ├── <Files>
```
