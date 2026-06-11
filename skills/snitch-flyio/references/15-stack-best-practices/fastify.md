# Fastify on Fly.io

Node + Fastify. Same shape as Express; built-in features for proxy trust, schema validation, structured logs.

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
  min_machines_running = 0

  [[http_service.checks]]
    grace_period = "10s"
    interval = "30s"
    path = "/health"
```

## Trust the proxy

```js
const fastify = Fastify({ logger: true, trustProxy: true });
```

## Health endpoint

```js
fastify.get('/health', async (req, reply) => {
  try { await pg.query('SELECT 1'); }
  catch (e) { return reply.code(503).send({ ok: false, error: e.message }); }
  return { ok: true };
});
```

## Multipart uploads

`@fastify/multipart` streams to disk by default. For large uploads, pipe to Tigris:

```js
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
const s3 = new S3Client({
  endpoint: 'https://fly.storage.tigris.dev',
  region: 'auto',
  credentials: { accessKeyId: process.env.AWS_ACCESS_KEY_ID, secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY },
});

fastify.post('/upload', async (req) => {
  const data = await req.file();
  await s3.send(new PutObjectCommand({ Bucket: process.env.BUCKET_NAME, Key: data.filename, Body: data.file }));
  return { ok: true };
});
```

## Sessions

`@fastify/session` with `connect-redis` or `connect-pg-simple`. Memory store doesn't survive machine swaps.

## Graceful shutdown

```js
process.on('SIGINT', async () => {
  await fastify.close();
  process.exit(0);
});
```

## Common mistakes

| Mistake | Cost |
|---|---|
| Forgetting `trustProxy: true` | `req.ip` is wrong. |
| `@fastify/static` for uploads on multi-machine | Uploads to A invisible from B. |
| No `@fastify/helmet` | Security headers absent. |
| Logging request bodies in prod | Secrets leak. |
