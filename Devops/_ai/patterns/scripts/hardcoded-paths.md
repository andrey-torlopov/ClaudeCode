# Hardcoded Paths

## Why this is bad

- `/home/ubuntu/app` ломается на CentOS (`/home/centos`), в Docker (`/app`), в CI (`/home/runner`)
- `/usr/local/bin/python3.9` перестает работать после обновления Python до 3.12
- Захардкоженные IP-адреса серверов превращают скрипт в одноразовый инструмент
- Скрипт невозможно протестировать на другой машине без правки путей

## Bad Example

```bash
# BAD: привязка к конкретной системе и пользователю
#!/bin/bash
set -euo pipefail

/usr/local/bin/python3.9 /home/ubuntu/app/manage.py migrate
cp /home/ubuntu/app/config/nginx.conf /etc/nginx/sites-available/myapp
/usr/local/bin/certbot renew
rsync -avz /home/ubuntu/app/static/ admin@192.168.1.50:/var/www/static/
```

```bash
# BAD: hardcoded temp directory и фиксированный порт
#!/bin/bash
LOGFILE="/tmp/deploy.log"
PID_FILE="/tmp/myapp.pid"
curl http://10.0.0.15:8080/api/health
```

## Good Example

```bash
# GOOD: конфигурируемые пути, поиск бинарников, переменные для хостов
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${APP_DIR:-$(dirname "${SCRIPT_DIR}")}"
CONFIG_DIR="${CONFIG_DIR:-${APP_DIR}/config}"

PYTHON="$(command -v python3 || { echo "[ERROR] python3 not found" >&2; exit 1; })"
CERTBOT="$(command -v certbot || { echo "[ERROR] certbot not found" >&2; exit 1; })"

STATIC_HOST="${STATIC_HOST:?STATIC_HOST is required}"
HEALTH_URL="${HEALTH_URL:-http://localhost:8080/api/health}"

"${PYTHON}" "${APP_DIR}/manage.py" migrate
cp "${CONFIG_DIR}/nginx.conf" /etc/nginx/sites-available/myapp
"${CERTBOT}" renew
rsync -avz "${APP_DIR}/static/" "${STATIC_HOST}:/var/www/static/"
```

```bash
# GOOD: использование mktemp и стандартных переменных
#!/bin/bash
set -euo pipefail

TMPDIR="${TMPDIR:-/tmp}"
WORKDIR="$(mktemp -d "${TMPDIR}/deploy-XXXXXX")"

trap 'rm -rf "${WORKDIR}"' EXIT

curl --fail --silent "${HEALTH_URL:?}" > "${WORKDIR}/health.json"
```

## What to look for in review

- Абсолютные пути `/home/<user>/`, `/opt/<app>/` без переменных
- Имя бинарника с версией: `python3.9`, `node16`, `go1.21`
- IP-адреса (`192.168.x.x`, `10.0.x.x`) вместо переменных или DNS
- `/tmp/` без `mktemp` для уникальных имен
- Отсутствие `command -v` / `which` для проверки наличия бинарников
