# Django on Azure

Verdict + caveats: `fit-matrix django`. Docs: `stack-docs django`.

## Landing

- **App Service Linux Python 3.11+** — canonical. `gunicorn` + uvicorn workers for ASGI.
- **Container Apps** — Docker.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `SECRET_KEY` + DB credentials from Key Vault.
- DB: PostgreSQL Flexible Server with AAD + private endpoint.
- Static: `whitenoise` + Blob Storage backing for `MEDIA_ROOT` (django-storages with `azure-storage-blob`).
- Channels (WebSockets): `daphne`/`uvicorn`; in-memory channel layer doesn't survive multi-instance — use Azure Cache for Redis.
- Celery: separate App Service or Container App; broker = Service Bus or Redis.
- `DEBUG = False` in production.
- `ALLOWED_HOSTS` set explicitly (no `*`).
- `SECURE_SSL_REDIRECT = True`, `SESSION_COOKIE_SECURE = True`, `CSRF_COOKIE_SECURE = True`.
- `SECURE_HSTS_SECONDS = 31536000` with `INCLUDE_SUBDOMAINS = True`.

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `DEBUG = True` in prod env | FAIL |
| `ALLOWED_HOSTS = ['*']` | FAIL |
