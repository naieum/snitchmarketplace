# Flask on Railway

Nixpacks detects Flask via `requirements.txt`. Use `gunicorn` for production.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "gunicorn app:app --bind 0.0.0.0:$PORT --workers 3",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

```python
from flask import Flask
from flask_talisman import Talisman
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1, x_for=1)

Talisman(
    app,
    force_https=True,
    strict_transport_security=True,
    strict_transport_security_max_age=31536000,
    strict_transport_security_include_subdomains=True,
    strict_transport_security_preload=True,
    content_security_policy={'default-src': "'self'"},
    referrer_policy='strict-origin-when-cross-origin'
)

@app.route('/health')
def health():
    return 'ok', 200
```

## Patterns

- Background jobs: separate Railway service running Celery + Redis Railway service.
- Sessions: server-side via `flask-session` + Redis.
- DB: SQLAlchemy with `${{ Postgres.DATABASE_URL }}`.

## Docs

- https://flask.palletsprojects.com/en/latest/security/
- https://docs.railway.com/guides/flask
