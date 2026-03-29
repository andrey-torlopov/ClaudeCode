# No Rollback Strategy

## Why this is bad

- Плохой деплой без отката означает даунтайм до тех пор, пока не будет готов hotfix
- `DROP TABLE` или необратимая миграция не позволяет вернуться к предыдущей версии
- Overwrite in-place уничтожает предыдущую рабочую версию артефакта
- Без revision history невозможно быстро определить какая версия работала до инцидента

## Bad Example

```bash
# BAD: перезапись текущей версии без сохранения предыдущей
scp app.jar admin@prod:/opt/myapp/app.jar
ssh admin@prod "systemctl restart myapp"
```

```sql
-- BAD: необратимая миграция - нельзя откатить без бэкапа
ALTER TABLE users DROP COLUMN legacy_role;
DROP TABLE old_sessions;
```

```yaml
# BAD: деплой без revision history
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  revisionHistoryLimit: 0
  template:
    spec:
      containers:
        - name: app
          image: myapp:latest
```

## Good Example

```yaml
# GOOD: revision history + стратегия rolling update
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
        - name: app
          image: myapp:1.5.2
```

```sql
-- GOOD: обратимая миграция - данные сохраняются
ALTER TABLE users ADD COLUMN role_v2 VARCHAR(50);
UPDATE users SET role_v2 = legacy_role;
-- legacy_role удаляется в следующем релизе после подтверждения
```

```bash
# GOOD: быстрый откат через kubectl
kubectl rollout undo deployment/myapp
kubectl rollout status deployment/myapp
```

## What to look for in review

- `revisionHistoryLimit: 0` в K8s Deployment
- SQL миграции с `DROP TABLE`, `DROP COLUMN` без предварительного этапа deprecation
- Перезапись артефакта в registry одним и тем же тегом
- Отсутствие blue-green или canary стратегии для критичных сервисов
- Деплой-скрипты без шага "сохранить предыдущую версию"
