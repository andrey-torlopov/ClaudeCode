# Privileged Containers

## Why this is bad

- `--privileged` дает контейнеру доступ ко всем устройствам хоста и отключает все ограничения
- `SYS_ADMIN` capability позволяет монтировать файловые системы и выполнять escape из контейнера
- `hostNetwork: true` ломает сетевую изоляцию - контейнер видит все порты хоста
- Один скомпрометированный привилегированный контейнер = полный контроль над нодой

## Bad Example

```bash
# BAD: контейнер с полными привилегиями хоста
docker run -d --privileged --name monitoring cadvisor:latest
```

```yaml
# BAD: под с избыточными capabilities и hostNetwork
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  hostNetwork: true
  hostPID: true
  containers:
    - name: debug
      image: ubuntu:22.04
      securityContext:
        privileged: true
        capabilities:
          add: ["SYS_ADMIN", "NET_ADMIN"]
```

## Good Example

```bash
# GOOD: контейнер с минимальными capabilities
docker run -d \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --security-opt=no-new-privileges \
  --name web nginx:1.25.3
```

```yaml
# GOOD: жесткий securityContext с минимальными правами
apiVersion: v1
kind: Pod
metadata:
  name: api
spec:
  containers:
    - name: api
      image: myapi:1.2.0
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir: {}
```

## What to look for in review

- `--privileged` в `docker run` или `docker-compose.yml`
- `privileged: true` в K8s securityContext
- `capabilities.add` с `SYS_ADMIN`, `NET_ADMIN`, `SYS_PTRACE`
- `hostNetwork: true`, `hostPID: true`, `hostIPC: true` в спецификации пода
- Отсутствие `allowPrivilegeEscalation: false` и `capabilities.drop: ["ALL"]`
