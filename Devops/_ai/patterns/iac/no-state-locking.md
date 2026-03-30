# No State Locking

## Why this is bad

- Два параллельных `terraform apply` перезаписывают state друг друга, вызывая потерю ресурсов
- Corrupted state означает ручной импорт каждого ресурса или пересоздание инфраструктуры
- Локальный state на ноутбуке разработчика - единая точка отказа, нет командной работы
- Без версионирования state невозможно откатиться после неудачного apply

## Bad Example

```hcl
# BAD: локальный backend, нет блокировки, нет командной работы
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

```hcl
# BAD: S3 без DynamoDB - нет блокировки, race condition при параллельном apply
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}
```

## Good Example

```hcl
# GOOD: S3 с DynamoDB для блокировки и шифрованием state
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

```hcl
# GOOD: ресурсы для бутстрапа state backend
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

## What to look for in review

- `backend "local"` в Terraform конфигурации
- `backend "s3"` без `dynamodb_table`
- `terraform.tfstate` файлы в git-репозитории (должны быть в `.gitignore`)
- Отсутствие `encrypt = true` для remote backend
- Нет версионирования на S3 bucket со state
