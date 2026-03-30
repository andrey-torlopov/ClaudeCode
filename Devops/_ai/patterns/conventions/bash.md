# Bash Conventions

**Applies to:** Все Bash/Shell-скрипты проекта

## Правила

- Всегда `set -euo pipefail` в начале скрипта
- Переменные в двойных кавычках: `"$var"`, не `$var`
- `[[ ]]` вместо `[ ]` для условий
- `local` для локальных переменных в функциях
- `readonly` для констант
- Логирование через stderr: `echo "INFO: message" >&2`
- Trap для cleanup: `trap cleanup EXIT`
- `mktemp` для временных файлов, не хардкодь пути
- Длинные пайпы разбивай на переменные для читаемости
- Функции: имя как глагол, `snake_case`

## Bad Example

```bash
# BAD: нет strict mode, переменные без кавычек, [ ] вместо [[ ]]
#!/bin/bash

TMPFILE=/tmp/myapp.tmp
result=$1

if [ $result = "ok" ]; then
    rm -rf $TMPFILE
fi

process_data() {
    var=$(some_command)
    echo "Processing $var"
}
```

## Good Example

```bash
# GOOD: strict mode, кавычки, [[ ]], local, readonly, mktemp, trap
#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPFILE="$(mktemp)"

cleanup() {
    rm -f "${TMPFILE}"
}
trap cleanup EXIT

process_data() {
    local result
    result="$(some_command)"
    echo "INFO: Processing ${result}" >&2
}

if [[ "${1:-}" == "ok" ]]; then
    process_data
fi
```

## What to look for in review

- Скрипты без `set -euo pipefail`
- Переменные без кавычек: `$var` вместо `"${var}"`
- `[ ]` вместо `[[ ]]`
- Отсутствие `local` в функциях
- Захардкоженные пути для временных файлов вместо `mktemp`
- `echo` в stdout для логирования вместо stderr
- Отсутствие `trap` для очистки
- Функции с именами-существительными вместо глаголов
