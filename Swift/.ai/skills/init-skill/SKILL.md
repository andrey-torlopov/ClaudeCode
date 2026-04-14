---
name: init-skill
description: Generates new skills with interactive workflow, checkpoints and iterative refinement. Use it when you need to create a new skill or automate routine checks. Do not use existing skills to edit.
allowed-tools: "Read Write Edit Glob Grep Bash"
context: fork
---

# /init-skill — Generator of new Skills

<purpose>
Interactive creation of a new skill with step-by-step workflow, checkpoints and revision cycle.
</purpose>

## When to use

- Create a new tool for a recurring task
- Standardization of the process in the team
- Automation of routine checks

---

## Progressive Disclosure principle

YAML header (always in the prompt) → SKILL.md body (upon activation) → scripts/references (upon request).

Full diagram: `references/skill-template.md` → "Progressive Disclosure" section.

## Writing style

Use **imperative/infinitive style** in skill statements:

| Correct | Wrong |
|-----------|-------------|
| Generate test cases | You must generate test cases |
| Check input data | The input data should be checked |
| Read the specification | Need to read the specification |

---

## Verbosity Protocol

**Structured Output Priority:** All analysis goes to the artifact (MD/HTML), not to the chat.

**Chat output (limitations):**
- Brief Summary: max 5 lines (what was found, how much, total)
- Findings table: max 15 lines (top by severity)
- Full report: `📊 Full report: {path}` + open file

**Iterative steps:** Do not display progress for each file. Checkpoint only when:
- Phase transition (Phase N → Phase N+1)
- Blocker detected
- Completion (SKILL COMPLETE)

**Tools first:**
- Grep → table → report, without "Now I will grep..."
- Read → analyze → report, without "The file shows..."

**Post-Check:** Inline before SKILL COMPLETE (5-7 lines checklist), not a separate file.

---

# INTERACTIVE WORKFLOW

## Phase 1: Determine Destination

### Step 1.1: Ask for an appointment

```
What should the new skill do?

Examples:
- Analyze [what] into [what to look for]
- Generate [what] for [context]
- Check [artifact] for compliance with [standard]
- Refactor [what] according to [rules]
```

### Step 1.2: Define a Category

Categories: **Analysis** (report), **Generation** (code/document), **Validation** (pass/fail), **Transformation** (conversion).

Full table with examples: `references/skill-template.md` → section “Skill categories”.

### Step 1.3: Collect specific use cases

Ask the user to provide **2-3 specific examples**:

```
Before designing a skill, I need concrete examples:

1. **Trigger phrases** - what will the user say to trigger the skill?
   Example: “analyze dependencies”, “do a code review of the module”

2. **Use cases** - describe 2-3 real-life use cases:
   - What are the input data?
   - What is the expected result?
   - What is the context (project, stage, team)?

3. **Anti-examples** - when should a skill NOT be used?
```

**Why:** Specific examples define the scope of a skill more accurately than an abstract description. Trigger phrases will help you write an accurate YAML description.

### ✅ CHECKPOINT 1: Confirm appointment

```
I understood the problem like this:
- Purpose: [what does it do]
- Category: [Analysis/Generation/Validation/Transformation]
- Name: /[skill-name]

Examples of use:
1. [use case 1]
2. [use case 2]

Trigger phrases: "[phrase 1]", "[phrase 2]"

Is everything right? (yes/no, I’ll clarify)
```

**⚠️ DO NOT CONTINUE without user confirmation!**

---

## Phase 2: Structure Design

### Step 2.1: Propose a category-based structure

Suggestions vary by skill category (Analysis/Generation/Validation/Transformation).

A complete list of questions for each category is in `references/interaction-guide.md` → section "Structural sentences by category"

### Step 2.2: Define the file structure

```
.ai/skills/{skill-name}/
├── SKILL.md # Required (case-sensitive!)
├── scripts/ # Executable - automation and utilities
│   └── [name].py/.sh
├── references/ # Loaded into context - reference books, checklists
│   └── [name].md/.json
└── assets/ # Used in output, NOT loaded - templates, icons
    └── [name].md/.png
```

**Critical rules:**
- Folder: kebab-case only (`my-skill` ✅, `My_Skill` ​​❌)
- File: exactly `SKILL.md` (case-sensitive, not `skill.md`)
- **DO NOT create README.md inside the skill folder** - all documentation is in SKILL.md or references/

### ✅ CHECKPOINT 2: Structure confirmation

```
Skill structure:
- Main file: SKILL.md
- Scripts: [yes/no] - [purpose]
- References: [yes/no] - [purpose]
- Assets: [yes/no] - [purpose]

Additional features:
- [list of selected options]

Shall we continue? (yes / change)
```

**⚠️ DO NOT CONTINUE without user confirmation!**

---

## Phase 3: Creating the YAML header

Read `references/yaml-reference.md` for a complete reference on fields, restrictions and examples.

### Step 3.1: Generate name and description

**Key Rules:**
- `name`: kebab-case, same as folder name, without "claude"/"anthropic"
- `description`: formula `[What it does]. [When to use]`, < 1024 characters, no XML tags

**Use trigger phrases from Checkpoint 1** to formulate “When to use.”

### ✅ CHECKPOINT 3: YAML frontmatter confirmation

```
YAML Frontmatter (will be visible in the system prompt):

---
name: [skill-name]
description: [your option]
---

Are you satisfied? (yes / suggest your option)
```

**⚠️ DO NOT CONTINUE without user confirmation!**

---

## Phase 4: Preparing resources (scripts, references, assets)

Create the resources selected in Checkpoint 2:
- **scripts/** - executable utilities (Python/Bash)
- **references/** — reference books loaded into the context
- **assets/** - templates for output (NOT loaded into the context)

**✅ CHECKPOINT 4:** Confirm the list of created files before going to SKILL.md

---

## Phase 5: Writing the body SKILL.md

### Step 5.1: Generate complete SKILL.md

Read and use the template from `references/skill-template.md` → "Template" section.

**Style:** imperative (see "Writing style" above).

When writing instructions **refer to the real resources** prepared in Phase 4:
- `Read references/checklist.md` — and not the abstract “use a checklist”
- `Run scripts/validate.sh` - not “validate”

### ✅ CHECKPOINT 5: Review SKILL.md

Show the full SKILL.md and offer editing options (see `references/interaction-guide.md` → "Editing options").

**⚠️ BE SURE to show the file and wait for the selection!**

---

## Phase 6: Iterative refinement

The rework cycle is described in `references/interaction-guide.md` → "Rework cycle"

---

## Phase 7: Saving and Validation

### ✅ CHECKPOINT 6: Final confirmation

```
Ready to save:

.ai/skills/[skill-name]/
├── SKILL.md ✅
├── scripts/[name].* ✅ (if any)
├── references/[name].* ✅ (if available)
└── assets/[name].* ✅ (if any)

Save? (yes / back to edit)
```

**⚠️ DO NOT SAVE without user confirmation!**

### Step 7.1: Save the files

Create a directory and all files.

**Hint:** Use `scripts/init_skill.sh` to generate a template structure:
```bash
bash .ai/skills/init-skill/scripts/init_skill.sh [skill-name]
```

### Step 7.2: Validation and Completion

- Go through `references/validation-checklist.md`
- If SKILL.md > 500 lines, suggest splitting
- Show the result: path to skill, call command
- Suggest a cycle of improvements after first use (see `references/interaction-guide.md`)

---

## Related files

- Init script: `.ai/skills/init-skill/scripts/init_skill.sh`
- Template: `references/skill-template.md`
- Examples: `.ai/skills/*/SKILL.md`
