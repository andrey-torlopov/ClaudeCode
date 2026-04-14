---
name: dependency-check
description: Analyzes iOS/Swift project SPM dependencies for relevance, conflicts and health. Use before updating dependencies or to audit the current state. Don't use it for code analysis - that's what /swift-review is for.
allowed-tools: "Read Write Glob Grep Bash(swift*) Bash(curl*) Bash(wc*)"
context: fork
---

# /dependency-check - SPM dependency analysis

<purpose>
Analysis of iOS/Swift project dependencies: versions, conflicts, relevance. Helps make decisions about updating dependencies.
</purpose>

## When to use

- Before updating dependencies
- Periodic audit of the “health” of dependencies
- When adding a new dependency (compatibility check)
- Estimation of tech debt depending on

## When NOT to use

- Project code analysis (use `/swift-review`)
- Repo exploration (use `/repo-scout`)

## Input data

- Path to the project with Package.swift (or current directory)

---

## Verbosity Protocol

**Tools first:** Analyze silently. In chat - only summary + path to the report.

---

## Algorithm

### Step 1: Discovery

1. Find and read `Package.swift`
2. Find and read `Package.resolved` (if available)
3. Find `Podfile` / `Cartfile` ​​(if available)

If Package.swift is not found -> notify the user and complete.

### Step 2: Dependency Inventory

For each dependency extract:
- Package name
- Repository URL
- Specified version/branch/revision
- Resolved version (from Package.resolved)
- Which targets use the dependency

Classify by category:
- **UI:** SnapKit, Kingfisher, Lottie, SDWebImage, etc.
- **Networking:** Alamofire, Moya, Apollo, etc.
- **Storage:** Realm, GRDB, etc.
- **Testing:** Quick, Nimble, SnapshotTesting, etc.
- **Utilities:** SwiftyJSON, KeychainAccess, etc.
- **Architecture:** TCA, RxSwift, Combine extensions, etc.

### Step 3: Version Analysis

For each dependency:
1. Define the version constraint type:
   - Exact (`.exact("1.0.0")`) -> hard binding, risk
   - Range (`.upToNextMajor`, `.upToNextMinor`) -> standard
   - Branch (`branch: "main"`) -> unstable
   - Revision (`revision: "abc123"`) -> frozen

2. Note potential problems:
   - Branch-based dependencies -> WARNING
   - Exact version -> INFO
   - Revision-based -> WARNING

### Step 4: Health Assessment

For each dependency, evaluate the “health” (without accessing the network, only based on Package.swift/resolved data):

| Indicator | Evaluation |
|-----------|--------|
| Version constraint type | Strict/Flexible/Unstable |
| Is it used in main targets | Core/Testing/Optional |
| Number of transitive dependencies | Low/Medium/High |

### Step 5: Conflict Detection

1. Check if there are any duplication of dependencies (one library through SPM and Pods)
2. Find potential version conflicts (transitive dependencies)
3. Check platforms compatibility (if Package.swift specifies platforms)

### Step 6: Report Generation

Save the report to the path specified by the user or `audit/dependency-check-report.md`.

---

## Report format

```markdown
# Dependency Check Report

> Project: {name}
> Package Manager: {SPM / CocoaPods / Mixed}
> Dependencies: {N}
> Date: {YYYY-MM-DD}

## Summary

| Metric | Meaning |
|---------|----------|
| Total dependencies | {N} |
| SPM | {N} |
| CocoaPods | {N} |
| Branch-based (unstable) | {N} |
| Exact version (hard) | {N} |
| Warnings | {N} |

## Dependencies Inventory

| # | Package | Version | Constraint | Category | Status |
|---|-------|--------|-----------|-----------|--------|
| 1 | {name} | {version} | {range/exact/branch} | {UI/Net/...} | {OK/WARNING} |

## Warnings

| # | Package | Problem | Recommendation |
|---|-------|---------|--------------|

## Categories

### UI ({N})
{list}

### Networking ({N})
{list}

### Storage ({N})
{list}

### Testing ({N})
{list}

### Utilities ({N})
{list}

## Recommendations

{Specific recommendations for updating/replacing dependencies}
```

---

## Quality Gates

- [ ] Package.swift read and parsed
- [ ] All dependencies are cataloged
- [ ] Each dependency is classified by category
- [ ] Warnings have a specific recommendation
- [ ] No placeholders in the report

## Completion

```
SKILL COMPLETE: /dependency-check
|- Artifacts: {path to report}
|- Dependencies: {N} ({X} SPM, {Y} Pods)
|- Warnings: {N}
```
