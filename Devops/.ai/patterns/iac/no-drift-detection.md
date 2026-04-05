# No Drift Detection

## Why this is bad

- Ручные изменения через консоль AWS/GCP накапливаются и state перестает отражать реальность
- `terraform apply` может удалить ресурсы, добавленные вручную, вызвав даунтайм
- Нарушения безопасности (открытый security group) остаются незамеченными неделями
- Нет уверенности, что disaster recovery воссоздаст идентичную инфраструктуру

## Bad Example

```yaml
# BAD: terraform apply только при деплое, между деплоями дрифт не отслеживается
name: Deploy Infrastructure
on:
  push:
    branches: [main]
    paths: ["terraform/**"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

## Good Example

```yaml
# GOOD: ежедневный plan выявляет дрифт и уведомляет команду
name: Drift Detection
on:
  schedule:
    - cron: "0 8 * * *"
  workflow_dispatch:

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Detect Drift
        id: plan
        run: terraform plan -detailed-exitcode -out=plan.tfplan
        continue-on-error: true

      - name: Notify on Drift
        if: steps.plan.outcome == 'failure'
        run: |
          curl -X POST "${{ secrets.SLACK_WEBHOOK }}" \
            -H "Content-Type: application/json" \
            -d '{"text": "Infrastructure drift detected! Review terraform plan output."}'
```

```yaml
# GOOD: ArgoCD автоматически обнаруживает и исправляет дрифт K8s ресурсов
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 3
```

## What to look for in review

- Отсутствие `terraform plan` в scheduled CI/CD pipeline
- Нет алертов при расхождении state с реальной инфраструктурой
- ArgoCD/Flux без `selfHeal: true`
- Команда регулярно использует cloud-консоль для ручных изменений
- Нет процесса reconciliation между IaC и реальным состоянием
