# Unnecessary .clone()

## Applies to
- Функции, принимающие owned типы (String, Vec<T>, PathBuf) когда достаточно ссылки
- Вызовы .clone() для передачи данных в функции, которые не требуют ownership

## Why this is bad
- Аллокация памяти на каждый clone() - O(n) по размеру данных
- Лишняя нагрузка на аллокатор, увеличение давления на GC (drop)
- Скрывает реальные ownership requirements API
- Маскирует архитектурные проблемы - если clone нужен везде, значит ownership модель неправильная

## Bad Example

```rust
fn process_name(name: String) {
    println!("Processing: {}", name);
}

fn validate_email(email: String) -> bool {
    email.contains('@') && email.contains('.')
}

fn filter_items(items: Vec<Item>) -> Vec<Item> {
    items.into_iter().filter(|i| i.is_active).collect()
}

fn main() {
    let user_name = String::from("Alice");
    let email = String::from("alice@example.com");
    let items = vec![Item::new("a"), Item::new("b")];

    // Вынуждены клонировать, потому что функции забирают ownership
    process_name(user_name.clone());
    validate_email(email.clone());
    filter_items(items.clone());

    // А потом используем оригиналы дальше
    println!("User: {}, Email: {}", user_name, email);
    println!("Items count: {}", items.len());
}
```

## Good Example

```rust
fn process_name(name: &str) {
    println!("Processing: {}", name);
}

fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.')
}

fn filter_items(items: &[Item]) -> Vec<Item> {
    items.iter().filter(|i| i.is_active).cloned().collect()
}

fn main() {
    let user_name = String::from("Alice");
    let email = String::from("alice@example.com");
    let items = vec![Item::new("a"), Item::new("b")];

    // Передаем ссылки - zero-cost, без аллокаций
    process_name(&user_name);
    validate_email(&email);
    filter_items(&items);

    // Оригиналы доступны без clone
    println!("User: {}, Email: {}", user_name, email);
    println!("Items count: {}", items.len());
}
```

### Правило для параметров функций

| Owned тип | Borrowed альтернатива | Когда использовать owned |
|-----------|----------------------|--------------------------|
| `String` | `&str` | Только если функция сохраняет строку в struct |
| `Vec<T>` | `&[T]` | Только если функция забирает вектор навсегда |
| `PathBuf` | `&Path` | Только если функция сохраняет путь |
| `OsString` | `&OsStr` | Только если функция сохраняет строку |

## What to look for in code review
- `.clone()` перед вызовом функции - проверь, можно ли функцию переписать на ссылку
- Параметры типа `String`, `Vec<T>`, `PathBuf` - спроси "нужен ли ownership?"
- Цепочки `.clone().clone()` - явный признак проблемы
- `.to_string()` / `.to_owned()` для передачи в функцию - то же самое что clone
- `impl Into<String>` как параметр, когда функция только читает данные
