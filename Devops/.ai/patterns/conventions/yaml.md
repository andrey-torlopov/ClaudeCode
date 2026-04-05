# YAML Conventions

**Applies to:** Все YAML-файлы проекта (CI/CD, K8s, Ansible, docker-compose)

## Правила

- 2 пробела отступ, без табов
- Строки в кавычках если содержат спецсимволы
- Явные булевы: `true`/`false`, не yes/no
- Якоря и алиасы (`&` / `*`) для DRY
- Комментарии для нетривиальных значений

## Bad Example

```yaml
# BAD: табы, yes/no, дублирование, нет комментариев
services:
	web:
		enabled: yes
		replicas: 3
		memory: 512Mi
		cpu: 250m
	api:
		enabled: yes
		replicas: 3
		memory: 512Mi
		cpu: 250m
```

## Good Example

```yaml
# GOOD: 2 пробела, true/false, якоря для DRY
x-defaults: &defaults
  replicas: 3
  resources:
    memory: "512Mi"
    cpu: "250m"

services:
  web:
    enabled: true
    <<: *defaults
  api:
    enabled: true
    <<: *defaults
    replicas: 5  # повышенная нагрузка на API
```

## What to look for in review

- Табы вместо пробелов или отступ != 2
- `yes`/`no`/`on`/`off` вместо `true`/`false`
- Строки со спецсимволами без кавычек
- Копипаста блоков вместо якорей/алиасов
- Магические числа без комментариев
