# NSString-Swift String Bridging in Tight Loop

**Applies to:** Performance, Objective-C interop, bridging

## Why this is bad

Частые конвертации NSString <-> String в горячем пути:
- Каждый bridging cast создает копию или увеличивает refcount
- В tight loop это заметно бьет по производительности
- Смешивание NSString и String API в одном блоке кода - двойные затраты
- Особенно критично при работе с legacy Obj-C библиотеками

## Bad Example

```swift
// ❌ BAD: Постоянные переходы NSString <-> String
func processItems(_ items: [NSString]) -> [String] {
    return items.map { nsString in
        let swiftString = nsString as String         // bridging
        let modified = swiftString.lowercased()
        let nsModified = modified as NSString         // bridging обратно
        let range = nsModified.range(of: "pattern")
        let result = nsModified.substring(from: range.location) // NSString API
        return result as String                       // и снова bridging
    }
}

// ❌ BAD: Использование NSString API на Swift String
func extractComponent(_ path: String) -> String {
    return (path as NSString).lastPathComponent      // bridging ради одного вызова
}
```

## Good Example

```swift
// ✅ GOOD: Работа полностью в одном мире
func processItems(_ items: [NSString]) -> [String] {
    // Один раз конвертируем, дальше работаем только со Swift
    let swiftItems = items.map { $0 as String }
    return swiftItems.map { string in
        let modified = string.lowercased()
        guard let range = modified.range(of: "pattern") else { return modified }
        return String(modified[range.lowerBound...])
    }
}

// ✅ GOOD: URL API вместо NSString path manipulation
func extractComponent(_ url: URL) -> String {
    return url.lastPathComponent
}

// ✅ GOOD: Если нужен Obj-C блок - держи его целиком в NSString
func processLegacy(_ items: [NSString]) -> [NSString] {
    return items.map { nsString in
        // Весь блок на NSString, без переключений
        let range = nsString.range(of: "pattern")
        guard range.location != NSNotFound else { return nsString }
        return nsString.substring(from: range.location) as NSString
    }
}
```

## What to look for in code review

- `as NSString` / `as String` в цикле или map/filter/reduce
- Чередование Swift String методов и NSString методов в одном блоке
- `(path as NSString).lastPathComponent` - замени на URL
- Legacy Obj-C API вызовы вперемешку со Swift string processing
