# Project Context

- SSOT: `COMMON.md`
- Entry points: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
- Язык: Rust
- Пакетный менеджер: Cargo
- Комментарии и документация: на русском языке

## Verify

- Build: `cargo build`
- Check: `cargo check`
- Test: `cargo test`
- Clippy: `cargo clippy`
- Fmt: `cargo fmt`

## AI Layers

- `_ai/dev_agent.md` — базовая роль и лёгкая маршрутизация.
- `_ai/agents/` — компактные role cards.
- `_ai/skills/` — специализированные сценарии.
- `_ai/commands/` — короткие command-prompts.
- `_ai/patterns/_index.md` — lazy-load каталог паттернов.
- `_ai/hooks/skill-lint.sh` — быстрая валидация AI-файлов.
