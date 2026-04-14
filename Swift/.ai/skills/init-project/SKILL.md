---
name: init-project
description: Generates a starting prompt pack for an iOS/Swift project: COMMON.md, anchor files and minimal AI context. Use for a new project or migration to a lightweight AI workflow. Do not use if the core context is already configured and only minor edits are required.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Generator of COMMON.md and anchor files

Creates a compact prompt pack based on the iOS/Swift repository structure.

## When to use

- New iOS/Swift project without `COMMON.md`
- Migration of an existing project to AI-assisted workflow
- Standardization of prompt pack by command

## Verbosity Protocol

**Tools first:** Scan silently. In the chat - only the final result.

---

## Execution algorithm

### Step 1: Scan the project

Find and analyze:

1. **Project files:**
   - `Package.swift` -> SPM, targets, dependencies
   - `*.xcodeproj` / `*.xcworkspace` -> Xcode project
   - `Podfile` -> CocoaPods
   - `Cartfile` -> Carthage

2. **Source structure:**
   - `Sources/` or root .swift files
   - `Tests/` or `*Tests/`
   - Modules/frameworks

3. **Configurations:**
   - `.swiftlint.yml` -> SwiftLint
   - `.swiftformat` -> SwiftFormat
   - `fastlane/` -> Fastlane

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `fastlane/Fastfile` -> Fastlane lanes

### Handling Step 1 errors

**Project files not found** -> Ask the user:

```
The project structure could not be determined automatically. Specify:
- Project type: (App/Framework/SPM Package)
- Package manager: (SPM / CocoaPods / Carthage)
- UI framework: (SwiftUI / UIKit / Hybrid)
```

**CI/CD configs missing** -> Don't make up the CI section. Leave only verified information.

### Step 2: Define Tech Stack

Based on dependencies and code, determine:

| Category | What to look for |
|-----------|------------|
| UI | SwiftUI / UIKit / Hybrid |
| Architecture | MVVM / VIPER / TCA / MVC |
| Networking | URLSession / Alamofire / Moya |
| Storage | CoreData / SwiftData / Realm |
| DI | Swinject / Factory / Manual |
| Concurrency | Swift Concurrency / Combine / RxSwift |
| Testing | XCTest / swift-testing / Quick+Nimble |
| Linting | SwiftLint / SwiftFormat |

### Step 3: Generating core context

Read and use the template from `references/common-md-template.md`.

Generate:

- `COMMON.md` as SSOT
- `CLAUDE.md` as Claude anchor
- `AGENTS.md` as generic agent anchor
- `GEMINI.md` as Gemini anchor

For `CLAUDE.md` use `references/claude-md-template.md`.
Do `AGENTS.md` and `GEMINI.md` ​​in the same style: a short read-order and a link to `COMMON.md`.

### Step 4: Validation

Before saving, check:

- [ ] Tech Stack matches real dependencies
- [ ] Commands work (check for Package.swift / xcodeproj)
- [ ] `COMMON.md` remains compact and without duplicate tables
- [ ] Anchor files do not copy core rules
- [ ] There are no placeholders like `[xxx]` in the final files

## Conclusion

Save the result to the project root:

- `COMMON.md`
- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`

## Related files

- SSOT Template: `references/common-md-template.md`
- Claude anchor template: `references/claude-md-template.md`
- Reconnaissance: `/repo-scout` (can be done before init-project)
