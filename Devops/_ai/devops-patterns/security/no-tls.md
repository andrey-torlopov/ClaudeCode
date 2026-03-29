# No TLS

## Why this is bad

- Трафик между сервисами передается в открытом виде - перехват через MITM тривиален
- Пароли, токены, персональные данные видны при tcpdump на любом промежуточном узле
- Compliance (GDPR, PCI DSS) требует шифрование данных в транзите
- В cloud-средах трафик проходит через shared-инфраструктуру провайдера

## Bad Example

```nginx
# BAD: nginx слушает только HTTP без редиректа на HTTPS
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend:8080;
    }
}
```

```yaml
# BAD: Redis без TLS в Kubernetes
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  ports:
    - port: 6379
      targetPort: 6379
---
# Приложение подключается по redis://redis:6379 без шифрования
```

## Good Example

```nginx
# GOOD: принудительный HTTPS с современными параметрами TLS
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://backend:8080;
    }
}
```

```yaml
# GOOD: cert-manager автоматически выпускает TLS-сертификаты в K8s
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend
                port:
                  number: 8080
```

## What to look for in review

- URL-ы вида `http://` вместо `https://` в конфигах сервисов
- nginx конфиги с `listen 80` без `return 301 https://`
- Отсутствие `ssl_certificate` / `tls` секций в конфигах прокси
- Redis, PostgreSQL, MongoDB подключения без `?ssl=true` или `sslmode=require`
- K8s Ingress без `tls:` секции
