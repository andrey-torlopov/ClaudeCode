# Swift/iOS Patterns Index

> Каждый файл содержит Bad Example (как не надо) и Good Example (как надо).
> Используется и при генерации нового кода, и при code review.

> **Lazy Load Protocol:** Читай файл ТОЛЬКО при обнаружении нарушения или при генерации кода в соответствующей области.
> Превентивная загрузка всех файлов ЗАПРЕЩЕНА (Token Economy).

## Naming Convention

`{category}/{pattern-name}.md` - описание паттерна с Bad/Good Example.

## Available Patterns

### common/ - Базовая гигиена кода

| Файл | Паттерн |
|------|---------|
| `common/architecture.md` | Не предлагай архитектуру без запроса, сохраняй существующую |
| `common/assertion-without-message.md` | XCTAssert без message |
| `common/hardcoded-test-data.md` | Hardcoded данные в тестах |
| `common/no-abstraction-layer.md` | Прямые URLSession-вызовы в тестах |
| `common/static-test-data.md` | Статичные тестовые данные без рандомизации |
| `common/no-order-dependent-tests.md` | Тесты зависят друг от друга |
| `common/no-cleanup-pattern.md` | Нет cleanup после тестов |

### networking/ - Специфика HTTP и URLSession

| Файл | Паттерн |
|------|---------|
| `networking/dictionary-instead-of-model.md` | `[String: Any]` вместо Codable |
| `networking/missing-content-type-validation.md` | Content-Type не валидируется |
| `networking/configure-urlsession.md` | URLSession не настроен (дефолтные таймауты) |
| `networking/wrap-infrastructure-errors.md` | URLError не отличим от бизнес-ошибки |
| `networking/inline-urlsession-calls.md` | URLSession.shared inline в коде |
| `networking/missing-security-headers.md` | Нет проверки security headers |
| `networking/missing-error-body-check.md` | Проверка только HTTP-кода без бизнес-ошибки |

### platform/ - Swift Concurrency + XCTest

| Файл | Паттерн |
|------|---------|
| `platform/async-test-pitfalls.md` | `Task {}` в sync тестах, legacy XCTestExpectation для async |
| `platform/xctest-setup-crashes.md` | Force unwrap / try! в property init XCTestCase |
| `platform/flaky-sleep-tests.md` | `Thread.sleep()` / `Task.sleep()` вместо polling |
| `platform/no-hardcoded-timeouts.md` | Magic numbers в таймаутах |
| `platform/no-shared-mutable-state.md` | Shared mutable state, отсутствие actor/Sendable |
| `platform/controlled-retries.md` | Неконтролируемая retry-логика |

### performance/ - Производительность (источник: T-Bank perf research)

| Файл | Паттерн |
|------|---------|
| `performance/naive-disk-space-check.md` | Мемоизация disk space с TTL вместо повторных вызовов |
| `performance/nsdictionary-file-attributes.md` | URL `resourceValues(forKeys:)` вместо `attributesOfItem(atPath:)` |
| `performance/naive-directory-traversal.md` | `enumerator(at:includingPropertiesForKeys:)` вместо поштучного обхода |
| `performance/string-ops-in-hot-path.md` | `[UInt8]`/`Data` вместо String в горячем пути |
| `performance/string-search-in-collection.md` | `Set`/`Dictionary` вместо поиска подстроки в большой строке |
| `performance/nsstring-swift-bridging.md` | Не чередовать NSString/String в tight loop |
| `performance/protocol-cast-over-class-cast.md` | Каст к классу вместо каста к протоколу в горячем пути |
| `performance/string-describing-reflection.md` | `_typeName`/`ObjectIdentifier` вместо `String(describing:)` |
| `performance/expensive-generic-constants.md` | Замыкания вместо дженерик-констант в массовых регистрациях |
| `performance/multiple-protocol-conformance.md` | Один протокол вместо множества мелких для UI-компонентов |

### security/ - Данные и безопасность

| Файл | Паттерн |
|------|---------|
| `security/no-sensitive-data-logging.md` | PII в логах, print(), os_log |
| `security/information-leakage-in-errors.md` | Утечка данных через error.localizedDescription |
| `security/pii-in-code.md` | PII в тестах, Previews и Mock-данных |

### best-practices/ - Общие рекомендации Swift

| Файл | Паттерн |
|------|---------|
| `best-practices/prefer-final-class.md` | Помечай классы `final` если наследование не планируется |
| `best-practices/prefer-let-over-var.md` | `let` по умолчанию, `var` только при необходимости мутации |
| `best-practices/prefer-value-types.md` | `struct` > `class`, value semantics по умолчанию |

## Маппинг QA (Kotlin) -> Swift

| QA (Kotlin/JUnit) | Swift/iOS | Изменения |
|---|---|---|
| `HttpClient` / Ktor | `URLSession` / `URLRequest` | API полностью другой |
| `@Test` / JUnit 5 | `func test*()` / XCTest | Lifecycle: `setUp()`/`tearDown()` вместо `@BeforeEach`/`@AfterEach` |
| `runBlocking {}` | `async throws` test methods | Нативная поддержка в Xcode 13+ |
| `Awaitility` | `XCTestExpectation` / custom polling | Нет прямого аналога, нужен helper |
| `@Serializable` (Kotlin) | `Codable` (Swift) | `CodingKeys` вместо `@SerialName` |
| `companion object` | `static` properties | `actor` для thread-safe state |
| `lateinit var` | `var ... : T!` в XCTestCase | Опасен при init crash |
| Allure steps | `XCTContext.runActivity` | Менее развит, но аналогичен |
| `@BeforeAll` | `override class func setUp()` | Вызывается один раз для класса |

## Usage (для разработчика)

При обнаружении проблемы или написании нового кода:
1. Определи категорию: common / networking / platform / performance / security / best-practices
2. Прочитай `.ai/patterns/{category}/{name}.md` - примени Good Example - процитируй `(ref: {category}/{name}.md)`
3. Если reference не найден - BLOCKER, не угадывай fix

## Usage (для code review)

```bash
# Сканируй по категории
ls .ai/patterns/performance/

# Grep в проекте
grep -rn "URLSession.shared\|[String: Any]\|Thread.sleep\|attributesOfItem" --include="*.swift" Sources/ Tests/

# Прочитай файл при match
cat .ai/patterns/performance/naive-disk-space-check.md
```
