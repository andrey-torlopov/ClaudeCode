---
name: init-project
description: Генерирует CLAUDE.md для DevOps-проекта - сканирует репозиторий, анализирует tech stack, создает онбординг-документ. Используй для нового проекта без CLAUDE.md или настройки AI-assisted workflow. Не используй если CLAUDE.md уже настроен - редактируй вручную.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор CLAUDE.md для DevOps-проекта

<purpose>
Автоматическое создание CLAUDE.md (онбординг AI в проект) на основе анализа DevOps-репозитория.
</purpose>

## Когда использовать

- Новый DevOps-проект без CLAUDE.md
- Миграция существующего проекта на AI-assisted workflow
- Стандартизация CLAUDE.md по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

---

## Алгоритм выполнения

### Шаг 1: Сканирование проекта

Найди и проанализируй:

1. **Файлы контейнеризации:**
   - `Dockerfile` / `Dockerfile.*` -> Docker-образы
   - `docker-compose.yml` / `docker-compose.*.yml` -> Docker Compose стек
   - `.dockerignore` -> настройка контекста сборки

2. **IaC (Infrastructure as Code):**
   - `*.tf` / `terraform/` -> Terraform
   - `ansible/` / `playbooks/` / `*.yml` (с ansible-специфичным содержимым) -> Ansible
   - `pulumi/` / `Pulumi.yaml` -> Pulumi
   - `cloudformation/` / `*.template.json` -> CloudFormation

3. **Kubernetes:**
   - `k8s/` / `kubernetes/` / `manifests/` / `helm/` -> K8s-манифесты
   - `Chart.yaml` -> Helm-чарты
   - `kustomization.yaml` -> Kustomize

4. **CI/CD:**
   - `.github/workflows/` -> GitHub Actions
   - `.gitlab-ci.yml` -> GitLab CI
   - `Jenkinsfile` -> Jenkins
   - `.circleci/` -> CircleCI
   - `argocd/` / `applicationset.yaml` -> ArgoCD

5. **Скрипты и автоматизация:**
   - `Makefile` -> Make
   - `scripts/` / `bin/` -> Bash/Python скрипты
   - `Taskfile.yml` -> Task runner

6. **Мониторинг и логирование:**
   - `prometheus/` / `prometheus.yml` -> Prometheus
   - `grafana/` / `dashboards/` -> Grafana
   - `alertmanager.yml` -> Alertmanager
   - `filebeat.yml` / `fluentd/` -> Лог-коллекторы

### Обработка ошибок Шага 1

**Инфраструктурные файлы не найдены** -> Спроси пользователя:

```
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (Контейнеры / IaC / Kubernetes / CI-CD / Mixed)
- Облачный провайдер: (AWS / GCP / Azure / On-premise)
- Оркестрация: (Kubernetes / Docker Compose / ECS / Nomad)
```

**CI/CD-конфиги отсутствуют** -> Пропусти секцию CI в CLAUDE.md, отметь как TODO.

### Шаг 2: Определение Tech Stack

На основе файлов проекта определи:

| Категория | Что искать |
|-----------|------------|
| Container Runtime | Docker / Podman / containerd |
| Orchestration | Kubernetes / Docker Compose / ECS / Nomad |
| IaC | Terraform / Ansible / Pulumi / CloudFormation |
| CI/CD | GitHub Actions / GitLab CI / Jenkins / ArgoCD |
| Monitoring | Prometheus / Grafana / Datadog / ELK |
| Cloud | AWS / GCP / Azure / On-premise |
| Config Mgmt | Ansible / Puppet / Chef / SaltStack |
| Secret Mgmt | Vault / SOPS / AWS Secrets Manager / sealed-secrets |

### Шаг 3: Генерация CLAUDE.md

Прочитай и используй шаблон из `references/claude-md-template.md`.

Заполни все placeholder-ы `[xxx]` данными из Шагов 1-2.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным файлам проекта
- [ ] Commands работают (проверь наличие Dockerfile / terraform / и т.д.)
- [ ] Structure отражает реальные папки
- [ ] Нет placeholder-ов вида `[xxx]` или TODO в финальном файле

## Вывод

Сохрани результат в `CLAUDE.md` в корне проекта.

## Пример диалога

```
User: /init-project

AI: Сканирую проект...

Найдено:
- Dockerfile (python:3.12-slim)
- docker-compose.yml (3 сервиса)
- terraform/ (AWS, 12 .tf файлов)
- .github/workflows/ (CI + CD)
- k8s/ (deployment, service, ingress)

Генерирую CLAUDE.md...

[Показывает сгенерированный файл]

Сохранить в ./CLAUDE.md? (y/n)
```

## Связанные файлы

- Шаблон: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
