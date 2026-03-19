# String где достаточно &str

## Applies to
- Параметры функций, принимающие `String` когда функция только читает данные
- Аналогично: `Vec<T>` вместо `&[T]`, `PathBuf` вместо `&Path`
- Возвращаемые типы, где можно вернуть `&str` из существующих данных

## Why this is bad
- `String` требует ownership - вызывающий код вынужден отдать или клонировать строку
- `&str` принимает и `String` (через deref coercion), и `&str`, и строковые литералы
- Каждый `String` - аллокация на куче, `&str` - zero-cost указатель + длина
- Нарушает принцип "borrow when possible, own when necessary"

## Bad Example

```rust
fn greet(name: String) {
    println!("Привет, {}!", name);
}

fn contains_keyword(text: String, keyword: String) -> bool {
    text.contains(&keyword)
}

fn build_path(base: PathBuf, filename: String) -> PathBuf {
    base.join(filename)
}

fn process_items(items: Vec<u32>) -> u32 {
    items.iter().sum()
}

// Вызывающий код вынужден клонировать:
fn main() {
    let name = String::from("Alice");
    greet(name.clone()); // clone, потому что name нужен дальше
    println!("{}", name);
}
```

## Good Example

```rust
fn greet(name: &str) {
    println!("Привет, {}!", name);
}

fn contains_keyword(text: &str, keyword: &str) -> bool {
    text.contains(keyword)
}

fn build_path(base: &Path, filename: &str) -> PathBuf {
    base.join(filename)
}

fn process_items(items: &[u32]) -> u32 {
    items.iter().sum()
}

// Вызывающий код - без clone:
fn main() {
    let name = String::from("Alice");
    greet(&name); // deref coercion: &String -> &str
    greet("Bob"); // литерал тоже работает
    println!("{}", name); // name не перемещен
}
```

### Таблица соответствий

| Owned тип | Borrowed тип | Когда owned оправдан |
|-----------|-------------|---------------------|
| `String` | `&str` | Функция сохраняет строку в struct field |
| `Vec<T>` | `&[T]` | Функция забирает владение элементами |
| `PathBuf` | `&Path` | Функция сохраняет путь для дальнейшего использования |
| `OsString` | `&OsStr` | Функция сохраняет OS-строку |
| `CString` | `&CStr` | Функция сохраняет C-строку |
| `Box<[T]>` | `&[T]` | Функция забирает ownership на heap slice |

### Когда String в параметре оправдан

```rust
struct User {
    name: String, // owned field
}

impl User {
    // OK: функция сохраняет строку - нужен ownership
    fn new(name: String) -> User {
        User { name }
    }

    // Альтернатива через Into<String> - гибче:
    fn with_name(name: impl Into<String>) -> User {
        User { name: name.into() }
    }
}
```

## What to look for in code review
- Параметр `String` в функции, которая не сохраняет строку
- Параметр `Vec<T>` в функции, которая только итерирует
- Параметр `PathBuf` в функции, которая только читает путь
- `.to_string()` / `.to_owned()` / `.clone()` на месте вызова - сигнал, что API слишком жадный
- `impl Into<String>` в параметре, когда `&str` достаточно (Into тоже вызовет аллокацию)
