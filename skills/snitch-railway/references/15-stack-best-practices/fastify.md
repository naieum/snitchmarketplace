# Fastify on Railway

Fastify with `@fastify/helmet` and `@fastify/rate-limit` runs cleanly on Railway.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "node server.js",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

```js
import Fastify from 'fastify';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';

const fastify = Fastify({ trustProxy: true, logger: true });

await fastify.register(helmet, {
  global: true,
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true }
});

await fastify.register(rateLimit, {
  max: 5,
  timeWindow: '1 minute',
  allowList: [],
  keyGenerator: (req) => req.ip
});

fastify.get('/health', () => ({ ok: true }));

await fastify.listen({ port: process.env.PORT ?? 3000, host: '0.0.0.0' });
```

## Notes

- `trustProxy: true` required behind Railway's proxy.
- For multipart streaming uploads, ship to R2/S3 — not local disk.

## Docs

- https://fastify.dev/docs/latest/Reference/Server/
- https://docs.railway.com/guides/fastify
