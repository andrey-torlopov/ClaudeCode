# Project context
- Домен: DevOps, инфраструктура, автоматизация, CI/CD
- Языки: Bash, Python, YAML, HCL (Terraform), Dockerfile, JSON, TOML
- Комментарии и рассуждения пишем на русском языке

# Validation & Linting
- Bash: `shellcheck script.sh`
- YAML: `yamllint file.yml`
- Terraform: `terraform validate && terraform fmt -check`
- Dockerfile: `hadolint Dockerfile`
- Ansible: `ansible-lint playbook.yml`
- Kubernetes: `kubectl apply --dry-run=client -f manifest.yml`
- Python: `ruff check .`

## General Conventions
- Вся документация и контент скиллов - на русском языке, если явно не указано иное.
- При выполнении расчётов показывай полную формулу с числителем и знаменателем перед результатом.
- Мне нужен строгий наставник, который поможет мне вырасти как инженеру.
- Объясняй WHY, а не только HOW: для каждого решения кратко объясни, почему выбран этот подход.

# Bash conventions
- Всегда `set -euo pipefail` в начале скрипта
- Переменные в двойных кавычках: `"$var"`, не `$var`
- `[[ ]]` вместо `[ ]` для условий
- `local` для локальных переменных в функциях
- `readonly` для констант
- Логирование через stderr: `echo "INFO: message" >&2`
- Trap для cleanup: `trap cleanup EXIT`
- `mktemp` для временных файлов, не хардкодь пути
- Длинные пайпы разбивай на переменные для читаемости
- Функции: имя как глагол, `snake_case`

# YAML conventions
- 2 пробела отступ, без табов
- Строки в кавычках если содержат спецсимволы
- Явные булевы: `true`/`false`, не yes/no
- Якоря и алиасы (`&` / `*`) для DRY
- Комментарии для нетривиальных значений

# Terraform conventions
- Переменные с `description` и `type`
- Outputs для межмодульного взаимодействия
- Backend с state locking (S3+DynamoDB, GCS, etc.)
- Data sources вместо хардкода
- Теги на все ресурсы: Name, Environment, ManagedBy
- Модули для повторяющихся паттернов
- `terraform fmt` перед коммитом

# Docker conventions
- Multi-stage builds для уменьшения размера
- Минимальные базовые образы (alpine, distroless, scratch)
- `USER nonroot` - не запускать от root
- `COPY` вместо `ADD` (кроме tar-архивов)
- Один процесс на контейнер
- `HEALTHCHECK` в каждом образе
- `.dockerignore` для исключения лишнего
- Фиксированные версии образов, не `:latest`

# Kubernetes conventions
- Resource limits и requests обязательны
- Readiness и liveness probes
- Network policies для изоляции
- RBAC: минимальные привилегии
- Namespaces для разделения окружений
- Labels и annotations для всех ресурсов
- ConfigMaps/Secrets для конфигурации, не хардкод

# Naming
- Файлы и директории: kebab-case (`my-service`, `deploy-script.sh`)
- Переменные Bash: `UPPER_SNAKE_CASE` для экспорта, `lower_snake_case` для локальных
- Terraform ресурсы: `snake_case`
- Kubernetes ресурсы: kebab-case
- Docker образы: kebab-case, семантическое версионирование тегов

# Security
- Никаких секретов в коде, конфигах или git-истории
- Secret managers: Vault, AWS SSM, SOPS, sealed-secrets
- TLS везде, включая внутренние сервисы
- Минимальные привилегии для всех сервисов и пользователей
- SSH: только ключи, без паролей, порт != 22
- Firewall: deny all, allow explicitly

# Code style
- Не используй длинное тире в комментариях, используй "-"
- Не добавляй комментарии к очевидному коду
- Не добавляй docstrings без запроса

# Architecture
- Не предлагай инфраструктурные паттерны без запроса
- При рефакторинге сохраняй существующую архитектуру

# RnD. Research, исследования, анализ
- Для анализа всегда запрашиваем путь куда сохранить результат в markdown

## Core Principles
1. **Trust No One** - проверяй требования на противоречия
2. **Production Ready** - конфиги проходят валидацию без правок
3. **Idempotent** - повторный запуск не должен ломать систему
4. **Immutable** - инфраструктура как код, не ручные правки на серверах
5. **Read** - Читать можно без запроса на подтверждение
6. **DELETE** - Удалять только с подтверждением

## Editing Conventions

Когда просят сократить, упростить или обрезать вывод/контент - удаляй только то, что явно запрошено. Никогда не удаляй протоколы безопасности или промпты кастомизации, если об этом явно не сказано.

## Project Structure
```
.
├── CLAUDE.md
└── <Infrastructure>
    ├── <Configs>
```

## AI-сетап
- Базовый промт и оркестратор: `.ai/dev_agent.md`.
- Роли агентов: `.ai/agents/`.
- Скиллы и команды: `.ai/skills/`, `.ai/commands/`; пост-хуки: `.ai/hooks/`.
- Паттерны и протоколы: `.ai/patterns/`, `.ai/protocols/`.
