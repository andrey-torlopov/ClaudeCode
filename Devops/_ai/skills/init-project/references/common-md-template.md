# COMMON.md - SSOT template

Используй этот шаблон как ядро контекста DevOps-проекта. Именно он должен хранить общие правила, verify-команды и базовые conventions.

```markdown
# [Project Name] Core Context

`COMMON.md` — единый SSOT для базового контекста проекта.

## Stack

- Project: [Краткое описание инфраструктуры или платформы]
- Domain: DevOps / Platform / SRE / Infra Automation
- Languages: Bash, Python, YAML, HCL, Dockerfile
- Platform: [AWS / GCP / Azure / On-premise / Hybrid]
- Environments: [dev / staging / production]

## Verify

- Bash: `shellcheck script.sh`
- YAML: `yamllint file.yml`
- Terraform: `terraform validate && terraform fmt -check`
- Dockerfile: `hadolint Dockerfile`
- Ansible: `ansible-lint playbook.yml`
- Kubernetes: `kubectl apply --dry-run=client -f manifest.yml`
- Python: `ruff check .`

## Core Rules

1. Trust No One
2. Minimal Diff
3. Production Ready
4. Idempotent
5. Immutable
6. Read Freely
7. Delete Carefully

## Working Conventions

- Документация и комментарии: [русский / иной язык]
- Не менять архитектуру без прямого запроса
- Не хранить секреты в репозитории
- Паттерны загружать лениво через `_ai/patterns/_index.md`
- Для исследований сначала согласовывать путь к Markdown-результату
```
