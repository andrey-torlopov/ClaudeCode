---
name: init-project
description: Генерирует стартовый prompt pack для DevOps-проекта: COMMON.md, anchor-файлы и минимальный AI-контекст. Используй для нового проекта или миграции на облегчённый AI workflow. Не используй если core context уже настроен и требуется только точечная правка.
allowed-tools: "Read Write Edit Glob Grep Bash(ls*)"
context: fork
---

# /init-project - Генератор COMMON.md и anchor-файлов

Создаёт компактный prompt pack на основе структуры DevOps-репозитория.

## Когда использовать

- Новый DevOps-проект без `COMMON.md`
- Миграция существующего проекта на облегчённый AI workflow
- Стандартизация prompt pack по команде

## Verbosity Protocol

**Tools first:** Сканируй молча. В чат - только финальный результат.

## Алгоритм выполнения

### Шаг 1: Сканирование проекта

Найди и проанализируй:

1. **Контейнеризацию и оркестрацию:**
   - `Dockerfile` / `Dockerfile.*`
   - `docker-compose.yml` / `docker-compose.*.yml`
   - `k8s/`, `kubernetes/`, `manifests/`, `helm/`
   - `Chart.yaml`, `kustomization.yaml`

2. **Infrastructure as Code:**
   - `*.tf`, `terraform/`
   - `ansible/`, `playbooks/`, `roles/`, `ansible.cfg`
   - `Pulumi.yaml`, `pulumi/`
   - `cloudformation/`, `*.template.json`

3. **CI/CD и automation:**
   - `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`
   - `argocd/`, `applicationset.yaml`, `tekton/`
   - `Makefile`, `Taskfile.yml`, `scripts/`, `bin/`

4. **Observability и security:**
   - `prometheus/`, `prometheus.yml`, `grafana/`, `dashboards/`
   - `alertmanager.yml`, `loki/`, `promtail/`, `filebeat.yml`
   - `.sops.yaml`, `vault/`, `sealed-secrets/`, `cert-manager/`

### Обработка ошибок Шага 1

**Инфраструктурные файлы не найдены** -> Спроси пользователя:

```text
Не удалось определить структуру проекта автоматически. Уточни:
- Тип проекта: (Контейнеры / IaC / Kubernetes / CI-CD / Mixed)
- Облачный провайдер: (AWS / GCP / Azure / On-premise)
- Оркестрация: (Kubernetes / Docker Compose / ECS / Nomad)
```

**CI/CD-конфиги отсутствуют** -> Не выдумывай секцию CI. Оставь только подтверждённые данные.

### Шаг 2: Определение Tech Stack

На основе файлов проекта определи:

| Категория | Что искать |
|-----------|------------|
| Container Runtime | Docker / Podman / containerd |
| Orchestration | Kubernetes / Docker Compose / ECS / Nomad |
| IaC | Terraform / Ansible / Pulumi / CloudFormation |
| CI/CD | GitHub Actions / GitLab CI / Jenkins / ArgoCD / Tekton |
| Monitoring | Prometheus / Grafana / Datadog / ELK / Loki |
| Cloud | AWS / GCP / Azure / On-premise |
| Config Mgmt | Ansible / Helm / Kustomize / Puppet / Chef |
| Secret Mgmt | Vault / SOPS / AWS Secrets Manager / sealed-secrets |

### Шаг 3: Генерация core context

Прочитай и используй шаблон из `references/common-md-template.md`.

Сгенерируй:

- `COMMON.md` как SSOT
- `CLAUDE.md` как Claude anchor
- `AGENTS.md` как generic agent anchor
- `GEMINI.md` как Gemini anchor

Для `CLAUDE.md` используй `references/claude-md-template.md`.
`AGENTS.md` и `GEMINI.md` делай в том же стиле: короткий read-order и ссылка на `COMMON.md`.

### Шаг 4: Валидация

Перед сохранением проверь:

- [ ] Tech Stack соответствует реальным файлам проекта
- [ ] Verify-команды релевантны стеку проекта
- [ ] `COMMON.md` остаётся компактным и не дублирует подробные инструкции скиллов
- [ ] Anchor-файлы не копируют core rules и таблицы
- [ ] Нет placeholder-ов вида `[xxx]` в финальных файлах

## Вывод

Сохрани результат в корень проекта:

- `COMMON.md`
- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`

## Связанные файлы

- Шаблон SSOT: `references/common-md-template.md`
- Шаблон Claude anchor: `references/claude-md-template.md`
- Разведка: `/repo-scout` (может быть выполнен перед init-project)
