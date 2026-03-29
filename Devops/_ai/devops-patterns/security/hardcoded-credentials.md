# Hardcoded Credentials

## Why this is bad

- Секреты попадают в git-историю и остаются там навсегда, даже после удаления файла
- Любой с доступом к репозиторию получает доступ к production-базе, API, серверам
- Ротация скомпрометированных секретов требует изменения кода и передеплоя
- Автоматические сканеры (truffleHog, git-secrets) находят такие утечки в публичных репо за минуты

## Bad Example

```yaml
# BAD: пароль базы данных прямо в docker-compose.yml
version: "3.8"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: "SuperSecret123!"
      POSTGRES_USER: "admin"
  app:
    image: myapp:latest
    environment:
      DATABASE_URL: "postgresql://admin:SuperSecret123!@db:5432/mydb"
      API_KEY: "sk-proj-abc123def456ghi789"
```

```bash
# BAD: токен захардкожен в деплой-скрипте
#!/bin/bash
curl -H "Authorization: Bearer ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  https://api.github.com/repos/myorg/myrepo/deployments
```

## Good Example

```yaml
# GOOD: секреты передаются через внешний secret manager
version: "3.8"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
  app:
    image: myapp:latest
    environment:
      DATABASE_URL_FILE: /run/secrets/database_url
    secrets:
      - database_url

secrets:
  db_password:
    external: true
  database_url:
    external: true
```

```bash
# GOOD: токен берется из vault в рантайме
#!/bin/bash
set -euo pipefail
TOKEN=$(vault kv get -field=token secret/github/deploy)
curl -H "Authorization: Bearer ${TOKEN}" \
  https://api.github.com/repos/myorg/myrepo/deployments
```

## What to look for in review

- Строки вида `password`, `secret`, `token`, `api_key` со значением рядом в YAML/JSON/ENV файлах
- Файлы `.env` без записи в `.gitignore`
- Строки `ghp_`, `sk-`, `AKIA`, `-----BEGIN RSA PRIVATE KEY-----` в любых файлах
- `docker-compose.yml` с `environment:` содержащим явные пароли
- Bash-скрипты с `curl -H "Authorization: Bearer <literal>"` или `export PASSWORD=...`
