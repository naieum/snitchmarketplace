# SvelteKit — ads-tracking best practices

## Pixel install

`src/app.html` `<head>`. SvelteKit injects layout content via `%sveltekit.head%` and `%sveltekit.body%`.

```html
<!doctype html>
<html lang="%sveltekit.lang%">
<head>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
  </script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=%env.PUBLIC_GA_ID%"></script>
  <script>
    window.gtag = window.gtag || function(){dataLayer.push(arguments)};
    gtag('js', new Date());
    gtag('config', '%env.PUBLIC_GA_ID%');
  </script>
  %sveltekit.head%
</head>
<body>
  <div style="display: contents">%sveltekit.body%</div>
</body>
</html>
```

For per-route page-view fire on `afterNavigate`, use `+layout.svelte`:

```svelte
<script>
  import { afterNavigate } from "$app/navigation";
  afterNavigate(({ to }) => {
    if (typeof window.gtag === "function" && to) {
      window.gtag("config", import.meta.env.PUBLIC_GA_ID, { page_path: to.url.pathname });
    }
  });
</script>

<slot />
```

## Server-side CAPI

`src/routes/api/capi/[platform]/+server.ts`:

```ts
import { json } from "@sveltejs/kit";
import { sendMetaCapiEvent } from "$lib/meta-capi";

export async function POST({ request }) {
  const body = await request.json();
  await sendMetaCapiEvent({ ... });
  return json({ ok: true });
}
```

The Cloudflare adapter targets Workers — same edge-runtime caveat: use Web Crypto, not `node:crypto`.

## CWV

- `+page.server.ts` `load` runs server-side; prefer for data fetching.
- Form actions are POST-heavy — rate-limit at the edge when public.

## CSP

`hooks.server.ts` for headers + per-request nonce:

```ts
import type { Handle } from "@sveltejs/kit";

export const handle: Handle = async ({ event, resolve }) => {
  const nonce = crypto.randomUUID();
  return await resolve(event, {
    transformPageChunk: ({ html }) => html.replace(/{{NONCE}}/g, nonce),
    filterSerializedResponseHeaders: () => true
  });
};
```

Reference `{{NONCE}}` in inline scripts and CSP `script-src 'self' 'nonce-{{NONCE}}'`.

## Verification

`bash ads-ready.sh state site <url> pixels`, `state crux <url> mobile`.
