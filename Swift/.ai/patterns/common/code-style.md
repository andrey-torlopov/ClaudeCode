# Code Style

**Applies to:** Весь Swift-код проекта

## Правила

- Не используй "—" (длинное тире и дефисы) в комментариях - используй "-"
- Не добавляй комментарии к очевидному коду
- Не добавляй `// MARK:` без запроса
- Не добавляй docstrings без запроса
- Не оборачивай код в `#if DEBUG` без запроса

## Bad Example

```swift
// ❌ BAD: лишние комментарии, MARK, docstrings, длинное тире
// MARK: - Properties

/// Загружает данные из сети
func loadData() async throws -> Data {
    // Создаём URL — формируем запрос
    let url = URL(string: endpoint)!
    #if DEBUG
    print("loading...")
    #endif
    // Возвращаем результат
    return try await URLSession.shared.data(from: url).0
}
```

## Good Example

```swift
// ✅ GOOD: только необходимые комментарии, без MARK/docstrings без запроса
func loadData() async throws -> Data {
    let url = URL(string: endpoint)!
    return try await URLSession.shared.data(from: url).0
}
```

## What to look for in code review

- "—" (длинное тире) в комментариях вместо "-"
- Комментарии, дублирующие очевидный код
- `// MARK:` добавленные без явного запроса
- Docstrings добавленные без явного запроса
- `#if DEBUG` обёртки добавленные без явного запроса
