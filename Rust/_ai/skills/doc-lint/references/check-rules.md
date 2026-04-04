# Правила проверки doc-lint

## 1. Size Thresholds

| Тип файла | Рекомендовано | WARNING | CRITICAL | Обоснование |
|-----------|:------------:|:-------:|:--------:|-------------|
| `COMMON.md` | ≤120 | >120 | >200 | Всегда в контексте, это SSOT |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | ≤60 | >60 | >120 | Anchor-файлы должны быть короткими |
| `SKILL.md` | ≤300 | >300 | >500 | Навык должен оставаться компактным |
| `agents/*.md` | ≤120 | >120 | >220 | Role cards, а не большие system prompts |
| docs/*.md | ≤400 | >500 | >700 | Общая документация |
| README.md | ≤300 | >500 | >700 | Entry point + guide |
| YAML config (.yaml, .yml) | ≤200 | >300 | >500 | Конфиг, не проза |
| Generic .md (fallback) | ≤400 | >500 | >700 | Fallback для прочих markdown |

### Классификация файла

Приоритет:

1. Имя `SKILL.md` → SKILL.md
2. Путь содержит `agents/` → agents/*.md
3. Имя `COMMON.md` → `COMMON.md`
4. Имя `CLAUDE.md`, `AGENTS.md` или `GEMINI.md` → anchor-файл
5. Имя `README.md` → README.md
6. Расширение `.yaml` или `.yml` → YAML config
7. Путь содержит `docs/` → docs/*.md
8. Расширение `.md` → Generic .md

## 2. Known Duplicate Signatures

| ID | Паттерн | Grep-сигнатура | Min match |
|----|---------|----------------|-----------|
| KP-1 | Core Rules block | `Trust No One` + `Minimal Diff` + `Production Ready` | 3 строки в пределах 12 строк |
| KP-2 | COMMON as SSOT | `COMMON.md` + `SSOT` | 2 строки |
| KP-3 | Anchor duplication | `Read Order` + `COMMON.md` + `core rules` | 3 строки |
| KP-4 | Skill Size Limit | `500 строк` или `≤500` в контексте skill | 1 строка |
| KP-5 | Legacy process | `gardener` или `Protocol Injection` или `Escalation Protocol` | 1 строка |

## 3. SSOT Ownership Matrix

| Категория контента | SSOT Owner | Обоснование |
|--------------------|------------|-------------|
| Core rules, verify-команды, общие conventions | `COMMON.md` | Базовый контекст для всех рантаймов |
| Runtime entry instructions | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | Anchor-слой для конкретного рантайма |
| Правила авторинга скиллов | `COMMON.md` + skill-specific refs | Не дублировать в anchor-файлах |
| Алгоритм конкретного скилла | `SKILL.md` | Scoped context |
| Туториалы, гайды | `docs/*.md` | Документационный слой |
| Обзор проекта | `README.md` | Точка входа |

## 4. Diataxis Type Detection

| Тип | Маркеры | Примеры |
|-----|---------|---------|
| **Tutorial** | "шаг 1", "step 1", "давайте создадим" | Workshop guides |
| **How-to** | "как сделать", "how to", "чтобы X, сделайте Y" | Recipes |
| **Reference** | таблицы параметров, API, enum values | API docs, config refs |
| **Explanation** | "почему", "зачем", "архитектура", "принцип" | Architecture docs |

## 5. Structure Rules

| Правило | Критерий | Severity |
|---------|----------|----------|
| Пропуск уровня заголовка | H1→H3 или H2→H4 | CRITICAL |
| Anchor-file раздут | anchor-файл > warning threshold | WARNING |
| Дисбаланс секций | Одна секция >40% от файла | WARNING |
| Пустая секция | Заголовок без контента | WARNING |
| Wall-of-text | >20 строк подряд без структуры | WARNING |
| Длинные строки | >200 символов | INFO |
