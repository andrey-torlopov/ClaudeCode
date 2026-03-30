# Фазы анализа документации

## Фаза 1: Discovery & File Inventory

**Цель:** Собрать каталог файлов, исключая тяжелые и служебные директории.

1. **Glob Pattern:** `**/*.md`, `**/*.yaml`, `**/*.yml`, `**/*.txt`
2. **Исключения (Blacklist):**
   - Системные: `node_modules/`, `.git/`, `.gradle/`, `build/`, `dist/`, `vendor/`, `_ai/`
   - Бинарные/Lock: `*.lock`, `*.bin`, `*.jar`, `*.png`, `*.jpg`
   - **Генерируемые отчеты (ВАЖНО):** `audit/` (чтобы не линтить отчеты прошлых запусков)
   - **Архив/Спецификации:** `specifications/` (исторические данные), `legacy/`
3. **Smart Filtering:**
   - Если пользователь не задал `Scope`, игнорировать файлы в корне `.github/` (обычно это шаблоны)
4. **Inventory Step:**
   - Используй `wc -l` для подсчета строк (НЕ ИСПОЛЬЗУЙ `read` для этого шага, экономь токены).
   - Классифицируй файлы по пути.
   - Для каждого файла определить:
     - Path (относительный)
     - Line count (`wc -l`)
     - Type classification (по правилам из `references/check-rules.md` § 1)
5. Сформировать таблицу-инвентарь:

```markdown
| # | Файл | Строк | Тип | Status |
|---|------|------:|-----|--------|
| 1 | CLAUDE.md | 107 | CLAUDE.md | — |
```

**Checkpoint:** Все файлы в scope найдены, line counts верифицированы.

---

## Фаза 2: Size Analysis

**Цель:** Определить файлы, превышающие пороги.

1. Загрузить пороги из `references/check-rules.md` § 1
2. Для каждого файла из инвентаря:
   - Определить applicable threshold по типу файла
   - Сравнить line count с порогами
   - Присвоить severity: **OK** / **WARNING** / **CRITICAL**
3. Обновить колонку Status в инвентаре

**Формула:**
```
Если lines > CRITICAL threshold → CRITICAL
Если lines > WARNING threshold → WARNING
Иначе → OK
```

---

## Фаза 3: Structure Analysis

**Цель:** Проверить внутреннюю структуру каждого файла.

Для каждого .md файла:

**3.1 Heading Hierarchy**
- Извлечь все заголовки (`# `, `## `, `### `, ...)
- Проверить на пропуски уровней: H1→H3 (минуя H2) → **CRITICAL**
- Проверить глубину: >H4 → **INFO** "Consider restructuring"

**3.2 Section Balance**
- Посчитать строки между заголовками
- Если одна секция > 40% от всего файла → **WARNING**

**3.3 Empty Sections**
- Заголовок → следующий заголовок без контента (только whitespace) → **WARNING**

**3.4 TOC Check**
- Файл >200 строк без `## Table of Contents`, `## Содержание`, `## TOC` → **INFO**

**3.5 Readability**
- Wall-of-text: >20 строк подряд без заголовков/списков/пустых строк/code blocks → **WARNING**
- Строки >200 символов → **INFO**

---

## Фаза 4: Cross-File Duplicate Detection

**Цель:** Найти дублирование контента между файлами. Ключевая фаза.

### 4.1 Block Extraction

Для каждого файла извлечь семантические блоки:
- Таблицы (от `|` до конца таблицы)
- Code blocks (от ``` до ```)
- Списки (последовательные строки с `- `, `* `, `1. `)
- Параграфы (>3 строк подряд)

### 4.2 Known Pattern Matching (быстрый проход)

Загрузить паттерны из `references/check-rules.md` § 2.
Для каждого паттерна KP-1..KP-5:

1. Grep по сигнатуре
2. Собрать файлы с совпадением
3. Если файлов ≥2 → зафиксировать кластер дубликатов

### 4.3 Heuristic Cross-Comparison

**ВАЖНО:** Сравнивать содержимое ТОЛЬКО для файлов, попавших в один кластер на шаге 4.2 (Grep match). Не проводить полное попарное сравнение всего проекта (риск комбинаторного взрыва токенов).

Для таблиц (внутри кластера):
1. Сравнить header rows (строки с `|`)
2. Если headers совпадают >70% → сравнить содержимое
3. Содержимое совпадает >70% → **WARNING** near-duplicate

Для code blocks и списков (внутри кластера):
1. Нормализовать по правилам из `references/check-rules.md` § 5
2. Exact match ≥5 строк → **CRITICAL**
3. Exact match 3-5 строк → **WARNING**

### 4.4 Intra-file Duplicates

Внутри одного файла:
- Повторяющиеся секции (одинаковые заголовки + похожий контент)
- Повторяющиеся таблицы
- Copy-paste параграфы

### 4.5 SSOT Owner Assignment

Для каждого кластера дубликатов:
1. Определить категорию контента по `references/check-rules.md` § 3
2. Назначить SSOT Owner
3. Сформировать рекомендацию: "Оставить в {Owner}, остальные заменить ссылкой"

---

## Фаза 5: Content Hygiene

**Цель:** Найти проблемы с содержимым.

**5.1 Markers**
- `TODO`, `FIXME`, `HACK`, `XXX`, `TEMP` → **INFO**

**5.2 Broken Internal Links**
- Найти все `[text](path)` где path — относительный путь
- Проверить существование файла → не существует → **CRITICAL**
- Пустые ссылки `[text]()` или `[](path)` → **WARNING**

**5.3 Stale Dates**
- Даты в формате YYYY-MM-DD старше 6 месяцев от текущей даты → **INFO** "Potentially stale"

**5.4 Diataxis Type Mix**
- Загрузить маркеры из `references/check-rules.md` § 4
- Если файл содержит маркеры ≥2 типов → **INFO**

---

## Фаза 6: Report Generation

**Цель:** Собрать все findings в структурированный отчёт.

### 6.2 Safe Fix Script Generation

Сгенерировать Bash-скрипт `audit/safe-fix.sh` с безопасными автоматическими исправлениями.

**Safe (автоматические):**
- Добавление `## Table of Contents` (если отсутствует и файл >200 строк)
- Создание пустых файлов-заглушек для битых ссылок (помеченных `# TODO: Content needed`)
- Удаление trailing spaces (пробелов в конце строк)

**Manual (требуют человека):**
- Удаление дубликатов (риск потери контекста)
- Разбиение файлов на части
- Рефакторинг содержимого

Скрипт должен содержать:
1. Shebang `#!/usr/bin/env bash`
2. Safety header с предупреждением
3. Dry-run mode по умолчанию (флаг `--apply` для применения)
4. Каждое действие с комментарием и echo перед выполнением

**Пример структуры:**
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Safe Fix Script for Doc-Lint Report"
echo "Run with --apply to execute changes"

DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

# Fix 1: Add TOC to large files
if [ "$DRY_RUN" = false ]; then
  # actual fix command
else
  echo "[DRY-RUN] Would add TOC to file.md"
fi
```

---

## Фаза 7: Generate Safe-Fix Script

**Цель:** Создать `audit/safe-fix.sh`, который оркестрирует исправления, используя надежные инструменты.

1. Создать файл `audit/safe-fix.sh` с shebang `#!/usr/bin/env bash` и `set -euo pipefail`.
2. **Логика для TOC (Оглавлений):**
   - Проверить наличие утилиты `_ai/scripts/generate-toc.sh`.
   - Если утилита существует: добавить в скрипт команду вызова этой утилиты для всех файлов, где найден Warning "No TOC".
     Пример: `_ai/scripts/generate-toc.sh "$file" || echo "⚠️  Failed to generate TOC for $file"`
   - Если утилиты НЕТ: добавить команду вставки *только* плейсхолдера с помощью простого `sed`.
     Пример: вставить `## Table of Contents\n\n*TODO: Auto-generate TOC*\n` после заголовка H1.
3. **Логика для битых ссылок:**
   - Если найдены битые ссылки (CRITICAL), добавить команды `mkdir -p $(dirname path/to/missing.md) && touch path/to/missing/file.md` и `echo "# TODO: Created by doc-lint" > ...`.
4. Сделать скрипт исполняемым (`chmod +x`).

**Важно:** Не пытайся генерировать сложный Bash-код для парсинга заголовков Markdown внутри этого скрипта. Используй внешнюю утилиту (`_ai/scripts/generate-toc.sh`) или оставляй эту задачу IDE (через плейсхолдер).

**Checkpoint:** Скрипт создан, исполняемые права выставлены, использует статические утилиты где возможно.
