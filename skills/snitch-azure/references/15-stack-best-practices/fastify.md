# Fastify on Azure

Verdict + caveats: `fit-matrix fastify`. Docs: `stack-docs fastify`.

## Landing

- **App Service Linux Node 20** — canonical.
- **Container Apps** — Docker.
- **Functions** — Fastify in Functions via custom handler loses plugin lifecycle on cold start; only for low-traffic APIs.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `@fastify/helmet` for headers.
- Connection pool: PG / MySQL — pool size = (vCPUs * 2) + 1 typical.
- `@fastify/multipart` streaming uploads → write directly to Blob Storage SDK; never local disk.

## Skill targets

Same App Service hardening as Express. Plus:

| Finding | Severity |
|---|---|
| `@fastify/helmet` not present | WARN |
| `@fastify/cors` with `origin: '*'` and `credentials: true` | FAIL (browser rejects anyway) |
