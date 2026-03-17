# String Search in Collection via Concatenation

**Applies to:** Performance, collections, search

## Why this is bad

Поиск строки внутри большой склеенной строки вместо структур данных:
- Линейный поиск подстроки: ~200 мс в реальном кейсе
- Замена на Set: ~2 мс (ускорение в 100x)
- "Собрал все в String и ищу contains" - почти всегда антипаттерн
- O(n*m) вместо O(1) при использовании хэш-таблицы

## Bad Example

```swift
// ❌ BAD: Поиск через contains в склеенной строке
final class FeatureRegistry {
    private var allFeatures: String = ""

    func register(_ feature: String) {
        allFeatures += "|\(feature)"
    }

    func isEnabled(_ feature: String) -> Bool {
        return allFeatures.contains(feature) // O(n*m)
    }
}

// ❌ BAD: Линейный поиск в массиве строк
func findUser(by email: String, in users: [String]) -> Bool {
    return users.contains(email) // O(n)
}
```

## Good Example

```swift
// ✅ GOOD: Set для O(1) поиска
final class FeatureRegistry {
    private var features: Set<String> = []

    func register(_ feature: String) {
        features.insert(feature)
    }

    func isEnabled(_ feature: String) -> Bool {
        return features.contains(feature) // O(1)
    }
}

// ✅ GOOD: Dictionary для поиска с ассоциированными данными
struct UserLookup {
    private var usersByEmail: [String: User] = [:]

    mutating func add(_ user: User) {
        usersByEmail[user.email] = user
    }

    func find(by email: String) -> User? {
        return usersByEmail[email] // O(1)
    }
}

// ✅ GOOD: Хэш-суффиксы для быстрого сопоставления
struct SuffixMatcher {
    private var suffixMap: [String: [String]] = [:]

    mutating func add(_ value: String, suffixLength: Int = 4) {
        let suffix = String(value.suffix(suffixLength))
        suffixMap[suffix, default: []].append(value)
    }

    func matches(for suffix: String) -> [String] {
        return suffixMap[suffix] ?? []
    }
}
```

## What to look for in code review

- `bigString.contains(substring)` для поиска в коллекции значений
- Массив строк + `contains` / `first(where:)` для частых lookup-ов
- Конкатенация строк как способ хранения коллекции
- `joined(separator:)` + последующий `contains` / `range(of:)`
