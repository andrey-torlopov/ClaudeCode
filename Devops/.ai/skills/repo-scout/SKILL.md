---
name: repo-scout
description: Сканирует DevOps-репозиторий, каталогизирует структуру проекта, зависимости, архитектуру и инфраструктуру. Используй при входе в новый репо для понимания инфраструктурной базы. Не используй для ревью инфраструктуры - для этого /infra-review.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*)"
context: fork
---

# /repo-scout - Разведка DevOps-репозитория

<purpose>
Глубокое сканирование DevOps-репозитория -> структурированный отчет о проекте, зависимостях, архитектуре и инфраструктурном стеке. Дает полную картину проекта перед началом работы.
</purpose>

## Когда использовать

- Первый вход в новый DevOps-репозиторий
- Перед `/init-project` - для понимания проекта
- Периодический аудит: "что изменилось в проекте?"
- Онбординг в существующий проект

## Когда НЕ использовать

- Ревью инфраструктуры (используй `/infra-review`)
- Анализ зависимостей (используй `/dependency-check`)

## Входные данные

- Путь к репозиторию (или текущая директория)
- Не требует `COMMON.md`, anchor-файлов или других AI-файлов
- Может быть **первым шагом** в новом репо

## Verbosity Protocol

**Structured Output Priority:** Весь analysis идет в артефакт, не в чат.

**Chat output:** Только Summary table + "Отчет: audit/repo-scout-report.md".

**Tools first:** Grep -> table -> report, без "Now I will grep...". Read -> analyze -> report, без "The file shows...".

**Фазы 1-5:** Silent execution. **Фаза 6:** Только Summary + путь к отчету.

---

## Алгоритм

### Фаза 1: Project Structure Scan

**Цель:** Определить тип проекта, инструменты, структуру директорий.

1. Проверь наличие project-файлов:
   ```
   Dockerfile, docker-compose.yml, *.tf, ansible/, k8s/, .github/workflows/, Makefile, Jenkinsfile
   ```
   Приоритет определения: Kubernetes (k8s/) > Terraform (*.tf) > Docker Compose > Dockerfile > Scripts

2. Извлеки из ключевых файлов:
   - `docker-compose.yml` -> сервисы, сети, volumes
   - `*.tf` -> провайдеры, ресурсы, модули
   - `Chart.yaml` -> Helm-чарт, версия, зависимости
   - `Makefile` -> доступные цели

3. Определи структуру:
   ```
   Glob: terraform/ -> Terraform-модули
   Glob: k8s/ или kubernetes/ -> K8s-манифесты
   Glob: ansible/ или playbooks/ -> Ansible
   Glob: scripts/ или bin/ -> Скрипты автоматизации
   Glob: docker/ -> Docker-конфигурации
   ```

4. Подсчитай размер:
   ```
   Количество конфигурационных файлов (.tf, .yml, .yaml, Dockerfile)
   Количество скриптов (.sh, .py)
   ```

### Фаза 2: Dependencies Analysis

**Цель:** Каталогизировать все зависимости.

#### 2.1 Docker Images

Найди все FROM-инструкции в Dockerfile и image-ключи в docker-compose.yml:
- Базовые образы с версиями
- Классификация: Runtime, Build, Tools, Database, Cache

#### 2.2 Terraform Providers

Из `*.tf` файлов:
- Список провайдеров с версиями
- Модули (source + version)

#### 2.3 Helm Charts

Если есть Chart.yaml / Chart.lock:
- Зависимости чартов
- Версии

#### 2.4 Package Dependencies

- `requirements.txt` / `Pipfile` -> Python
- `package.json` -> Node.js
- `Gemfile` -> Ruby

### Фаза 3: Architecture Discovery

**Цель:** Определить архитектурные паттерны проекта.

1. **Архитектура сервисов:**
   ```
   Grep: docker-compose.yml -> services count -> монолит/микросервисы
   Glob: k8s/*/deployment.yaml -> сервисы в Kubernetes
   Grep: serverless.yml, lambda/ -> Serverless
   ```
   Определить: Monolith / Microservices / Serverless / Hybrid

2. **Оркестрация:**
   ```
   Glob: k8s/, helm/ -> Kubernetes
   Grep: docker-compose -> Docker Compose
   Grep: ecs, task-definition -> AWS ECS
   Grep: nomad -> HashiCorp Nomad
   ```

3. **IaC:**
   ```
   Glob: *.tf -> Terraform
   Glob: playbooks/, roles/ -> Ansible
   Grep: Pulumi -> Pulumi
   Grep: CloudFormation, AWSTemplateFormatVersion -> CloudFormation
   ```

4. **Networking:**
   ```
   Grep: ingress, LoadBalancer -> Ingress/LB
   Grep: NetworkPolicy -> Network Policies
   Grep: service mesh, istio, linkerd -> Service Mesh
   ```

5. **Storage:**
   ```
   Grep: PersistentVolume, StorageClass -> K8s storage
   Grep: aws_s3, google_storage -> Cloud storage
   Grep: volumes: -> Docker volumes
   ```

### Фаза 4: Security Scan

**Цель:** Оценить безопасность инфраструктурного кода.

1. Поиск секретов в коде:
   ```
   Grep: password=, secret=, api_key=, token=, AWS_SECRET
   Grep: BEGIN RSA PRIVATE KEY, BEGIN OPENSSH PRIVATE KEY
   ```

2. TLS и сертификаты:
   ```
   Grep: tls, ssl, certificate, cert-manager
   Grep: http:// (не https://) в production-конфигах
   ```

3. Контроль доступа:
   ```
   Grep: RBAC, ClusterRole, Role, ServiceAccount
   Grep: privileged: true, runAsRoot
   Grep: SecurityContext, securityContext
   ```

4. Сетевая безопасность:
   ```
   Grep: NetworkPolicy, firewall, security_group
   Grep: 0.0.0.0, ::/0 -> широко открытые порты
   ```

### Фаза 5: Infrastructure Scan

**Цель:** Понять инфраструктурный контекст.

1. **CI/CD:**
   ```
   Glob: .github/workflows/*.yml -> GitHub Actions
   Glob: .gitlab-ci.yml -> GitLab CI
   Glob: Jenkinsfile -> Jenkins
   Glob: .circleci/ -> CircleCI
   Glob: argocd/ -> ArgoCD
   ```

2. **Мониторинг:**
   ```
   Glob: prometheus.yml, prometheus/ -> Prometheus
   Glob: grafana/, dashboards/ -> Grafana
   Glob: alertmanager.yml -> Alertmanager
   Grep: datadog, dd-agent -> Datadog
   ```

3. **Логирование:**
   ```
   Grep: elasticsearch, kibana, fluentd, filebeat -> ELK/EFK
   Grep: loki, promtail -> Grafana Loki
   ```

4. **AI Setup:**
   ```
   Glob: COMMON.md -> shared core context
   Glob: CLAUDE.md -> Claude entry
   Glob: AGENTS.md -> agent-runtime entry
   Glob: GEMINI.md -> Gemini entry
   Glob: .ai/** -> local AI config
   Glob: .cursor/rules/*.mdc -> Cursor IDE
   ```

### Фаза 6: Report Generation

Собери отчет и сохрани в `audit/repo-scout-report.md`. Используй шаблон из `references/report-template.md`.

**Обязательные секции:**
1. Project Profile (name, type, cloud, services count)
2. Service Structure (сервисы, образы, порты, зависимости)
3. Dependencies Catalog (Docker images, Terraform providers, Helm charts)
4. Architecture Summary (orchestration, networking, storage, IaC)
5. Security Assessment (секреты, TLS, RBAC, network policies)
6. Infrastructure (CI/CD, monitoring, logging)
7. Readiness Assessment (strengths + areas for improvement + next step)

## Quality Gates

- [ ] Ключевые конфигурационные файлы найдены и проанализированы
- [ ] Все зависимости каталогизированы
- [ ] Архитектурный паттерн определен
- [ ] Безопасность оценена
- [ ] Нет placeholder-ов `{xxx}` в финальном отчете
- [ ] Readiness Assessment заполнен

## Self-Check

- [ ] **Completeness:** Все 7 секций заполнены?
- [ ] **Accuracy:** Количества файлов верифицированы?
- [ ] **No Hallucinations:** Каждый найденный паттерн подтвержден Grep-ом?
- [ ] **Readiness:** Оценка обоснована данными?

## Завершение

```
SKILL COMPLETE: /repo-scout
|- Артефакты: audit/repo-scout-report.md
|- Compilation: N/A
|- Upstream: нет
|- Services: {N} | Config files: {M} | Scripts: {K}
```

## Связанные файлы

- Паттерны DevOps: `references/devops-detection-patterns.md`
- Шаблон отчета: `references/report-template.md`
- Следующий шаг: `/init-project` (использует отчет как вход)
