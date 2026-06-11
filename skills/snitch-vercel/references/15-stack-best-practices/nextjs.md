# Next.js on Vercel — best practices

Next.js is Vercel's home turf; almost every feature lights up here.

## Runtime choice

- App Router default: Node serverless. Add `export const runtime = 'edge'` per route to opt into edge.
- Pages Router default: same.
- Mixing is fine; route-level config wins.

| Pick | For |
|---|---|
| Edge | Auth checks, geo routing, lightweight transforms |
| Node | `fs`, native modules, >30s timeouts |

## Server Actions

- Always validate input. Server Actions look like RPC; they ARE public POST endpoints.
- Rate-limit at edge middleware before they fire.
- Don't leak the action's `id` server-to-client unless you're OK with anyone calling it.

## ISR / on-demand revalidation

- `revalidate` on `fetch` works on Vercel out of the box.
- `revalidatePath`/`revalidateTag` need a server action or route handler.
- Verify a `signature` header on revalidation endpoints (`CRON_SECRET` or HMAC).

## next/image

- Pin `images.remotePatterns` to known hosts. Never wildcards in production.
- For UGC, host on Vercel Blob or a dedicated image CDN.
- Image Optimization counts unique source URLs against your plan quota.

## Auth

- `next-auth` / `@auth/core` v5, Clerk, Auth0, or roll JWT.
- Verify session at edge middleware to short-circuit unauth before the function fires.
- Cookies: `httpOnly`, `secure`, `sameSite: 'lax'` for sessions; `'strict'` for CSRF-sensitive paths.

## Configuration

```js
// next.config.js
module.exports = {
  poweredByHeader: false,                  // remove X-Powered-By: Next.js
  reactStrictMode: true,
  experimental: {
    serverActions: { bodySizeLimit: '1mb' },
  },
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'images.example.com' },
    ],
    minimumCacheTTL: 60,
  },
  async headers() {
    // Set headers here OR vercel.json. Pick one source.
    return [];
  },
};
```

## CSP

Use a per-request nonce (App Router middleware injects nonce; components read via `next/headers`). Baseline:

```
default-src 'self';
script-src 'self' 'nonce-${NONCE}' 'strict-dynamic';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
connect-src 'self' https://vitals.vercel-insights.com;
object-src 'none';
base-uri 'self';
frame-ancestors 'none';
```

`'unsafe-inline'` for styles is hard to remove without breaking many libs; `'nonce-...' 'strict-dynamic'` for scripts is the right path.

## Common security mistakes

- `NEXT_PUBLIC_*` containing secrets — ships to the browser. Never put server-only credentials there.
- Server Actions without input validation.
- Cron handlers without `x-vercel-signature` verification → public mutation endpoints.
- Wildcard `images.remotePatterns` → arbitrary upstream image fetch (SSRF-ish).

## References

- https://nextjs.org/docs/app/building-your-application/configuring/content-security-policy
- https://vercel.com/docs/frameworks/nextjs
- https://nextjs.org/docs/app/api-reference/functions/headers
