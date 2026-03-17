# Hardcoded данные в тестах

## Applies to
- Строковые литералы и числовые константы как тестовые данные
- Одни и те же захардкоженные значения во всех тестах
- ID, email, имена, заданные вручную без генерации

## Why this is bad
- Hardcoded данные могут случайно совпасть с production данными
- Одинаковые значения во всех тестах маскируют проблемы с уникальностью
- Тесты не выявляют edge cases, связанные с различными входными данными
- При параллельном запуске тестов одинаковые данные могут конфликтовать (например, в shared БД)

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_user() {
        let user = User::new("John", "john@test.com");
        assert_eq!(user.name(), "John");
    }

    #[test]
    fn test_update_user() {
        // Те же данные что и выше - при параллельном запуске с БД будет конфликт
        let user = User::new("John", "john@test.com");
        user.update_name("Jane");
        assert_eq!(user.name(), "Jane");
    }

    #[test]
    fn test_find_user_by_email() {
        let store = UserStore::new();
        store.add(User::new("John", "john@test.com"));

        // Тест пройдет, но не обнаружит проблему с case-sensitivity
        let found = store.find_by_email("john@test.com");
        assert!(found.is_some());
    }

    #[test]
    fn test_process_order() {
        let order = Order {
            id: 1,                    // Магическое число
            amount: 100,              // Магическое число
            user_id: 42,              // Магическое число
            description: "test order".to_owned(),
        };
        assert!(process_order(&order).is_ok());
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;

    /// Генерирует уникальное имя для тестового пользователя
    fn unique_name() -> String {
        format!("test-user-{}", &Uuid::new_v4().to_string()[..8])
    }

    /// Генерирует уникальный email на safe домене
    fn unique_email() -> String {
        format!("test-{}@example.com", &Uuid::new_v4().to_string()[..8])
    }

    /// Создает тестового пользователя с уникальными данными
    fn test_user() -> User {
        User::new(&unique_name(), &unique_email())
    }

    #[test]
    fn test_create_user() {
        let name = unique_name();
        let user = User::new(&name, &unique_email());
        assert_eq!(user.name(), name, "имя должно совпадать с переданным");
    }

    #[test]
    fn test_update_user() {
        let user = test_user();
        let new_name = unique_name();
        user.update_name(&new_name);
        assert_eq!(user.name(), new_name, "имя должно обновиться");
    }

    #[test]
    fn test_find_user_by_email() {
        let store = UserStore::new();
        let email = unique_email();
        store.add(User::new(&unique_name(), &email));

        let found = store.find_by_email(&email);
        assert!(found.is_some(), "пользователь должен находиться по email");
    }

    #[test]
    fn test_process_order() {
        let order = Order {
            id: rand::random(),
            amount: rand::thread_rng().gen_range(1..10_000),
            user_id: rand::random(),
            description: format!("test-order-{}", Uuid::new_v4()),
        };
        assert!(
            process_order(&order).is_ok(),
            "заказ с валидными данными должен быть обработан"
        );
    }

    // Для struct с множеством полей - Default + builder
    #[test]
    fn test_order_with_defaults() {
        let order = Order {
            amount: 500, // только значимое для теста поле
            ..Order::test_default()
        };
        assert!(process_order(&order).is_ok());
    }
}

// В отдельном test_helpers модуле
#[cfg(test)]
impl Order {
    fn test_default() -> Order {
        Order {
            id: rand::random(),
            amount: rand::thread_rng().gen_range(1..10_000),
            user_id: rand::random(),
            description: format!("test-order-{}", Uuid::new_v4()),
        }
    }
}
```

## What to look for in code review
- Одинаковые строковые литералы ("John", "test@test.com") в разных тестах
- Магические числа (1, 42, 100) без объяснения почему именно это значение
- `id: 1` - при параллельных тестах с БД будет конфликт
- Отсутствие helper-функций для генерации тестовых данных
- Захардкоженные UUID или timestamps
