# iOS/Swift Patterns - Reference for /repo-scout

## Project Files

| File | Destination |
|------|-----------|
| `Package.swift` | SPM - modules, dependencies, targets |
| `Package.resolved` | SPM - Committed Dependency Versions |
| `*.xcodeproj` | Xcode project (targets, schemes, build settings) |
| `*.xcworkspace` | Xcode workspace (multi-project) |
| `Podfile` / `Podfile.lock` ​​| CocoaPods dependencies |
| `Cartfile` / `Cartfile.resolved` ​​| Carthage dependencies |
| `.swiftlint.yml` | SwiftLint configuration |
| `.swiftformat` | SwiftFormat configuration |

## Architecture Detection Patterns

### UI Framework

| Pattern | Framework |
|---------|-----------|
| `import SwiftUI` | SwiftUI |
| `import UIKit` | UIKit |
| `import AppKit` | macOS (AppKit) |
| Both SwiftUI and UIKit | Hybrid |

### Architecture Patterns

| Pattern (Grep) | Architecture |
|----------------|-------------|
| `ViewModel`, `ObservableObject`, `@Published` | MVVM |
| `Presenter`, `Interactor`, `Router`, `Assembly` | VIPER |
| `Store`, `Reducer`, `Effect`, `import ComposableArchitecture` | TCA |
| `Coordinator`, `CoordinatorProtocol` | Coordinator pattern |
| `Controller` (without ViewModel) | MVC |

### Networking

| Pattern | Library |
|---------|-----------|
| `URLSession` | Native URLSession |
| `import Alamofire` | Alamofire |
| `import Moya` | Moya (Alamofire wrapper) |
| `import Apollo` | Apollo (GraphQL) |

### Storage

| Pattern | Technology |
|---------|-----------|
| `import CoreData`, `NSManagedObject` | CoreData |
| `import SwiftData`, `@Model` | SwiftData |
| `import RealmSwift` | Realm |
| `import GRDB` | GRDB |
| `UserDefaults` | UserDefaults |

### Concurrency

| Pattern | Approach |
|---------|-------|
| `actor `, `@MainActor`, `async/await` | Swift Concurrency |
| `DispatchQueue`, `DispatchGroup` | GCD |
| `import RxSwift`, `Observable` | RxSwift |
| `import Combine`, `Publisher` | Combine |
| `import ReactiveSwift` | ReactiveSwift |

### DI

| Pattern | Framework |
|---------|-----------|
| `import Swinject` | Swinject |
| `import Factory` | Factory |
| `import Needle` | Needle |
| Manual init injection | Manual DI |

## Test Patterns

| Type | Signs |
|-----|----------|
| **Unit** | `XCTestCase`, `@Test`, without UI/Network imports |
| **UI** | `XCUIApplication`, `XCUIElement`, `launch()` |
| **Snapshot** | `import SnapshotTesting`, `assertSnapshot` |
| **Performance** | `measure {}`, `XCTMetric` |

### Test Frameworks

| Library | Destination |
|-----------|-----------|
| `XCTest` | Apple native testing |
| `Testing` (swift-testing) | Modern Swift testing (Swift 5.9+) |
| `Quick` | BDD-style specs |
| `Nimble` | Matchers |
| `SnapshotTesting` | Snapshot tests (Point-Free) |
| `OHHTTPStubs` / `Mocker` | Network mocking |
| `ViewInspector` | SwiftUI view testing |

## Infrastructure Markers

| Globe | What is this |
|------|---------|
| `.github/workflows/*.yml` | GitHub Actions CI/CD |
| `.gitlab-ci.yml` | GitLab CI |
| `fastlane/Fastfile` | Fastlane automation |
| `.bitrise.yml` | Bitrise CI |
| `Jenkinsfile` | Jenkins pipeline |
| `Gemfile` | Ruby deps (usually for Fastlane/CocoaPods) |
| `.ruby-version` | Ruby version manager |

## Code Generation

| Globe | Tool |
|------|-----------|
| `**/*.generated.swift` | Sourcery / SwiftGen output |
| `**/Sourcery/**`, `*.sourcery.yml` | Sourcery templates |
| `**/swiftgen.yml` | SwiftGen config |
| `**/*.strings` | Localization strings |
| `**/*.xcassets` | Asset catalogs |

## AI Setup Files

| File | Tool |
|------|-----------|
| `COMMON.md` | Shared AI core context |
| `CLAUDE.md` | Claude Code entry |
| `AGENTS.md` | Agent runtime entry |
| `GEMINI.md` | Gemini entry |
| `.ai/skills/*/SKILL.md` | Claude Code Skills |
| `.ai/commands/*.md` | Claude Code Commands |
| `.ai/agents/*.md` | Claude Code Agents |
| `.cursor/rules/*.mdc` | Cursor IDE |
| `.github/copilot-instructions.md` | GitHub/VS Code Copilot |
