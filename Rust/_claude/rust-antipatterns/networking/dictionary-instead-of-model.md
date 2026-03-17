# HashMap<String, Value> вместо typed struct

## Applies to
- `HashMap<String, serde_json::Value>` для парсинга API ответов
- `serde_json::Value` без десериализации в конкретный тип
- Ручное извлечение полей через `value["key"]` или `value.get("key")`

## Why this is bad
- Нет compile-time проверки имен полей - опечатка обнаружится только в runtime
- Каждое обращение к полю требует проверки типа и наличия
- Рефакторинг API невозможно отследить - компилятор не поможет
- Потеря документации - struct с полями самодокументируется, HashMap - нет
- Производительность: serde_json::Value аллоцирует каждое значение отдельно

## Bad Example

```rust
use std::collections::HashMap;
use serde_json::Value;

async fn fetch_user(client: &reqwest::Client, id: u64) -> Result<HashMap<String, Value>, Error> {
    let response = client
        .get(format!("https://api.example.com/users/{}", id))
        .send()
        .await?;

    let data: HashMap<String, Value> = response.json().await?;
    Ok(data)
}

fn process_user(data: &HashMap<String, Value>) {
    // Опечатка в "emial" - обнаружится только в runtime
    let email = data.get("emial").and_then(|v| v.as_str()).unwrap_or("");

    // Нужна ручная проверка типа каждого поля
    let age = data.get("age").and_then(|v| v.as_u64()).unwrap_or(0);

    // Вложенные структуры - еще хуже
    let city = data
        .get("address")
        .and_then(|v| v.get("city"))
        .and_then(|v| v.as_str())
        .unwrap_or("unknown");

    println!("User: {}, age: {}, city: {}", email, age, city);
}
```

## Good Example

```rust
use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct User {
    email: String,
    age: u32,
    address: Address,
    #[serde(rename = "display_name")]
    display_name: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Address {
    city: String,
    #[serde(default)]
    zip_code: Option<String>,
}

async fn fetch_user(client: &reqwest::Client, id: u64) -> Result<User, Error> {
    let user: User = client
        .get(format!("https://api.example.com/users/{}", id))
        .send()
        .await?
        .json()
        .await?;

    Ok(user)
}

fn process_user(user: &User) {
    // Compile-time гарантии: поля существуют, типы проверены
    println!(
        "User: {}, age: {}, city: {}",
        user.email, user.age, user.address.city
    );

    // Option обрабатывается явно
    if let Some(name) = &user.display_name {
        println!("Display name: {}", name);
    }
}
```

### Полезные serde атрибуты

| Атрибут | Назначение |
|---------|-----------|
| `#[serde(rename_all = "camelCase")]` | Маппинг camelCase JSON -> snake_case Rust |
| `#[serde(rename = "type")]` | Маппинг одного поля (например зарезервированного слова) |
| `#[serde(default)]` | Значение по умолчанию если поле отсутствует |
| `#[serde(skip_serializing_if = "Option::is_none")]` | Пропустить None при сериализации |
| `#[serde(flatten)]` | Встроить вложенную struct в parent |
| `#[serde(deny_unknown_fields)]` | Ошибка при неизвестных полях (strict mode) |

## What to look for in code review
- `HashMap<String, Value>` или `serde_json::Value` как тип ответа API
- `value["key"]` или `value.get("key")` цепочки - признак untyped доступа
- `.as_str()`, `.as_u64()`, `.as_bool()` - ручная проверка типов вместо serde
- Строковые литералы с именами полей API разбросаны по коду
- `serde_json::from_str::<Value>(...)` вместо `serde_json::from_str::<MyStruct>(...)`
