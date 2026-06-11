# Express on Vercel — best practices

Express on Vercel is **partial**. Two patterns work.

## Pattern A: per-file `api/` handlers (recommended for greenfield)

```
api/
  hello.ts       # exports default fn(req, res)
  users/[id].ts
package.json
```

Each file is a separate function. Cold starts per file. Use this if you're API-first; scales like serverless.

## Pattern B: single Express app wrapped as a function

```ts
// api/index.ts
import express from 'express';
const app = express();
app.use(express.json());
app.get('/api/hello', (req, res) => res.json({ ok: true }));
export default app;
```

`vercel.json`:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/api" }
  ]
}
```

Works but you pay one cold start for the whole app on every region scale-out. Fine for small APIs; for large ones, prefer per-file or move off serverless.

## What Express loses

| Lost | Replacement |
|---|---|
| `app.listen()` | No-op — Vercel manages the listener |
| In-memory state | Doesn't persist across invocations (no shared sessions, no cache) |
| WebSocket upgrades | Don't work — long-running host |
| `multer` disk uploads | Use `@vercel/blob` upload |
| Large request body | Capped at function body-size limit |

## Hardening

```ts
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

app.use(helmet({
  contentSecurityPolicy: false,            // set CSP via vercel.json
  hsts: { maxAge: 63072000, includeSubDomains: true, preload: true },
}));

app.use('/api/auth/', rateLimit({
  windowMs: 60_000,
  max: 5,
  // memory store doesn't survive across functions; use a Redis store
  // store: new RedisStore({ ... }),
}));

app.set('trust proxy', 1);                 // req.ip = real client behind Vercel proxy
```

## When to leave

- WebSockets / long-poll
- Long-running tasks (>15min)
- Heavy native modules (`puppeteer`, large `sharp`)
- Sticky sessions

→ Fly Machines, Railway, AWS.

## References

- https://vercel.com/guides/using-express-with-vercel
- https://expressjs.com/en/advanced/best-practice-security.html
