# Astro — ads-tracking best practices

## Pixel install

`src/layouts/Layout.astro` `<head>`. Static-first, so pixels load with the static HTML — no hydration delay.

```astro
---
const gaId = import.meta.env.PUBLIC_GA_ID;
---
<html>
<head>
  <script is:inline>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
  </script>
  <script is:inline async src={`https://www.googletagmanager.com/gtag/js?id=${gaId}`}></script>
  <script is:inline define:vars={{ gaId }}>
    window.gtag = window.gtag || function(){dataLayer.push(arguments)};
    gtag('js', new Date());
    gtag('config', gaId);
  </script>
</head>
<body><slot /></body>
</html>
```

`is:inline` keeps Astro from processing (otherwise it bundles + converts to module). Required for inline pixel snippets.

## Off-main-thread pixels with Partytown

```bash
npm install @astrojs/partytown
```

```js
// astro.config.mjs
import partytown from "@astrojs/partytown";

export default defineConfig({
  integrations: [partytown({
    config: { forward: ["dataLayer.push", "fbq", "ttq.track", "_linkedin_partner_id"] }
  })]
});
```

Add `type="text/partytown"` to pixel `<script>` tags. Moves them to a Web Worker so they don't block main-thread INP.

Trade-off: pixels relying on synchronous DOM reads don't work in a worker. Test platform helper extensions after enabling.

## Server-side CAPI

If `output: "server"` (SSR) with Cloudflare / Vercel / Node adapter, create `src/pages/api/capi/[platform].ts`:

```ts
import type { APIRoute } from "astro";
import { sendMetaCapiEvent } from "../../../lib/meta-capi";

export const POST: APIRoute = async ({ request }) => {
  const body = await request.json();
  await sendMetaCapiEvent({ ... });
  return new Response(JSON.stringify({ ok: true }), { status: 200 });
};
```

For static (`output: "static"`), host CAPI as separate Cloudflare Worker / Vercel function / Lambda.

## CWV

Static-first output gives near-perfect LCP / CLS by default. Watch for:
- View Transitions API — verify pixels still fire on virtual nav.
- Image components: `<Image>` with `width`/`height`; pick AVIF/WebP via `format`.
- Don't import heavy JS client-side without `client:idle` / `client:visible`.

## CSP

Per-request nonces in middleware (Astro 4+). CSP headers via integration or hosting layer (Pages `_headers`, Vercel `vercel.json`).

## Verification

`bash ads-ready.sh state site <url> pixels`, `state lighthouse <url>` — typically 95+ Performance.
