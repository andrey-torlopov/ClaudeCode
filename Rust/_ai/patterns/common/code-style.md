# Code Style

**Applies to:** Весь Rust-код проекта, комментарии, документация

## Правила

- Не используй "—" (длинное тире) в комментариях, используй "-"
- Не добавляй комментарии к очевидному коду
- Не добавляй doc-комментарии (`///`) без запроса
- Не добавляй `#[cfg(test)]` модули без запроса
- Не оборачивай код в `#[cfg(debug_assertions)]` без запроса
- Используй `todo!()` и `unimplemented!()` как плейсхолдеры, не оставляй пустые блоки

## Bad Example

```rust
// ❌ BAD: очевидные комментарии, длинное тире, пустые блоки, незапрошенные doc/cfg
/// Структура пользователя — хранит данные
#[derive(Debug)]
struct User {
    // Имя пользователя
    name: String,
    // Возраст пользователя
    age: u32,
}

impl User {
    /// Создаёт нового пользователя
    fn new(name: String, age: u32) -> Self {
        Self { name, age }
    }

    fn validate(&self) -> bool {
        // TODO
        false
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // тесты добавлены "на всякий случай"
}

#[cfg(debug_assertions)]
fn debug_dump(user: &User) {
    println!("{:?}", user);
}
```

## Good Example

```rust
// ✅ GOOD: без лишних комментариев, плейсхолдеры через todo!()
#[derive(Debug)]
struct User {
    name: String,
    age: u32,
}

impl User {
    fn new(name: String, age: u32) -> Self {
        Self { name, age }
    }

    fn validate(&self) -> bool {
        todo!("реализовать валидацию возраста и формата имени")
    }
}
```

## What to look for in code review

- "—" (длинное тире) в комментариях вместо "-"
- Комментарии, дублирующие код: `// Создаём переменную`, `// Возвращаем результат`
- `///` doc-комментарии, которые не были запрошены
- `#[cfg(test)]` модули, добавленные без запроса
- `#[cfg(debug_assertions)]` обёртки без запроса
- Пустые блоки `{}` или `false`/`0` вместо `todo!()`/`unimplemented!()`
