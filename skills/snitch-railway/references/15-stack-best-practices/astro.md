# Astro on Railway

Astro fits Railway only in **server** or **hybrid** output mode. Static-only Astro → Pages/Netlify/Vercel — Railway is wasted compute for static.

## Adapter (`astro.config.mjs`)

```js
import { defineConfig } from 'astro/config';
import node from '@astrojs/node';
export default defineConfig({
  output: 'server',
  adapter: node({ mode: 'standalone' }),
});
```

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "node ./dist/server/entry.mjs",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

- Set HSTS + security headers in middleware (`src/middleware.ts`).
- Bind `HOST=0.0.0.0` (Railway sets `PORT`).
- Disable dev-mode integrations in production.

## Gotchas

- Astro DB is libSQL — separate from Railway Postgres.
- `sharp` for image optimization — Nixpacks installs automatically on Node builds.

## Docs

- https://docs.astro.build/en/guides/integrations-guide/node/
- https://docs.railway.com/guides/astro
