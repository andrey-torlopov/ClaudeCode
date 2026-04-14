---
name: repo-scout
description: Scans the iOS/Swift repository, cataloging project structure, dependencies, architecture and test coverage. Use when entering a new repo to understand the codebase. Don't use for code review - that's what /swift-review is for.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*)"
context: fork
---

# /repo-scout - iOS repository scouting

<purpose>
Deep scan of the iOS/Swift repository -> structured report on the project, dependencies, architecture and current test coverage. Gives a complete picture of the project before starting work.
</purpose>

## When to use

- First entry into the new iOS repository
- Before `/init-project` - to understand the project
- Periodic audit: “what has changed in the project?”
- Onboarding to an existing project

## When NOT to use

- Code review (use `/swift-review`)
- Dependency analysis (use `/dependency-check`)

## Input data

- Path to the repository (or current directory)
- Does not require `COMMON.md` or anchor files
- Could be the **first step** in a new repo

## Verbosity Protocol

**Structured Output Priority:** All analysis goes to the artifact, not to the chat.

**Chat output:** Only Summary table + "Report: audit/repo-scout-report.md".

**Tools first:** Grep -> table -> report, without "Now I will grep...". Read -> analyze -> report, without "The file shows...".

**Phases 1-5:** Silent execution. **Phase 6:** Summary only + path to report.

---

## Algorithm

### Phase 1: Project Structure Scan

**Goal:** Determine the type of project, build system, directory structure.

1. Check for the presence of project files:
   ```
   Package.swift, *.xcodeproj, *.xcworkspace, Podfile, Cartfile
   ```
   Definition priority: Package.swift (SPM) > xcworkspace > xcodeproj > Podfile

2. Extract from Package.swift (if available):
   - Package name
   - Platforms and minimum versions
   - Products (library/executable)
   - Dependencies (packages)
   - Targets and test targets

3. Define the structure:
   ```
   Glob: Sources/*/ -> modules/frameworks
   Glob: Tests/*/ -> test targets
   Glob: **/Info.plist -> application targets
   Glob: **/*.entitlements -> capabilities
   ```

4. Calculate the size:
   ```
   Number of .swift files (without Tests/)
   Number of test .swift files
   ```

### Phase 2: Dependencies Analysis

**Goal:** Catalog all dependencies.

#### 2.1 SPM Dependencies

If there is Package.swift and/or Package.resolved:
- List of all packages with versions
- Classification: UI, Networking, Storage, Testing, Utilities

#### 2.2 CocoaPods

If there is a Podfile:
- List of pods with versions
- Availability of Podfile.lock

#### 2.3 Carthage

If there is a Cartfile:
- List of dependencies

### Phase 3: Architecture Discovery

**Goal:** Define architectural patterns for the project.

1. **UI Framework:**
   ```
   Grep: import SwiftUI -> SwiftUI
   Grep: import UIKit -> UIKit
   Grep: import Combine -> Combine usage
   ```
   Define: SwiftUI/UIKit/Hybrid

2. **Architectural pattern:**
   ```
   Grep: ViewModel, ObservableObject -> MVVM
   Grep: Presenter, Interactor, Router -> VIPER
   Grep: Store, Reducer, Effect -> TCA/Redux
   Grep: Coordinator -> Coordinator pattern
   ```

3. **Networking:**
   ```
   Grep: URLSession -> Native
   Grep: import Alamofire -> Alamofire
   Grep: import Moya -> Moya
   ```

4. **Storage:**
   ```
   Grep: import CoreData -> CoreData
   Grep: import SwiftData -> SwiftData
   Grep: import RealmSwift -> Realm
   Grep: UserDefaults -> UserDefaults usage
   Grep: import KeychainAccess|KeychainSwift -> Keychain
   ```

5. **Concurrency:**
   ```
   Grep: actor |@MainActor -> Modern concurrency
   Grep: DispatchQueue -> GCD
   Grep: import RxSwift -> RxSwift
   ```

### Phase 4: Test Coverage Analysis

**Goal:** Evaluate current test coverage.

1. Find test files:
   ```
   Glob: **/Tests/**/*.swift, **/*Tests*/**/*.swift
   ```

2. Classify:
   - **Unit:** files with XCTestCase / @Test without network/UI dependencies
   - **UI:** files with XCUIApplication, XCUIElement
   - **Snapshot:** files with import SnapshotTesting
   - **Integration:** files with network mocks

3. Define test frameworks:
   ```
   Grep: import XCTest -> XCTest
   Grep: import Testing -> swift-testing
   Grep: import Quick -> Quick
   Grep: import Nimble -> Nimble
   Grep: import SnapshotTesting -> SnapshotTesting
   ```

### Phase 5: Infrastructure Scan

**Goal:** Understand the infrastructure context.

1. **CI/CD:**
   ```
   Glob: .github/workflows/*.yml -> GitHub Actions
   Glob: .gitlab-ci.yml -> GitLab CI
   Glob: fastlane/** -> Fastlane
   Glob: .bitrise.yml -> Bitrise
   Glob: Jenkinsfile -> Jenkins
   ```

2. **Linting/Formatting:**
   ```
   Glob: .swiftlint.yml -> SwiftLint
   Glob: .swiftformat -> SwiftFormat
   ```

3. **AI Setup:**
   ```
   Glob: COMMON.md -> shared core context
   Glob: CLAUDE.md -> Claude entry
   Glob: AGENTS.md -> agent-runtime entry
   Glob: GEMINI.md -> Gemini entry
   Glob: .ai/** -> local AI config
   Glob: .cursor/rules/*.mdc -> Cursor IDE
   Glob: .github/copilot-instructions.md -> Copilot
   ```

4. **Code Generation:**
   ```
   Glob: **/*.generated.swift -> Generated code
   Glob: **/Sourcery/** -> Sourcery templates
   Glob: **/SwiftGen/** -> SwiftGen
   ```

### Phase 6: Report Generation

Collect the report and save it in `audit/repo-scout-report.md`. Use the template from `references/report-template.md`.

**Required sections:**
1. Project Profile (name, platforms, type, dependencies count)
2. Module Structure (targets, source/test files)
3. Dependencies Catalog (SPM/Pods/Carthage with classification)
4. Architecture Summary (UI framework, pattern, networking, storage, concurrency)
5. Test Coverage (unit/UI/snapshot/integration)
6. Infrastructure (CI/CD, linting, AI setup)
7. Readiness Assessment (strengths + areas for improvement + next step)

## Quality Gates

- [ ] Package.swift or xcodeproj found and analyzed
- [ ] All dependencies are cataloged
- [ ] Architectural pattern defined
- [ ] Test coverage assessed
- [ ] There are no `{xxx}` placeholders in the final report
- [ ] Readiness Assessment is complete

## Self-Check

- [ ] **Completeness:** Are all 7 sections complete?
- [ ] **Accuracy:** Number of files verified?
- [ ] **No Hallucinations:** Is each found pattern confirmed by Grep?
- [ ] **Readiness:** Is the assessment supported by data?

## Completion

```
SKILL COMPLETE: /repo-scout
|- Artifacts: audit/repo-scout-report.md
|- Compilation: N/A
|- Upstream: no
|- Modules: {N} | Swift files: {M} | Tests: {K}
```

## Related files

- iOS Patterns: `references/ios-patterns.md`
- Report template: `references/report-template.md`
- Next step: `/init-project` (uses report as input)
