# Тесты зависят от порядка выполнения

## Applies to
- Тесты, которые работают только в определенном порядке
- Shared mutable state между тестами (глобальные переменные, файлы, БД)
- Тест B рассчитывает на side effects теста A

## Why this is bad
- `cargo test` запускает тесты в рандомном порядке внутри одного потока
- `cargo test -- --test-threads=N` запускает тесты параллельно - порядок непредсказуем
- Тест, зависящий от другого - flaky: работает локально, падает в CI (или наоборот)
- При добавлении нового теста старые могут начать падать без изменения кода

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Mutex;

    // Shared state между тестами - порядок зависимость
    static USERS: Mutex<Vec<User>> = Mutex::new(Vec::new());

    #[test]
    fn test_01_add_user() {
        let mut users = USERS.lock().unwrap();
        users.push(User::new("Alice"));
        assert_eq!(users.len(), 1);
    }

    #[test]
    fn test_02_find_user() {
        // Зависит от test_01 - если запустить отдельно, упадет
        let users = USERS.lock().unwrap();
        let found = users.iter().find(|u| u.name() == "Alice");
        assert!(found.is_some()); // Падает если test_01 еще не выполнился
    }

    #[test]
    fn test_03_remove_user() {
        // Зависит от test_01 и порядка выполнения
        let mut users = USERS.lock().unwrap();
        users.retain(|u| u.name() != "Alice");
        assert!(users.is_empty()); // Падает если test_01 не выполнился
    }

    // Тесты с файлами - конфликт при параллельном запуске
    #[test]
    fn test_write_config() {
        std::fs::write("/tmp/test-config.json", r#"{"key": "value"}"#).unwrap();
    }

    #[test]
    fn test_read_config() {
        // Зависит от test_write_config и одного /tmp/test-config.json
        let content = std::fs::read_to_string("/tmp/test-config.json").unwrap();
        assert!(content.contains("key"));
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    /// Каждый тест создает свою изолированную среду
    fn setup_store() -> UserStore {
        UserStore::new() // Чистое состояние
    }

    #[test]
    fn test_add_user() {
        let mut store = setup_store();
        store.add(User::new("Alice"));
        assert_eq!(store.count(), 1, "хранилище должно содержать 1 пользователя");
    }

    #[test]
    fn test_find_user() {
        let mut store = setup_store();
        // Тест сам создает нужные данные
        store.add(User::new("Alice"));

        let found = store.find_by_name("Alice");
        assert!(found.is_some(), "пользователь должен находиться по имени");
    }

    #[test]
    fn test_remove_user() {
        let mut store = setup_store();
        // Тест сам создает и удаляет
        store.add(User::new("Alice"));
        store.remove_by_name("Alice");
        assert!(store.is_empty(), "хранилище должно быть пустым после удаления");
    }

    // Изолированные файлы через tempdir
    #[test]
    fn test_write_and_read_config() {
        let dir = TempDir::new().unwrap();
        let config_path = dir.path().join("config.json");

        // Один тест - полный цикл
        std::fs::write(&config_path, r#"{"key": "value"}"#).unwrap();
        let content = std::fs::read_to_string(&config_path).unwrap();

        assert!(content.contains("key"), "конфиг должен содержать ключ");
        // TempDir автоматически удалится при drop
    }

    // Если нужна последовательность шагов - один тест с шагами
    #[test]
    fn test_user_lifecycle() {
        let mut store = setup_store();

        // Шаг 1: создание
        store.add(User::new("Alice"));
        assert_eq!(store.count(), 1, "после добавления должен быть 1 пользователь");

        // Шаг 2: поиск
        let user = store.find_by_name("Alice");
        assert!(user.is_some(), "пользователь должен находиться");

        // Шаг 3: удаление
        store.remove_by_name("Alice");
        assert!(store.is_empty(), "после удаления хранилище должно быть пустым");
    }
}
```

### Признаки order-dependent тестов

| Признак | Проблема |
|---------|----------|
| `static mut` или `static Mutex<Vec<>>` в тестах | Shared state |
| Нумерация тестов (`test_01_`, `test_02_`) | Зависимость от порядка |
| Один тест создает данные, другой их ищет | Неявная зависимость |
| Фиксированные пути к файлам (`/tmp/test.txt`) | Конфликт при параллельном запуске |
| Тест падает при `cargo test -- test_name` но проходит при `cargo test` | Order dependency |

## What to look for in code review
- `static` переменные в `#[cfg(test)]` модулях - shared state между тестами
- Тесты с нумерацией в именах (test_01, test_02) - подозрение на зависимость
- Фиксированные пути к файлам/БД в тестах - использовать `tempfile` crate
- Отсутствие setup функции - каждый тест должен создавать свою среду
- `#[serial]` из `serial_test` crate - допустимо, но лучше изолировать данные
