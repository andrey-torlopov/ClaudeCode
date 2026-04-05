# Security Rules Reference

## 1. Secrets Detection Patterns

Grep-паттерны для поиска секретов в коде:

### Пароли и ключи
```
password\s*[:=]
passwd\s*[:=]
secret\s*[:=]
api_key\s*[:=]
apikey\s*[:=]
api_secret\s*[:=]
access_key\s*[:=]
private_key\s*[:=]
auth_token\s*[:=]
```

### Cloud-провайдеры
```
AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID
AKIA[0-9A-Z]{16}
azure_client_secret
google_credentials
```

### SSH и сертификаты
```
BEGIN RSA PRIVATE KEY
BEGIN OPENSSH PRIVATE KEY
BEGIN EC PRIVATE KEY
BEGIN PGP PRIVATE KEY
BEGIN CERTIFICATE
```

### Токены и JWT
```
ghp_[0-9a-zA-Z]{36}
gho_[0-9a-zA-Z]{36}
glpat-[0-9a-zA-Z\-]{20}
eyJ[A-Za-z0-9_-]*\.eyJ
Bearer\s+[A-Za-z0-9\-._~+/]+=*
```

### False Positive исключения

Не флаговать:
- Ссылки на переменные окружения: `${SECRET_KEY}`, `$DB_PASSWORD`
- Ссылки на секрет-менеджеры: `vault:secret/...`, `aws_secretsmanager`
- Placeholder значения: `<YOUR_KEY_HERE>`, `CHANGE_ME`, `xxx`
- Примеры в документации (внутри code blocks в .md файлах)

---

## 2. TLS Verification Checklist

| # | Проверка | Severity |
|---|---------|----------|
| TLS-1 | Все внешние эндпоинты через HTTPS | CRITICAL |
| TLS-2 | Сертификаты автоматически обновляются (cert-manager, Let's Encrypt) | WARNING |
| TLS-3 | Минимальная версия TLS 1.2 | CRITICAL |
| TLS-4 | Не используются self-signed сертификаты в production | WARNING |
| TLS-5 | Internal traffic шифруется (service mesh TLS, mTLS) | INFO |

### Что искать
- `http://` в конфигах (кроме localhost и healthcheck)
- Порт 80 без редиректа на 443
- `tls.minVersion` < 1.2
- `insecureSkipVerify: true` / `verify_ssl: false`

---

## 3. Network Security Checklist

| # | Проверка | Severity |
|---|---------|----------|
| NET-1 | NetworkPolicy по умолчанию deny-all | WARNING |
| NET-2 | Нет wildcard ingress (0.0.0.0/0) для production | CRITICAL |
| NET-3 | Internal сервисы не выставлены наружу | CRITICAL |
| NET-4 | Security groups с минимальными правилами | WARNING |
| NET-5 | DNS-резолвинг через internal DNS, не hardcoded IP | INFO |

### Что искать
- `0.0.0.0/0` или `::/0` в ingress rules
- `type: LoadBalancer` для internal сервисов
- `hostNetwork: true` без обоснования
- `hostPort` в pod spec
- Отсутствие `NetworkPolicy` в namespace

---

## 4. Container Security Checklist

| # | Проверка | Severity |
|---|---------|----------|
| CS-1 | Не запускать от root | WARNING |
| CS-2 | Read-only root filesystem | INFO |
| CS-3 | Drop all capabilities, add explicitly | WARNING |
| CS-4 | No privileged mode | BLOCKER |
| CS-5 | Seccomp/AppArmor profile | INFO |
| CS-6 | Image signing / scanning в CI | INFO |

### Что искать в K8s SecurityContext
```yaml
securityContext:
  runAsNonRoot: true       # CS-1: должен быть true
  readOnlyRootFilesystem: true  # CS-2: рекомендовано
  allowPrivilegeEscalation: false  # обязательно
  capabilities:
    drop: ["ALL"]          # CS-3: drop all
    add: ["NET_BIND_SERVICE"]  # добавлять только необходимое
```

### Что искать в Dockerfile
```dockerfile
USER nonroot              # CS-1: не root
RUN addgroup -S app && adduser -S app -G app  # создание пользователя
```

---

## 5. RBAC Best Practices

| Правило | Описание |
|---------|----------|
| Least Privilege | Минимальные необходимые права |
| No cluster-admin | Не использовать cluster-admin для сервисов |
| Namespace-scoped | Предпочитать Role над ClusterRole |
| Service Accounts | Отдельный SA для каждого сервиса |
| No wildcard verbs | Не использовать `verbs: ["*"]` |
| No wildcard resources | Не использовать `resources: ["*"]` |

### Что искать
- `ClusterRoleBinding` с `cluster-admin`
- `rules` с `verbs: ["*"]` или `resources: ["*"]`
- Использование `default` ServiceAccount
- Отсутствие `automountServiceAccountToken: false`

---

## 6. Compliance References

### CIS Kubernetes Benchmark (ключевые пункты)

| ID | Проверка | Категория |
|----|---------|-----------|
| 5.1.1 | Не использовать cluster-admin | RBAC |
| 5.1.3 | Минимизировать wildcard access | RBAC |
| 5.2.1 | Минимизировать привилегированные контейнеры | Pod Security |
| 5.2.2 | Не запускать контейнеры от root | Pod Security |
| 5.2.3 | Не использовать hostNetwork | Pod Security |
| 5.2.4 | Не использовать hostPID/hostIPC | Pod Security |
| 5.4.1 | Предпочитать Secrets через файлы, не env vars | Secrets |
| 5.7.1 | Включить NetworkPolicy | Network |

### CIS Docker Benchmark (ключевые пункты)

| ID | Проверка | Категория |
|----|---------|-----------|
| 4.1 | Не запускать контейнеры от root | Container |
| 4.2 | Использовать trusted base images | Images |
| 4.6 | Добавить HEALTHCHECK | Container |
| 4.9 | Не хранить секреты в Dockerfile | Secrets |
| 5.10 | Установить memory limits | Resources |
| 5.12 | Не использовать privileged | Security |
