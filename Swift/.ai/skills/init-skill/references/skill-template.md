# SKILL.md - Tool skill template

> **Purpose:** Instructions for a typical task. You need to do a review - get the code review instructions. It is necessary to analyze the dependencies - take another tool.

## ⚠️ Size limit: ≤500 lines

**SKILL.md should not exceed 500 lines.** If more, split into:
- `references/*.md` - examples, tables, checklists
- `scripts/*.py` - executable code

---

## Sample

```markdown
---
description: [Verb] + [what] + [context]. Max 100 characters.
---

# /[skill-name] - [Name]

<purpose>
[1-2 sentences: what it does and for whom]
</purpose>

## When to use
- [Trigger 1]
- [Trigger 2]

## Input data
- [What is needed from the user]

## Algorithm

### Step 1: [Title]
[Specific Actions]

### Step 2: [Title]
[Specific Actions]

### Step N: [Title]
[Specific Actions]

## Output format

```[language]
[Result template]
```

## Quality Gates

- [ ] [Check 1]
- [ ] [Check 2]

## Linked files (optional)

- `scripts/[name]` - [destination]
- `references/[name]` - [destination]
```

---

## Progressive Disclosure

```
┌─────────────────────────────────────────────────────────┐
│ Level 1: YAML header │
│ → Always in the system prompt (< 100 characters) │
├─────────────────────────────────────────────────────────┤
│ Level 2: Body SKILL.md │
│ → Loaded when skill is activated │
├─────────────────────────────────────────────────────────┤
│ Level 3: scripts/ and references/ │
│ → Loaded upon explicit request │
└─────────────────────────────────────────────────────────┘
```

---

## Skill directory structure

```
.ai/skills/{skill-name}/
├── SKILL.md # Levels 1-2: header + instruction (≤500 lines)
├── scripts/ # Level 3: executable code (optional)
│   ├── generate.py
│   └── validate.sh
└── references/ # Level 3: documentation (optional)
    ├── checklist.md
    └── examples.json
```

### Real example: swift-review

```
.ai/skills/swift-review/
├── SKILL.md # ~250 lines - core logic
└── references/
    ├── swift-checklist.md # Complete checklist of checks
    └── concurrency-rules.md # Swift Concurrency Rules
```

---

## Examples description

**Fine:**
```yaml
description: Analyzes Swift code for retain cycles, data races and conventions violations
description: Scans the iOS repository and catalogs the structure, dependencies, architecture
description: Checks SPM dependencies for relevance and conflicts
```

**Badly:**
```yaml
description: This skill is designed for... # too long
description: Helps with testing # too abstract
description: API tests # no verb
```

---

## Skill categories

| Category | Examples | Typical output |
|-----------|---------|----------------|
| **Analysis** | /swift-review, /repo-scout | Report with findings |
| **Generation** | /init-project, /refactor-plan | Code or document |
| **Validation** | /dependency-check, /skill-audit | Pass/Fail + details |
| **Transformation** | /doc-lint | Format conversion |

---

