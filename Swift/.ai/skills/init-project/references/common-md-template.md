# COMMON.md - SSOT template

Use this template as the core of your project context. It is he who should store general rules, build/test and basic conventions.

```markdown
# [Project Name] Core Context

`COMMON.md` is a single SSOT for the base project context.

## Stack

- Project: [Brief description]
- Language: Swift
- Platform: [iOS / macOS / multiplatform]
- Package Manager: [SPM / CocoaPods / Carthage]
- UI: [SwiftUI / UIKit / Hybrid]
- Architecture: [MVVM / VIPER / TCA / MVC]
- Testing: [XCTest / swift-testing / Quick+Nimble]

## Verify

- Build: `[swift build / xcodebuild ...]`
- Test: `[swift test / xcodebuild test ...]`

## Core Rules

1. Trust No One
2. Minimal Diff
3. Production Ready
4. Read Freely
5. Delete Carefully

## Working Conventions

- Documentation and comments: [Russian / other language]
- Do not change the architecture without a direct request
- Patterns are lazy to load via `.ai/patterns/_index.md`
- For research, first agree on the path to the Markdown result
```
