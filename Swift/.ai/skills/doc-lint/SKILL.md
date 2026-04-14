---
name: doc-lint
description: Documentation quality audit - size, structure, duplicates between files, SSOT violations. Use it to control the quality of human-readable files, search for duplication and check the structure. Do not use for code review or source code analysis.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /doc-lint — Documentation quality audit

Scans human-readable project files, looking for size issues, structural problems, duplicate blocks and SSOT violations.

## When to use

- After changes in `COMMON.md`, anchor files and documentation
- Before splitting large `.md` files
- If you suspect stale links and duplication between documents

## Verbosity

- Tables and detailed analysis - only in the artifact.
- To chat - a short summary and the path to the report.

## Algorithm

1. Collect inventory for `references/phases.md`.
2. Apply size and structure rules from `references/check-rules.md`.
3. Check duplication and assign an SSOT owner for each cluster.
4. Check `COMMON.md` and anchor files separately:
   - core rules live in `COMMON.md`,
   - `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` must remain short.
5. Find broken links, stale dates, TODO/FIXME and wall-of-text.
6. Save the report in `audit/doc-lint-report.md`.
7. If there are safe patches, create `audit/safe-fix.sh`.

## Severity

| Severity | What does |
|----------|--------------|
| `CRITICAL` | broken links, exact duplicates, severely exceeding limits |
| `WARNING` | near-duplicates, wall-of-text, large sections, anchor files with SSOT copy |
| `INFO` | TODO, stale dates, formatting noise |

## Quality Gates

- All files in scope are found and counted through `wc -l`.
- Each finding contains severity, file and specific recommendation.
- An SSOT owner is assigned to each duplicate cluster.
- Formulas are shown with a numerator and a denominator if metrics are considered.

## Related files

- `references/check-rules.md`
- `references/phases.md`

## Completion

```text
SKILL COMPLETE: /doc-lint
|- Artifacts: audit/doc-lint-report.md, audit/safe-fix.sh
|- Compilation: N/A
```
