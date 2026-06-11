# Laravel on Azure

Verdict + caveats: `fit-matrix laravel`. Docs: `stack-docs laravel`.

## Landing

- **App Service Linux PHP 8.2** — canonical. Composer install + artisan migrate via deployment script.
- **Container Apps** — Docker.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `APP_KEY` + DB credentials from Key Vault references.
- Sessions: `SESSION_DRIVER=redis` → Azure Cache for Redis.
- Storage: `FILESYSTEM_DISK=azure` with `league/flysystem-azure-blob-storage`. Default `local` writes to ephemeral disk.
- Queue: `QUEUE_CONNECTION=redis` or `azure-servicebus`. Worker = separate Web App with `php artisan queue:work` or Container App.
- Trust proxies: `TrustProxies` middleware needs App Service + Front Door X-Forwarded-* headers.
- CSRF: Laravel handles by default.
- `APP_DEBUG=false` in prod (stack traces leak server paths + DB driver info).

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `APP_DEBUG=true` in production env vars | FAIL |
| File storage default = `local` (breaks on multi-instance) | WARN |
