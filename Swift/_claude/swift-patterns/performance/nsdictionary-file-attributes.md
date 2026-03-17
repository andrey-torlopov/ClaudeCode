# NSDictionary File Attributes

**Applies to:** FileManager, file metadata, URL resources

## Why this is bad

Использование старого NSDictionary API для атрибутов файлов:
- `attributesOfItem(atPath:)` возвращает словарь со ВСЕМИ атрибутами
- Избыточная работа CPU и памяти когда нужны 1-2 значения
- String-based пути дороже URL-based при массовых операциях
- Нет кэширования атрибутов, каждый вызов идет в FS

## Bad Example

```swift
// ❌ BAD: Полный словарь атрибутов через старое API
func fileSize(at path: String) throws -> Int64 {
    let attrs = try FileManager.default.attributesOfItem(atPath: path)
    return attrs[.size] as? Int64 ?? 0
}

// ❌ BAD: String paths в массовых операциях
func totalSize(of directory: String) throws -> Int64 {
    let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
    return try contents.reduce(0) { total, name in
        let fullPath = (directory as NSString).appendingPathComponent(name)
        let attrs = try FileManager.default.attributesOfItem(atPath: fullPath)
        return total + (attrs[.size] as? Int64 ?? 0)
    }
}
```

## Good Example

```swift
// ✅ GOOD: URL + resourceValues - запрашиваем только нужные ключи
func fileSize(at url: URL) throws -> Int64 {
    let values = try url.resourceValues(forKeys: [.fileSizeKey])
    return Int64(values.fileSize ?? 0)
}

// ✅ GOOD: enumerator с prefetch нужных ключей
func totalSize(of directory: URL) throws -> Int64 {
    guard let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
        options: [.skipsHiddenFiles]
    ) else {
        return 0
    }

    var total: Int64 = 0
    for case let fileURL as URL in enumerator {
        let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        if values.isRegularFile == true {
            total += Int64(values.fileSize ?? 0)
        }
    }
    return total
}
```

## What to look for in code review

- `attributesOfItem(atPath:)` - замени на `url.resourceValues(forKeys:)`
- `NSString.appendingPathComponent` - замени на `URL.appending(path:)`
- `contentsOfDirectory(atPath:)` - замени на `enumerator(at:includingPropertiesForKeys:)`
- `FileManager` вызовы без `includingPropertiesForKeys`
- Работа с путями через `String` вместо `URL`
