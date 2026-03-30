# Naming Conventions

**Applies to:** Весь Swift-код проекта

## Правила

- Типы и протоколы: UpperCamelCase
- Переменные, функции, параметры: lowerCamelCase
- Протоколы-способности: суффикс -able/-ible (Sendable, Codable)
- Булевые свойства: `isEnabled`, `hasContent`, `shouldReload`

## Bad Example

```swift
// ❌ BAD: Неправильный нейминг
protocol data_provider { }
struct user_model { }

let IsLoading = true
let enabled = false
func FetchData() { }
```

## Good Example

```swift
// ✅ GOOD: Swift API Design Guidelines
protocol DataProviding { }
protocol Cacheable { }
struct UserModel { }

let isLoading = true
let isEnabled = false
let hasContent = true
let shouldReload = false
func fetchData() { }
```

## What to look for in code review

- snake_case в именах типов или функций
- Протоколы-способности без суффикса -able/-ible
- Булевые свойства без префикса is/has/should
- UpperCamelCase в именах переменных/функций
- lowerCamelCase в именах типов/протоколов
