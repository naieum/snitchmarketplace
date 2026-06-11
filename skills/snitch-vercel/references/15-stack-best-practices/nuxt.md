# Nuxt on Vercel — best practices

Nuxt's Nitro engine has first-class Vercel presets: `vercel`, `vercel-edge`, `vercel-static`.

## Configuration

```ts
// nuxt.config.ts
export default defineNuxtConfig({
  nitro: {
    preset: 'vercel',
    routeRules: {
      '/admin/**': { ssr: false },
      '/api/**':   { cors: true, headers: { 'Cache-Control': 'no-store' } },
      '/':         { isr: 60 * 60 },
    },
  },
});
```

## Edge vs Node

`preset: 'vercel-edge'` runs every route on edge — smaller stdlib, lower latency. Verify Nitro modules are edge-compatible (most are; native Node modules aren't).

## H3 (server) middleware

```ts
// server/middleware/headers.ts
export default defineEventHandler((event) => {
  setHeaders(event, {
    'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload',
    'X-Frame-Options': 'DENY',
  });
});
```

## Auth

`nuxt-auth-utils` or roll your own. Cookies: `httpOnly`, `secure`, `sameSite`. Server-only routes for credential exchange.

## Server $fetch

`$fetch` server-side has no built-in CSRF; for client-initiated mutations, validate origin in `defineEventHandler`.

## Common mistakes

- `runtimeConfig.public.*` ships to the browser — same secret-leak risk as `NEXT_PUBLIC_*`.
- Missing `cors: true` on public APIs causes cross-origin failures.
- Nitro plugins importing Node modules in edge preset → build failure.

## References

- https://vercel.com/docs/frameworks/nuxt
- https://nuxt.com/docs/getting-started/deployment
- https://nitro.unjs.io/deploy/providers/vercel
