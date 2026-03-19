# Статичные тестовые данные без рандомизации

## Applies to
- `const` / `static` с фиксированными тестовыми значениями
- Одни и те же значения от запуска к запуску - тесты не обнаруживают edge cases
- Фикстуры без вариативности

## Why this is bad
- Тесты проверяют только один конкретный сценарий - пропускают граничные случаи
- Фиксированные данные создают ложную уверенность в корректности
- При параллельных тестах с external storage (БД, файлы) - коллизии
- Не обнаруживают баги, зависящие от длины строки, знака числа, спецсимволов

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // Одни и те же значения во всех тестах, во всех запусках
    const TEST_EMAIL: &str = "user@test.com";
    const TEST_NAME: &str = "Test User";
    const TEST_AMOUNT: u64 = 1000;

    static TEST_TOKEN: &str = "abc123token";

    #[test]
    fn test_validate_email() {
        assert!(validate_email(TEST_EMAIL));
    }

    #[test]
    fn test_create_user() {
        let user = User::new(TEST_NAME, TEST_EMAIL);
        assert_eq!(user.name(), TEST_NAME);
    }

    #[test]
    fn test_process_payment() {
        let payment = Payment::new(TEST_AMOUNT, TEST_TOKEN);
        assert!(payment.process().is_ok());
        // Не обнаружит баг с amount = 0 или amount = u64::MAX
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;
    use rand::Rng;

    /// Генерирует уникальный суффикс для тестовых данных
    fn unique_suffix() -> String {
        Uuid::new_v4().to_string()[..8].to_owned()
    }

    /// Генератор тестовых email с уникальным ID
    fn gen_email() -> String {
        format!("test-{}@example.com", unique_suffix())
    }

    /// Генератор тестового имени
    fn gen_name() -> String {
        format!("Test User {}", unique_suffix())
    }

    /// Генератор суммы в допустимом диапазоне
    fn gen_amount() -> u64 {
        rand::thread_rng().gen_range(1..100_000)
    }

    /// Генератор токена
    fn gen_token() -> String {
        format!("test-token-{}", Uuid::new_v4())
    }

    #[test]
    fn test_validate_email() {
        let email = gen_email();
        assert!(
            validate_email(&email),
            "сгенерированный email должен быть валидным: {}",
            email
        );
    }

    #[test]
    fn test_validate_email_edge_cases() {
        // Граничные случаи тестируем явно
        let edge_cases = vec![
            ("a@b.co", true),
            ("", false),
            ("no-at-sign", false),
            ("spaces in@email.com", false),
            (&format!("{}@example.com", "x".repeat(64)), true),
        ];

        for (email, expected) in edge_cases {
            assert_eq!(
                validate_email(email),
                expected,
                "email '{}' должен быть valid={}",
                email,
                expected
            );
        }
    }

    #[test]
    fn test_create_user() {
        let name = gen_name();
        let email = gen_email();
        let user = User::new(&name, &email);
        assert_eq!(user.name(), name, "имя пользователя должно сохраниться");
    }

    #[test]
    fn test_process_payment() {
        let amount = gen_amount();
        let token = gen_token();
        let payment = Payment::new(amount, &token);
        assert!(
            payment.process().is_ok(),
            "платеж на сумму {} должен быть обработан",
            amount
        );
    }

    // Property-based подход: тестируем инвариант на случайных данных
    #[test]
    fn test_payment_amount_preserved() {
        for _ in 0..100 {
            let amount = gen_amount();
            let payment = Payment::new(amount, &gen_token());
            assert_eq!(
                payment.amount(), amount,
                "сумма платежа должна сохраниться"
            );
        }
    }
}
```

### Стратегии рандомизации

| Стратегия | Когда использовать |
|-----------|-------------------|
| `Uuid::new_v4()` | Уникальные строковые ID |
| `rand::thread_rng().gen_range(a..b)` | Числа в допустимом диапазоне |
| `format!("prefix-{}", unique_id)` | Строки с узнаваемым паттерном |
| `proptest` / `quickcheck` crate | Property-based testing |
| `fake` crate | Реалистичные данные (имена, адреса) |

## What to look for in code review
- `const` / `static` в тестовых модулях с конкретными значениями
- Одинаковые литералы во всех тестах файла
- Отсутствие тестов на граничные случаи (пустая строка, 0, MAX, спецсимволы)
- Тесты, которые проходят всегда - могут не тестировать ничего реального
- Отсутствие генераторов тестовых данных (test fixtures, factories)
