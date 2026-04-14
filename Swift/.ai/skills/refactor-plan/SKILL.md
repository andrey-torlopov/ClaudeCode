---
name: refactor-plan
description: Analyzes a section of code and creates a step-by-step refactoring plan with priorities and risk assessment. Use it when you need to plan refactoring of a module or group of files. Don't use for code review - that's what /swift-review is for.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /refactor-plan - Refactoring planning

<purpose>
Analysis of a section of Swift code, identification of code smells and technical debt, creation of a step-by-step refactoring plan with priorities and risk assessment.
</purpose>

## When to use

- Planning module/feature refactoring
- Technical debt assessment
- Preparing for migration (UIKit -> SwiftUI, GCD -> Swift Concurrency)
- Decomposition of God objects

## When NOT to use

- Search for bugs (use `/swift-review`)
- Repo exploration (use `/repo-scout`)
- Easy renaming

## Input data

| Parameter | Obligation | Description |
|----------|:--------------:|----------|
| Scope | Required | Path to file, module or directory |
| Goal | Optional | Specific purpose of refactoring |

---

## Verbosity Protocol

**Tools first:** Analyze silently. Chat is the only way to the report.

---

## Algorithm

### Step 1: Scope Analysis

1. Identify files to analyze
2. Calculate metrics:
   - Number of files and lines
   - Number of types (class/struct/enum/protocol)
   - Dependencies between files (imports)
3. Read `COMMON.md` for restrictions and conventions, and derive the architecture from real code

### Step 2: Code Smells Detection

Check each file for:

**Structural smells:**
- God Object: class/structure > 300 lines or > 10 methods
- Long Method: function > 50 lines
- Large File: file > 500 lines
- Deep Nesting: > 4 levels of nesting

**Design smells:**
- Massive ViewController / ViewModel
- Fat Model (business logic in the data model)
- Close connectivity (concrete types instead of protocols)
- Violation of Single Responsibility

**Swift-specific smells:**
- Completion handlers instead of async/await
- DispatchQueue instead of actors/@MainActor
- Mutable shared state without synchronization
- Force unwraps in production code
- Retain cycles (delegate without weak, closures without [weak self])

### Step 3: Dependency Mapping

1. Build a graph of dependencies between types in scope
2. Find cyclic dependencies
3. Identify “bottlenecks” (types on which a lot depends)

### Step 4: Refactoring Plan

For each smell found, create a refactoring step:

| Field | Description |
|------|----------|
| Priority | P0 (blocker) / P1 (high) / P2 (medium) / P3 (low) |
| What | Specific description of the problem |
| Action | Specific description of the solution |
| Files | List of affected files |
| Risk | Low / Medium / High |
| Dependencies | What steps does it depend on |

**Prioritization:**
- P0: Crashes, data races, memory leaks
- P1: Architectural violations blocking development
- P2: Code smells, tech debt
- P3: Stylistics, minor improvements

### Step 5: Report Generation

Save the plan to the path specified by the user or `audit/refactor-plan.md`.

---

## Report format

```markdown
# Refactoring Plan

> Scope: {path}
> Files: {N} | Strings: {M} | Types: {K}
> Date: {YYYY-MM-DD}

## Summary

| Metric | Meaning |
|---------|----------|
| Code smells | {N} |
| P0 (blocker) | {N} |
| P1 (high) | {N} |
| P2 (medium) | {N} |
| P3 (low) | {N} |

## Code Smells

| # | File | Type smell | Description | Severity |
|---|------|----------|----------|----------|

## Dependency Map

{Text description of the dependency graph and problematic connections}

## Refactoring Steps

### P0: Blockers

| # | What | Action | Files | Risk | Depends on |
|---|-----|----------|-------|------|-----------|

### P1: High priority

| # | What | Action | Files | Risk | Depends on |
|---|-----|----------|-------|------|-----------|

### P2: Medium priority

| # | What | Action | Files | Risk | Depends on |
|---|-----|----------|-------|------|-----------|

### P3: Low priority

| # | What | Action | Files | Risk | Depends on |
|---|-----|----------|-------|------|-----------|

## Recommended execution order

{Sequence of steps taking into account dependencies}
```

---

## Quality Gates

- [ ] All files in scope have been read
- [ ] Each smell has a specific file and description
- [ ] Step plan has dependencies between steps
- [ ] Execution order takes into account dependencies
- [ ] Risks assessed for each step

## Completion

```
SKILL COMPLETE: /refactor-plan
|- Artifacts: {path to report}
|- Scope: {N} files, {M} lines
|- Smells: {N} total ({P0} P0, {P1} P1, {P2} P2, {P3} P3)
```
