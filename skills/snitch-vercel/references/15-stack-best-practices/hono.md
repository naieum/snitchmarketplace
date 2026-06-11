# Hono on Vercel — best practices

Hono fits Vercel naturally as either serverless or edge. Easiest non-framework stack on Vercel.

## Edge function

```ts
// app/api/[[...path]]/route.ts (Next.js App Router) — or api/index.ts (no framework)
import { Hono } from 'hono';
import { handle } from 'hono/vercel';

export const runtime = 'edge';

const app = new Hono().basePath('/api');
app.get('/hello', (c) => c.json({ ok: true }));

export const GET  = handle(app);
export const POST = handle(app);
```

## Standalone (no Next.js)

```
api/
  index.ts        # Hono app + export default handle(app)
package.json
vercel.json       # optional
```

`vercel.json`:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/api" }
  ]
}
```

## Built-in security middleware

```ts
import { secureHeaders } from 'hono/secure-headers';
import { csrf } from 'hono/csrf';
import { logger } from 'hono/logger';

app.use(secureHeaders());
app.use(csrf({ origin: 'https://example.com' }));
app.use(logger());
```

`secureHeaders()` emits HSTS, X-Frame, Referrer-Policy by default. Override or supplement with `vercel.json` `headers` for static asset paths.

## Validation

```ts
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

app.post('/items',
  zValidator('json', z.object({ name: z.string().min(1).max(200) })),
  (c) => {
    const { name } = c.req.valid('json');
    return c.json({ ok: true });
  },
);
```

## Auth

`hono/jwt` middleware for stateless auth, or cookie-based session + KV store.

## Common mistakes

- Importing Node modules in edge runtime → build fails.
- Missing CSRF middleware on browser-initiated POSTs.
- Mounting Hono inside Next.js without setting `runtime` — picks up Node default.

## References

- https://hono.dev/docs/getting-started/vercel
- https://hono.dev/docs/middleware/builtin/secure-headers
