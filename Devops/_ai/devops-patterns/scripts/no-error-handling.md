# No Error Handling

## Why this is bad

- Без `set -e` скрипт продолжает выполнение после ошибки, ломая данные следующими командами
- `rm -rf $DIR/` при пустой переменной `$DIR` удаляет `/` - катастрофа из-за отсутствия `set -u`
- Без `trap` временные файлы и lock-файлы остаются после аварийного завершения
- `set -o pipefail` нужен, иначе `failing_cmd | grep` скрывает ошибку первой команды

## Bad Example

```bash
# BAD: нет обработки ошибок, нет очистки при сбое
#!/bin/bash

cd /opt/myapp
git pull origin main
pip install -r requirements.txt
systemctl restart myapp

# Если git pull упал, pip install выполнится на старом коде
# Если pip упал, restart произойдет с битыми зависимостями
```

```bash
# BAD: пустая переменная приводит к удалению /
#!/bin/bash
DEPLOY_DIR=""
rm -rf ${DEPLOY_DIR}/*
# Выполнится: rm -rf /*
```

## Good Example

```bash
# GOOD: строгий режим + trap для очистки
#!/bin/bash
set -euo pipefail

LOCKFILE="/tmp/deploy.lock"
BACKUP_DIR="/opt/myapp/backup"

cleanup() {
    local exit_code=$?
    rm -f "${LOCKFILE}"
    if [[ ${exit_code} -ne 0 ]]; then
        echo "[ERROR] Deploy failed with exit code ${exit_code}. Rolling back..." >&2
        if [[ -d "${BACKUP_DIR}" ]]; then
            cp -r "${BACKUP_DIR}/." /opt/myapp/current/
        fi
    fi
    exit ${exit_code}
}

trap cleanup EXIT

if [[ -f "${LOCKFILE}" ]]; then
    echo "[ERROR] Deploy already in progress (lockfile exists)" >&2
    exit 1
fi

touch "${LOCKFILE}"

cp -r /opt/myapp/current "${BACKUP_DIR}"
cd /opt/myapp/current
git pull origin main
pip install -r requirements.txt
systemctl restart myapp

echo "[OK] Deploy completed successfully"
```

## What to look for in review

- Bash-скрипты без `set -euo pipefail` в начале
- Отсутствие `trap` для очистки временных файлов и lock-ов
- `rm -rf $VAR/` без кавычек вокруг переменной
- Игнорирование exit code: `command || true` без объяснения почему
- Pipe без `set -o pipefail`: `cat file | grep pattern` скрывает ошибку cat
