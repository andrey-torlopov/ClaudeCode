# No Logging

## Why this is bad

- Молчащий скрипт при сбое не дает понять на каком шаге он упал
- Вывод данных и диагностики в один поток (stdout) ломает пайпы и парсинг
- Без timestamp в логах невозможно корреляция с событиями в других системах
- Cron-задача без логирования: "скрипт запускался?" - ответа нет

## Bad Example

```bash
# BAD: молчащий скрипт - при сбое непонятно что произошло
#!/bin/bash
set -euo pipefail

pg_dump mydb > /backup/mydb.sql
gzip /backup/mydb.sql
aws s3 cp /backup/mydb.sql.gz s3://backups/
rm /backup/mydb.sql.gz
```

```bash
# BAD: echo мешает данные с диагностикой в одном потоке
#!/bin/bash
echo "Starting backup..."
pg_dump mydb
echo "Backup complete!"
# Если stdout перенаправлен в файл, echo тоже попадет в дамп БД
```

## Good Example

```bash
# GOOD: функция логирования с уровнями и timestamp
#!/bin/bash
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

log() {
    local level="$1"
    shift
    echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [${level}] [${SCRIPT_NAME}] $*" >&2
}

log INFO "Starting database backup"

BACKUP_FILE="/backup/mydb-$(date +%Y%m%d-%H%M%S).sql"

if ! pg_dump mydb > "${BACKUP_FILE}"; then
    log ERROR "pg_dump failed"
    exit 1
fi
log INFO "Dump created: ${BACKUP_FILE}"

gzip "${BACKUP_FILE}"
log INFO "Dump compressed"

if ! aws s3 cp "${BACKUP_FILE}.gz" s3://backups/; then
    log ERROR "S3 upload failed"
    exit 1
fi
log INFO "Uploaded to S3"

rm -f "${BACKUP_FILE}.gz"
log INFO "Backup completed successfully"
```

## What to look for in review

- Скрипты без единого `echo` или функции логирования
- `echo` в stdout вместо stderr (`>&2`) в скриптах, генерирующих данные
- Отсутствие timestamp в логах скриптов
- Cron-задачи без перенаправления вывода (`> /var/log/...` или `logger`)
- Нет `--verbose` / `--quiet` флагов в скриптах, используемых и вручную, и в автоматизации
