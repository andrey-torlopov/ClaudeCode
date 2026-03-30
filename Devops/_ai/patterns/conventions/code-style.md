# Code Style

**Applies to:** Весь код и конфигурации проекта

## Правила

- Не используй длинное тире в комментариях - используй "-"
- Не добавляй комментарии к очевидному коду
- Не добавляй docstrings без запроса

## Bad Example

```bash
# BAD: длинное тире, очевидные комментарии, лишние docstrings
#!/bin/bash
set -euo pipefail

# Устанавливаем переменную — задаём путь к директории
readonly DEPLOY_DIR="/opt/app"

# Переходим в директорию
cd "${DEPLOY_DIR}"

# Запускаем деплой
deploy() {
    # Описание: функция деплоя приложения
    # Аргументы: нет
    # Возвращает: 0 при успехе
    git pull origin main
}
```

## Good Example

```bash
# GOOD: только необходимые комментарии
#!/bin/bash
set -euo pipefail

readonly DEPLOY_DIR="/opt/app"

cd "${DEPLOY_DIR}"

deploy() {
    git pull origin main
}
```

## What to look for in review

- Длинное тире "—" в комментариях вместо "-"
- Комментарии, дублирующие очевидный код (`# Устанавливаем переменную`)
- Docstrings добавленные без явного запроса
