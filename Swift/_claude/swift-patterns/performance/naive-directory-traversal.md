# Naive Directory Traversal

**Applies to:** FileManager, file enumeration, directory scanning

## Why this is bad

Рекурсивный обход директорий без оптимизации:
- Наивная реализация: ~3.3 секунды на типичном дереве файлов
- Оптимизированная: ~160 мс (ускорение в 20x)
- Каждый `attributesOfItem` - отдельный syscall
- Без prefetch ключей каждый `resourceValues` повторно идет в FS

## Bad Example

```swift
// ❌ BAD: Рекурсивный обход с attributesOfItem по каждому файлу
func calculateSize(at path: String) throws -> Int64 {
    let contents = try FileManager.default.subpathsOfDirectory(atPath: path)
    var total: Int64 = 0
    for subpath in contents {
        let fullPath = (path as NSString).appendingPathComponent(subpath)
        let attrs = try FileManager.default.attributesOfItem(atPath: fullPath)
        if let type = attrs[.type] as? FileAttributeType,
           type == .typeRegular {
            total += attrs[.size] as? Int64 ?? 0
        }
    }
    return total
}
```

## Good Example

```swift
// ✅ GOOD: enumerator с includingPropertiesForKeys для prefetch
func calculateSize(at directory: URL) throws -> Int64 {
    let keys: Set<URLResourceKey> = [.fileSizeKey, .isRegularFileKey]

    guard let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: Array(keys),
        options: [.skipsHiddenFiles],
        errorHandler: { url, error in
            // Логируем, но продолжаем обход
            false
        }
    ) else {
        return 0
    }

    var total: Int64 = 0
    for case let url as URL in enumerator {
        // resourceValues берутся из кэша благодаря includingPropertiesForKeys
        let values = try url.resourceValues(forKeys: keys)
        if values.isRegularFile == true {
            total += Int64(values.fileSize ?? 0)
        }
    }
    return total
}
```

## What to look for in code review

- `subpathsOfDirectory(atPath:)` + поштучный `attributesOfItem`
- `enumerator` без `includingPropertiesForKeys` (упущенный prefetch)
- `contentsOfDirectory` + рекурсия вручную вместо `enumerator`
- Обход больших директорий в main thread
