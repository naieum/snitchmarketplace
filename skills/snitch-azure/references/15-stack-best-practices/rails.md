# Rails on Azure

Verdict + caveats: `fit-matrix rails`. Docs: `stack-docs rails`.

## Landing

- **App Service Linux Ruby** — supports Ruby 3.x. Rails 7+ runs directly.
- **Container Apps** — Docker.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `RAILS_MASTER_KEY` from Key Vault (`@Microsoft.KeyVault(...)`).
- DB: PostgreSQL Flexible Server with AAD + private endpoint.
- Active Storage: `azure` service via `azure-storage-blob` gem.
- Active Job: `sidekiq` worker as separate App Service / Container App; broker = Azure Cache for Redis.
- ActionCable WebSockets: enable Web Sockets on App Service (`webSocketsEnabled=true`); behind Front Door, ensure session affinity if needed.
- `config.force_ssl = true`.
- `config.session_store :cookie_store` — `secure: true, httponly: true, same_site: :lax`.

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `RAILS_ENV` not `production` in prod env | FAIL |
| `force_ssl` not enabled | FAIL |
| Sidekiq web UI exposed without auth | FAIL |
