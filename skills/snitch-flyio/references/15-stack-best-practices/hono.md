# Hono on Fly.io

Hono is Workers-first; on Fly it runs via Node/Bun adapter. Use Fly when you also want WebSockets / volumes / long-lived TCP — otherwise Workers is cheaper for short bursty requests.

## Dockerfile (Bun)

```dockerfile
FROM oven/bun:1 AS build
WORKDIR /app
COPY . .
RUN bun install --frozen-lockfile && bun run build

FROM oven/bun:1
WORKDIR /app
COPY --from=build /app/dist /app/dist
COPY --from=build /app/node_modules /app/node_modules
COPY package.json .
EXPOSE 8080
CMD ["bun", "run", "start"]
```

(Node runtime works equally well.)

## fly.toml essentials

```toml
[env]
  NODE_ENV = "production"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true

  [[http_service.checks]]
    grace_period = "10s"
    interval = "30s"
    path = "/health"
```

## src/index.ts

```ts
import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { secureHeaders } from 'hono/secure-headers';

const app = new Hono();
app.use(logger());
app.use(secureHeaders());
app.get('/health', (c) => c.json({ ok: true }));

export default { port: parseInt(process.env.PORT || '8080'), fetch: app.fetch };
```

## Migrating from Workers — drop list

| Drop | Replace with |
|---|---|
| `@cloudflare/workers-types` | — |
| `wrangler.toml` | `fly.toml` |
| `c.env.MY_KV` | Redis (Upstash) or Postgres |
| `c.env.MY_R2` | Tigris (S3-compat) via AWS SDK |
| `c.env.MY_DO` (Durable Object) | Stateful Fly app + volumes, OR keep on Workers |

## Fly vs Workers

| Fly wins | Workers wins |
|---|---|
| WebSocket-heavy app (DOs charge by duration) | Short request lifecycles, high request count |
| Background workers / long compute | 300+ city edge presence vs 30+ Fly regions |
| Volumes needed | D1 / KV / R2 / DOs fit your data model |
| Postgres low-latency from app | |

## Common mistakes

| Mistake | Cost |
|---|---|
| Using `c.env` bindings on Fly | Workers-specific. |
| Importing `@cloudflare/workers-types` | Type errors at runtime. |
| Building for edge runtime, deploying to Node | Unused bundling. |
| KV-style eventual-consistency assumptions on Postgres | Race conditions. |
