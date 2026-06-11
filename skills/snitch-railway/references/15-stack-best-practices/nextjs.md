# Next.js on Railway

Nixpacks detects `package.json` + `next` dependency. Build runs `next build`; start runs `next start`.

## railway.json

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "npm run start",
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 30,
    "numReplicas": 2,
    "restartPolicyType": "ON_FAILURE"
  }
}
```

Add `pages/api/health.ts` (or `app/api/health/route.ts`) returning `200`.

## Hardening

`next.config.js`:

```js
module.exports = {
  poweredByHeader: false,
  async headers() {
    return [{
      source: '/(.*)',
      headers: [
        { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains; preload' },
        { key: 'X-Content-Type-Options', value: 'nosniff' },
        { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
        { key: 'Permissions-Policy', value: 'geolocation=(), microphone=(), camera=()' },
        { key: 'X-Frame-Options', value: 'DENY' }
      ]
    }];
  }
}
```

Notes:
- Image optimization works. Pin `sharp` if Nixpacks doesn't pick it up.
- ISR works (long-lived Node); set `revalidate` per route.
- Server Actions: rate-limit at middleware.

## Env

Reference DB: `${{ Postgres.DATABASE_URL }}`. Never expose `NEXT_PUBLIC_*` for secrets.

## Docs

- https://nextjs.org/docs
- https://docs.railway.com/guides/nextjs
