---
name: skill-audit
description: Audits project AI files for bloat, duplication, and stale references. Use after changes to COMMON.md, anchor files, agents and skills. Don't use /doc-lint for general documentation auditing.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /skill-audit

Audits AI instructions for token value, stale references and violations of the new `COMMON.md -> anchor-files` model.

## When to use

- After changing `COMMON.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
- After editing `agents/*.md`, `skills/*/SKILL.md`, `commands/*.md`
- If you suspect duplication of core rules or process-theater

## Verbosity

- Analysis and tables - in the report.
- In the chat - only a brief summary and the path to the artifact.

## Checks

1. **Inventory**
   - Collect scope via Glob.
   - For each file, count the lines through `wc -l`.
2. **Size**
   - Check the dimensions with `doc-lint/references/check-rules.md`.
   - Separately, check that `COMMON.md` and anchor files remain short.
3. **SSOT model**
   - `COMMON.md` stores core rules, build/test and general conventions.
   - `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` contain only entry instructions and links.
4. **Stale references**
   - Find references to `CLAUDE.md` as SSOT.
   - Find `gardener`, `Protocol Injection`, `Escalation Protocol` and other remote process blocks.
   - Check for broken relative links.
5. **Duplication**
   - Find exact or near-duplicate blocks that copy `COMMON.md` into anchor files, agents or skills.
   - Find bloated templates, long decorative blocks and rarely used inline sections.
6. **Actions**
   - For each finding, give a specific action: `MOVE`, `DELETE`, `SHRINK`, `RELINK`, `KEEP`.

## Severity

| Severity | What does |
|----------|--------------|
| `CRITICAL` | broken SSOT, broken links, deleted-protocol references, exact duplicates >5 lines |
| `WARNING` | bloated files, near-duplicates, duplicated anchor files core rules |
| `INFO` | decorative verbosity and takeaway candidates in `references/` ​​|

## Report

Save the result in `audit/skill-audit-report.md`.

Minimum report sections:

- Inventory
- Findings by severity
- SSOT violations
- Recommended actions

## Completion

```text
SKILL COMPLETE: /skill-audit
|- Artifacts: audit/skill-audit-report.md
|- Compilation: N/A
|- Findings: {N} CRITICAL, {N} WARNING, {N} INFO
```
