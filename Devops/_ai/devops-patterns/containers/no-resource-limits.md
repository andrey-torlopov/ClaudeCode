# No Resource Limits

## Why this is bad

- Один контейнер без лимитов может съесть всю RAM ноды и вызвать OOM-killer для других подов
- CPU starvation: утечка в одном сервисе замедляет все остальные на ноде
- Kubernetes scheduler не может правильно распределять поды без requests
- Без лимитов невозможно планировать capacity и считать стоимость инфраструктуры

## Bad Example

```yaml
# BAD: под без ресурсных ограничений
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: api
          image: myapi:1.2.0
          ports:
            - containerPort: 8080
```

```bash
# BAD: docker run без ограничений памяти и CPU
docker run -d --name myapp myapp:1.2.0
```

## Good Example

```yaml
# GOOD: requests для scheduling, limits для защиты ноды
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: api
          image: myapi:1.2.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
```

```bash
# GOOD: docker run с ограничениями ресурсов
docker run -d --name myapp \
  --memory=512m \
  --cpus=0.5 \
  --memory-swap=512m \
  myapp:1.2.0
```

## What to look for in review

- K8s Deployment/Pod без секции `resources:` в спецификации контейнера
- `resources.requests` без `resources.limits` (или наоборот)
- `docker run` без `--memory` и `--cpus` флагов
- `docker-compose.yml` без секции `deploy.resources.limits`
- LimitRange и ResourceQuota не настроены для namespace
