# YAML Frontmatter Reference

## Required fields

### name
- **Format:** kebab-case
- **Restrictions:**
  - Only lowercase letters, numbers, hyphens
  - Must match the name of the skill folder
  - Without the prefixes "claude", "anthropic"
  - Unique within the project
- **Examples:**
  - ✅ `test-cases`, `api-tests`, `screenshot-analyze`
  - ❌ `TestPlan`, `api_tests`, `claude-helper`

### description
- **Format:** `[What it does]. [When to use]. [When NOT to use]`
- **Restrictions:**
  - Maximum 1024 characters
  - Without XML tags (<>, &lt;, &gt;)
  - No line breaks (one-line)
  - Use trigger phrases from examples of use
- **Structure:**
  1. What does it do (1-2 sentences)
  2. When to use (specific scenarios)
  3. When NOT to use (anti-use-cases)
- **Examples:**
  - ✅ `Generates test cases from an API specification. Use after /spec-audit to cover endpoints with tests. Do not use for UI testing.`
  - ❌ `A useful tool for testing` (too general)

## Optional fields

### allowed-tools
- **Format:** String with space separated list
- **Examples:**
  - `"Read Write Edit Glob Grep"`
  - `"Read Write Bash(wc*) Bash(git*)"`
- **Wildcards:** Bash commands can be limited to a pattern: `Bash(ls*)` only allows `ls`

### agent
- **Format:** Path to the agent file relative to `.ai/`
- **Example:** `agents/sdet.md`, `agents/auditor.md`

### context
- **Options:**
  - `fork` - isolated context (Process Isolation)
  - `inherit` — inherited context (default)

## Examples of ready-made YAML

### Analysis Skill
```yaml
---
name: swift-review
description: Deep code review of Swift code with a focus on memory safety, concurrency and Swift conventions. Use it for module reviews and PR. Do not use for dependency analysis.
allowed-tools: "Read Write Edit Glob Grep"
context: fork
---
```

### Generation Skill
```yaml
---
name: init-project
description: Generates COMMON.md and anchor files for an iOS/Swift project based on repository analysis. Use for a new project without a prompt pack. Do not use if the core context is already configured.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---
```

### Validation Skill
```yaml
---
name: dependency-check
description: Analyzes project SPM dependencies for relevance and conflicts. Use before updating dependencies. Do not use for code analysis.
allowed-tools: "Read Glob Grep Bash(swift*)"
context: fork
---
```

## Validation

After writing YAML, check:
- [ ] `name` = skill directory name
- [ ] `description` contains all 3 parts (what/when/not when)
- [ ] `description` < 1024 characters
- [ ] No XML characters in `description`
- [ ] YAML is syntactically correct (triple-dash start and end)
