# Nuxt — ads-tracking best practices

## Pixel install

`useHead()` in `app.vue` or top-level layout, OR `nuxt.config.ts` `app.head.script[]`.

```ts
// nuxt.config.ts
export default defineNuxtConfig({
  app: {
    head: {
      script: [
        { children: `window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});`, type: "text/javascript" },
        { src: `https://www.googletagmanager.com/gtag/js?id=G-XXX`, async: true },
        { children: `window.gtag=window.gtag||function(){dataLayer.push(arguments)};gtag('js',new Date());gtag('config','G-XXX');`, type: "text/javascript" }
      ]
    }
  }
});
```

Per-page customization via `useHead()` in components.

## Modules

- `nuxt-gtag` — Google Tag with consent integration.
- `@nuxtjs/partytown` — off-main-thread pixel loader.
- `nuxt-meta-pixel` — Meta Pixel community module.

## Server-side CAPI (Nitro)

`server/api/`:

```ts
// server/api/capi/meta.post.ts
import { sendMetaCapiEvent } from "~/server/utils/meta-capi";

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  await sendMetaCapiEvent({ ... });
  return { ok: true };
});
```

Nitro presets target every major host. Edge presets can't use `node:crypto` — use Web Crypto.

## CWV

- `<NuxtImg>` with `loading="eager"` + `fetchpriority="high"` on LCP image.
- `experimental.payloadExtraction: true` to ship smaller initial payloads.
- Avoid heavy client-only Vue components above the fold.

## CSP

`nuxt-security` module or set headers at host layer (Pages `_headers`, Vercel headers).

## Verification

`state site`, `state crux`, `score`.
