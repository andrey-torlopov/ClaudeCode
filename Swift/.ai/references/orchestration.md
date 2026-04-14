# Orchestration Reference

`COMMON.md` - SSOT. `CLAUDE.md`, `AGENTS.md` and `GEMINI.md` are only runtime entry points.

## Routing

| Request | Who to use | Result |
|--------|-------------------|-----------|
| Development, fixes, refactoring | Self or `agents/sdet.md` | Code and tests |
| Review, audit, risk check | `agents/auditor.md` | Findings and report |
| Repository Intelligence | Self + `/repo-scout` | `audit/repo-scout-report.md` ​​|
| Initializing prompt pack | Self + `/init-project` | `COMMON.md` ​​and anchor files |
| AI file registry update | Self + `/update-ai-setup` | `docs/ai-setup.md` ​​|

## Guidelines

- Prefer direct work instead of a complex multi-agent pipeline.
- Pass only the necessary context: scope, restrictions and path to the artifact.
- If the task requires patterns, open `.ai/patterns/_index.md` first, not the entire directory.

## Completion

Use short blocks `SKILL COMPLETE` or `SKILL PARTIAL` ​​with artifact and verification status.
