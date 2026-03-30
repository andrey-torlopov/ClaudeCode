# Docker Conventions

**Applies to:** Все Dockerfile и docker-compose конфигурации проекта

## Правила

- Multi-stage builds для уменьшения размера
- Минимальные базовые образы (alpine, distroless, scratch)
- `USER nonroot` - не запускать от root
- `COPY` вместо `ADD` (кроме tar-архивов)
- Один процесс на контейнер
- `HEALTHCHECK` в каждом образе
- `.dockerignore` для исключения лишнего
- Фиксированные версии образов, не `:latest`

## Bad Example

```dockerfile
# BAD: один stage, ubuntu, root, ADD, нет healthcheck, latest
FROM ubuntu:latest

ADD . /app
WORKDIR /app
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip install -r requirements.txt

CMD ["python3", "app.py"]
```

## Good Example

```dockerfile
# GOOD: multi-stage, alpine, nonroot, COPY, healthcheck, pinned version
FROM python:3.12-alpine AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

FROM python:3.12-alpine
RUN adduser -D appuser
WORKDIR /app

COPY --from=builder /deps /usr/local/lib/python3.12/site-packages
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["python3", "app.py"]
```

## What to look for in review

- Один stage для сборки и runtime
- Тяжёлые базовые образы (ubuntu, debian) без необходимости
- Отсутствие `USER` - контейнер работает от root
- `ADD` вместо `COPY` (кроме tar/URL)
- Несколько процессов в одном контейнере
- Отсутствие `HEALTHCHECK`
- Нет `.dockerignore` в проекте
- `:latest` или отсутствие тега у базового образа
