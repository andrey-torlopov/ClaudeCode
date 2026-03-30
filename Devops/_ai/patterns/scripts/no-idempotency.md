# No Idempotency

## Why this is bad

- Повторный запуск скрипта после частичного сбоя ломает систему вместо того, чтобы довести до целевого состояния
- `mkdir` без `-p` падает если директория уже существует, блокируя весь скрипт
- `CREATE TABLE` без `IF NOT EXISTS` ломает миграцию при повторном запуске
- CI/CD retry при timeout запускает скрипт заново - он должен безопасно продолжить

## Bad Example

```bash
# BAD: скрипт ломается при повторном запуске
#!/bin/bash
set -euo pipefail

mkdir /opt/myapp
useradd myapp
cp config.yml /opt/myapp/config.yml
echo "export APP_ENV=production" >> /etc/environment
```

```sql
-- BAD: миграция падает при повторном запуске
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL
);

CREATE INDEX idx_users_email ON users(email);

INSERT INTO settings (key, value) VALUES ('version', '2.0');
```

## Good Example

```bash
# GOOD: каждая операция проверяет текущее состояние перед действием
#!/bin/bash
set -euo pipefail

mkdir -p /opt/myapp

if ! id myapp &>/dev/null; then
    useradd --system --no-create-home myapp
fi

cp config.yml /opt/myapp/config.yml

if ! grep -q "APP_ENV=production" /etc/environment; then
    echo "export APP_ENV=production" >> /etc/environment
fi
```

```sql
-- GOOD: идемпотентная миграция
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

INSERT INTO settings (key, value) VALUES ('version', '2.0')
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
```

## What to look for in review

- `mkdir` без `-p` флага
- `CREATE TABLE` / `CREATE INDEX` без `IF NOT EXISTS`
- `INSERT INTO` без `ON CONFLICT` / `UPSERT` логики
- `useradd` / `groupadd` без предварительной проверки `id user`
- `echo "..." >> file` без проверки `grep -q` что строка уже есть
