# Laravel on DigitalOcean

Verdict: `fit-matrix laravel`. Docs: `stack-docs laravel`.

## Landing

| Option | Detail |
|---|---|
| App Platform PHP service | Composer + nginx + php-fpm |
| Droplet + LEMP + supervisord | Full control; queue workers |
| DOKS | Scaled-out |

## Hardening

- `APP_ENV=production`, `APP_DEBUG=false`. Debugbar / Telescope must NOT ship.
- `APP_KEY` set; rotate only with downtime (encrypted columns / sessions break).
- `SESSION_DRIVER=redis` (Managed Redis) for multi-instance.
- `QUEUE_CONNECTION=redis` + Worker component or supervisord for `artisan queue:work`.
- `Storage::disk('do')` for Spaces. Signed URLs for private content.
- DB: Managed Postgres / MySQL with `sslmode=require` / `MYSQL_ATTR_SSL_CA`.
- Build step: `php artisan config:cache && route:cache && view:cache`.
- CSRF on POST/PUT/PATCH/DELETE (default; verify not disabled).
- Rate limiting via `RateLimiter` facade.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `APP_DEBUG=true` in prod |
| 🔴 FAIL | `APP_KEY` not in `type: SECRET` |
| 🔴 FAIL | `SESSION_DRIVER=file` with `instance_count > 1` |
| 🔴 FAIL | Storage driver pointing at local disk on App Platform |
| 🔴 FAIL | Plain `DB_PASSWORD` env |
