# String Operations in Hot Path

**Applies to:** Performance, crypto, security, parsing

## Why this is bad

Строковые операции в критических по производительности участках:
- Создание String из UTF-8 дорого (валидация, копирование, ARC)
- Индексация String учитывает grapheme clusters - не O(1)
- Сравнение строк значительно дороже сравнения байтов
- В кейсе Т-Банка переход String -> [UInt8] дал ускорение до 400x

## Bad Example

```swift
// ❌ BAD: Сравнение токенов/хэшей через строки
func verifyToken(_ token: String, expected: String) -> Bool {
    return token == expected
}

// ❌ BAD: Посимвольная обработка через String.Index
func parseProtocol(_ input: String) -> [String] {
    var result: [String] = []
    var index = input.startIndex
    while index < input.endIndex {
        // O(n) для каждого доступа по индексу
        let char = input[index]
        // ...
        index = input.index(after: index)
    }
    return result
}

// ❌ BAD: Конкатенация строк для построения бинарных данных
func buildPayload(parts: [String]) -> String {
    return parts.joined(separator: "|")
}
```

## Good Example

```swift
// ✅ GOOD: Сравнение через байтовые массивы
func verifyToken(_ token: Data, expected: Data) -> Bool {
    guard token.count == expected.count else { return false }
    // Constant-time comparison для security
    var result: UInt8 = 0
    for i in 0..<token.count {
        result |= token[i] ^ expected[i]
    }
    return result == 0
}

// ✅ GOOD: Парсинг через UTF8View или [UInt8]
func parseProtocol(_ input: String) -> [ArraySlice<UInt8>] {
    let bytes = Array(input.utf8)
    var result: [ArraySlice<UInt8>] = []
    var start = 0
    for i in 0..<bytes.count {
        if bytes[i] == UInt8(ascii: "|") {
            result.append(bytes[start..<i])
            start = i + 1
        }
    }
    if start < bytes.count {
        result.append(bytes[start..<bytes.count])
    }
    return result
}

// ✅ GOOD: Data для бинарных операций
func buildPayload(parts: [Data]) -> Data {
    var payload = Data()
    for (i, part) in parts.enumerated() {
        if i > 0 { payload.append(UInt8(ascii: "|")) }
        payload.append(part)
    }
    return payload
}
```

## What to look for in code review

- Сравнение секретов (токены, хэши, ключи) через `String ==`
- Циклы по `String.Index` в горячем пути
- `String(data:encoding:)` в tight loop
- Конкатенация строк для бинарных протоколов
- Частое создание/уничтожение больших String объектов
