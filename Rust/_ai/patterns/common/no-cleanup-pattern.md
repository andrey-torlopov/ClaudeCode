# Нет cleanup после тестов

## Applies to
- Тесты, создающие файлы, директории, записи в БД без удаления
- Отсутствие teardown / cleanup логики
- Ресурсы, утекающие при панике теста (assert! прерывает выполнение)

## Why this is bad
- Мусор накапливается в /tmp, тестовых БД, файловой системе
- Следующий запуск тестов может упасть из-за артефактов предыдущего
- В CI - исчерпание диска при частых запусках
- При панике (assert failure) код после assert не выполняется - cleanup пропускается

## Bad Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_export_report() {
        // Создаем файл, но не удаляем
        let path = "/tmp/test-report.csv";
        export_report(path).unwrap();

        let content = fs::read_to_string(path).unwrap();
        assert!(content.contains("header")); // Если упадет - файл останется

        // Cleanup не вызовется при панике
        fs::remove_file(path).unwrap();
    }

    #[test]
    fn test_database_operations() {
        let db = Database::connect("test.db").unwrap();

        // Записи в БД, но нет cleanup
        db.insert("key1", "value1").unwrap();
        db.insert("key2", "value2").unwrap();

        assert_eq!(db.get("key1").unwrap(), "value1");
        // key1 и key2 остаются в БД навсегда
        // При следующем запуске: "key already exists"
    }

    #[test]
    fn test_create_temp_directory() {
        let dir = "/tmp/test-work-dir";
        fs::create_dir_all(dir).unwrap();

        // ... тест ...

        // Забыли удалить директорию
    }
}
```

## Good Example

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::{TempDir, NamedTempFile};

    // tempfile::TempDir - автоматический cleanup через Drop
    #[test]
    fn test_export_report() {
        let dir = TempDir::new().expect("не удалось создать temp dir");
        let path = dir.path().join("report.csv");

        export_report(path.to_str().unwrap()).unwrap();

        let content = std::fs::read_to_string(&path).unwrap();
        assert!(content.contains("header"), "отчет должен содержать заголовок");

        // TempDir удалится автоматически при выходе из scope
        // Даже если assert выше упадет!
    }

    // NamedTempFile - для одного файла
    #[test]
    fn test_process_file() {
        let mut temp_file = NamedTempFile::new().expect("не удалось создать temp file");
        std::io::Write::write_all(&mut temp_file, b"test data").unwrap();

        let result = process_file(temp_file.path());
        assert!(result.is_ok(), "обработка файла должна завершиться успешно");
        // Файл удалится при drop
    }

    // Database cleanup через Drop trait
    struct TestDb {
        db: Database,
        keys: Vec<String>,
    }

    impl TestDb {
        fn new() -> TestDb {
            TestDb {
                db: Database::connect("test.db").unwrap(),
                keys: Vec::new(),
            }
        }

        fn insert(&mut self, key: &str, value: &str) {
            self.db.insert(key, value).unwrap();
            self.keys.push(key.to_owned());
        }
    }

    impl Drop for TestDb {
        fn drop(&mut self) {
            for key in &self.keys {
                let _ = self.db.delete(key); // Игнорируем ошибки в cleanup
            }
        }
    }

    #[test]
    fn test_database_operations() {
        let mut db = TestDb::new();

        db.insert("key1", "value1");
        db.insert("key2", "value2");

        assert_eq!(
            db.db.get("key1").unwrap(), "value1",
            "значение должно сохраниться"
        );
        // Drop автоматически удалит key1 и key2, даже при панике
    }

    // scopeguard для произвольного cleanup
    #[test]
    fn test_with_scopeguard() {
        use scopeguard::defer;

        let socket_path = "/tmp/test-socket.sock";
        create_unix_socket(socket_path).unwrap();

        // defer! выполнится при выходе из scope, даже при панике
        defer! {
            let _ = std::fs::remove_file(socket_path);
        }

        assert!(
            std::path::Path::new(socket_path).exists(),
            "сокет должен быть создан"
        );
        // cleanup через defer!
    }
}
```

### Инструменты cleanup

| Инструмент | Назначение | Гарантия при панике |
|-----------|-----------|-------------------|
| `tempfile::TempDir` | Временная директория | Да (Drop) |
| `tempfile::NamedTempFile` | Временный файл | Да (Drop) |
| `impl Drop for TestWrapper` | Кастомный cleanup | Да (Drop) |
| `scopeguard::defer!` | Произвольный cleanup код | Да |
| Ручной `fs::remove_file()` | Удаление файла | Нет - пропускается при панике |

## What to look for in code review
- Файловые операции в тестах без `tempfile` crate
- Фиксированные пути (`/tmp/test-*`) - использовать `TempDir`
- Cleanup код после `assert!` - не выполнится при панике
- Запись в БД без cleanup или transaction rollback
- Отсутствие `Drop` impl для тестовых wrapper-ов, управляющих ресурсами
- `std::fs::create_dir_all` в тестах без парного `std::fs::remove_dir_all`
