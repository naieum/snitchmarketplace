# Astro on Vercel — best practices

Astro builds with `@astrojs/vercel`. Output mode dictates runtime: `static`, `server`, or `hybrid`.

## Output mode

| Mode | Adapter | Best for |
|---|---|---|
| `static` | none (or `@astrojs/vercel/static`) | Pure SSG; everything pre-rendered |
| `server` | `@astrojs/vercel/serverless` | Fully dynamic; every page hits a function |
| `hybrid` | `@astrojs/vercel/serverless` | Default static, opt-in dynamic per route |

Edge variant: `@astrojs/vercel/edge` — smaller stdlib, no Node modules.

## Configuration

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import vercel from '@astrojs/vercel/serverless';

export default defineConfig({
  output: 'hybrid',
  adapter: vercel({
    webAnalytics: { enabled: true },
    speedInsights: { enabled: true },
    imageService: true,                 // use Vercel Image Optimization
    isr: { expiration: 60 * 60 * 24 },  // ISR-style per-page revalidation
  }),
});
```

## Headers + CSP

Astro doesn't auto-emit security headers. Use `vercel.json` `headers` (preferred) or middleware:

```ts
// src/middleware.ts
import { defineMiddleware } from "astro:middleware";

export const onRequest = defineMiddleware(async (context, next) => {
  const res = await next();
  res.headers.set("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload");
  res.headers.set("X-Content-Type-Options", "nosniff");
  res.headers.set("X-Frame-Options", "DENY");
  return res;
});
```

## Astro DB (libSQL)

Astro DB is on Turso (libSQL). Not Vercel Postgres or KV. You can run both Astro DB and Vercel Postgres but pick one for app data.

## Auth

- `astro:middleware` for session checks.
- `cookie` package + signed cookies; or Lucia, Auth.js, Clerk Astro.
- For server actions (Astro 4+), validate every input.

## Common mistakes

- `output: 'server'` on a mostly-static site → every request is a function invocation.
- Forgetting `imageService: true` → images bypass Vercel Image Optimization.
- `PUBLIC_*` env vars in Astro = `NEXT_PUBLIC_*` equivalent — same secret-leak risk.

## References

- https://docs.astro.build/en/guides/integrations-guide/vercel/
- https://docs.astro.build/en/guides/middleware/
