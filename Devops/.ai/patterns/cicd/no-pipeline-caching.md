# No Pipeline Caching

## Why this is bad

- Каждая сборка скачивает все зависимости заново - npm install на 500 пакетов занимает 2+ минуты
- Docker слои пересобираются с нуля без BuildKit cache, даже если код не менялся
- Медленные пайплайны демотивируют разработчиков и замедляют цикл обратной связи
- Лишний трафик к registry и package managers увеличивает счет и создает risk rate-limiting

## Bad Example

```yaml
# BAD: каждый запуск скачивает все зависимости заново
name: CI
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install
      - run: npm test
      - run: npm run build
```

```dockerfile
# BAD: COPY . . перед npm ci инвалидирует кеш при любом изменении файла
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build
CMD ["node", "dist/server.js"]
```

## Good Example

```yaml
# GOOD: кеширование зависимостей между запусками
name: CI
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test
      - run: npm run build
```

```dockerfile
# GOOD: package.json копируется первым для оптимального кеширования слоев
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

```yaml
# GOOD: Docker BuildKit cache в CI
- name: Build with cache
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: myapp:${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## What to look for in review

- CI-конфиги без `cache:`, `actions/cache`, или `cache-from`
- Dockerfile с `COPY . .` перед `RUN npm ci` / `pip install`
- `docker build` без `--cache-from` в CI/CD пайплайнах
- Время сборки >5 минут при неизмененных зависимостях
- `pip install` без `--cache-dir` или `pip cache` в CI
