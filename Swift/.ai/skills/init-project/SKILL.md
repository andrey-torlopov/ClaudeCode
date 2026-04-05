---
name: init-project
description: Генерирует стартовый prompt pack для iOS/Swift проекта: COMMON.md, anchor-файлы и минимальный AI-контекст. Используй для нового проекта или миграции на облегчённый AI workflow. Не используй если core context уже настроен и требуется только точечная правка.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор COMMON.md и anchor-файлов

Создаёт компактный prompt pack на основе структуры iOS/Swift репозитория.

## Когда использовать

- Новый iOS/Swift проект без `COMMON.md`
- Миграция существующего проекта на AI-assisted workflow
- Стандартизация prompt pack по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

---

## Алгоритм выполнения

### Шаг 1: Сканирование проекта

Найди и проанализируй:

1. **Project files:**
   - `Package.swift` -> SPM, targets, dependencies
   - `*.xcodeproj` / `*.xcworkspace` -> Xcode project
   - `Podfile` -> CocoaPods
   - `Cartfile` -> Carthage

2. **Структуру исходников:**
   - `Sources/` или корневые .swift файлы
   - `Tests/` или `*Tests/`
   - Модули/фреймворки

3. **Конфигурации:**
   - `.swiftlint.yml` -> SwiftLint
   - `.swiftformat` -> SwiftFormat
   - `fastlane/` -> Fastlane

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `fastlane/Fastfile` -> Fastlane lanes

### Обработка ошибок Шага 1

**Project-файлы не найдены** -> Спроси пользователя:

```
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (App / Framework / SPM Package)
- Package manager: (SPM / CocoaPods / Carthage)
- UI framework: (SwiftUI / UIKit / Hybrid)
```

**CI/CD-конфиги отсутствуют** -> Не выдумывай секцию CI. Оставь только подтверждённые данные.

### Шаг 2: Определение Tech Stack

На основе зависимостей и кода определи:

| Категория | Что искать |
|-----------|------------|
| UI | SwiftUI / UIKit / Hybrid |
| Architecture | MVVM / VIPER / TCA / MVC |
| Networking | URLSession / Alamofire / Moya |
| Storage | CoreData / SwiftData / Realm |
| DI | Swinject / Factory / Manual |
| Concurrency | Swift Concurrency / Combine / RxSwift |
| Testing | XCTest / swift-testing / Quick+Nimble |
| Linting | SwiftLint / SwiftFormat |

### Шаг 3: Генерация core context

Прочитай и используй шаблон из `references/common-md-template.md`.

Сгенерируй:

- `COMMON.md` как SSOT
- `CLAUDE.md` как Claude anchor
- `AGENTS.md` как generic agent anchor
- `GEMINI.md` как Gemini anchor

Для `CLAUDE.md` используй `references/claude-md-template.md`.
`AGENTS.md` и `GEMINI.md` делай в том же стиле: короткий read-order и ссылка на `COMMON.md`.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным зависимостям
- [ ] Commands работают (проверь наличие Package.swift / xcodeproj)
- [ ] `COMMON.md` остаётся компактным и без дублирующих таблиц
- [ ] Anchor-файлы не копируют core rules
- [ ] Нет placeholder-ов вида `[xxx]` в финальных файлах

## Вывод

Сохрани результат в корень проекта:

- `COMMON.md`
- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`

## Связанные файлы

- Шаблон SSOT: `references/common-md-template.md`
- Шаблон Claude anchor: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
