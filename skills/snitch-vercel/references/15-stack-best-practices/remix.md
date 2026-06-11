# Remix on Vercel — best practices

Use `@vercel/remix` (or the Remix Vite + Vercel template for greenfield).

## Configuration

```js
// vite.config.ts
import { vitePlugin as remix } from "@remix-run/dev";
import { vercelPreset } from "@vercel/remix/vite";

export default defineConfig({
  plugins: [
    remix({ presets: [vercelPreset()] }),
  ],
});
```

Per-route options:

```ts
export const config = { runtime: 'edge' };
```

## Loaders + actions

- Loaders are GETs. Cache via `Cache-Control` in the loader's `Response`.
- Actions are mutations (POST/PUT/PATCH/DELETE). Validate, rate-limit, CSRF-check.
- Long-running side effects in actions (sending 1k emails) → enqueue, return immediately.

## Headers in Remix

Set in the route's `headers` export:

```ts
export const headers: HeadersFunction = () => ({
  'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload',
  'X-Frame-Options': 'DENY',
});
```

Or globally via `vercel.json` `headers`. Don't double-set; pick one.

## Sessions

`createCookieSessionStorage` with `httpOnly`, `secure`, `sameSite: 'lax'`. For larger sessions, switch to a KV-backed store.

## Common mistakes

- Long-running actions exceed `maxDuration`. Move to a queue.
- Untyped form data → validation gaps. Use Zod / Valibot.
- Cross-loader N+1 DB queries. Profile with `vercel logs`.

## References

- https://vercel.com/docs/frameworks/remix
- https://remix.run/docs/en/main/guides/templates
