# CLAUDE.md - Шаблон для DevOps-проекта

> **Назначение:** Wiki проекта для AI. Первый день нового инженера - какой стек, где что лежит, как собирать и деплоить.

---

## Шаблон

```markdown
# [Project Name]

## Context
- **Project:** [Что деплоим/управляем - описание инфраструктуры и сервисов]
- **Languages:** Bash, Python, YAML, HCL, Dockerfile
- **Platform:** [AWS / GCP / Azure / On-premise / Hybrid]
- **Environments:** [dev / staging / production]

## Tech Stack

| Категория | Технология |
|-----------|------------|
| Container Runtime | [Docker / Podman / containerd] |
| Orchestration | [Kubernetes / Docker Compose / ECS / Nomad] |
| IaC | [Terraform / Ansible / Pulumi / CloudFormation] |
| CI/CD | [GitHub Actions / GitLab CI / Jenkins / ArgoCD] |
| Monitoring | [Prometheus + Grafana / Datadog / ELK / CloudWatch] |
| Cloud | [AWS / GCP / Azure / On-premise] |
| Config Mgmt | [Ansible / Puppet / Chef / нет] |
| Secret Mgmt | [Vault / SOPS / AWS SM / sealed-secrets / нет] |

## Project Structure

```text
[Реальная структура проекта]
```

## Build & Run

| Действие | Команда |
|----------|---------|
| Build | `[docker build -t app . / make build]` |
| Deploy | `[kubectl apply -k k8s/ / terraform apply / docker compose up -d]` |
| Validate | `[terraform validate / ansible-lint / kubeconform]` |
| Lint | `[shellcheck scripts/*.sh / yamllint . / hadolint Dockerfile]` |
| Test | `[make test / pytest / bats tests/]` |

## DevOps Conventions

### Bash
- Используй `set -euo pipefail` в начале скриптов
- Оборачивай переменные в двойные кавычки: `"${VAR}"`
- Используй `shellcheck` для валидации
- Логируй через stderr: `echo "msg" >&2`
- Используй `trap` для очистки ресурсов

### YAML
- 2 пробела для отступов (не табы)
- Валидируй через `yamllint`
- Используй anchors (&) и aliases (*) для переиспользования

### Terraform
- Один ресурс на файл (или логическая группа)
- Используй модули для переиспользования
- Переменные с описаниями и типами
- Используй `terraform fmt` перед коммитом
- State хранить в remote backend (S3, GCS)

### Docker
- Минимальные базовые образы (alpine, distroless)
- Multi-stage builds для уменьшения размера
- Не запускать от root (USER директива)
- Фиксированные версии образов (не latest)
- HEALTHCHECK в каждом Dockerfile

### Kubernetes
- Limits и requests для всех контейнеров
- Readiness и liveness probes
- Network Policies для изоляции
- RBAC с минимальными привилегиями

## Naming

- Сервисы и ресурсы: kebab-case (`my-service`, `web-frontend`)
- Переменные Terraform: snake_case (`instance_type`, `vpc_id`)
- Переменные окружения: UPPER_SNAKE_CASE (`DATABASE_URL`, `API_KEY`)
- Docker-образы: kebab-case с тегом версии (`my-app:1.2.3`)
- K8s namespace: kebab-case (`production`, `staging-v2`)

## Security Protocols

FORBIDDEN: `git reset --hard`, `git clean -fd`, удаление веток, `terraform destroy` без плана
MANDATORY: Backup перед деструктивными операциями, review `terraform plan` перед apply
```

---

## Расположение файла

```
project-root/
└── CLAUDE.md    # В корне проекта
```
