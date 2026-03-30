# Rust Conventions

**Applies to:** Весь Rust-код проекта

## Правила

- Следуй Rust API Design Guidelines (https://rust-lang.github.io/api-guidelines/)
- Используй `let` по умолчанию, `let mut` только когда действительно нужна мутабельность
- Предпочитай ownership и borrowing вместо `Rc`/`Arc` где возможно
- Используй `&str` в параметрах функций вместо `String`, если не нужно владение
- Обрабатывай ошибки через `Result<T, E>` и оператор `?`, не через `.unwrap()` в продакшн-коде
- `.unwrap()` / `.expect()` допустимы в тестах и примерах
- Предпочитай `match` и `if let` для обработки `Option`/`Result`
- Используй `impl Trait` в аргументах и возвращаемых типах где уместно
- Используй derive-макросы (`#[derive(Debug, Clone, PartialEq)]`) вместо ручных реализаций
- Предпочитай итераторы и комбинаторы (`.map()`, `.filter()`, `.collect()`) вместо явных циклов где читаемость не страдает
- Используй `enum` для моделирования состояний и вариантов, `struct` для данных
- Группируй связанные методы в `impl` блоки
- Избегай `clone()` без необходимости - предпочитай ссылки
- Используй `Box<dyn Trait>` для trait objects, `impl Trait` для статического диспатча
- Для асинхронного кода предпочитай `tokio` или `async-std`
- Используй `Arc<Mutex<T>>` / `Arc<RwLock<T>>` для разделяемого состояния между потоками
- Предпочитай каналы (`mpsc`, `crossbeam`) вместо разделяемой памяти где возможно
- Помечай типы как `Send + Sync` где уместно
- Используй lifetime annotations явно только когда компилятор не может вывести их сам
- Избегай `'static` lifetime без необходимости
- Не используй `unsafe` без крайней необходимости и документирования причины

## Bad Example

```rust
// ❌ BAD: .unwrap() в продакшне, clone() без нужды, mut где не нужно, String вместо &str
fn process_user(name: String) -> String {
    let mut result = name.clone();
    let config = std::fs::read_to_string("config.toml").unwrap();
    let mut parsed: Config = toml::from_str(&config).unwrap();

    result.push_str(&parsed.suffix);
    result
}

fn find_item(items: Vec<Item>, id: u64) -> Item {
    let mut found = None;
    for item in &items {
        if item.id == id {
            found = Some(item.clone());
        }
    }
    found.unwrap()
}
```

## Good Example

```rust
// ✅ GOOD: Result + ?, &str, итераторы, без лишних clone/mut
fn process_user(name: &str, config: &Config) -> String {
    format!("{}{}", name, config.suffix)
}

fn find_item(items: &[Item], id: u64) -> Option<&Item> {
    items.iter().find(|item| item.id == id)
}

async fn fetch_data(client: &Client, url: &str) -> Result<Response, AppError> {
    let response = client.get(url).send().await?;
    if !response.status().is_success() {
        return Err(AppError::HttpError(response.status()));
    }
    Ok(response)
}
```

## What to look for in code review

- `.unwrap()` в продакшн-коде (не тесты)
- `let mut` где переменная не мутируется
- `clone()` без обоснования
- `String` в параметрах где достаточно `&str`
- `Rc`/`Arc` где хватает ownership/borrowing
- Явные циклы вместо итераторов/комбинаторов
- Ручные реализации `Debug`/`Clone`/`PartialEq` вместо derive
- `unsafe` без комментария с обоснованием
- `'static` без необходимости
- Разделяемая память вместо каналов для межпоточного обмена
