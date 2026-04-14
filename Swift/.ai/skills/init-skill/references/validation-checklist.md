# New Skill validation checklist

## Structure

- [ ] The file name is exactly `SKILL.md` (case-sensitive)
- [ ] Folder in kebab-case, matches the `name` field
- [ ] No README.md inside skill folder
- [ ] **SKILL.md ≤ 500 lines** (if more, split into references/)

## YAML Frontmatter

- [ ] The `name` field is also present in kebab-case
- [ ] Field `name` does NOT contain "claude" or "anthropic"
- [ ] YAML description < 1024 characters
- [ ] Description contains **What** + **When**
- [ ] Description without XML tags (`<`, `>`)

## Content

- [ ] There is a section "When to use"
- [ ] Steps are numbered and specific
- [ ] Style is imperative (without “you should”, “should”)
- [ ] Links to resources point to real files
- [ ] There is an example output
- [ ] There are Quality Gates
- [ ] Large files are moved to references/

## If SKILL.md > 500 lines

```
Skill is too large ([N] lines > 500).

I propose to take out:
1. Code examples → references/examples.md
2. Checklists → references/checklist.md
3. Tables → references/tables.md

Break it? (yes / leave as is)
```
