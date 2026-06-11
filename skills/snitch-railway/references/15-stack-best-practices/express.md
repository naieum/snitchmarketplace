# Express on Railway

Express is Railway's natural home — long-lived Node, no edge-runtime constraints.

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
import express from 'express';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

const app = express();
app.set('trust proxy', 1);
app.use(helmet({
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true }
}));

const authLimiter = rateLimit({ windowMs: 60_000, max: 5, standardHeaders: true, legacyHeaders: false });
app.use(['/login', '/signup', '/api/auth/'], authLimiter);

app.get('/health', (_, res) => res.status(200).send('ok'));

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`listening on ${PORT}`));
```

## Gotchas

- `express-session` in-memory: per-replica. Move to Redis when `numReplicas > 1`.
- `multer` disk uploads: local FS resets on restart. Use Railway volume or R2/S3.
- `app.set('trust proxy', 1)` required for `req.ip` behind Railway's proxy.

## Docs

- https://expressjs.com/en/advanced/best-practice-security.html
- https://docs.railway.com/guides/express
