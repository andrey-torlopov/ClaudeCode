# Swift Agents Entry

This file is the entry point for agent runtimes, which automatically look for `AGENTS.md`.

## Read Order

1. `COMMON.md` - SSOT for rules and general restrictions.
2. `.ai/setup_context.md` - map of runtime and available layers.
3. `.ai/dev_agent.md` - basic role and easy routing.

## Available Layers

- `.ai/agents/sdet.md` is a compact role for implementing code and tests.
- `.ai/agents/auditor.md` - compact role for review and audit.
- `.ai/skills/*/SKILL.md` - specialized scripts.
- `.ai/patterns/_index.md` — lazy-load pattern directory.

Do not duplicate the rules from `COMMON.md` in this file.
