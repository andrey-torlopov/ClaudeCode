# Prefer final class

**Applies to:** Все классы в production и тестовом коде

## Why this matters

Пометка `final` для классов, которые не предназначены для наследования:
- Компилятор применяет static dispatch вместо dynamic dispatch - быстрее вызов методов
- Явно выражает намерение: "этот класс не для наследования"
- Предотвращает случайное наследование и хрупкие иерархии
- Совместимо с Sendable (final class проще сделать Sendable)

## Bad Example

```swift
// ❌ BAD: Класс без final - неясно, планируется ли наследование
class NetworkService {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch(_ url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)
        return data
    }
}

// ❌ BAD: ViewModel без final - dynamic dispatch на каждый вызов
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""

    func load() async { /* ... */ }
}
```

## Good Example

```swift
// ✅ GOOD: final - явное намерение, static dispatch
final class NetworkService {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch(_ url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)
        return data
    }
}

// ✅ GOOD: final + Sendable
final class ProfileViewModel: ObservableObject, Sendable {
    @Published var name: String = ""

    func load() async { /* ... */ }
}

// ✅ Исключение: класс НАМЕРЕННО создан для наследования
class BaseCoordinator {
    func start() {
        // Override point для наследников
    }
}
```

## What to look for in code review

- `class` без `final` - спросить: планируется ли наследование?
- Если наследников нет и не планируется - добавить `final`
- `open class` в модуле без внешних потребителей
