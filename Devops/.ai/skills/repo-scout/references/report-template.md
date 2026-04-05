# Шаблон отчета repo-scout-report.md

```markdown
# Repo Scout Report: {project-name}

> Сгенерировано: {дата} | Скилл: /repo-scout

## 1. Project Profile

| Параметр | Значение |
|----------|----------|
| Project | {название проекта} |
| Type | {Microservices / Monolith / Serverless / IaC-only / Mixed} |
| Cloud | {AWS / GCP / Azure / On-premise / Hybrid} |
| Orchestration | {Kubernetes / Docker Compose / ECS / Nomad / нет} |
| IaC Tool | {Terraform / Ansible / Pulumi / CloudFormation / нет} |
| CI/CD | {GitHub Actions / GitLab CI / Jenkins / ArgoCD} |
| Services | {N сервисов} |
| Config Files | {N конфигурационных файлов} |
| Scripts | {N скриптов} |

## 2. Service Structure

| Сервис | Docker Image | Порт | Зависимости | Описание |
|--------|-------------|:----:|-------------|----------|
| {service name} | {image:tag} | {port} | {depends_on} | {краткое описание} |

## 3. Dependencies Catalog

### Docker Images

| # | Образ | Тег/Версия | Используется в | Категория |
|---|-------|-----------|----------------|-----------|
| 1 | {image} | {tag} | {Dockerfile/compose} | {Runtime/Build/DB/Cache} |

### Terraform Providers

| # | Провайдер | Версия | Описание |
|---|-----------|--------|----------|
| 1 | {provider} | {version} | {что управляет} |

### Helm Charts (если есть)

| # | Чарт | Версия | Репозиторий |
|---|------|--------|-------------|
| 1 | {chart} | {version} | {repo} |

**Итого:** {N} зависимостей ({X} Docker + {Y} Terraform + {Z} Helm)

## 4. Architecture Summary

| Аспект | Значение | Детали |
|--------|----------|--------|
| Architecture | {Microservices / Monolith / Serverless} | {обоснование} |
| Orchestration | {Kubernetes / Docker Compose / ECS} | {детали} |
| Networking | {Ingress / LB / Service Mesh / нет} | {детали} |
| Storage | {PV / S3 / EBS / Docker volumes} | {детали} |
| IaC | {Terraform / Ansible / Pulumi} | {модулей/playbooks} |
| Secret Mgmt | {Vault / SOPS / K8s Secrets / нет} | {детали} |
| Config Mgmt | {ConfigMap / Ansible vars / .env / нет} | {детали} |

## 5. Security Assessment

| Категория | Статус | Детали |
|-----------|:------:|--------|
| Секреты в коде | {ok/warning/critical} | {детали} |
| TLS/SSL | {ok/warning/not configured} | {детали} |
| RBAC | {ok/warning/not configured} | {детали} |
| Network Policies | {ok/warning/not configured} | {детали} |
| Container Security | {ok/warning/critical} | {детали} |
| Image Scanning | {есть/нет} | {детали} |

## 6. Infrastructure

| Компонент | Наличие | Детали |
|-----------|:-------:|--------|
| CI/CD | {есть/нет} | {GitHub Actions / GitLab CI / Jenkins} |
| Monitoring | {есть/нет} | {Prometheus / Grafana / Datadog} |
| Logging | {есть/нет} | {ELK / Loki / CloudWatch} |
| Alerting | {есть/нет} | {Alertmanager / PagerDuty / Slack} |
| Backup | {есть/нет} | {детали} |
| Documentation | {есть/нет} | {README / docs/ / wiki} |

## 7. AI Setup Status

| Файл | Статус |
|------|--------|
| COMMON.md | {есть / нет} |
| CLAUDE.md | {есть / нет} |
| AGENTS.md | {есть / нет} |
| GEMINI.md | {есть / нет} |
| .ai/skills/ | {N скиллов / нет} |
| .ai/agents/ | {N агентов / нет} |
| .cursor/rules/ | {есть / нет} |

## 8. Readiness Assessment

### Сильные стороны
- {пункт 1}
- {пункт 2}

### Области для улучшения
- {пункт 1}
- {пункт 2}

### Рекомендуемый следующий шаг

{Конкретная рекомендация: /init-project, /infra-review, "настроить мониторинг" и т.д.}
```
