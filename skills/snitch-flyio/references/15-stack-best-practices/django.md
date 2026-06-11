# Django on Fly.io

Django + gunicorn (or uvicorn for async). `fly launch` autodetects manage.py and generates a Dockerfile. Pair with Managed Postgres.

## fly.toml essentials

```toml
[env]
  PORT = "8000"
  PYTHONUNBUFFERED = "1"
  DJANGO_SETTINGS_MODULE = "myproject.settings"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1

  [[http_service.checks]]
    grace_period = "15s"
    interval = "30s"
    path = "/health/"

[processes]
  app = "gunicorn myproject.wsgi --bind 0.0.0.0:8000 --workers 4"
  worker = "celery -A myproject worker -l INFO"

[deploy]
  release_command = "python manage.py migrate --no-input"
```

## Secrets

```sh
fly secrets set \
  SECRET_KEY=$(python -c 'import secrets; print(secrets.token_urlsafe(50))') \
  DEBUG=False \
  ALLOWED_HOSTS=myapp.fly.dev,myapp.com \
  -a <app>
```

`DATABASE_URL` from `fly postgres attach`.

## settings.py for Fly

```python
SECRET_KEY = os.environ['SECRET_KEY']
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

DATABASES = {'default': dj_database_url.parse(os.environ['DATABASE_URL'])}

# Trust Fly's proxy
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

## Channels (WebSockets)

Use Daphne or uvicorn (ASGI). Channels needs Redis as the channel layer:

```sh
fly redis create --name myapp-channels
fly secrets set REDIS_URL=$(fly redis status myapp-channels --json | jq -r '.private_url') -a <app>
```

## Static files

| Option | Use |
|---|---|
| WhiteNoise | Bundles static; one-line setup; small/medium apps. |
| Tigris | `django-storages[s3]` with `AWS_S3_ENDPOINT_URL=https://fly.storage.tigris.dev`. Better for large media. |

## Common mistakes

| Mistake | Cost |
|---|---|
| `DEBUG=True` in prod | Verbose errors leak code paths. |
| `SECRET_KEY` in [env] | Should be fly secret. |
| `ALLOWED_HOSTS = ['*']` | Security risk; use explicit list. |
| No `SECURE_PROXY_SSL_HEADER` | Django thinks every request is HTTP. |
| Missing `release_command` | Migrations don't run; deploys break schema mid-rollout. |
| Channels without explicit Redis URL | Falls back to in-memory, breaks across machines. |
