# Naive Disk Space Check

**Applies to:** FileManager, disk space, app startup

## Why this is bad

Повторное вычисление свободного места без кэширования:
- `attributesOfFileSystem` занимает 400-850 мс за вызов
- На запуске может вызываться 3-4 раза разными компонентами
- Суммарно это 1-3 секунды потерянного времени старта
- Значение не меняется за секунды - нет смысла пересчитывать

## Bad Example

```swift
// ❌ BAD: Каждый вызов идет в файловую систему
final class StorageManager {
    func freeSpace() throws -> Int64 {
        let attrs = try FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        )
        return attrs[.systemFreeSize] as? Int64 ?? 0
    }
}

// Вызывается на каждом экране
let free = try storageManager.freeSpace() // 400-850 мс
```

## Good Example

```swift
// ✅ GOOD: Кэширование с TTL через actor
actor DiskSpaceService {
    private var cachedFreeSpace: Int64?
    private var lastCheck: Date = .distantPast
    private let ttl: TimeInterval = 300 // 5 минут

    func freeSpace() throws -> Int64 {
        if let cached = cachedFreeSpace,
           Date().timeIntervalSince(lastCheck) < ttl {
            return cached
        }

        let url = URL(fileURLWithPath: NSHomeDirectory())
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        let free = values.volumeAvailableCapacityForImportantUsage ?? 0

        cachedFreeSpace = free
        lastCheck = Date()
        return free
    }

    func invalidate() {
        cachedFreeSpace = nil
    }
}
```

## What to look for in code review

- `attributesOfFileSystem(forPath:)` без кэширования результата
- Множественные вызовы проверки свободного места на запуске
- `NSHomeDirectory()` + `attributesOfItem(atPath:)` для получения размера
- Отсутствие TTL/мемоизации для дисковых метрик
