# Terraform Conventions

**Applies to:** Все Terraform/HCL-конфигурации проекта

## Правила

- Переменные с `description` и `type`
- Outputs для межмодульного взаимодействия
- Backend с state locking (S3+DynamoDB, GCS, etc.)
- Data sources вместо хардкода
- Теги на все ресурсы: Name, Environment, ManagedBy
- Модули для повторяющихся паттернов
- `terraform fmt` перед коммитом

## Bad Example

```hcl
# BAD: нет description/type, хардкод, нет тегов, нет модулей
variable "region" {}

resource "aws_instance" "web" {
  ami           = "ami-0123456789"
  instance_type = "t3.medium"
  subnet_id     = "subnet-abc123"
}
```

## Good Example

```hcl
# GOOD: типизированные переменные, data sources, теги, модули
variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

module "web" {
  source = "./modules/ec2-instance"

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  tags = {
    Name        = "web-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

## What to look for in review

- Переменные без `description` или `type`
- Захардкоженные AMI ID, subnet ID, IP-адреса
- Ресурсы без тегов Name, Environment, ManagedBy
- Копипаста блоков вместо модулей
- Backend без state locking
- Отсутствие outputs для межмодульного взаимодействия
