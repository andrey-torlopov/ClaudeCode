# Weak Permissions

## Why this is bad

- chmod 777 дает любому пользователю системы право читать, писать и выполнять файлы
- Приватные ключи с широкими правами отклоняются SSH-клиентом и становятся бесполезны
- Избыточные IAM-политики превращают компрометацию одного сервиса в компрометацию всего аккаунта
- Аудит безопасности невозможен, когда все имеют доступ ко всему

## Bad Example

```bash
# BAD: избыточные права на секретные файлы
chmod 777 /opt/myapp/config/
chmod 644 /home/deploy/.ssh/id_rsa
chmod 666 /etc/myapp/secrets.env
```

```hcl
# BAD: IAM-политика с полными правами
resource "aws_iam_role_policy" "app_policy" {
  name = "app-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
```

## Good Example

```bash
# GOOD: минимальные необходимые права
chmod 600 /home/deploy/.ssh/id_rsa
chmod 644 /home/deploy/.ssh/id_rsa.pub
chmod 700 /home/deploy/.ssh
chmod 750 /opt/myapp/config/
chown root:myapp /opt/myapp/config/
```

```hcl
# GOOD: IAM-политика с минимальными правами для конкретной задачи
resource "aws_iam_role_policy" "app_policy" {
  name = "app-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-app-bucket/*"
    }]
  })
}
```

## What to look for in review

- `chmod 777`, `chmod 666`, `chmod 755` на файлы с секретами
- Приватные ключи (`.pem`, `id_rsa`) с правами шире `600`
- IAM-политики с `Action: "*"` или `Resource: "*"`
- `AdministratorAccess` или `PowerUserAccess` на сервисные аккаунты
- K8s RBAC с `verbs: ["*"]` или `resources: ["*"]`
