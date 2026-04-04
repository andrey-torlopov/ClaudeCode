# COMMON.md - SSOT template

Используй этот шаблон как ядро контекста проекта. Именно он должен хранить общие правила, verify-команды и базовые conventions.

```markdown
# [Project Name] Core Context

`COMMON.md` — единый SSOT для базового контекста проекта.

## Stack

- Project: [Краткое описание]
- Language: Rust
- Platform: [Linux / macOS / cross-platform]
- Package Manager: Cargo
- Runtime: [tokio / async-std / none]
- Main stack: [axum / clap / library / etc.]
- Testing: [std #[test] / criterion / proptest / rstest]

## Verify

- Build: `cargo build`
- Check: `cargo check`
- Test: `cargo test`
- Clippy: `cargo clippy`
- Fmt: `cargo fmt`

## Core Rules

1. Trust No One
2. Minimal Diff
3. Production Ready
4. Read Freely
5. Delete Carefully

## Working Conventions

- Документация и комментарии: [русский / иной язык]
- Не менять архитектуру без прямого запроса
- Паттерны загружать лениво через `_ai/patterns/_index.md`
- Для исследований сначала согласовывать путь к Markdown-результату
```
