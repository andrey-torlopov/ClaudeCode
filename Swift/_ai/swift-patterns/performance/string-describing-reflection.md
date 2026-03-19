# String(describing:) and Reflection

**Applies to:** Performance, logging, app startup

## Why this is bad

`String(describing:)` (String Scrubbing) вызывает множество кастов к протоколам:
- Для простой структуры без полей - 4 каста через `swift_conform_protocol`
- С каждым полем количество кастов растет
- На старте приложения Т-Банка занимал ~250 мс
- Результат зависит от флага `Swift Reflection Level` - недетерминированный вывод
- Отказ от String Scrubbing дал: -5% старта, -12% подготовки главного экрана, -7% загрузки

## Bad Example

```swift
// ❌ BAD: String(describing:) для имени типа
func logEvent<T>(_ value: T) {
    let typeName = String(describing: type(of: value))
    logger.info("Processing \(typeName)")
}

// ❌ BAD: Интерполяция T.self (вызывает String Scrubbing)
func register<T>(_ type: T.Type) {
    let key = "\(T.self)"
    registry[key] = Factory<T>()
}

// ❌ BAD: String(describing:) для значения
func cacheKey(for value: some Hashable) -> String {
    return String(describing: value)
}
```

## Good Example

```swift
// ✅ GOOD: _typeName для имени типа (без рефлексии)
func logEvent<T>(_ value: T) {
    let typeName = _typeName(type(of: value))
    logger.info("Processing \(typeName)")
}

// ✅ GOOD: ObjectIdentifier для идентификации типа
func register<T>(_ type: T.Type) {
    let key = ObjectIdentifier(T.self)
    registry[key] = Factory<T>()
}

// ✅ GOOD: CustomStringConvertible для контролируемого вывода
struct CacheEntry: CustomStringConvertible {
    let id: String
    let timestamp: Date

    var description: String {
        "CacheEntry(\(id))"
    }
}

func cacheKey(for value: CacheEntry) -> String {
    return value.description
}
```

## What to look for in code review

- `String(describing:)` в горячем пути или на старте
- `"\(T.self)"` или `"\(type(of: obj))"` для идентификации типов
- `String(describing:)` в качестве ключа словаря или кэша
- Отсутствие `CustomStringConvertible` при частом использовании строкового представления
