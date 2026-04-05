# DevOps Anti-Patterns Index

Библиотека типичных ошибок в DevOps-практиках.

## Протокол использования

**Lazy Load:** читай конкретный файл паттерна ТОЛЬКО когда обнаружено нарушение при ревью.
Не загружай всю библиотеку целиком - обращайся к файлу по категории и имени.

**Именование:** `{category}/{pattern-name}.md`

---

## security/

| Файл | Описание |
|------|----------|
| `security/hardcoded-credentials.md` | Пароли, API-ключи, токены захардкожены в конфигах или скриптах |
| `security/running-as-root.md` | Сервисы и контейнеры запущены от root |
| `security/no-tls.md` | Незашифрованные соединения между сервисами |
| `security/weak-permissions.md` | chmod 777, мир-читаемые секреты, избыточные IAM-права |
| `security/exposed-secrets.md` | Секреты видны в логах, env dump, списке процессов |

## containers/

| Файл | Описание |
|------|----------|
| `containers/latest-tag.md` | Использование :latest тега для Docker-образов |
| `containers/no-resource-limits.md` | Отсутствие лимитов CPU/RAM в контейнерах и подах |
| `containers/no-healthcheck.md` | Нет проверок здоровья в Docker и Kubernetes |
| `containers/fat-images.md` | Раздутые Docker-образы с лишними пакетами |
| `containers/privileged-containers.md` | Запуск контейнеров в привилегированном режиме |

## iac/

| Файл | Описание |
|------|----------|
| `iac/no-state-locking.md` | Terraform state без механизма блокировки |
| `iac/hardcoded-values.md` | Захардкоженные IP, AMI ID, регионы в Terraform/Ansible |
| `iac/no-modules.md` | Копипаста инфраструктурных блоков вместо модулей |
| `iac/mutable-infrastructure.md` | Ручные изменения на серверах, дрифт конфигурации |
| `iac/no-drift-detection.md` | Нет механизма обнаружения дрифта инфраструктуры |

## cicd/

| Файл | Описание |
|------|----------|
| `cicd/secrets-in-logs.md` | CI/CD пайплайн утекает секретами в логи сборки |
| `cicd/no-pipeline-caching.md` | Нет кеширования в CI/CD - медленные сборки |
| `cicd/manual-deployments.md` | Ручные шаги деплоя, нет автоматизации |
| `cicd/no-rollback-strategy.md` | Нет возможности откатить плохой деплой |
| `cicd/no-artifact-versioning.md` | Артефакты без версионных тегов или чексумм |

## monitoring/

| Файл | Описание |
|------|----------|
| `monitoring/no-alerting.md` | Метрики собираются, но алерты не настроены |
| `monitoring/missing-metrics.md` | Сервисы без базовой наблюдаемости |
| `monitoring/no-log-rotation.md` | Логи заполняют диск без ротации |
| `monitoring/no-dashboards.md` | Нет визуализации состояния системы |

## scripts/

| Файл | Описание |
|------|----------|
| `scripts/no-error-handling.md` | Shell-скрипты без обработки ошибок |
| `scripts/no-idempotency.md` | Скрипты ломаются при повторном запуске |
| `scripts/no-logging.md` | Скрипты без логирования |
| `scripts/hardcoded-paths.md` | Захардкоженные абсолютные пути и привязка к окружению |

## conventions/

| Файл | Описание |
|------|----------|
| `conventions/bash.md` | Правила написания Bash-скриптов (strict mode, кавычки, local, trap) |
| `conventions/yaml.md` | Правила оформления YAML (отступы, булевы, якоря) |
| `conventions/terraform.md` | Правила Terraform (переменные, теги, модули, state locking) |
| `conventions/docker.md` | Правила Docker (multi-stage, nonroot, healthcheck, pinned versions) |
| `conventions/kubernetes.md` | Правила K8s (limits, probes, RBAC, labels, ConfigMap/Secret) |
| `conventions/naming.md` | Конвенции именования (kebab-case, snake_case, UPPER_SNAKE) |
| `conventions/security.md` | Базовые правила безопасности (секреты, TLS, привилегии, SSH) |
| `conventions/code-style.md` | Стиль кода и комментариев |
| `conventions/architecture.md` | Не предлагай архитектуру без запроса, сохраняй существующую |
