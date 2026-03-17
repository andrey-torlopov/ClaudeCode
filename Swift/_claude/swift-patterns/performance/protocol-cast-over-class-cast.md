# Protocol Cast Over Class Cast

**Applies to:** Performance, app startup, swift_conform_protocol

## Why this is bad

Каст к протоколу (`as? SomeProtocol`) вызывает `swift_conform_protocol`:
- Линейный поиск по всем конформансам при промахе кэша (~130k в крупных приложениях)
- Первый каст к протоколу самый тяжелый, далее работает кэш
- `is SomeProtocol` такой же дорогой - тот же линейный поиск
- Каст к массиву (`as? [SomeProtocol]`) проверяет каждый элемент
- В Т-Банке замена кастов к протоколам на касты к классам дала -20% старта и -40% подготовки главного экрана

Каст к классу (`as? SomeClass`) - быстрая проверка ISA-указателя, O(1).

## Bad Example

```swift
// ❌ BAD: Каст к протоколу в горячем пути
protocol Configurable {
    func configure()
}

func process(items: [Any]) {
    for item in items {
        // swift_conform_protocol на каждой итерации
        if let configurable = item as? Configurable {
            configurable.configure()
        }
    }
}

// ❌ BAD: Проверка is с протоколом
func shouldProcess(_ item: Any) -> Bool {
    return item is Configurable // линейный поиск конформансов
}

// ❌ BAD: Каст массива к протокольному типу
let items: [Any] = loadItems()
if let configurables = items as? [Configurable] {
    // Проверка каждого элемента
}
```

## Good Example

```swift
// ✅ GOOD: Каст к базовому классу - O(1) через ISA-указатель
class BaseConfigurable {
    func configure() {}
}

func process(items: [Any]) {
    for item in items {
        if let configurable = item as? BaseConfigurable {
            configurable.configure()
        }
    }
}

// ✅ GOOD: Кэширование результата каста, если протокол неизбежен
func processOnce(item: Any) {
    // Один каст, результат сохраняется
    guard let configurable = item as? Configurable else { return }
    configurable.configure()
    configurable.validate()
    configurable.apply()
}

// ✅ GOOD: Использование дженериков вместо каста
func process<T: Configurable>(_ item: T) {
    item.configure()
}
```

## Exceptions

- `@objc` протоколы - не требуют `swift_conform_protocol`
- Маркерные протоколы (`Sendable`) - проверка в compile-time
- Инлайнинг protocol witness table для конкретных типов (только в Release)

## What to look for in code review

- `as? SomeProtocol` в циклах и на горячих путях
- `is SomeProtocol` как условие в часто вызываемом коде
- Каст массивов к протокольным типам (`as? [Protocol]`)
- Множественные касты одного объекта к разным протоколам
