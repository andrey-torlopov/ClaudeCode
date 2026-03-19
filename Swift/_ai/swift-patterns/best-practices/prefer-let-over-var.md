# Prefer let over var

**Applies to:** Все переменные в production и тестовом коде

## Why this matters

Использование `let` по умолчанию:
- Иммутабельность предотвращает случайные мутации
- Компилятор может оптимизировать неизменяемые значения
- Проще рассуждать о потоке данных - значение не меняется после инициализации
- Помогает с thread safety - неизменяемые данные безопасны для concurrent доступа

## Bad Example

```swift
// ❌ BAD: var для значения, которое не меняется
func processUser(_ user: User) {
    var name = user.displayName  // никогда не переприсваивается
    var url = URL(string: user.avatarURL)  // никогда не переприсваивается
    print(name)
    loadAvatar(from: url)
}

// ❌ BAD: var в параметрах замыкания без мутации
let names = users.map { user -> String in
    var result = user.firstName + " " + user.lastName  // не мутируется далее
    return result
}
```

## Good Example

```swift
// ✅ GOOD: let для всего, что не требует мутации
func processUser(_ user: User) {
    let name = user.displayName
    let url = URL(string: user.avatarURL)
    print(name)
    loadAvatar(from: url)
}

// ✅ GOOD: var только когда значение действительно меняется
func buildFullName(parts: [String]) -> String {
    var result = ""           // мутируется в цикле - var оправдан
    for (index, part) in parts.enumerated() {
        if index > 0 { result += " " }
        result += part
    }
    return result
}

// ✅ GOOD: let в замыканиях
let names = users.map { user -> String in
    let result = user.firstName + " " + user.lastName
    return result
}
```

## What to look for in code review

- `var` без последующего переприсваивания - заменить на `let`
- Xcode warning "Variable was never mutated" - всегда исправлять
- `var` в guard/if let - проверить, нужна ли мутация
