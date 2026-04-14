# Documentation review phases

## Phase 1: Inventory

1. Collect human-readable files: `*.md`, `*.yaml`, `*.yml`, `*.txt`.
2. Exclude `node_modules/`, `.git/`, `build/`, `dist/`, `vendor/`, `audit/`, binary files and lock files.
3. For each file, count the lines through `wc -l` and classify them according to `check-rules.md`.

Example inventory line:

```markdown
| 1 | COMMON.md | 30 | COMMON.md | OK |
```

## Phase 2: Size & Structure

1. Apply thresholds from `check-rules.md`.
2. Check the heading hierarchy, empty sections, wall-of-text and oversized sections.
3. For `COMMON.md` and anchor files, check separately that they do not swell.

## Phase 3: Duplicate Detection

1. Extract tables, code blocks, lists and large paragraphs.
2. Use known signatures from `check-rules.md`.
3. After match, compare only related files, not the entire project in pairs.
4. For each cluster, assign an SSOT owner.

## Phase 4: Content Hygiene

Check:

- broken relative links
- empty links
- `TODO` / `FIXME` / `HACK`
- stale dates
- mixed doc types

## Phase 5: Report & Safe Fixes

1. Save findings in `audit/doc-lint-report.md`.
2. If there are safe edits, generate `audit/safe-fix.sh`.
3. Add only safe operations to the script: placeholder TOC, creating placeholders for missing docs, deleting trailing spaces.
