# Project Context

- SSOT: `COMMON.md`
- Entry points: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
- Домен: DevOps, инфраструктура, автоматизация, CI/CD
- Языки: Bash, Python, YAML, HCL (Terraform), Dockerfile, JSON, TOML
- Комментарии и документация: на русском языке

## Verify

- Bash: `shellcheck script.sh`
- YAML: `yamllint file.yml`
- Terraform: `terraform validate && terraform fmt -check`
- Dockerfile: `hadolint Dockerfile`
- Ansible: `ansible-lint playbook.yml`
- Kubernetes: `kubectl apply --dry-run=client -f manifest.yml`
- Python: `ruff check .`

## AI Layers

- `_ai/dev_agent.md` — базовая роль и лёгкая маршрутизация.
- `_ai/agents/` — компактные role cards.
- `_ai/skills/` — специализированные сценарии.
- `_ai/commands/` — короткие command-prompts.
- `_ai/patterns/_index.md` — lazy-load каталог паттернов.
- `_ai/hooks/skill-lint.sh` — быстрая валидация AI-файлов.
