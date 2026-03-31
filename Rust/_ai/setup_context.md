# Project context
- Язык: Rust, Markdown
- Пакетный менеджер: Cargo
- Комментарии и рассуждения пишем на русском языке

## AI-сетап
- Базовый промт и оркестратор: `.ai/dev_agent.md`.
- Роли агентов: `.ai/agents/`.
- Скиллы и команды: `.ai/skills/`, `.ai/commands/`; пост-хуки: `.ai/hooks/`.
- Паттерны и протоколы: `.ai/patterns/`, `.ai/protocols/`.

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
