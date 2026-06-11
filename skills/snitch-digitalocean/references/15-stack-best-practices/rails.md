# Rails on DigitalOcean

Verdict: `fit-matrix rails`. Docs: `stack-docs rails`.

## Landing

| Option | Detail |
|---|---|
| App Platform Ruby buildpack | Puma; PG/Redis attachable |
| Droplet + Puma + nginx + Managed PG/Redis | Full control |
| DOKS | Scaled-out |

## Hardening

- `RAILS_ENV=production`, `RAILS_SERVE_STATIC_FILES=true` (or nginx serves `public/`).
- `SECRET_KEY_BASE` in `type: SECRET`. Rotation breaks signed cookies.
- `config.force_ssl = true` in `production.rb`.
- `config.action_dispatch.default_headers` — set `X-Frame-Options`, `X-Content-Type-Options`, CSP.
- Sidekiq Web UI behind Basic Auth: `Sidekiq::Web.use Rack::Auth::Basic ...`.
- DB: `DATABASE_URL` includes `?sslmode=require`.
- Cache / Sidekiq backend: Managed Redis with `rediss://`.
- ActionCable: explicit `config.action_cable.allowed_request_origins`.
- `Rack::Attack` for rate limiting + IP banning.
- Strong parameters everywhere (audit for `permit!`).

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `force_ssl = false` |
| 🔴 FAIL | `SECRET_KEY_BASE` plain env |
| 🔴 FAIL | `DATABASE_URL` without `sslmode=require` |
| 🔴 FAIL | Sidekiq Web UI exposed without auth |
| 🟡 WARN | `permit!` in any controller |
