# Interaction Guide

## Phase 2: Structural sentences by category

### Analysis Skills

```
I suggest adding:
- [ ] Severity levels (Critical/Major/Minor)?
- [ ] Export to JSON/Markdown?
- [ ] Checklist of checks in references/?
```

### Generation Skills

```
I suggest you clarify:
- [ ] Output language (Swift)?
- [ ] Do you need dry-run mode (show without saving)?
- [ ] Templates in references/?
```

### Validation Skills

```
I suggest adding:
- [ ] Output format (Pass/Fail, list of violations)?
- [ ] Auto-fix for simple cases?
- [ ] Rules in references/?
```

### Transformation Skills

```
I suggest you clarify:
- [ ] Input format?
- [ ] Output format?
- [ ] Need input validation?
```

## Phase 5: Editing Options

```
What's next?
1. ✅ Everything is fine, save
2. ✏️ Change description
3. ➕ Add a step to the algorithm
4. ➖ Remove a step from the algorithm
5. 📝 Change output format
6. ✓ Change Quality Gates
```

## Revision cycle

```
REPEAT until the user selects "Save":

  User selects action →

  IF "Change description":
    Show current → Ask new → Update → Show result

  IF "Add step":
    Ask: What step? After what step?
    Add → Renumber → Show result

  IF "Remove step":
    Show a list of steps with numbers
    Ask: Which one should I remove?
    Delete → Renumber → Show result

  IF "Change output format":
    Show current → Ask new → Update → Show result

  IF "Change Quality Gates":
    Show current → Ask for changes → Update → Show result

  → Return to CHECKPOINT 5
```

## Step 7.4: Improvement cycle after first use

```
Recommended revision cycle:
1. Call /[skill-name] on a real task
2. Pay attention: where does Claude “slip” or deviate from expectations?
3. Come back here with feedback - we’ll update SKILL.md
4. Repeat until stable result

Typical problems when starting for the first time:
- Too abstract instructions → add specific examples
- Missed an important step → add to the algorithm
- Extra steps → simplify workflow
- Inaccurate description → Claude does not activate the skill for the necessary phrases
```
