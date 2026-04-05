# Exposed Secrets

## Why this is bad

- Секреты в логах CI/CD доступны всем с доступом к пайплайну, включая подрядчиков
- `docker inspect` показывает все environment variables контейнера в открытом виде
- `/proc/<pid>/environ` позволяет прочитать переменные окружения любого процесса на хосте
- Логи часто отправляются в централизованные системы (ELK, Loki), расширяя поверхность утечки

## Bad Example

```bash
# BAD: секрет виден в логах пайплайна
echo "Deploying with token: ${DEPLOY_TOKEN}"
docker build --build-arg DB_PASSWORD="${DB_PASSWORD}" -t myapp .
```

```yaml
# BAD: секрет в переменных окружения пода - виден через kubectl describe
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
    - name: app
      image: myapp:1.0
      env:
        - name: DB_PASSWORD
          value: "SuperSecret123!"
```

```bash
# BAD: секрет в process list
mysql -u admin -pSuperSecret123! -h db.example.com mydb
```

## Good Example

```bash
# GOOD: секреты маскированы, передаются через файлы
echo "Deploying version ${APP_VERSION}..."
DOCKER_BUILDKIT=1 docker build \
  --secret id=db_pass,src=/run/secrets/db_password \
  -t myapp .
```

```yaml
# GOOD: секрет через K8s Secret, не виден в describe
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
    - name: app
      image: myapp:1.0
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: db-password
      volumeMounts:
        - name: secrets
          mountPath: /run/secrets
          readOnly: true
  volumes:
    - name: secrets
      secret:
        secretName: myapp-secrets
```

## What to look for in review

- `echo` с `$SECRET`, `$PASSWORD`, `$TOKEN`, `$API_KEY` в CI-скриптах
- `docker build --build-arg` с секретными переменными
- K8s манифесты с `env.value:` вместо `env.valueFrom.secretKeyRef:`
- Команды с паролем в аргументах (`mysql -p<password>`, `curl -u user:pass`)
- Логирование полных HTTP-заголовков (содержат Authorization)
