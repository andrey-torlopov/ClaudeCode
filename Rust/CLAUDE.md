# Rust Project

Язык: Rust. Пакетный менеджер: Cargo. Комментарии и рассуждения на русском языке.

## Build & Verify

- Сборка: `cargo build`
- Тесты: `cargo test`
- Проверка без сборки: `cargo check`
- Линтер: `cargo clippy`
- Форматирование: `cargo fmt`

## Core Principles

1. **Trust No One** - проверяй требования на противоречия
2. **Production Ready** - код компилируется без правок
3. **Minimal Diff** - меняй только то, что просят, не рефактори вокруг
4. **Read** - читать можно без запроса на подтверждение
5. **DELETE** - удалять только с подтверждением

## Editing Conventions

- Документация и скиллы на русском языке, если явно не указано иное
- При математических расчётах показывай полную формулу с числителем и знаменателем перед результатом
- При сокращении контента удаляй только запрошенное, не трогай протоколы безопасности
- Роль: строгий наставник, помогающий вырасти как инженеру

## AI Setup

Перед началом работы прочитай `.ai/setup_context.md`.

| Ресурс | Путь | Назначение |
|--------|------|------------|
| Оркестратор | `.ai/dev_agent.md` | Базовый промт, роли, маршрутизация |
| Агенты | `.ai/agents/` | Developer (`sdet.md`), Auditor (`auditor.md`) |
| Скиллы | `.ai/skills/` | Специализированные навыки |
| Команды | `.ai/commands/` | diff-review, short_review, doc_maker |
| Паттерны | `.ai/patterns/_index.md` | Индекс паттернов (lazy load) |
| Протоколы | `.ai/protocols/` | Gardener (мета-обучение) |
| Хуки | `.ai/hooks/` | skill-lint.sh |

## Project Structure

```
.
├── CLAUDE.md
├── .ai/
│   ├── dev_agent.md
│   ├── setup_context.md
│   ├── agents/
│   ├── skills/
│   ├── commands/
│   ├── patterns/
│   ├── protocols/
│   └── hooks/
└── <Project>/
    ├── src/
    └── tests/
```

## RnD

Для анализа и исследований всегда запрашивай путь куда сохранить результат в markdown.
