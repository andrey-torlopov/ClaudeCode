# Latest Tag

## Why this is bad

- `:latest` - мутабельный тег: сегодня это nginx 1.25, завтра - 1.26 с breaking changes
- Невозможно воспроизвести сборку - непонятно, какая версия была в production в момент инцидента
- Kubernetes не пуллит новый образ при `imagePullPolicy: IfNotPresent`, потому что тег тот же
- Откат невозможен - старая версия перезаписана тем же тегом `:latest`

## Bad Example

```dockerfile
# BAD: неизвестно какая версия Ubuntu окажется в сборке
FROM ubuntu:latest
RUN apt-get update && apt-get install -y nginx
```

```yaml
# BAD: при каждом рестарте пода может прилететь другой образ
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: web
          image: nginx:latest
```

## Good Example

```dockerfile
# GOOD: фиксированная версия, воспроизводимая сборка
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx=1.24.0-1~jammy
```

```yaml
# GOOD: образ привязан к конкретному digest
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: web
          image: nginx:1.25.3@sha256:6a59f1cbb8d28ac484176d52c473494859a512ddba3ea62a547258cf16c9b3
```

## What to look for in review

- `FROM <image>:latest` или `FROM <image>` без тега в Dockerfile
- `image: <name>:latest` в K8s манифестах и docker-compose.yml
- `image: <name>` без указания тега вообще (подразумевает `:latest`)
- `docker pull <image>` без тега в скриптах
- Отсутствие `@sha256:` в production-конфигах
