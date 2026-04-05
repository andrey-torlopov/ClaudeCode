# DevOps Detection Patterns - Справочник для /repo-scout

## Project Files

| Файл | Назначение |
|------|-----------|
| `Dockerfile` / `Dockerfile.*` | Docker-образы сервисов |
| `docker-compose.yml` / `docker-compose.*.yml` | Docker Compose стек |
| `.dockerignore` | Контекст сборки Docker |
| `Makefile` | Автоматизация задач |
| `Taskfile.yml` | Task runner (альтернатива Make) |
| `scripts/*.sh` / `bin/*.sh` | Скрипты автоматизации |
| `.env` / `.env.example` | Переменные окружения |

## IaC Files

| Файл | Назначение |
|------|-----------|
| `*.tf` / `terraform/` | Terraform конфигурация |
| `terraform.tfvars` / `*.auto.tfvars` | Terraform переменные |
| `.terraform.lock.hcl` | Terraform lock file |
| `backend.tf` | Terraform remote state config |
| `playbooks/*.yml` / `roles/` | Ansible playbooks и роли |
| `ansible.cfg` / `inventory/` | Ansible конфигурация |
| `Pulumi.yaml` / `pulumi/` | Pulumi конфигурация |
| `*.template.json` / `cloudformation/` | AWS CloudFormation |

## Kubernetes Files

| Файл | Назначение |
|------|-----------|
| `k8s/` / `kubernetes/` / `manifests/` | K8s-манифесты |
| `Chart.yaml` / `Chart.lock` | Helm-чарт |
| `values.yaml` / `values-*.yaml` | Helm values |
| `templates/` | Helm templates |
| `kustomization.yaml` | Kustomize конфигурация |
| `*-deployment.yaml` | K8s Deployment |
| `*-service.yaml` | K8s Service |
| `*-ingress.yaml` | K8s Ingress |
| `*-configmap.yaml` | K8s ConfigMap |
| `*-secret.yaml` | K8s Secret |

## Architecture Detection Patterns

### Архитектура сервисов

| Паттерн | Архитектура |
|---------|-------------|
| Множество `Dockerfile` + `docker-compose.yml` с >3 сервисами | Microservices |
| Один `Dockerfile` + один сервис | Monolith |
| `serverless.yml`, `lambda/`, `functions/` | Serverless |
| `k8s/` с множеством deployments | Microservices (K8s) |
| Один deployment + один service | Monolith (containerized) |

### Оркестрация

| Паттерн (Glob/Grep) | Оркестратор |
|---------------------|-------------|
| `k8s/`, `helm/`, `Chart.yaml`, `kubectl` | Kubernetes |
| `docker-compose.yml`, `docker compose` | Docker Compose |
| `ecs`, `task-definition`, `aws_ecs` | AWS ECS |
| `nomad`, `*.nomad.hcl` | HashiCorp Nomad |
| `docker-swarm`, `docker stack` | Docker Swarm |

### IaC

| Паттерн | Инструмент |
|---------|-----------|
| `*.tf`, `terraform`, `provider` | Terraform |
| `playbooks/`, `roles/`, `ansible.cfg` | Ansible |
| `Pulumi.yaml`, `pulumi` | Pulumi |
| `AWSTemplateFormatVersion`, `*.template.json` | CloudFormation |
| `crossplane`, `composition.yaml` | Crossplane |

## CI/CD Detection

| Glob | Платформа |
|------|-----------|
| `.github/workflows/*.yml` | GitHub Actions |
| `.gitlab-ci.yml` | GitLab CI |
| `Jenkinsfile` | Jenkins |
| `.circleci/config.yml` | CircleCI |
| `argocd/`, `applicationset.yaml` | ArgoCD |
| `.drone.yml` | Drone CI |
| `bitbucket-pipelines.yml` | Bitbucket Pipelines |
| `azure-pipelines.yml` | Azure DevOps |
| `tekton/`, `pipeline.yaml`, `task.yaml` | Tekton |
| `flux-system/`, `gotk-components.yaml` | FluxCD |

## Monitoring & Observability

| Glob/Grep | Инструмент |
|-----------|-----------|
| `prometheus.yml`, `prometheus/` | Prometheus |
| `grafana/`, `dashboards/*.json` | Grafana |
| `alertmanager.yml` | Alertmanager |
| `dd-agent`, `datadog` | Datadog |
| `newrelic` | New Relic |
| `elasticsearch`, `kibana`, `logstash` | ELK Stack |
| `fluentd`, `fluent-bit` | Fluentd/Fluent Bit |
| `filebeat.yml` | Filebeat |
| `loki`, `promtail` | Grafana Loki |
| `jaeger`, `opentelemetry` | Distributed Tracing |

## Security Tools

| Glob/Grep | Инструмент |
|-----------|-----------|
| `vault`, `vault-agent` | HashiCorp Vault |
| `.sops.yaml`, `sops` | Mozilla SOPS |
| `sealed-secrets`, `SealedSecret` | Bitnami Sealed Secrets |
| `cert-manager`, `Certificate`, `Issuer` | cert-manager |
| `opa`, `rego`, `gatekeeper` | Open Policy Agent |
| `trivy`, `snyk`, `grype` | Image/Dependency scanning |
| `falco` | Runtime security |
| `kyverno`, `ClusterPolicy` | Kyverno policies |
| `external-secrets`, `SecretStore` | External Secrets Operator |

## AI Setup Files

| Файл | Инструмент |
|------|-----------|
| `COMMON.md` | Shared AI core context |
| `CLAUDE.md` | Claude Code entry |
| `AGENTS.md` | Agent runtime entry |
| `GEMINI.md` | Gemini entry |
| `.ai/skills/*/SKILL.md` | Claude Code Skills |
| `.ai/agents/*.md` | Claude Code Agents |
| `.cursor/rules/*.mdc` | Cursor IDE |
| `.github/copilot-instructions.md` | GitHub/VS Code Copilot |
