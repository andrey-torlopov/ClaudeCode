# Security Conventions

**Applies to:** Вся инфраструктура и конфигурации проекта

## Правила

- Никаких секретов в коде, конфигах или git-истории
- Secret managers: Vault, AWS SSM, SOPS, sealed-secrets
- TLS везде, включая внутренние сервисы
- Минимальные привилегии для всех сервисов и пользователей
- SSH: только ключи, без паролей, порт != 22
- Firewall: deny all, allow explicitly

## Bad Example

```yaml
# BAD: секрет в конфиге, нет TLS, избыточные права
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: app
      env:
        - name: DB_PASSWORD
          value: "SuperSecret123"
        - name: API_URL
          value: "http://internal-api:8080"
      securityContext:
        privileged: true
```

```bash
# BAD: пароль в скрипте, SSH с паролем
#!/bin/bash
MYSQL_PASSWORD="root123"
mysql -u root -p${MYSQL_PASSWORD} -h db.example.com
sshpass -p "password" ssh root@server
```

## Good Example

```yaml
# GOOD: секреты через Secret, TLS, минимальные привилегии
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: app
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: API_URL
          value: "https://internal-api:8443"
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        runAsNonRoot: true
```

```bash
# GOOD: секреты из менеджера, SSH по ключу
#!/bin/bash
set -euo pipefail
MYSQL_PASSWORD="$(vault kv get -field=password secret/db)"
mysql -u app -p"${MYSQL_PASSWORD}" -h db.example.com --ssl-mode=REQUIRED
ssh -i ~/.ssh/deploy_key -p 2222 deploy@server
```

## What to look for in review

- Пароли, токены, ключи в коде или конфигах
- `.env` файлы с секретами в git
- HTTP вместо HTTPS для любых соединений
- `privileged: true` или `allowPrivilegeEscalation: true`
- SSH по паролю или на стандартном порту 22
- Firewall с правилами `0.0.0.0/0` без явной необходимости
- IAM/RBAC с `*` permissions
