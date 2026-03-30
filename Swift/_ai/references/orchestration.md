# Orchestration Reference

## Skills Matrix

| Скилл | Owner | Назначение | Артефакт |
|-------|-------|------------|----------|
| `/repo-scout` | **Self** | Разведка iOS-репозитория | `audit/repo-scout-report.md` |
| `/init-project` | **Self** | Генерация CLAUDE.md для Swift-проекта | `CLAUDE.md` |
| `/update-ai-setup` | **Self** | Обновление AI-реестра | `docs/ai-setup.md` |
| `/init-skill` | Developer | Создание новых скиллов | `_ai/skills/{name}/SKILL.md` |
| `/swift-review` | Auditor | Глубокий Swift code review | `audit/swift-review-report.md` |
| `/refactor-plan` | Auditor | Планирование рефакторинга | `audit/refactor-plan.md` |
| `/dependency-check` | Auditor | Анализ SPM-зависимостей | `audit/dependency-check-report.md` |
| `/doc-lint` | Auditor | Аудит документации | `audit/doc-lint-report.md` |
| `/skill-audit` | Auditor | Аудит скиллов | `audit/skill-audit-report.md` |

## Ad-Hoc Routing

| Запрос пользователя | Агент | Действие |
|---------------------|-------|----------|
| "Сделай ревью кода / модуля" | Auditor | `/swift-review` |
| "Проанализируй зависимости" | Auditor | `/dependency-check` |
| "Спланируй рефакторинг" | Auditor | `/refactor-plan` |
| "Разведка репозитория" | Self | `/repo-scout` |
| "Настрой CLAUDE.md" | Self | `/init-project` |
| "Создай новый скилл" | Developer | `/init-skill` |
| "Проверь документацию" | Auditor | `/doc-lint` |
| "Проверь качество скиллов" | Auditor | `/skill-audit` |
| "Обнови AI-реестр" | Self | `/update-ai-setup` |

## Pipeline Strategy

| Phase | Agent | Action / Skill | Gate | Output |
|:------|:------|:---------------|:-----|:-------|
| **1. Discovery** | **Self** | `/repo-scout` | Repo доступен, структура понятна | `audit/repo-scout-report.md` |
| **2. Development** | **Developer** | Код, `/init-skill` | `swift build` PASS | `Sources/**/*.swift`, `Tests/**/*.swift` |
| **3. Quality** | **Auditor** | `/swift-review`, `/doc-lint` | Нет CRITICAL findings | `audit/swift-review-report.md` |

### Cross-Skill Dependencies

`/repo-scout` -> `/init-project` -> код **(Developer)** -> `/swift-review` **(Auditor)**

- `/repo-scout` - нет зависимостей, первый шаг
- `/init-project` - после `/repo-scout` (Self)
- Код / `/init-skill` - после понимания проекта (Developer Agent)
- `/swift-review` - проверка артефактов после генерации (Auditor Agent)
- `/dependency-check`, `/doc-lint`, `/skill-audit`, `/refactor-plan` - независимые (Auditor Agent)

### Sub-Agent Protocol

Субагенты работают в `context: fork` - передавай **исчерпывающий контекст** в prompt:
- **Target:** файл/модуль/спецификация
- **Scope:** что покрыть
- **Constraints:** техстек, конвенции из CLAUDE.md
- **Upstream:** артефакты предыдущих скиллов (repo-scout-report)

**ESCALATION:** При блокере от агента - анализируй причину, выбирай:
- Replan (исключить проблемный scope)
- User escalation (техническая проблема)
- Partial coverage (некритичный компонент)

## Skill Completion Protocol

Каждый скилл завершается одним из блоков:

```
SKILL COMPLETE: /{skill-name}
|- Артефакты: [список]
|- Compilation: [PASS/FAIL/N/A]
|- Upstream: [файл | "нет"]
|- Coverage/Score: [метрика]
```

```
SKILL PARTIAL: /{skill-name}
|- Артефакты: [список]
|- Blockers: [описание]
|- Coverage: [X/Y]
```
