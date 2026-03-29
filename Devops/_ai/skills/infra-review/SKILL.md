---
name: infra-review
description: Глубокий ревью инфраструктурного кода с фокусом на безопасность, контейнеры, IaC, скрипты, CI/CD и архитектуру. Используй для ревью Dockerfile, Terraform, K8s-манифестов, Ansible, Bash-скриптов. Не используй для анализа зависимостей - для этого /dependency-check.
allowed-tools: "Read Write Edit Glob Grep Bash(wc*)"
context: fork
---

# /infra-review - Глубокий ревью инфраструктуры

<purpose>
Структурированный ревью инфраструктурного кода по чек-листу: безопасность, контейнеры, IaC, скрипты, CI/CD, архитектура. Результат - отчет с приоритизированными findings.
</purpose>

## Когда использовать

- Ревью Dockerfile / docker-compose перед мержем
- Аудит Terraform-модулей перед apply
- Проверка K8s-манифестов перед деплоем
- Ревью Bash/Python скриптов автоматизации
- Аудит CI/CD пайплайнов
- Глубокий анализ конкретного аспекта (security, containers, IaC)

## Когда НЕ использовать

- Анализ зависимостей (используй `/dependency-check`)
- Разведка нового репо (используй `/repo-scout`)
- Планирование рефакторинга (используй `/refactor-plan`)

## Входные данные

| Параметр | Обязательность | Описание |
|----------|:--------------:|----------|
| Scope | Обязательно | Путь к файлу, модулю или директории |
| Focus | Опционально | Конкретный аспект: security, containers, iac, scripts, cicd, architecture, all |

По умолчанию Focus = all.

---

## Verbosity Protocol

**SILENT MODE:** Весь analysis идет в артефакт, не в чат.

**В чат:** Только финальная сводка + путь к отчету.

**Tools first:** Read -> analyze -> report, без промежуточных комментариев.

---

## Алгоритм

### Шаг 1: Scope Discovery

1. Определи файлы для ревью:
   - Если указан файл -> один файл
   - Если указана директория -> все конфигурационные файлы (.tf, .yml, .yaml, Dockerfile, .sh, Makefile)
   - Если указан модуль -> все файлы модуля

2. Прочитай CLAUDE.md (если есть) для понимания конвенций проекта.

3. Подсчитай объем: `wc -l` для каждого файла.

### Шаг 2: Security Review

Прочитай `references/security-rules.md`.

Для каждого файла проверь:
- **Секреты в коде:** пароли, ключи, токены в открытом виде
- **Права доступа:** слишком широкие permissions, 0.0.0.0 привязки
- **TLS:** отсутствие шифрования, HTTP вместо HTTPS
- **RBAC:** отсутствие ограничений доступа, wildcard permissions
- **Сетевая безопасность:** открытые порты, отсутствие NetworkPolicy
- **Root-доступ:** контейнеры от root, sudo без ограничений
- **Firewall:** отсутствие security groups, широкие правила

### Шаг 3: Container Review

Прочитай `references/infra-checklist.md` секция "Containers".

Для каждого Dockerfile / docker-compose проверь:
- **Image tags:** использование latest или отсутствие тега
- **Resource limits:** отсутствие limits/requests для контейнеров
- **Health checks:** отсутствие HEALTHCHECK / readiness/liveness probes
- **Privileged mode:** контейнеры с privileged: true
- **Fat images:** большие базовые образы без multi-stage build
- **USER directive:** запуск от root без необходимости
- **Build cache:** неоптимальный порядок слоёв в Dockerfile

### Шаг 4: IaC Review

Для каждого Terraform/Ansible файла проверь:
- **State management:** отсутствие remote backend, нет state locking
- **Hardcoded values:** IP-адреса, пароли, account IDs в коде
- **Modules:** дублирование кода вместо использования модулей
- **Drift detection:** нет механизма обнаружения drift
- **Variables:** отсутствие описаний, типов, значений по умолчанию
- **Output:** отсутствие outputs для переиспользования
- **Formatting:** нарушение terraform fmt / ansible-lint

### Шаг 5: Script Review

Для каждого Bash/Python скрипта проверь:
- **Error handling:** отсутствие set -euo pipefail, необработанные ошибки
- **Idempotency:** скрипт не идемпотентен (повторный запуск ломает)
- **Logging:** отсутствие логирования, молчаливые ошибки
- **Hardcoded paths:** абсолютные пути, захардкоженные значения
- **Quoting:** переменные без кавычек, word splitting
- **Cleanup:** отсутствие trap для очистки временных ресурсов
- **Shellcheck:** нарушения правил shellcheck

### Шаг 6: CI/CD Review

Для каждого CI/CD конфига проверь:
- **Secrets in logs:** вывод секретов в логи пайплайна
- **Caching:** отсутствие кеширования зависимостей/артефактов
- **Rollback:** нет стратегии отката при ошибке деплоя
- **Artifact versioning:** артефакты без версионирования
- **Pipeline security:** использование непроверенных actions/images
- **Parallel stages:** последовательные шаги где возможны параллельные

### Шаг 7: Architecture Review

Для проекта в целом проверь:
- **SPOF:** единые точки отказа (один инстанс, нет реплик)
- **Coupling:** тесная связность между сервисами
- **Scalability:** отсутствие возможности горизонтального масштабирования
- **Documentation:** отсутствие README, комментариев в конфигах
- **Environment parity:** различия между dev/staging/production
- **Disaster recovery:** отсутствие бэкапов, плана восстановления

### Шаг 8: Report Generation

Сохрани отчет в путь указанный пользователем или `audit/infra-review-report.md`.

---

## Severity Model

| Severity | Критерии |
|----------|----------|
| **BLOCKER** | Утечка секретов, публичный доступ к БД, отсутствие аутентификации |
| **CRITICAL** | Контейнер от root с privileged, отсутствие resource limits, нет rollback |
| **WARNING** | Нарушение конвенций, отсутствие health checks, tech debt |
| **INFO** | Стилистика, мелкие улучшения, документация |

---

## Формат отчета

```markdown
# Infrastructure Review Report

> Scope: {path}
> Файлов: {N} | Строк: {M}
> Дата: {YYYY-MM-DD}

## Summary

| Severity | Количество |
|----------|:----------:|
| BLOCKER | {N} |
| CRITICAL | {N} |
| WARNING | {N} |
| INFO | {N} |

## Findings

### BLOCKER

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### CRITICAL

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### WARNING

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|

### INFO

| # | Файл:строка | Категория | Описание | Рекомендация |
|---|------------|-----------|----------|--------------|
```

---

## Quality Gates

- [ ] Все файлы в scope прочитаны
- [ ] Каждый finding имеет severity + файл:строка + рекомендацию
- [ ] Нет false positives (контекст проверен)
- [ ] BLOCKER/CRITICAL findings имеют конкретный пример из кода

## Завершение

```
SKILL COMPLETE: /infra-review
|- Артефакты: {путь к отчету}
|- Scope: {N} файлов, {M} строк
|- Findings: {B} BLOCKER, {C} CRITICAL, {W} WARNING, {I} INFO
```

## Связанные файлы

- Чек-лист: `references/infra-checklist.md`
- Безопасность: `references/security-rules.md`
