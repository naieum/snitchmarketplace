# Next.js on Fly.io

Long-lived Node process. `fly launch` autodetects next.config.js. Standalone output is best.

## next.config.js

```js
module.exports = { output: 'standalone' };   // smallest image
```

## fly.toml essentials

```toml
[env]
  NODE_ENV = "production"
  PORT = "3000"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0

  [[http_service.checks]]
    grace_period = "20s"     # Next builds the route tree on boot
    interval = "30s"
    path = "/api/health"
```

## /api/health

```ts
// app/api/health/route.ts
export const dynamic = 'force-dynamic';
export async function GET() {
  return Response.json({ ok: true });
}
```

## Server Actions / route handlers

Run as long-lived Node — no edge-runtime limitations. Multipart, streaming, WebSockets all work.

`export const runtime = 'edge'` still runs on the same Node process with the WinterCG subset; doesn't change Fly billing.

## ISR / on-demand revalidation

`.next/cache` is per-machine.

| Setup | Strategy |
|---|---|
| Single-machine app | Mount a volume on `.next/cache`. |
| Multi-machine | Shared cache: Redis with `@neshca/cache-handler` adapter. |

```toml
[mounts]
  source = "next_cache"
  destination = "/app/.next/cache"
  initial_size = "1gb"
```

## Secrets

```sh
fly secrets set \
  DATABASE_URL=... \
  NEXTAUTH_SECRET=$(openssl rand -base64 32) \
  STRIPE_SECRET_KEY=sk_... \
  -a <app>
```

## Common mistakes

| Mistake | Cost |
|---|---|
| `output: 'standalone'` not set | Image bloat. |
| ISR enabled but no shared cache | Inconsistent revalidation. |
| `NEXT_PUBLIC_*` for secrets | Values shipped to client. |
| `min_machines_running = 0` for SSR-heavy | Cold-start visible to users. |
| `/api/health` not `dynamic` | Next caches it; health "lies." |
