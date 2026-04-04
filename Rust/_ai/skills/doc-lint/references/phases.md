# Фазы анализа документации

## Фаза 1: Inventory

1. Собери human-readable файлы: `*.md`, `*.yaml`, `*.yml`, `*.txt`.
2. Исключи `node_modules/`, `.git/`, `build/`, `dist/`, `vendor/`, `audit/`, бинарные файлы и lock-файлы.
3. Для каждого файла посчитай строки через `wc -l` и классифицируй по `check-rules.md`.

Пример строки inventory:

```markdown
| 1 | COMMON.md | 33 | COMMON.md | OK |
```

## Фаза 2: Size & Structure

1. Примени thresholds из `check-rules.md`.
2. Проверь иерархию заголовков, пустые секции, wall-of-text и oversized sections.
3. Для `COMMON.md` и anchor-файлов отдельно проверь, что они не распухают.

## Фаза 3: Duplicate Detection

1. Извлеки таблицы, code blocks, списки и большие параграфы.
2. Используй known signatures из `check-rules.md`.
3. После match сравни только связанные файлы, не весь проект попарно.
4. Для каждого кластера назначь SSOT owner.

## Фаза 4: Content Hygiene

Проверь:

- broken relative links
- пустые ссылки
- `TODO` / `FIXME` / `HACK`
- stale dates
- mixed doc types

## Фаза 5: Report & Safe Fixes

1. Сохрани findings в `audit/doc-lint-report.md`.
2. Если есть безопасные правки, сгенерируй `audit/safe-fix.sh`.
3. В скрипт добавляй только безопасные операции: placeholder TOC, создание заглушек для missing docs, удаление trailing spaces.
