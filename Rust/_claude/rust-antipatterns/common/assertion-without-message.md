# assert! без message

## Applies to
- `assert!()`, `assert_eq!()`, `assert_ne!()` без третьего аргумента-сообщения
- `debug_assert!()` без пояснения
- Любые assertion macros в тестах и production коде

## Why this is bad
- При падении теста сообщение "assertion failed: `left == right`" не объясняет что проверялось
- В CI логах `assert_eq!(a, b)` выводит значения, но не контекст "это проверка баланса после списания"
- При 50+ assertions в тесте невозможно понять какая проверка упала без message
- Сообщение документирует намерение - не что сравнивается, а зачем

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new("Alice", "alice@example.com");

        assert!(user.is_active());
        assert_eq!(user.name(), "Alice");
        assert_eq!(user.email(), "alice@example.com");
        assert_ne!(user.id(), Uuid::nil());
    }

    #[test]
    fn test_transfer() {
        let mut from = Account::with_balance(1000);
        let mut to = Account::with_balance(500);

        transfer(&mut from, &mut to, 200).unwrap();

        // При падении: "assertion failed: `(left == right)` left: `850`, right: `800`"
        // Какой из assert_eq! упал? Баланс отправителя или получателя?
        assert_eq!(from.balance(), 800);
        assert_eq!(to.balance(), 700);
        assert!(from.balance() >= 0);
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new("Alice", "alice@example.com");

        assert!(user.is_active(), "новый пользователь должен быть активен");
        assert_eq!(user.name(), "Alice", "имя должно совпадать с переданным");
        assert_eq!(user.email(), "alice@example.com", "email должен совпадать");
        assert_ne!(user.id(), Uuid::nil(), "id должен быть сгенерирован, не nil");
    }

    #[test]
    fn test_transfer() {
        let mut from = Account::with_balance(1000);
        let mut to = Account::with_balance(500);

        transfer(&mut from, &mut to, 200).unwrap();

        assert_eq!(
            from.balance(), 800,
            "баланс отправителя должен уменьшиться на сумму перевода (1000 - 200)"
        );
        assert_eq!(
            to.balance(), 700,
            "баланс получателя должен увеличиться на сумму перевода (500 + 200)"
        );
        assert!(
            from.balance() >= 0,
            "баланс отправителя не должен стать отрицательным"
        );
    }

    #[test]
    fn test_parsing() {
        let input = r#"{"status": "ok", "count": 42}"#;
        let result: ApiResponse = serde_json::from_str(input)
            .expect("фикстура должна быть валидным JSON");

        assert_eq!(
            result.status, "ok",
            "статус должен быть 'ok' для успешного ответа"
        );
        assert_eq!(
            result.count, 42,
            "count должен соответствовать значению в JSON"
        );
    }
}
```

### Шаблон сообщения

Хорошее сообщение отвечает на вопрос "что должно быть true и почему?":

```rust
// Плохо: дублирует код
assert_eq!(balance, 100, "balance should be 100");

// Хорошо: объясняет бизнес-смысл
assert_eq!(balance, 100, "баланс после списания 50 из 150 должен быть 100");
```

## What to look for in code review
- `assert!()`, `assert_eq!()`, `assert_ne!()` без строки-сообщения
- `debug_assert!()` без пояснения
- Сообщения, дублирующие код: `assert_eq!(x, 5, "x should be 5")` - не добавляет контекст
- `.unwrap()` в тестах вместо `.expect("описание")` - тоже assert без message
