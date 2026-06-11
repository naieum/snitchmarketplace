# Flask on Azure

Verdict + caveats: `fit-matrix flask`. Docs: `stack-docs flask`.

## Landing

- **App Service Linux Python 3.11+** — canonical with `gunicorn`.
- **Container Apps** — Docker.
- **Functions** — low-traffic API-only Flask via WSGI adapter.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `SECRET_KEY` from Key Vault (Flask sessions are signed but not encrypted).
- Sessions: `flask-session` with Redis backend on Azure Cache.
- DB: SQLAlchemy with PG Flexible Server; pool size matters.
- `flask-talisman` for headers (CSP, HSTS, X-Frame-Options) — defaults reasonable.
- `flask-limiter` for rate limiting; or push to APIM.
- CSRF: `flask-wtf` `CSRFProtect`.
- `DEBUG = False` in production.

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `app.run(debug=True)` in production code | FAIL |
| No `flask-talisman` and no equivalent | WARN |
