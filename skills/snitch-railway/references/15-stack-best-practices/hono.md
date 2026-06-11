# Hono on Railway

Hono on the Node adapter runs fine on Railway. For edge runtime, use Cloudflare Workers instead.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "node dist/server.js",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

```ts
import { Hono } from 'hono';
import { secureHeaders } from 'hono/secure-headers';
import { rateLimiter } from 'hono-rate-limiter';
import { serve } from '@hono/node-server';

const app = new Hono();

app.use('*', secureHeaders({
  strictTransportSecurity: 'max-age=31536000; includeSubDomains; preload',
  xFrameOptions: 'DENY',
  xContentTypeOptions: 'nosniff'
}));

app.use('/login', rateLimiter({
  windowMs: 60_000,
  limit: 5,
  keyGenerator: (c) => c.req.header('x-forwarded-for') ?? 'unknown'
}));

app.get('/health', (c) => c.text('ok'));

serve({ fetch: app.fetch, port: Number(process.env.PORT ?? 3000), hostname: '0.0.0.0' });
```

## Docs

- https://hono.dev/docs/
- https://hono.dev/docs/getting-started/nodejs
