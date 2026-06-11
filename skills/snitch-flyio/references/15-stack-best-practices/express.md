# Express on Fly.io

Node + Express. `fly launch` autodetects package.json.

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
  min_machines_running = 0    # bump to 1 for prod-critical paths

  [[http_service.checks]]
    grace_period = "10s"
    interval = "30s"
    path = "/health"
```

## Trust the proxy

```js
app.set('trust proxy', 1);
```

Without this, `req.ip`, `req.protocol`, and middleware reading X-Forwarded-* are wrong.

## Health endpoint

```js
app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.status(200).json({ ok: true });
  } catch (e) {
    res.status(503).json({ ok: false, error: e.message });
  }
});
```

503 on critical-dep failure makes Fly stop routing.

## Graceful shutdown

```js
const server = app.listen(process.env.PORT);
process.on('SIGINT', () => {
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 5000);
});
```

## Sessions

`MemoryStore` doesn't survive across machines. Use:

| Option | When |
|---|---|
| `connect-pg-simple` | Sessions in your Postgres. |
| `connect-redis` | Upstash-on-Fly Redis (set `REDIS_URL`). |

## Helmet + CSP

```js
import helmet from 'helmet';
app.use(helmet({ contentSecurityPolicy: { directives: { defaultSrc: ["'self'"], scriptSrc: ["'self'"] } } }));
```

## Common mistakes

| Mistake | Cost |
|---|---|
| No `trust proxy` | `req.ip` is `127.0.0.1`; rate-limit/IP allowlists break. |
| Default `MemoryStore` | Users log out on every machine swap. |
| No `/health` | Fly can't route away from broken machines. |
| No SIGINT handler | In-flight requests die mid-response. |
| `console.log(req)` in error handlers | Secrets leak into logs. |
