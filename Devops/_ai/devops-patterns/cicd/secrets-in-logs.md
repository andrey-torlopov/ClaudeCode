# Secrets in Logs

## Why this is bad

- CI/CD логи доступны всем разработчикам с правами на репозиторий, включая внешних контрибьюторов
- `docker build --build-arg` записывает аргумент в image layer history навсегда
- Логи часто хранятся без шифрования и ротации месяцами
- Бот-сканеры автоматически парсят публичные CI-логи на GitHub Actions

## Bad Example

```yaml
# BAD: секреты утекают через echo и build-arg
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: |
          echo "Using token: ${{ secrets.DEPLOY_TOKEN }}"
          docker build \
            --build-arg DB_PASSWORD=${{ secrets.DB_PASSWORD }} \
            --build-arg API_KEY=${{ secrets.API_KEY }} \
            -t myapp:${{ github.sha }} .

      - name: Debug
        run: env | sort
```

## Good Example

```yaml
# GOOD: секреты замаскированы, передаются через secret mount
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: |
          echo "${{ secrets.DB_PASSWORD }}" > /tmp/db_password
          DOCKER_BUILDKIT=1 docker build \
            --secret id=db_pass,src=/tmp/db_password \
            -t myapp:${{ github.sha }} .
          rm -f /tmp/db_password

      - name: Deploy
        run: |
          echo "Deploying version ${{ github.sha }}..."
          helm upgrade myapp ./chart \
            --set image.tag=${{ github.sha }}
```

```dockerfile
# GOOD: секреты через BuildKit mount, не остаются в layer
FROM golang:1.22 AS builder
WORKDIR /app
COPY . .
RUN --mount=type=secret,id=db_pass \
    DB_PASSWORD=$(cat /run/secrets/db_pass) go build -o /server

FROM gcr.io/distroless/static-debian12
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

## What to look for in review

- `echo` с переменными `${{ secrets.* }}` или `$SECRET_*` в CI-пайплайнах
- `docker build --build-arg` с секретными значениями
- Шаг `env | sort` или `printenv` в пайплайне
- `set -x` в скриптах, которые работают с секретами
- Отсутствие `add-mask` для динамически полученных секретов в GitHub Actions
