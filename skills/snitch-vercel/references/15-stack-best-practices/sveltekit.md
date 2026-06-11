# SvelteKit on Vercel — best practices

`@sveltejs/adapter-vercel` is canonical. Auto-detects Vercel features.

## Configuration

```js
// svelte.config.js
import adapter from '@sveltejs/adapter-vercel';

export default {
  kit: {
    adapter: adapter({
      runtime: 'nodejs20.x',                 // or 'edge'
      regions: ['iad1', 'fra1'],
      memory: 1024,
      maxDuration: 60,
      isr: {
        expiration: 60 * 60,
        bypassToken: process.env.ISR_BYPASS_TOKEN,
      },
    }),
  },
};
```

`bypassToken` is required to revalidate ISR pages from a server action — keep it Sensitive.

## Form actions

Form actions are POST endpoints. Always:
- Validate inputs (Zod, Valibot).
- Rate-limit at edge middleware (or via `+server.ts` hooks).
- CSRF — SvelteKit's `csrf.checkOrigin: true` is on by default.

## Hooks for auth + headers

```ts
// src/hooks.server.ts
import { type Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
  const response = await resolve(event);
  response.headers.set('Strict-Transport-Security', 'max-age=63072000; includeSubDomains; preload');
  response.headers.set('X-Frame-Options', 'DENY');
  return response;
};
```

## CSP

Built-in via `svelte.config.js`:

```js
kit: {
  csp: {
    mode: 'auto',
    directives: {
      'script-src': ['self', 'https://va.vercel-scripts.com'],
      'connect-src': ['self', 'https://vitals.vercel-insights.com'],
    },
  },
},
```

`mode: 'auto'` injects nonces for inline scripts.

## Common mistakes

- Database queries in `+page.svelte` (client) instead of `+page.server.ts` (server).
- `PUBLIC_*` (Vite-style) prefix for secrets — ships to the browser.
- Overriding `csrf.checkOrigin` without understanding the attack surface.

## References

- https://kit.svelte.dev/docs/adapter-vercel
- https://kit.svelte.dev/docs/configuration#csp
- https://kit.svelte.dev/docs/configuration#csrf
