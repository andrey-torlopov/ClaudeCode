# Naming Conventions

**Applies to:** Весь Rust-код проекта

## Правила

- Типы, трейты, enum-ы: UpperCamelCase (`MyStruct`, `ErrorKind`)
- Функции, методы, переменные, модули: snake_case (`my_function`, `item_count`)
- Константы и статические переменные: SCREAMING_SNAKE_CASE (`MAX_BUFFER_SIZE`)
- Lifetime параметры: короткие lowercase (`'a`, `'de`)
- Трейты-способности: суффикс -able/-ible или описательное имя (`Serialize`, `Display`, `Iterator`)
- Булевые переменные: `is_enabled`, `has_content`, `should_reload`
- Конструкторы: `new()`, `with_capacity()`, `from_str()`
- Конверсии: `as_`, `to_`, `into_` по конвенциям Rust
- Fallible конструкторы: `try_new()`, `try_from()`

## Bad Example

```rust
// ❌ BAD: Неправильный нейминг
struct my_config {
    MaxRetries: u32,
    isEnabled: bool,
}

const max_size: usize = 1024;

fn BuildRequest() -> Request { todo!() }

impl my_config {
    fn Create() -> Self { todo!() }
    fn convert_to_string(&self) -> String { todo!() }
}
```

## Good Example

```rust
// ✅ GOOD: Rust naming conventions
struct MyConfig {
    max_retries: u32,
    is_enabled: bool,
}

const MAX_SIZE: usize = 1024;

fn build_request() -> Request { todo!() }

impl MyConfig {
    fn new() -> Self { todo!() }
    fn try_new(retries: u32) -> Result<Self, ConfigError> { todo!() }

    fn as_str(&self) -> &str { todo!() }
    fn to_string(&self) -> String { todo!() }
    fn into_inner(self) -> Inner { todo!() }
}

trait Configurable {
    fn configure(&mut self, opts: &Options);
}
```

## What to look for in code review

- camelCase или UpperCamelCase в именах функций/переменных/модулей
- snake_case в именах типов/трейтов/enum-ов
- Константы не в SCREAMING_SNAKE_CASE
- Конструкторы не по конвенции (`create()`, `build()` вместо `new()`)
- Конверсии без префикса `as_`/`to_`/`into_`
- Fallible конструкторы без префикса `try_`
- Булевые переменные без префикса `is_`/`has_`/`should_`
