# Infrastructure Review Checklist

## Security (S-1 .. S-7)

| # | Проверка | Severity | Grep-паттерн |
|---|---------|----------|-------------|
| S-1 | Секреты в коде (пароли, ключи, токены) | BLOCKER | `password=`, `secret=`, `api_key=`, `token=`, `AWS_SECRET` |
| S-2 | Слишком широкие permissions (0.0.0.0/0, *) | CRITICAL | `0.0.0.0/0`, `::/0`, `"*"` в policy |
| S-3 | Отсутствие TLS/SSL | CRITICAL | `http://` в production-конфигах, порт 80 без редиректа |
| S-4 | Отсутствие RBAC | WARNING | нет `Role`, `ClusterRole`, `ServiceAccount` в K8s |
| S-5 | Открытые сетевые порты без ограничений | CRITICAL | `hostPort`, `hostNetwork: true`, порты без NetworkPolicy |
| S-6 | Запуск от root | WARNING | нет `USER` в Dockerfile, `runAsRoot: true`, `runAsUser: 0` |
| S-7 | Отсутствие firewall/security groups | WARNING | нет `aws_security_group`, `NetworkPolicy` |

### Правила

- Секреты должны храниться в Vault/SOPS/Sealed Secrets, НИКОГДА в коде
- Все внешние эндпоинты только через HTTPS
- Network Policies по умолчанию deny-all, разрешать явно
- Контейнеры запускать от non-root пользователя
- Security groups: минимально необходимые порты и источники

## Containers (C-1 .. C-7)

| # | Проверка | Severity | Что искать |
|---|---------|----------|------------|
| C-1 | Тег latest или отсутствие тега | CRITICAL | `FROM image` без `:tag`, `image: xxx:latest` |
| C-2 | Отсутствие resource limits | CRITICAL | нет `resources.limits` в K8s, нет `mem_limit` в compose |
| C-3 | Отсутствие health checks | WARNING | нет `HEALTHCHECK` в Dockerfile, нет `livenessProbe` в K8s |
| C-4 | Privileged mode | BLOCKER | `privileged: true`, `--privileged` |
| C-5 | Fat images (нет multi-stage) | WARNING | большой базовый образ + build tools в финальном образе |
| C-6 | Отсутствие USER directive | WARNING | нет `USER` в Dockerfile (запуск от root) |
| C-7 | Нет .dockerignore | INFO | отсутствие `.dockerignore` рядом с Dockerfile |

### Правила

- Всегда фиксировать версию образа (лучше SHA digest для production)
- Multi-stage build: сборка отдельно, runtime отдельно
- Resource limits обязательны для production
- Health checks обязательны для production
- Не запускать от root без явной необходимости

## IaC (I-1 .. I-5)

| # | Проверка | Severity | Что искать |
|---|---------|----------|------------|
| I-1 | Нет remote backend / state locking | CRITICAL | `backend "local"`, отсутствие backend.tf |
| I-2 | Hardcoded значения | WARNING | IP-адреса, account IDs, пароли в .tf файлах |
| I-3 | Нет модулей (дублирование) | WARNING | copy-paste ресурсов вместо module {} |
| I-4 | Нет drift detection | INFO | отсутствие terraform plan в CI |
| I-5 | Переменные без описаний/типов | INFO | `variable "x" {}` без description и type |

### Правила

- State хранить в remote backend (S3 + DynamoDB, GCS, Terraform Cloud)
- State locking обязателен для командной работы
- Переменные для всего, что может отличаться между окружениями
- Модули для переиспользуемых паттернов
- terraform plan в CI перед каждым apply

## Scripts (SC-1 .. SC-5)

| # | Проверка | Severity | Что искать |
|---|---------|----------|------------|
| SC-1 | Нет error handling | CRITICAL | отсутствие `set -euo pipefail`, нет проверки `$?` |
| SC-2 | Не идемпотентен | WARNING | скрипт падает при повторном запуске |
| SC-3 | Нет логирования | WARNING | отсутствие echo/log перед ключевыми операциями |
| SC-4 | Hardcoded пути | WARNING | абсолютные пути `/home/user/...`, захардкоженные хосты |
| SC-5 | Переменные без кавычек | WARNING | `$VAR` вместо `"$VAR"`, word splitting risk |

### Правила

- Каждый Bash-скрипт начинается с `#!/usr/bin/env bash` и `set -euo pipefail`
- Все переменные в двойных кавычках
- Используй `trap` для очистки временных файлов
- Идемпотентность: повторный запуск не ломает систему
- shellcheck обязателен

## CI/CD (CI-1 .. CI-4)

| # | Проверка | Severity | Что искать |
|---|---------|----------|------------|
| CI-1 | Секреты в логах | BLOCKER | `echo $SECRET`, отсутствие маскирования |
| CI-2 | Нет кеширования | WARNING | отсутствие cache в GitHub Actions / GitLab CI |
| CI-3 | Нет rollback strategy | CRITICAL | деплой без проверки здоровья и плана отката |
| CI-4 | Артефакты без версионирования | WARNING | нет версии в имени/теге артефакта |

### Правила

- Секреты только через secrets management пайплайна
- Кеширование зависимостей и Docker layers
- Canary/Blue-Green деплой для production
- Версионирование артефактов (semver, git SHA)

## Architecture (A-1 .. A-4)

| # | Проверка | Severity | Что искать |
|---|---------|----------|------------|
| A-1 | Single Point of Failure | CRITICAL | replicas: 1 в production, один инстанс БД |
| A-2 | Тесная связность | WARNING | жестко прописанные адреса сервисов, нет service discovery |
| A-3 | Нет горизонтального масштабирования | WARNING | отсутствие HPA, нет auto-scaling group |
| A-4 | Отсутствие документации | INFO | нет README, нет комментариев в конфигах |

### Правила

- Production: минимум 2 реплики для каждого сервиса
- Service discovery через DNS / K8s Services, не hardcoded IP
- HPA или auto-scaling для переменной нагрузки
- README с описанием архитектуры и процедур деплоя
