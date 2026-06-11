# Django on Railway

Nixpacks detects `requirements.txt`. Use `gunicorn` for production.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "gunicorn yourproject.wsgi --bind 0.0.0.0:$PORT --workers 3 --timeout 60",
    "healthcheckPath": "/health/",
    "numReplicas": 2
  }
}
```

## Hardening (`settings.py`)

```python
import os

DEBUG = False
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
ALLOWED_HOSTS = [os.environ['RAILWAY_PUBLIC_DOMAIN'], 'yourdomain.com']

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_REFERRER_POLICY = 'strict-origin-when-cross-origin'
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
X_FRAME_OPTIONS = 'DENY'

CSRF_TRUSTED_ORIGINS = [
    f"https://{os.environ['RAILWAY_PUBLIC_DOMAIN']}",
]
```

## Patterns

- Celery workers: separate Railway service.
- Static: WhiteNoise for simple cases; R2/S3 for production.
- Channels (WebSockets): `daphne` or `uvicorn` ASGI; serve via public HTTPS domain.

## Docs

- https://docs.djangoproject.com/en/stable/topics/security/
- https://docs.railway.com/guides/django
