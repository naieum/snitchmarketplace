# NestJS on DigitalOcean

Verdict: `fit-matrix nestjs`. Docs: `stack-docs nestjs`.

## Landing

| Option | When |
|---|---|
| App Platform | HTTP-only Nest |
| DOKS | Microservice mesh (TCP transport between services) |
| Droplet + Docker | Full control |

## Hardening

- `app.use(helmet())`.
- `@nestjs/throttler` backed by Redis (`@nest-lab/throttler-storage-redis`).
- `app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))`.
- TypeORM / Prisma against Managed Postgres / MySQL with `sslmode=require` / `ssl=true`.
- Microservices TCP / Redis / NATS transports are not supported between App Platform components — use DOKS.
- `@nestjs/terminus` for `/healthz`.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | No `ValidationPipe` global (mass-assignment / over-posting) |
| 🔴 FAIL | No `helmet()` |
| 🔴 FAIL | Microservices via TCP transport on App Platform (won't work cross-component) |
| 🟡 WARN | No `health_check` endpoint exposed |
