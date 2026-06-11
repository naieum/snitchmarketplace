# Flask on DigitalOcean

Verdict: `fit-matrix flask`. Docs: `stack-docs flask`.

## Landing

App Platform Python (gunicorn) / Functions for tiny endpoints / Droplet + gunicorn + nginx + Managed Postgres.

## Hardening

- `DEBUG = False`. Werkzeug debugger PIN does not protect against RCE if exposed.
- `SECRET_KEY` in `type: SECRET`.
- `SESSION_COOKIE_SECURE = True`, `SESSION_COOKIE_HTTPONLY = True`, `SESSION_COOKIE_SAMESITE = 'Lax'`.
- `flask-talisman` for CSP / HSTS / X-Frame.
- `flask-limiter` backed by Redis.
- `flask-wtf` for CSRF.
- DB: SQLAlchemy with `connect_args={'sslmode': 'require'}`.
- Behind reverse proxy on Droplets, use `ProxyFix` for forwarded-for headers.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `DEBUG = True` in prod |
| 🔴 FAIL | No CSRF on POST endpoints |
| 🔴 FAIL | No rate limit on auth |
| 🔴 FAIL | `SECRET_KEY` plain env |
