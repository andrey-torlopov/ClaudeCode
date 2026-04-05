# Prefer Value Types (struct > class)

**Applies to:** Модели данных, сервисы без identity, вспомогательные типы

## Why this matters

Предпочтение struct перед class:
- Value semantics - копирование при присваивании, нет shared mutable state
- Нет ARC overhead (retain/release) - быстрее аллокация и деаллокация
- Потокобезопасность из коробки - каждый поток работает со своей копией
- Автоматический Sendable для struct с Sendable полями
- Stack allocation для небольших struct - быстрее heap

## Bad Example

```swift
// ❌ BAD: class для простой модели данных
class UserProfile {
    var name: String
    var email: String
    var age: Int

    init(name: String, email: String, age: Int) {
        self.name = name
        self.email = email
        self.age = age
    }
}

// Проблема: shared reference
let profile = UserProfile(name: "Alice", email: "a@b.com", age: 30)
let copy = profile
copy.name = "Bob"       // profile.name тоже стал "Bob"!

// ❌ BAD: class для конфигурации
class APIConfig {
    var baseURL: URL
    var timeout: TimeInterval
    // ...
}
```

## Good Example

```swift
// ✅ GOOD: struct для модели данных
struct UserProfile: Sendable {
    let name: String
    let email: String
    let age: Int
}

// Безопасно: value semantics
let profile = UserProfile(name: "Alice", email: "a@b.com", age: 30)
var copy = profile
copy = UserProfile(name: "Bob", email: copy.email, age: copy.age)
// profile.name все еще "Alice"

// ✅ GOOD: struct для конфигурации
struct APIConfig: Sendable {
    let baseURL: URL
    let timeout: TimeInterval
}

// ✅ Исключение: class нужен для identity, наследования или reference semantics
final class DatabaseConnection {
    // Управляет ресурсом - identity важна
    private let handle: OpaquePointer

    deinit {
        sqlite3_close(handle)
    }
}
```

## What to look for in code review

- `class` для моделей данных (DTO, response, config) - заменить на `struct`
- `class` без `deinit`, наследования или reference identity - кандидат на struct
- Shared mutable state через class reference - потенциальный data race
