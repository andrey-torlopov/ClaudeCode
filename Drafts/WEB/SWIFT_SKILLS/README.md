# Swift Skill Pack for Claude Code

Набор скиллов, агентов, команд и антипаттернов для AI-assisted разработки iOS/Swift проектов в Claude Code.

## Что внутри

### Скиллы (9 шт.)

| Скилл | Назначение |
|-------|------------|
| `/repo-scout` | Разведка iOS-репозитория: структура, зависимости, архитектура, тесты |
| `/init-project` | Генерация CLAUDE.md для нового Swift-проекта |
| `/init-skill` | Интерактивное создание новых скиллов |
| `/swift-review` | Глубокий code review: memory safety, concurrency, conventions |
| `/refactor-plan` | Планирование рефакторинга с приоритетами и оценкой рисков |
| `/dependency-check` | Анализ SPM-зависимостей на актуальность и конфликты |
| `/doc-lint` | Аудит документации: размер, структура, дубликаты, SSOT |
| `/skill-audit` | Аудит AI-скиллов на раздутость и вредные паттерны |
| `/update-ai-setup` | Синхронизация реестра AI-конфигурации |

### Агенты (2 шт.)

| Агент | Роль |
|-------|------|
| **Developer** (`agents/sdet.md`) | Кодогенератор: Swift-код, тесты, новые скиллы |
| **Auditor** (`agents/auditor.md`) | Quality Gatekeeper: ревью, аудит, read-only |

### Команды (3 шт.)

| Команда | Назначение |
|---------|------------|
| `/short_review` | Быстрый review git diff по критическим багам |
| `/diff-review` | Расширенный review git diff с отчетом в файл |
| `/doc_maker` | Анализ кода и генерация документации |

### Swift-антипаттерны (22 шт.)

Справочники по категориям:
- **Common** (6): assertion без message, хардкод тестовых данных, отсутствие абстракции, cleanup, порядок тестов, статические данные
- **Networking** (7): обертка ошибок, типизация моделей, абстракция URLSession, заголовки безопасности, валидация Content-Type, парсинг error body, конфигурация URLSession
- **Platform** (6): setup в XCTest, async-тесты, shared mutable state, контролируемые retry, flaky sleep-тесты, хардкод таймаутов
- **Security** (3): логирование sensitive data, утечка информации в ошибках, PII в коде

### Дополнительно

- **Оркестратор** (`dev_agent.md`): маршрутизация задач между агентами
- **Хук** (`hooks/skill-lint.sh`): пост-валидация SKILL.md при редактировании
- **Markdownlint** (`.markdownlint.yaml`): правила линтинга документации
- **Claudeignore** (`.aiignore`): фильтр шума (build, IDE, CI/CD)

## Установка

1. Скопируй содержимое в корень iOS/Swift проекта:

```
cp -r .ai/ <путь-к-проекту>/.ai/
cp CLAUDE.md <путь-к-проекту>/CLAUDE.md
cp AGENTS.md <путь-к-проекту>/AGENTS.md
cp .aiignore <путь-к-проекту>/.aiignore
cp .markdownlint.yaml <путь-к-проекту>/.markdownlint.yaml
```

2. Адаптируй `CLAUDE.md` под свой проект:
   - Укажи свой пакетный менеджер (SPM / CocoaPods / Carthage)
   - Укажи UI-фреймворк (SwiftUI / UIKit / Hybrid)
   - Добавь специфичные для проекта команды сборки
   - Добавь Project Structure

3. (Опционально) Запусти `/repo-scout` для анализа проекта, затем `/init-project` для генерации адаптированного CLAUDE.md.

## Структура

```
.
├── CLAUDE.md                  # Swift-конвенции и настройки проекта
├── AGENTS.md                  # Краткие правила для Codex
├── .aiignore              # Игнорируемые файлы
├── .markdownlint.yaml         # Правила линтинга MD
└── .ai/
    ├── dev_agent.md           # Оркестратор
    ├── agents/
    │   ├── auditor.md         # Auditor Agent
    │   └── sdet.md            # Developer Agent
    ├── commands/
    │   ├── short_review.md    # Быстрый review
    │   ├── diff-review.md     # Расширенный review
    │   └── doc_maker.md       # Генерация документации
    ├── skills/
    │   ├── swift-review/      # Code review
    │   ├── repo-scout/        # Разведка репо
    │   ├── init-project/      # Генерация CLAUDE.md
    │   ├── init-skill/        # Создание скиллов
    │   ├── refactor-plan/     # План рефакторинга
    │   ├── dependency-check/  # Анализ зависимостей
    │   ├── doc-lint/          # Аудит документации
    │   ├── skill-audit/       # Аудит скиллов
    │   └── update-ai-setup/   # Обновление AI-реестра
    ├── swift-antipatterns/
    │   ├── _index.md          # Индекс всех паттернов
    │   ├── common/            # 6 паттернов
    │   ├── networking/        # 7 паттернов
    │   ├── platform/          # 6 паттернов
    │   └── security/          # 3 паттерна
    ├── protocols/
    │   └── gardener.md        # Протокол мета-обучения
    └── hooks/
        └── skill-lint.sh      # Валидация при редактировании
```

## Требования

- Claude Code
- iOS/Swift проект с SPM

## Совместимость

Скилл-пак работает с любым iOS/Swift проектом. Конвенции в CLAUDE.md покрывают:
- Swift 5.9+
- SwiftUI и UIKit
- Swift Concurrency (async/await, actors, Sendable)
- SPM (с поддержкой CocoaPods/Carthage при анализе зависимостей)
- XCTest и swift-testing
