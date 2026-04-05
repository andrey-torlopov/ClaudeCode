---
name: dependency-check
description: Анализирует зависимости инфраструктурного проекта (Docker-образы, Terraform-провайдеры, Helm-чарты, пакеты ОС) на актуальность и уязвимости. Используй перед обновлением зависимостей или для аудита текущего состояния. Не используй для ревью инфраструктуры - для этого /infra-review.
allowed-tools: "Read Write Glob Grep Bash(docker*) Bash(curl*) Bash(wc*) Bash(helm*) Bash(terraform*)"
context: fork
---

# /dependency-check - Анализ инфраструктурных зависимостей

<purpose>
Анализ зависимостей DevOps-проекта: Docker-образы, Terraform-провайдеры, Helm-чарты, пакеты ОС. Помогает принять решение об обновлении и выявить уязвимости.
</purpose>

## Когда использовать

- Перед обновлением зависимостей инфраструктуры
- Периодический аудит "здоровья" зависимостей
- При добавлении нового компонента (проверка совместимости)
- Оценка tech debt в инфраструктурных зависимостях

## Когда НЕ использовать

- Ревью инфраструктуры (используй `/infra-review`)
- Разведка репо (используй `/repo-scout`)

## Входные данные

- Путь к проекту с Dockerfile / terraform / docker-compose.yml (или текущая директория)

---

## Verbosity Protocol

**Tools first:** Анализируй молча. В чат - только сводка + путь к отчету.

---

## Алгоритм

### Шаг 1: Discovery

1. Найди и прочитай `Dockerfile` / `Dockerfile.*` / `*.Dockerfile`
2. Найди и прочитай `docker-compose.yml` / `docker-compose.*.yml`
3. Найди и прочитай `*.tf` файлы (Terraform)
4. Найди и прочитай `requirements.yml` / `galaxy.yml` (Ansible)
5. Найди и прочитай `Chart.yaml` / `Chart.lock` (Helm)
6. Найди и прочитай `requirements.txt` / `Pipfile` / `package.json`

Если ни один файл зависимостей не найден -> сообщи пользователю и заверши.

### Шаг 2: Dependency Inventory

Для каждой зависимости извлеки:
- Название компонента
- Источник (Docker Hub, Terraform Registry, Helm repo, PyPI, npm)
- Указанная версия / тег
- Тип фиксации (точная / диапазон / latest / отсутствует)

Классифицируй по категориям:
- **Base Images:** alpine, ubuntu, nginx, python, node, golang и т.д.
- **Terraform Providers:** aws, azurerm, google, kubernetes, helm и т.д.
- **Helm Charts:** ingress-nginx, cert-manager, prometheus, grafana и т.д.
- **OS Packages:** apt-get install / apk add / yum install зависимости в Dockerfile
- **Python deps:** pip install / requirements.txt
- **Node deps:** package.json зависимости
- **Ansible Collections:** community.general, ansible.posix и т.д.

### Шаг 3: Version Analysis

Для каждой зависимости:
1. Определи тип version constraint:
   - Exact (`nginx:1.25.3`, `= 5.0.0`) -> стандарт для production
   - Range (`~> 5.0`, `>=1.2`) -> гибко, но может сломаться
   - Latest / нет тега (`nginx:latest`, `FROM python`) -> нестабильно
   - SHA digest (`nginx@sha256:abc...`) -> максимальная фиксация

2. Отметь потенциальные проблемы:
   - Тег `latest` или отсутствие тега -> CRITICAL
   - Нефиксированные мажорные версии -> WARNING
   - Устаревшие базовые образы (EOL) -> WARNING
   - SHA-digest без комментария с версией -> INFO

### Шаг 4: Health Assessment

Для каждой зависимости оцени "здоровье" (на основе данных из файлов проекта):

| Индикатор | Оценка |
|-----------|--------|
| Version pinning strategy | Strict/Flexible/Unstable |
| Критичность компонента | Core/Supporting/Development |
| Известные проблемы безопасности | Есть/Нет/Неизвестно |

### Шаг 5: Conflict Detection

1. Проверь нет ли конфликтов базовых образов (разные версии одного образа в разных Dockerfile)
2. Найди несовместимости версий Terraform-провайдеров
3. Проверь совместимость Helm-чартов с версией Kubernetes
4. Проверь дублирование зависимостей (один пакет в requirements.txt и в Dockerfile)

### Шаг 6: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/dependency-check-report.md`.

---

## Формат отчета

```markdown
# Dependency Check Report

> Project: {name}
> Тип инфраструктуры: {Docker / Terraform / Kubernetes / Mixed}
> Зависимостей: {N}
> Дата: {YYYY-MM-DD}

## Summary

| Метрика | Значение |
|---------|----------|
| Всего зависимостей | {N} |
| Docker-образы | {N} |
| Terraform-провайдеры | {N} |
| Helm-чарты | {N} |
| OS-пакеты | {N} |
| Python/Node deps | {N} |
| Без фиксации версии (нестабильные) | {N} |
| Warnings | {N} |

## Dependencies Inventory

| # | Компонент | Версия | Фиксация | Категория | Статус |
|---|-----------|--------|----------|-----------|--------|
| 1 | {name} | {version} | {exact/range/latest/sha} | {Base Images/...} | {OK/WARNING/CRITICAL} |

## Warnings

| # | Компонент | Проблема | Рекомендация |
|---|-----------|---------|--------------|

## Категории

### Base Images ({N})
{список}

### Terraform Providers ({N})
{список}

### Helm Charts ({N})
{список}

### OS Packages ({N})
{список}

### Python/Node deps ({N})
{список}

### Ansible Collections ({N})
{список}

## Рекомендации

{Конкретные рекомендации по обновлению/замене зависимостей}
```

---

## Quality Gates

- [ ] Все файлы зависимостей найдены и распарсены
- [ ] Все зависимости каталогизированы
- [ ] Каждая зависимость классифицирована по категории
- [ ] Warnings имеют конкретную рекомендацию
- [ ] Нет placeholder-ов в отчете

## Завершение

```
SKILL COMPLETE: /dependency-check
|- Артефакты: {путь к отчету}
|- Зависимостей: {N} ({X} Docker, {Y} Terraform, {Z} Helm)
|- Warnings: {N}
```
