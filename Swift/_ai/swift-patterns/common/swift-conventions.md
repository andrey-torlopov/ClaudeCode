# Swift Conventions

**Applies to:** Весь Swift-код проекта

## Правила

- Следуй Swift API Design Guidelines
- Используй `let` вместо `var` где возможно
- Предпочитай value types (struct, enum) над reference types (class), если нет явной необходимости
- enum используем только если планируется проверка перечислений. Иначе используем struct
- Используй `async/await` вместо completion handlers
- Используй Modern concurrency вместо NSLog, Semaphore прочих механизмов
- Используй structured concurrency (TaskGroup, async let) вместо неструктурированных Task {}
- Помечай типы как `Sendable` где возможно
- Используй `@MainActor` для UI-кода, не `DispatchQueue.main`
- Обрабатывай ошибки через `throws` / `Result`, не через опционалы для ошибочных состояний
- Используй `guard` для раннего выхода
- В Task если используем [weak self], то не усиливаем сразу self, а только перед первым его использованием
- Предпочитай `[weak self]` в escaping closures для предотвращения retain cycles
- Не используй force unwrap (`!`) кроме IBOutlet и тестов
- Не используй `Any` / `AnyObject` без крайней необходимости - предпочитай протоколы и дженерики
- Стараемся не использовать Task.detached()
- Стараемся не использовать .init, а явное указание класса/структуры

## Bad Example

```swift
// ❌ BAD: completion handler, force unwrap, var, DispatchQueue
class DataManager {
    var result: String? = nil

    func loadData(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let data = self.fetchFromNetwork()
            DispatchQueue.main.async {
                self.result = data
                completion(data)
            }
        }
    }

    func process() {
        let value = result!
        print(value)
    }
}
```

## Good Example

```swift
// ✅ GOOD: async/await, @MainActor, let, guard, Sendable
@MainActor
final class DataManager: Sendable {
    let repository: DataRepository

    func loadData() async throws -> String {
        let data = try await repository.fetch()
        return data
    }

    func process() throws {
        guard let value = optionalResult else { return }
        print(value)
    }
}
```

## What to look for in code review

- `var` где можно использовать `let`
- `class` где достаточно `struct`
- completion handlers вместо async/await
- `DispatchQueue.main` вместо `@MainActor`
- `Task {}` вместо structured concurrency (TaskGroup, async let)
- `Task.detached()` без явной необходимости
- Force unwrap (`!`) вне IBOutlet/тестов
- `Any` / `AnyObject` вместо протоколов/дженериков
- `.init(...)` вместо явного `TypeName(...)`
- Опционалы для ошибочных состояний вместо throws/Result
