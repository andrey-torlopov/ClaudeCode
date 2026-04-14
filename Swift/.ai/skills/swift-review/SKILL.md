---
name: swift-review
description: Deep code review of Swift code with a focus on memory safety, concurrency, Swift conventions and architecture. Use it to review modules, PRs or individual files. Don't use /dependency-check for dependency analysis.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /swift-review — Swift Code Review (light)

## Purpose

- Deep review of Swift code: memory safety, concurrency, conventions, error handling, architecture.
- The result is a report with BLOCKER / CRITICAL / WARNING / INFO.

## Entrance

- **Scope (required):** file / directory / module.
- **Focus (optional):** `memory` / `concurrency` ​​/ `architecture` / `all` (default).

## Verbosity & Loop Safety

- SILENT MODE: the analysis goes to the report, to the chat - only a short summary + path to the file.
- Tools first: Read/Grep → analysis → report, without description of steps.
- Do not restart `/swift-review` from the report and do not offer auto-repeat; one run = one report.

## Algorithm (briefly)

1. Define scope (file / directory `.swift` without tests / `Sources/{module}`), read `COMMON.md`, count lines.
2. **Memory Safety:** use `references/swift-checklist.md` (retain cycles, force unwrap, `Type!`, unowned).
3. **Concurrency:** use `references/concurrency-rules.md` (Sendable, `@MainActor`, data races, Task/actors).
4. **Conventions & Errors:** let/var, guard, value types, naming, Any/AnyObject, throws/try?/empty catch/Result.
5. **Architecture:** file size and responsibility, layers, SwiftUI status fields.

## Severity & Report

- BLOCKER / CRITICAL / WARNING / INFO - according to the criteria from the checklists.
- Save the report in `audit/swift-review-report.md` (or user path) in tabular form with files, lines and recommendations.

## Completion

- Print the final block: `SKILL COMPLETE: /swift-review` + scope, number of findings and path to the report.
