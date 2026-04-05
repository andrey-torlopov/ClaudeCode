# Manual Deployments

## Why this is bad

- Человеческий фактор: пропущенный шаг, опечатка в команде, деплой не в тот кластер
- Невоспроизводимость: "я деплоил в пятницу, но не помню какие флаги использовал"
- Нет аудит-трейла: кто, когда, что задеплоил - неизвестно
- Масштабирование невозможно: ручной деплой на 50 серверов занимает часы

## Bad Example

```bash
# BAD: деплой по SSH с ручными командами
ssh admin@production "
  cd /opt/myapp
  git pull origin main
  pip install -r requirements.txt
  sudo systemctl restart myapp
"
```

```bash
# BAD: ручной kubectl apply с локальной машины
kubectl config use-context production
kubectl apply -f deployment.yaml
kubectl rollout status deployment/myapp
```

```bash
# BAD: SCP файлов на сервер как метод деплоя
scp -r ./dist/ admin@web-server:/var/www/html/
ssh admin@web-server "sudo systemctl reload nginx"
```

## Good Example

```yaml
# GOOD: автоматический деплой через GitOps (ArgoCD)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/k8s-configs.git
    targetRevision: main
    path: apps/myapp/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

```yaml
# GOOD: CD пайплайн с автоматическим деплоем и smoke-тестом
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy via Helm
        run: |
          helm upgrade --install myapp ./chart \
            --namespace production \
            --set image.tag=${{ github.sha }} \
            --wait --timeout 300s
      - name: Smoke test
        run: |
          curl --fail --retry 5 --retry-delay 10 \
            https://api.example.com/healthz
```

## What to look for in review

- `ssh` + команды на production в runbook-ах или скриптах деплоя
- `kubectl apply` без обертки в CI/CD пайплайн
- `scp` / `rsync` как метод доставки артефактов
- Отсутствие файлов `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`
- Документация деплоя в виде списка ручных команд
