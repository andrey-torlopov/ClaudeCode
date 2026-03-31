# Rust Anti-Patterns Index

> Lazy Load Protocol: Читай файл ТОЛЬКО при обнаружении нарушения.
> Превентивная загрузка всех файлов ЗАПРЕЩЕНА (Token Economy).

## Naming Convention
{category}/{problem-name}.md

## Available Patterns

### common/ - Базовая гигиена кода
| Файл | Описание |
|------|----------|
| architecture.md | Не предлагай архитектуру без запроса, сохраняй существующую |
| assertion-without-message.md | assert! без message |
| hardcoded-test-data.md | Hardcoded данные в тестах |
| static-test-data.md | Статичные тестовые данные без рандомизации |
| no-order-dependent-tests.md | Тесты зависят друг от друга |
| no-cleanup-pattern.md | Нет cleanup после тестов |

### networking/ - HTTP и reqwest
| Файл | Описание |
|------|----------|
| dictionary-instead-of-model.md | HashMap<String, Value> вместо typed struct |
| missing-content-type-validation.md | Content-Type не валидируется |
| configure-http-client.md | reqwest::Client не настроен |
| wrap-infrastructure-errors.md | reqwest::Error не отличим от бизнес-ошибки |
| inline-http-calls.md | reqwest::get() inline без shared client |
| missing-security-headers.md | Нет проверки security headers |
| missing-error-body-check.md | Проверка только HTTP-кода без бизнес-ошибки |

### async/ - Tokio, async runtime, тестирование
| Файл | Описание |
|------|----------|
| async-test-pitfalls.md | tokio::spawn в sync #[test] |
| blocking-in-async.md | Blocking I/O в async runtime |
| no-hardcoded-timeouts.md | Magic numbers в таймаутах |
| no-shared-mutable-state.md | Shared mutable state без синхронизации |
| controlled-retries.md | Неконтролируемая retry-логика |

### security/ - Данные и безопасность
| Файл | Описание |
|------|----------|
| no-sensitive-data-logging.md | PII в логах, println!(), tracing |
| information-leakage-in-errors.md | Утечка данных через error Display |
| pii-in-code.md | PII в тестах и Mock-данных |

### ownership/ - Ownership, borrowing, unsafe
| Файл | Описание |
|------|----------|
| unnecessary-clone.md | .clone() вместо borrowing |
| unsafe-without-justification.md | unsafe без // SAFETY: |
| unwrap-in-production.md | .unwrap() в production коде |
| rc-cycles.md | Rc<RefCell<T>> циклические ссылки |
| string-vs-str.md | String где достаточно &str |

## Usage
При обнаружении проблемы:
1. Определи категорию
2. Прочитай .ai/patterns/{category}/{name}.md
3. Примени Good Example, процитируй (ref: {category}/{name}.md)
4. Если reference не найден - BLOCKER
