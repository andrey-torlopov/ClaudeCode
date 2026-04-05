# COMMON.md - SSOT template

Используй этот шаблон как ядро контекста проекта. Именно он должен хранить общие правила, build/test и базовые conventions.

```markdown
# [Project Name] Core Context

`COMMON.md` — единый SSOT для базового контекста проекта.

## Stack

- Project: [Краткое описание]
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

- Документация и комментарии: [русский / иной язык]
- Не менять архитектуру без прямого запроса
- Паттерны загружать лениво через `.ai/patterns/_index.md`
- Для исследований сначала согласовывать путь к Markdown-результату
```
