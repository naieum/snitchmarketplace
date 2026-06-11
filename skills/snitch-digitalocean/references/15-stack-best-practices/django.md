# Django on DigitalOcean

Verdict: `fit-matrix django`. Docs: `stack-docs django`.

## Landing

| Option | Detail |
|---|---|
| App Platform Python service | gunicorn + Managed Postgres |
| Droplet + gunicorn/uvicorn + nginx | Full control |
| DOKS | Scaled-out |

## Hardening

- `DEBUG = False`. Critical — `DEBUG=True` leaks settings + DB schema on errors.
- `ALLOWED_HOSTS` populated explicitly (no `*`).
- `SECURE_SSL_REDIRECT = True`, `SESSION_COOKIE_SECURE = True`, `CSRF_COOKIE_SECURE = True`.
- `SECRET_KEY` in `type: SECRET`. Rotation breaks sessions / signed URLs.
- `SECURE_HSTS_SECONDS = 31536000`, `SECURE_HSTS_INCLUDE_SUBDOMAINS = True`, `SECURE_HSTS_PRELOAD = True`.
- `SECURE_CONTENT_TYPE_NOSNIFF = True`, `X_FRAME_OPTIONS = 'DENY'`.
- DB: `'OPTIONS': {'sslmode': 'require'}`.
- Cache: `django-redis` against Managed Redis with `rediss://`.
- Channels (WebSockets): Managed Redis as channel layer.
- Celery: App Platform Worker component or supervisord on Droplet.
- `django-axes` or `django-ratelimit` for auth brute-force protection.
- Static files: `collectstatic` to Spaces via `django-storages`.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `DEBUG = True` in any production env |
| 🔴 FAIL | `ALLOWED_HOSTS = ['*']` |
| 🔴 FAIL | `SECRET_KEY` plain env |
| 🔴 FAIL | `DATABASES.default.OPTIONS.sslmode` not `require` |
| 🟡 WARN | No `SECURE_HSTS_SECONDS` |
