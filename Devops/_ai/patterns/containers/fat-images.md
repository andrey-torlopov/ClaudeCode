# Fat Images

## Why this is bad

- Образ 1GB+ означает медленный pull при каждом деплое и scale-up, особенно в spot-инстансах
- Каждый лишний пакет - потенциальная CVE; больше поверхность атаки
- Тратится дисковое пространство на нодах и в registry, растет счет за storage
- Медленные CI/CD пайплайны из-за долгой сборки и передачи образов

## Bad Example

```dockerfile
# BAD: полная Ubuntu с компилятором оставлена в финальном образе
FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y python3 python3-pip gcc libpq-dev curl wget vim && \
    pip3 install flask gunicorn psycopg2
WORKDIR /app
COPY . .
EXPOSE 5000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

```dockerfile
# BAD: node_modules с devDependencies в production-образе
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
```

## Good Example

```dockerfile
# GOOD: multi-stage build, минимальный финальный образ
FROM python:3.12-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
WORKDIR /app
COPY app.py .
EXPOSE 5000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

```dockerfile
# GOOD: distroless для Go - только бинарник
FROM golang:1.22 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server

FROM gcr.io/distroless/static-debian12
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

## What to look for in review

- `FROM ubuntu`, `FROM debian` без `-slim` в финальном stage
- Отсутствие multi-stage build при наличии build-зависимостей
- `apt-get install` без `--no-install-recommends` и без `rm -rf /var/lib/apt/lists/*`
- `npm install` вместо `npm ci --only=production`
- Нет `.dockerignore` в корне проекта (`.git`, `node_modules` попадают в контекст)
