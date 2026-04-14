---
name: update-ai-setup
description: Scans the AI ​​project files and updates the docs/ai-setup.md registry with the latest data. Use after adding or removing core/anchor/skill files and when migrating an AI setup. Do not use for code analysis or documentation outside the AI ​​layer.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*) Bash(ls*)"
context: fork
---

# /update-ai-setup - Update the AI ​​configuration registry

Synchronizes `docs/ai-setup.md` with the real state of the project's AI files.

## When to use

- After changing `COMMON.md`, anchor files, agents, skills, commands, hooks or pattern index
- After adding or removing AI files
- Before manual audit of an AI setup

## Verbosity

- Inventory and delta details are included in the document.
- In the chat - only a short summary and the path to the file.

## Algorithm

1. Read `docs/ai-setup.md`, and if the file is not there, create a new minimal registry.
2. Scan and count lines through `wc -l` for:
   - `COMMON.md`
   - `CLAUDE.md`
   - `AGENTS.md`
   - `GEMINI.md`
   - `.ai/setup_context.md`
   - `.ai/dev_agent.md`
   - `.ai/agents/*.md`
   - `.ai/skills/*/SKILL.md`
   - `.ai/commands/*.md`
   - `.ai/patterns/_index.md`
   - `.ai/hooks/skill-lint.sh`
   - `docs/ai-setup.md`
3. Optionally check `.mcp.json`, `.cursor/`, `.github/copilot-instructions.md`, if they exist.
4. Compare the found files with the current registry and collect the delta:
   - `ADD`
   - `REMOVE`
   - `UPDATE_LINES`
   - `RENAME_OWNER`
5. Update `docs/ai-setup.md`:
   - core layer with `COMMON.md`
   - anchor layer with `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
   - runtime layer, skills, commands, patterns and hooks
6. Add a changelog entry with the current date.

## Quality Gates

- All paths from the registry exist on disk.
- Row counters are the same as `wc -l`.
- `COMMON.md` is marked as SSOT.
- Anchor files are listed separately from SSOT.
- There are no placeholders in the final document.

## Completion

```text
SKILL COMPLETE: /update-ai-setup
|- Artifacts: docs/ai-setup.md
|- Delta: [+N / -N / ~N]
|- Quality Gates: PASS
```
