# Project context
- Домен: DevOps, инфраструктура, автоматизация, CI/CD
- Языки: Bash, Python, YAML, HCL (Terraform), Dockerfile, JSON, TOML
- Комментарии и рассуждения пишем на русском языке

## AI-сетап
- Базовый промт и оркестратор: `_ai/dev_agent.md`.
- Роли агентов: `_ai/agents/`.
- Скиллы и команды: `_ai/skills/`, `_ai/commands/`; пост-хуки: `_ai/hooks/`.
- Паттерны и протоколы: `_ai/patterns/`, `_ai/protocols/`.

# Validation & Linting
- Bash: `shellcheck script.sh`
- YAML: `yamllint file.yml`
- Terraform: `terraform validate && terraform fmt -check`
- Dockerfile: `hadolint Dockerfile`
- Ansible: `ansible-lint playbook.yml`
- Kubernetes: `kubectl apply --dry-run=client -f manifest.yml`
- Python: `ruff check .`

## Project Structure
```
.
├── CLAUDE.md
└── <Infrastructure>
    ├── <Configs>
```
