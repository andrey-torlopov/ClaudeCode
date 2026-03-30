# Kubernetes Conventions

**Applies to:** Все Kubernetes-манифесты проекта

## Правила

- Resource limits и requests обязательны
- Readiness и liveness probes
- Network policies для изоляции
- RBAC: минимальные привилегии
- Namespaces для разделения окружений
- Labels и annotations для всех ресурсов
- ConfigMaps/Secrets для конфигурации, не хардкод

## Bad Example

```yaml
# BAD: нет limits, нет probes, нет labels, хардкод конфигурации
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: myapp:1.0
          env:
            - name: DB_HOST
              value: "10.0.1.50"
            - name: DB_PASSWORD
              value: "s3cret"
```

## Good Example

```yaml
# GOOD: limits, probes, labels, secrets, RBAC
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app.kubernetes.io/name: api
    app.kubernetes.io/part-of: platform
    app.kubernetes.io/managed-by: kubectl
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: api
  template:
    metadata:
      labels:
        app.kubernetes.io/name: api
    spec:
      containers:
        - name: api
          image: myapp:1.0.3
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
          envFrom:
            - configMapRef:
                name: api-config
            - secretRef:
                name: api-secrets
```

## What to look for in review

- Контейнеры без `resources.requests` и `resources.limits`
- Отсутствие readiness/liveness probes
- Хардкоженные значения конфигурации вместо ConfigMap/Secret
- Пароли и токены прямо в манифестах
- Отсутствие стандартных labels (`app.kubernetes.io/*`)
- Всё в namespace `default`
- Отсутствие NetworkPolicy
