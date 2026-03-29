# Hardcoded Values

## Why this is bad

- Захардкоженный AMI ID ломается при смене региона или обновлении образа
- Копипаста IP-адресов между окружениями приводит к тому, что dev-трафик идет в production
- Нельзя переиспользовать модуль в другом аккаунте или регионе без правки кода
- При обновлении одного значения приходится grep-ать и менять во всех файлах

## Bad Example

```hcl
# BAD: захардкоженные IP, AMI, регион повсюду
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  subnet_id              = "subnet-0bb1c79de3EXAMPLE"

  tags = {
    Name = "web-prod"
  }
}

resource "aws_security_group_rule" "allow_office" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["203.0.113.42/32"]
  security_group_id = "sg-0123456789abcdef0"
}
```

## Good Example

```hcl
# GOOD: переменные с описанием и валидацией
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.medium"
}

variable "office_cidr_blocks" {
  description = "Office IP ranges for SSH access"
  type        = list(string)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnets[0]

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.environment}-web"
  }
}
```

## What to look for in review

- Строки `ami-`, `sg-`, `subnet-`, `vpc-` с литеральными ID в `.tf` файлах
- IP-адреса (`cidr_blocks = ["x.x.x.x/32"]`) захардкоженные в ресурсах
- `region = "eu-west-1"` без использования переменной
- Дублирование одного и того же значения в нескольких `.tf` файлах
- Отсутствие `data` sources для динамических значений (AMI, AZ, account ID)
