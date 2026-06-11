# Bun on Fly.io

Bun runtime in a Dockerfile. Long-lived HTTP, fast cold-start. Bun's HTTP server is unusually fast — useful for high-throughput APIs.

## Dockerfile

```dockerfile
FROM oven/bun:1.1
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile --production
COPY . .
EXPOSE 8080
CMD ["bun", "run", "src/index.ts"]
```

Pin Bun's version (`oven/bun:1.1`, not `:latest`).

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
    grace_period = "5s"
    interval = "30s"
    path = "/health"
```

## src/index.ts

```ts
const server = Bun.serve({
  port: Number(Bun.env.PORT ?? 8080),
  hostname: "0.0.0.0",
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/health") return new Response("ok");
    return new Response("Hello, Fly!");
  },
});

process.on("SIGINT", () => { server.stop(); process.exit(0); });
```

## With Hono

```ts
import { Hono } from "hono";
const app = new Hono();
app.get("/health", (c) => c.json({ ok: true }));
export default { port: Number(Bun.env.PORT ?? 8080), fetch: app.fetch };
```

Hono is the most-tested framework on Bun.

## DB drivers

| Driver | Status |
|---|---|
| `postgres` (porsager/postgres) | Works. |
| `pg` (node-postgres) | Works. |
| `mysql2` | Works. |
| `redis` (node-redis) | Works. |

For native bindings (`bcrypt`), prefer `bun-bcrypt` or pure-JS `argon2`.

## Common mistakes

| Mistake | Cost |
|---|---|
| `oven/bun:latest` | Deploys differ over time. |
| `bun install` cache for prod | Use `--frozen-lockfile --production`. |
| Mixing CJS + ESM | Bun handles it; errors are confusing. Prefer pure ESM. |
| No graceful shutdown | In-flight requests die. |
| Pinning only `:1` for prod | Pin major.minor (Bun is still maturing). |
