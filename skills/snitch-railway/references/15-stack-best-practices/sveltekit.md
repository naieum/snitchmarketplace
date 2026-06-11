# SvelteKit on Railway

Use `@sveltejs/adapter-node`. SvelteKit's edge adapter is Cloudflare-specific; on Railway use Node.

## svelte.config.js

```js
import adapter from '@sveltejs/adapter-node';
export default {
  kit: { adapter: adapter({ out: 'build' }) }
};
```

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "node build",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

`hooks.server.ts`:

```ts
export const handle = async ({ event, resolve }) => {
  const response = await resolve(event);
  response.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  return response;
};
```

- Form actions are POST-heavy — rate-limit at middleware or framework level.
- Bind `HOST=0.0.0.0`.

## Docs

- https://kit.svelte.dev/docs/adapter-node
- https://docs.railway.com/guides/sveltekit
