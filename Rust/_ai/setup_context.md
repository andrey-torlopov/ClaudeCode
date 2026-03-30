# Project context
- Язык: Rust, Markdown
- Пакетный менеджер: Cargo
- Комментарии и рассуждения пишем на русском языке

## AI-сетап
- Базовый промт и оркестратор: `_ai/dev_agent.md`.
- Роли агентов: `_ai/agents/`.
- Скиллы и команды: `_ai/skills/`, `_ai/commands/`; пост-хуки: `_ai/hooks/`.
- Паттерны и протоколы: `_ai/patterns/`, `_ai/protocols/`.

# Build & Run
- Сборка: `cargo build`
- Тесты: `cargo test`
- Проверка без сборки: `cargo check`
- Форматирование: `cargo fmt`
- Линтер: `cargo clippy`

## Project Structure
```
.
├── CLAUDE.md
└── <Project>
    ├── <Files>
```
