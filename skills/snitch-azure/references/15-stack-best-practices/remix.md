# Remix on Azure

Verdict + caveats: `fit-matrix remix`. Docs: `stack-docs remix`.

## Landing

- **App Service Linux Node 20** — canonical full-Remix SSR.
- **Container Apps** — Docker.
- **Static Web Apps** — fully static Remix builds only (`@remix-run/serve` not used).

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off (`fix appservice`).
- Loaders that hit DBs: connection string in Key Vault, not env.
- Form actions (POSTs): rate-limit via Front Door / App Gateway WAF.
- CSP in `headers()` per route or global via App Service custom headers.

## Skill targets

Same App Service hardening as Next.js. Plus:

| Finding | Severity |
|---|---|
| Long-running side effects from actions (>30s) | WARN — move to Service Bus + Container Apps Job |
