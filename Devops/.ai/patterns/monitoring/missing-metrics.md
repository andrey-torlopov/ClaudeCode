# Missing Metrics

## Why this is bad

- Без метрик диагностика инцидента превращается в гадание: "что-то тормозит, но непонятно где"
- Нет baseline - невозможно определить нормальное поведение и отклонения от нормы
- Capacity planning без данных о потреблении ресурсов - пустая трата денег или риск перегрузки
- Post-mortem без метрик и трейсов не дает actionable выводов

## Bad Example

```python
# BAD: приложение без метрик, логи через print
from flask import Flask

app = Flask(__name__)

@app.route("/api/orders", methods=["POST"])
def create_order():
    try:
        order = process_order(request.json)
        print(f"Order created: {order.id}")
        return jsonify(order), 201
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500
```

```yaml
# BAD: сервис без /metrics endpoint, нечего скрейпить
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  template:
    spec:
      containers:
        - name: api
          image: myapi:1.0
          ports:
            - containerPort: 8080
```

## Good Example

```python
# GOOD: Prometheus метрики + структурированные логи
import logging
import structlog
from flask import Flask, request
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)
logger = structlog.get_logger()

REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["endpoint"])

@app.route("/api/orders", methods=["POST"])
def create_order():
    with REQUEST_LATENCY.labels(endpoint="/api/orders").time():
        try:
            order = process_order(request.json)
            REQUEST_COUNT.labels(method="POST", endpoint="/api/orders", status="201").inc()
            logger.info("order_created", order_id=order.id)
            return jsonify(order), 201
        except Exception:
            REQUEST_COUNT.labels(method="POST", endpoint="/api/orders", status="500").inc()
            logger.exception("order_creation_failed")
            return jsonify({"error": "internal"}), 500

@app.route("/metrics")
def metrics():
    return generate_latest()
```

```yaml
# GOOD: под с Prometheus annotations для автоматического scraping
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: api
          image: myapi:1.0
          ports:
            - containerPort: 8080
```

## What to look for in review

- Сервисы без `/metrics` endpoint или Prometheus-экспортера
- `print()` / `console.log()` вместо structured logging (JSON)
- K8s поды без `prometheus.io/scrape` annotation
- Отсутствие RED-метрик (Rate, Errors, Duration) для HTTP-сервисов
- Нет трейсинга (OpenTelemetry / Jaeger) для распределенных систем
