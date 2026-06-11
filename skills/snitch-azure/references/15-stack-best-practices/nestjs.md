# NestJS on Azure

Verdict + caveats: `fit-matrix nestjs`. Docs: `stack-docs nestjs`.

## Landing

- **App Service Linux Node 20** — canonical.
- **Container Apps** — Docker; preferred for multiple microservices over Dapr.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `@nestjs/throttler` for rate limiting; or push to Front Door / App Gateway WAF.
- `helmet` middleware for headers.
- DI scoping: REQUEST-scoped providers prevent shared-state leaks.
- Microservices over TCP/Redis: prefer Container Apps with internal-only ingress; Service Bus is the Azure-native broker.
- TypeORM / Sequelize: pool size matters. Validate against DB instance size.

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `helmet` not present | WARN |
| Microservices via TCP transport on App Service | WARN (fragile; recommend Container Apps) |
