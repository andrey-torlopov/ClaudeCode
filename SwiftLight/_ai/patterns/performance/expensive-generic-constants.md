# Expensive Generic Constants

**Applies to:** Performance, generics, app startup

## Why this is bad

Swift создает метаданные для дженерик-типов в рантайме:
- `swift_checkGenericRequirements` вызывает `swift_conform_protocol` для каждого протокольного ограничения
- Дженерик-константы в переиспользуемых компонентах особенно дороги
- Экономия размера метаданных в бинарнике приводит к дополнительным затратам CPU
- В Т-Банке отказ от дженерик-констант ускорил старт на 11% (220 мс) и подготовку главной страницы на 10% (95 мс)

## Bad Example

```swift
// ❌ BAD: Дженерик-константа для декодирования
struct Feature<T: Decodable> {
    let decoder: JSONDecoder
    let type: T.Type

    func decode(from data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }
}

// Каждое создание Feature<X> -> swift_checkGenericRequirements
let featureA = Feature<ConfigA>(decoder: decoder, type: ConfigA.self)
let featureB = Feature<ConfigB>(decoder: decoder, type: ConfigB.self)
// ... десятки таких регистраций на старте
```

## Good Example

```swift
// ✅ GOOD: Инжекция decode/encode через замыкание вместо дженерика
struct Feature {
    let decode: (Data) throws -> Any

    init<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) {
        self.decode = { data in
            try decoder.decode(T.self, from: data)
        }
    }
}

// Дженерик используется только в init, не в хранимом типе
let featureA = Feature(type: ConfigA.self)
let featureB = Feature(type: ConfigB.self)
```

## What to look for in code review

- Дженерик-структуры/классы с протокольными ограничениями, создаваемые массово
- Массовая регистрация дженерик-компонентов на старте приложения
- Дженерик-параметры, которые можно заменить на замыкания или type erasure
- `where T: ProtocolA & ProtocolB & ProtocolC` - каждый протокол проверяется отдельно
