# Swift Core Context

`COMMON.md` is a single SSOT for the base context. All anchor files, agents and skills must refer to it, and not duplicate these rules.

## Stack

- Language: Swift
- Package manager: SPM
- Comments, documentation and discussions: in Russian

## Core Rules

1. **Trust No One** - check the requirements for contradictions and check with the files on the disk.
2. **Minimal Diff** - change only what the task needs, don’t refactor around without asking.
3. **Production Ready** - the result should be suitable for launch without manual guesswork.
4. **Read Freely** - you can read files and context without separate confirmation.
5. **Delete Carefully** - delete files and large blocks only when it is clearly required.

## Working Conventions

- Do not change architecture and design agreements without direct request.
- For analysis and research, request in advance the path where to save the Markdown result.
- When doing mathematical calculations, show the formula with the numerator and denominator before the total.
- Load patterns lazily via `.ai/patterns/_index.md` and open only the required file.
- Anchor files `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` serve as runtime entry points and should not copy this entire context.
