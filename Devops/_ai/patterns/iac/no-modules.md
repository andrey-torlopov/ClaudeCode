# No Modules

## Why this is bad

- Копипаста VPC-конфига в 5 окружений - при изменении надо править 5 мест
- Дрифт между окружениями: dev и prod расходятся потому что забыли обновить один из файлов
- Невозможно тестировать инфраструктурный блок изолированно
- Новому инженеру нужно разбираться в 2000 строк main.tf вместо набора именованных модулей

## Bad Example

```hcl
# BAD: VPC скопирован в каждое окружение, 200+ строк дублирования
# environments/dev/main.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "dev-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}

# ... еще 150 строк идентичных ресурсов (IGW, NAT, route tables)

# environments/prod/main.tf
# Те же 200 строк, скопированных с dev, с другим CIDR
```

## Good Example

```hcl
# GOOD: переиспользуемый модуль VPC
# modules/vpc/main.tf
variable "name" { type = string }
variable "cidr" { type = string }
variable "azs"  { type = list(string) }

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  tags = { Name = var.name }
}

output "vpc_id" { value = aws_vpc.this.id }

# environments/dev/main.tf
module "vpc" {
  source = "../../modules/vpc"
  name   = "dev-vpc"
  cidr   = "10.0.0.0/16"
  azs    = ["eu-west-1a", "eu-west-1b"]
}

# environments/prod/main.tf
module "vpc" {
  source = "../../modules/vpc"
  name   = "prod-vpc"
  cidr   = "10.1.0.0/16"
  azs    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
```

## What to look for in review

- Одинаковые блоки `resource` в нескольких директориях окружений
- `main.tf` длиннее 300 строк без разделения на модули
- Отсутствие директории `modules/` при наличии нескольких окружений
- Ansible playbooks с дублированными task-блоками вместо ролей
- Копипаста Helm values между окружениями без base + overlay
