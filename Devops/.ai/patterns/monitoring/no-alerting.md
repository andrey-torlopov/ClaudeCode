# No Alerting

## Why this is bad

- Метрики без алертов - как камера наблюдения, которую никто не смотрит
- Инциденты обнаруживаются пользователями, а не командой - время реакции растет в 10 раз
- Без алертов на SLO-нарушения невозможно выполнить SLA перед клиентами
- Grafana-дашборд бесполезен в 3 часа ночи, когда никто его не открывает

## Bad Example

```yaml
# BAD: Prometheus без Alertmanager - метрики собираются, но никто не узнает о проблемах
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: myapp
        static_configs:
          - targets: ["myapp:8080"]
```

```yaml
# BAD: Grafana dashboard без alert rules - только визуализация
{
  "panels": [
    {
      "title": "Error Rate",
      "targets": [
        { "expr": "rate(http_errors_total[5m])" }
      ]
    }
  ]
}
```

## Good Example

```yaml
# GOOD: Prometheus alert rules на ключевые SLO
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-alerts
spec:
  groups:
    - name: myapp.rules
      rules:
        - alert: HighErrorRate
          expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Error rate выше 1% в течение 5 минут"
            runbook: "https://wiki.example.com/runbooks/high-error-rate"

        - alert: HighLatency
          expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 1
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "p99 латентность выше 1 секунды"
```

```yaml
# GOOD: Alertmanager с маршрутизацией в Slack и PagerDuty
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-config
stringData:
  alertmanager.yml: |
    route:
      receiver: slack-default
      routes:
        - match:
            severity: critical
          receiver: pagerduty
    receivers:
      - name: slack-default
        slack_configs:
          - channel: "#alerts"
      - name: pagerduty
        pagerduty_configs:
          - service_key_file: /etc/alertmanager/secrets/pagerduty-key
```

## What to look for in review

- Prometheus/VictoriaMetrics без настроенных alert rules
- Grafana дашборды без alert conditions
- Отсутствие Alertmanager или аналога в стеке мониторинга
- Alert rules без `runbook` ссылки в annotations
- Нет `severity` label для приоритизации алертов
