# Deno on Fly.io

Deno runtime in a Dockerfile. Long-lived HTTP fits Fly's machine model. WebSockets work natively.

## Dockerfile

```dockerfile
FROM denoland/deno:alpine-1.43.6
WORKDIR /app
COPY . .
RUN deno cache main.ts
EXPOSE 8080
CMD ["deno", "run", "--allow-net", "--allow-env", "--allow-read", "main.ts"]
```

## fly.toml essentials

```toml
[env]
  PORT = "8080"
  DENO_ENV = "production"

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

## main.ts

```ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
const port = Number(Deno.env.get("PORT") ?? 8080);
serve(
  (req) => {
    const url = new URL(req.url);
    if (url.pathname === "/health") return new Response("ok");
    return new Response("Hello, Fly!");
  },
  { port, hostname: "0.0.0.0" },
);
```

## Permissions

Run with minimum permissions. Avoid `--allow-all`:

| Use case | Flags |
|---|---|
| HTTP server | `--allow-net --allow-env` |
| Static files | `--allow-read=./public` |
| DB driver | `--allow-net=db-host:5432` |

## Migrating from Deno Deploy

| Deploy concept | Fly replacement |
|---|---|
| `Deno.openKv()` | Postgres / Redis / Tigris |
| `Deno.serve()` | Works identically. |
| Per-request isolation | Fly machines have CPU/memory limits, not isolation. |

## DB drivers

```ts
import { Client } from "https://deno.land/x/postgres@v0.19.3/mod.ts";
// or:
import pg from "npm:pg";
```

## Common mistakes

| Mistake | Cost |
|---|---|
| `--allow-all` in prod | Defeats Deno's main security feature. |
| Using `Deno.openKv()` on Fly | Deploy-only; will fail. |
| Forgetting `--allow-read` for static assets | 500s on asset paths. |
| `denoland/deno:latest` | Production should pin a version. |
