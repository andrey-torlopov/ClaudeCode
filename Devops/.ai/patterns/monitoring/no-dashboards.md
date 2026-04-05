# No Dashboards

## Why this is bad

- Проверка состояния через CLI (`kubectl top`, `curl /metrics`) не масштабируется на 10+ сервисов
- Без overview-дашборда невозможно быстро оценить масштаб инцидента при on-call
- Тренды (рост трафика, деградация латентности) видны только на графиках, не в числах
- Новый инженер не может понять состояние системы без визуального обзора

## Bad Example

```bash
# BAD: мониторинг через CLI - работает для одного сервиса, не для production
kubectl top pods -n production
curl -s http://localhost:9090/api/v1/query?query=up | jq .
docker stats --no-stream
```

```yaml
# BAD: Prometheus настроен, но нет ни одного дашборда
# Все метрики собираются, но визуализации нет
# Команда проверяет состояние через Prometheus Expression Browser
```

## Good Example

```json
# GOOD: Grafana дашборд с ключевыми метриками сервиса (provisioned as code)
{
  "dashboard": {
    "title": "MyApp Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "timeseries",
        "targets": [
          { "expr": "sum(rate(http_requests_total{service=\"myapp\"}[5m]))" }
        ]
      },
      {
        "title": "Error Rate (%)",
        "type": "stat",
        "targets": [
          { "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100" }
        ],
        "thresholds": [
          { "value": 0, "color": "green" },
          { "value": 1, "color": "yellow" },
          { "value": 5, "color": "red" }
        ]
      },
      {
        "title": "p99 Latency",
        "type": "timeseries",
        "targets": [
          { "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=\"myapp\"}[5m])) by (le))" }
        ]
      }
    ]
  }
}
```

```yaml
# GOOD: дашборды как код через Grafana provisioning
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  labels:
    grafana_dashboard: "1"
data:
  myapp-overview.json: |
    { ... dashboard JSON ... }
```

## What to look for in review

- Grafana/мониторинг установлен, но нет dashboard provisioning в IaC
- Мониторинг состояния через `kubectl`, `docker stats`, `htop` в runbook
- Нет отдельных дашбордов для: overview, per-service, SLO, infrastructure
- Дашборды созданы вручную через UI, не сохранены как код
- Отсутствие RED (Rate/Errors/Duration) или USE (Utilization/Saturation/Errors) панелей
