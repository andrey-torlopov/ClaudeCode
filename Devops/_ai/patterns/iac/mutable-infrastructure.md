# Mutable Infrastructure

## Why this is bad

- Ручные правки на сервере не зафиксированы в коде - при пересоздании сервера они теряются
- Configuration drift: production отличается от staging, и никто не знает чем именно
- Невоспроизводимые окружения: "работает на этом сервере" потому что кто-то поставил пакет руками
- Аудит невозможен - нет истории кто, когда и что менял на сервере

## Bad Example

```bash
# BAD: SSH на production для ручного исправления
ssh admin@prod-server-01
sudo apt-get update && sudo apt-get install -y libssl3
sudo vim /etc/nginx/nginx.conf
sudo systemctl restart nginx
```

```yaml
# BAD: Ansible playbook, который мутирует существующие серверы ad-hoc
- hosts: production
  become: true
  tasks:
    - name: Quick fix for memory leak
      lineinfile:
        path: /etc/sysctl.conf
        line: "vm.swappiness=10"
    - name: Restart app
      systemd:
        name: myapp
        state: restarted
```

## Good Example

```hcl
# GOOD: immutable AMI через Packer, замена инстансов при изменении
data "aws_ami" "app" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myapp-*"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "myapp-"
  image_id      = data.aws_ami.app.id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}
```

```yaml
# GOOD: GitOps - все изменения через git, ArgoCD синхронизирует
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  source:
    repoURL: https://github.com/myorg/k8s-manifests.git
    targetRevision: main
    path: apps/myapp
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## What to look for in review

- `ssh` + ручные команды в runbook-ах и документации
- Ansible ad-hoc команды (`ansible all -m shell -a "..."`) в production
- Отсутствие Packer/Docker для создания образов
- `terraform taint` / `terraform apply -target` как регулярная практика
- Конфиг-файлы на серверах, которые не генерируются из шаблонов
