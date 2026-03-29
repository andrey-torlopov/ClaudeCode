# Running as Root

## Why this is bad

- Компрометация процесса дает атакующему полный контроль над хостом или контейнером
- Root внутри контейнера при escape-уязвимости становится root на хосте
- Нарушает принцип наименьших привилегий - процессу не нужны права root для работы
- Compliance-требования (PCI DSS, SOC2) явно запрещают запуск сервисов от root

## Bad Example

```dockerfile
# BAD: контейнер работает от root (USER не указан)
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

```ini
# BAD: systemd-сервис от root без ограничений
[Service]
ExecStart=/opt/myapp/bin/server
Restart=always
```

```bash
# BAD: SSH как root на production
ssh root@production-server "systemctl restart nginx"
```

## Good Example

```dockerfile
# GOOD: выделенный пользователь с минимальными правами
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=build --chown=appuser:appgroup /app .
COPY --chown=appuser:appgroup . .
USER appuser
EXPOSE 3000
CMD ["node", "server.js"]
```

```ini
# GOOD: systemd-сервис с выделенным пользователем и ограничениями
[Service]
User=myapp
Group=myapp
ExecStart=/opt/myapp/bin/server
Restart=always
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
```

## What to look for in review

- Dockerfile без инструкции `USER` перед `CMD`/`ENTRYPOINT`
- `ssh root@` в скриптах или документации
- `systemd` unit-файлы без `User=` / `Group=`
- K8s манифесты без `securityContext.runAsNonRoot: true`
- `docker run` без `--user` флага
