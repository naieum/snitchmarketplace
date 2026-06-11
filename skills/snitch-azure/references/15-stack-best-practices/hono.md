# Hono on Azure

Verdict + caveats: `fit-matrix hono`. Docs: `stack-docs hono`.

## Landing

- **Functions (Node)** — Hono runs natively; serverless cold-start tradeoffs.
- **Container Apps** — low-latency or scale-to-zero with longer-lived containers.
- **App Service Linux** — works, loses serverless economics.

## Must-do

- Functions: deploy via `func azure functionapp publish` or GitHub Actions OIDC + `azure/functions-action`.
- Auth via `hono/jwt` middleware; verify against AAD JWKS for Entra-issued tokens.
- Rate limiting: APIM in front of Functions, or `hono/rate-limit` middleware.
- HTTPS-only at Function App level (`httpsOnly=true`).
- Min TLS 1.2 on host.

## Skill targets

| Finding | Severity |
|---|---|
| Function app `httpsOnly` off | FAIL |
| Function app no managed identity | WARN |
| Cold-start sensitive workload on Consumption plan | WARN (recommend Premium) |
