# No Log Rotation

## Why this is bad

- Лог-файл растет бесконечно и заполняет диск - сервис падает с "No space left on device"
- Docker без ограничения размера лога может заполнить `/var/lib/docker` за часы при высокой нагрузке
- Полный диск каскадно ломает все сервисы на ноде: базы данных, мониторинг, systemd journal
- Восстановление требует ручного SSH, удаления логов, перезапуска сервисов

## Bad Example

```bash
# BAD: приложение пишет в файл без ротации
/opt/myapp/bin/server >> /var/log/myapp/app.log 2>&1
```

```yaml
# BAD: Docker без ограничения размера логов
version: "3.8"
services:
  app:
    image: myapp:1.0
    # logging section отсутствует - логи растут без ограничений
```

```ini
# BAD: systemd journal без ограничений
# /etc/systemd/journald.conf
[Journal]
Storage=persistent
# SystemMaxUse не задан - journal растет без ограничений
```

## Good Example

```bash
# GOOD: logrotate конфигурация для приложения
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    maxsize 100M
}
```

```yaml
# GOOD: Docker logging driver с ограничением размера
version: "3.8"
services:
  app:
    image: myapp:1.0
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "5"
```

```json
# GOOD: глобальный лимит Docker логов в daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
```

## What to look for in review

- Перенаправление stdout/stderr в файл (`>>`) без logrotate
- `docker-compose.yml` без секции `logging:` с `max-size`
- Отсутствие `/etc/logrotate.d/` конфигурации для сервисов, пишущих в файлы
- `/etc/docker/daemon.json` без `log-opts` или `max-size`
- systemd journal без `SystemMaxUse` в `journald.conf`
