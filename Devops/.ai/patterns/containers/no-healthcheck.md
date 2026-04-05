# No Healthcheck

## Why this is bad

- Контейнер может висеть с zombie-процессом и считаться "здоровым" для оркестратора
- Без readinessProbe K8s отправляет трафик на под, который еще не готов принимать запросы
- Без livenessProbe зависший процесс никогда не будет перезапущен автоматически
- Балансировщик не может убрать нездоровый инстанс из ротации

## Bad Example

```dockerfile
# BAD: нет healthcheck - Docker не знает жив ли процесс
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci
EXPOSE 3000
CMD ["node", "server.js"]
```

```yaml
# BAD: K8s под без проб - трафик идет сразу, перезапуска при зависании нет
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  template:
    spec:
      containers:
        - name: api
          image: myapi:1.2.0
          ports:
            - containerPort: 8080
```

## Good Example

```dockerfile
# GOOD: Docker healthcheck проверяет реальный ответ приложения
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --spider -q http://localhost:3000/healthz || exit 1
CMD ["node", "server.js"]
```

```yaml
# GOOD: K8s пробы для полного lifecycle-контроля
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  template:
    spec:
      containers:
        - name: api
          image: myapi:1.2.0
          ports:
            - containerPort: 8080
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          startupProbe:
            httpGet:
              path: /healthz
              port: 8080
            failureThreshold: 30
            periodSeconds: 10
```

## What to look for in review

- Dockerfile без инструкции `HEALTHCHECK`
- K8s Deployment без `livenessProbe` и `readinessProbe`
- Health endpoint, который всегда возвращает 200 без реальной проверки зависимостей
- `initialDelaySeconds: 0` при долгом старте приложения
- Отсутствие `startupProbe` для приложений с медленной инициализацией
