# Naming Conventions

**Applies to:** Все файлы и ресурсы проекта

## Правила

- Файлы и директории: kebab-case (`my-service`, `deploy-script.sh`)
- Переменные Bash: `UPPER_SNAKE_CASE` для экспорта, `lower_snake_case` для локальных
- Terraform ресурсы: `snake_case`
- Kubernetes ресурсы: kebab-case
- Docker образы: kebab-case, семантическое версионирование тегов

## Bad Example

```bash
# BAD: смешанные стили
#!/bin/bash
myService_dir="/opt/MyService"          # camelCase + PascalCase
export dbHost="localhost"               # camelCase для экспорта
local COUNTER=0                         # UPPER для локальной
```

```hcl
# BAD: kebab-case в Terraform
resource "aws_instance" "my-web-server" {
  tags = { Name = "My Web Server" }
}
```

```yaml
# BAD: snake_case в K8s
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my_api_service
```

## Good Example

```bash
# GOOD: правильные стили
#!/bin/bash
readonly SERVICE_DIR="/opt/my-service"  # UPPER_SNAKE для экспорта/readonly
export DB_HOST="localhost"              # UPPER_SNAKE для экспорта
local counter=0                         # lower_snake для локальных
```

```hcl
# GOOD: snake_case в Terraform
resource "aws_instance" "my_web_server" {
  tags = { Name = "my-web-server" }
}
```

```yaml
# GOOD: kebab-case в K8s
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-api-service
```

## What to look for in review

- Файлы/директории не в kebab-case
- Экспортируемые Bash-переменные не в UPPER_SNAKE_CASE
- Локальные Bash-переменные в UPPER_SNAKE_CASE
- Terraform ресурсы не в snake_case
- K8s ресурсы не в kebab-case
- Docker-образы не в kebab-case или теги не по semver
