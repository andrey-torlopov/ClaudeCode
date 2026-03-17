# PII в тестах и Mock-данных

## Applies to
- Реальные email, телефоны, имена в тестовых данных
- Захардкоженные паспортные данные, ИНН, СНИЛС в mock-ах
- Production данные скопированные в тесты для воспроизведения бага

## Why this is bad
- PII в коде попадает в git историю навсегда (даже после удаления)
- Нарушает GDPR Article 5 - принцип минимизации данных
- При утечке репозитория (open source, leak) - утечка реальных данных
- Затрудняет compliance audit - нужно сканировать всю git историю

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;

    fn test_user() -> User {
        User {
            name: "Иван Петров".to_owned(),          // реальное имя
            email: "ivan.petrov@gmail.com".to_owned(), // реальный email
            phone: "+79161234567".to_owned(),           // реальный телефон
            inn: "770123456789".to_owned(),             // реальный ИНН
        }
    }

    #[test]
    fn test_send_notification() {
        let user = test_user();
        // Тест отправит на реальный email при ошибке в mock
        let result = send_notification(&user);
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_passport() {
        // Реальные паспортные данные в тесте
        let passport = Passport {
            series: "4510".to_owned(),
            number: "123456".to_owned(),
            issued_by: "ОВД района Тверской".to_owned(),
        };
        assert!(validate_passport(&passport).is_ok());
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;

    /// Генерирует тестового пользователя с синтетическими данными
    fn fake_user() -> User {
        let id = Uuid::new_v4().to_string()[..8].to_owned();
        User {
            name: format!("Test User {}", id),
            email: format!("test-{}@example.com", id), // example.com - RFC 2606
            phone: format!("+7000{:07}", rand::random::<u32>() % 10_000_000),
            inn: "000000000000".to_owned(), // нулевой - невалидный по контрольной сумме
        }
    }

    /// Генерирует тестовый паспорт с невалидными данными
    fn fake_passport() -> Passport {
        Passport {
            series: "0000".to_owned(),
            number: "000000".to_owned(),
            issued_by: "Test Department".to_owned(),
        }
    }

    #[test]
    fn test_send_notification() {
        let user = fake_user();
        let result = send_notification(&user);
        assert!(result.is_ok(), "уведомление должно быть отправлено");
    }

    #[test]
    fn test_validate_passport() {
        let passport = fake_passport();
        assert!(validate_passport(&passport).is_ok());
    }
}
```

### Таблица безопасных замен

| Тип данных | Плохо | Хорошо |
|-----------|-------|--------|
| Email | ivan@gmail.com | test-{uuid}@example.com |
| Телефон | +79161234567 | +7000XXXXXXX |
| Имя | Иван Петров | Test User {id} |
| ИНН | 770123456789 | 000000000000 |
| IP адрес | 192.168.1.100 | 192.0.2.1 (TEST-NET RFC 5737) |
| Домен | company.ru | example.com (RFC 2606) |
| UUID (production) | реальный UUID из БД | Uuid::new_v4() |
| Адрес | ул. Тверская, д. 1 | Test Street, 1 |

### Обнаружение в коде

```bash
# Поиск потенциальных PII в .rs файлах
grep -rn --include="*.rs" -E \
  '(\+7[0-9]{10}|[a-zA-Z0-9._%+-]+@(?!example\.com)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|[0-9]{12})' \
  src/ tests/
```

## What to look for in code review
- Email адреса не на `@example.com` / `@example.org` / `@test.com` в тестовых данных
- Телефоны, похожие на реальные (начинаются с +7, +1, +44)
- Строки, похожие на ФИО, с пробелом между кириллическими словами
- Константы с 10-12 цифрами подряд (ИНН, СНИЛС, паспорт)
- Комментарии типа "скопировано из production" или "данные от клиента"
- IP адреса вне TEST-NET диапазонов (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)
