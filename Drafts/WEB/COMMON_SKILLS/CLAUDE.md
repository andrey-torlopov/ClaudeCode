# Project context
- Язык: Swift
- Пакетный менеджер: SPM
- UI: SwiftUI / UIKit

# Build & Run
- Сборка: `swift build`
- Тесты: `swift test`

# Swift conventions
- Следуй Swift API Design Guidelines
- Используй `let` вместо `var` где возможно
- Предпочитай value types (struct, enum) над reference types (class), если нет явной необходимости
- enum используем только если планируется проверка перечислений. Иначе используем struct
- Используй `async/await` вместо completion handlers
- Используй Modern concurrency вместо NSLog, Semaphore и прочих механизмов
- Используй structured concurrency (TaskGroup, async let) вместо неструктурированных Task {}
- Помечай типы как `Sendable` где возможно
- Используй `@MainActor` для UI-кода, не `DispatchQueue.main`
- Обрабатывай ошибки через `throws` / `Result`, не через опционалы для ошибочных состояний
- Используй `guard` для раннего выхода
- В Task если используем [weak self], то не усиливаем сразу self, а только перед первым его использованием
- Предпочитай `[weak self]` в escaping closures для предотвращения retain cycles
- Не используй force unwrap (`!`) кроме IBOutlet и тестов
- Не используй `Any` / `AnyObject` без крайней необходимости - предпочитай протоколы и дженерики
- Стараемся не использовать Task.detached()
- Стараемся не использовать .init, а явное указание класса/структуры

# Naming
- Типы и протоколы: UpperCamelCase
- Переменные, функции, параметры: lowerCamelCase
- Протоколы-способности: суффикс -able/-ible (Sendable, Codable)
- Булевые свойства: `isEnabled`, `hasContent`, `shouldReload`

# Architecture
- Не предлагай архитектурные паттерны (VIPER, MVC и т.д.) без запроса
- При рефакторинге сохраняй существующую архитектуру проекта

# Code style
- Не используй длинное тире в комментариях, используй "-"
- Не добавляй комментарии к очевидному коду
- Не добавляй `// MARK:` без запроса
- Не добавляй docstrings без запроса
- Не оборачивай код в `#if DEBUG` без запроса

# RnD
- Для анализа всегда запрашиваем путь куда сохранить результат в markdown

## Core Principles
1. **Trust No One** - проверяй требования на противоречия
2. **Production Ready** - код компилируется без правок
3. **Safety** - деструктивные команды только с подтверждением

## Editing Conventions

Когда просят сократить, упростить или обрезать вывод/контент - удаляй только то, что явно запрошено. Никогда не удаляй протоколы безопасности или промпты кастомизации, если об этом явно не сказано.

## AI-сетап

**Перед выполнением любого skill читай:** `.claude/dev_agent.md`

**Структура:** `.claude/` -> `dev_agent.md`, `agents/`, `skills/`, `swift-antipatterns/`
