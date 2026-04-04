# Правила проверки doc-lint

## 1. Size Thresholds

| Тип файла | Рекомендовано | WARNING | CRITICAL | Обоснование |
|-----------|:------------:|:-------:|:--------:|-------------|
| `COMMON.md` | ≤120 | >120 | >200 | Всегда в контексте, это SSOT |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | ≤60 | >60 | >120 | Anchor-файлы должны быть короткими |
| `SKILL.md` | ≤300 | >300 | >500 | Навык должен оставаться компактным |
| `agents/*.md` | ≤120 | >120 | >220 | Role cards, а не большие system prompts |
| docs/*.md | ≤400 | >500 | >700 | Microsoft Docs: 200-800 ideal range |
| README.md | ≤300 | >500 | >700 | Entry point + workshop guide |
| YAML config (.yaml, .yml) | ≤200 | >300 | >500 | Конфиг, не проза |
| Generic .md (fallback) | ≤400 | >500 | >700 | Fallback для прочих markdown |

### Классификация файла

Приоритет (сверху вниз, первое совпадение):

1. Имя `SKILL.md` → SKILL.md
2. Путь содержит `agents/` → agents/*.md
3. Имя `COMMON.md` → `COMMON.md`
4. Имя `CLAUDE.md`, `AGENTS.md` или `GEMINI.md` → anchor-файл
5. Имя `README.md` → README.md
6. Расширение `.yaml` или `.yml` → YAML config
7. Путь содержит `docs/` → docs/*.md
8. Расширение `.md` → Generic .md

---

## 2. Known Duplicate Signatures

Pre-registered паттерны для быстрого поиска через Grep:

| ID | Паттерн | Grep-сигнатура | Min match |
|----|---------|----------------|-----------|
| KP-1 | Core Rules block | `Trust No One` + `Minimal Diff` + `Production Ready` | 3 строки в пределах 12 строк |
| KP-2 | COMMON as SSOT | `COMMON.md` + `SSOT` | 2 строки |
| KP-3 | Anchor duplication | `Read Order` + `COMMON.md` + `core rules` | 3 строки |
| KP-4 | Skill Size Limit | `500 строк` или `≤500` в контексте skill | 1 строка |
| KP-5 | Legacy process | `gardener` или `Protocol Injection` или `Escalation Protocol` | 1 строка |

### Правило KP-match

Файл считается содержащим паттерн, если найдены ВСЕ строки из колонки "Min match".
Дубликат = паттерн найден в ≥2 файлах.

---

## 3. SSOT Ownership Matrix

| Категория контента | SSOT Owner | Обоснование |
|--------------------|------------|-------------|
| Core rules, build/test, общие conventions | `COMMON.md` | Базовый контекст для всех рантаймов |
| Runtime entry instructions | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | Anchor-слой для конкретного рантайма |
| Правила авторинга скиллов | `COMMON.md` + skill-specific refs | Не дублировать в anchor-файлах |
| Алгоритм конкретного скилла | `SKILL.md` | Scoped context |
| Туториалы, гайды | `docs/*.md` | Документационный слой |
| Обзор проекта | `README.md` | Точка входа |

### Правило SSOT

Если контент из категории X найден вне SSOT Owner — это WARNING (near-duplicate) или CRITICAL (exact duplicate >5 строк). Рекомендация: заменить на ссылку `→ см. {SSOT Owner}`.

---

## 4. Diataxis Type Detection

Маркеры для определения типа документа:

| Тип | Маркеры | Примеры |
|-----|---------|---------|
| **Tutorial** | "шаг 1", "step 1", "давайте создадим", "let's create", пошаговые инструкции с нарастающей сложностью | Workshop guides |
| **How-to** | "как сделать", "how to", "чтобы X, сделайте Y", целевые рецепты | Troubleshooting |
| **Reference** | таблицы параметров, API signatures, enum values, чисто факты без нарратива | API docs, config refs |
| **Explanation** | "почему", "зачем", "архитектура", "принцип", концептуальные объяснения | Architecture docs |

### Правило Diataxis

Один файл содержит маркеры ≥2 типов → INFO "Mixed Diataxis types". Не критично, но рекомендуется разделять.

## 5. Structure Rules

| Правило | Критерий | Severity |
|---------|----------|----------|
| Пропуск уровня заголовка | H1→H3 или H2→H4 | CRITICAL |
| Anchor-file раздут | anchor-файл > warning threshold | WARNING |
| Дисбаланс секций | Одна секция >40% от файла | WARNING |
| Пустая секция | Заголовок без контента | WARNING |
| Wall-of-text | >20 строк подряд без структуры | WARNING |
| Длинные строки | >200 символов | INFO |
