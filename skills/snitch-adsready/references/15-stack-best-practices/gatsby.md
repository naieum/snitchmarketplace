# Gatsby — ads-tracking best practices

## Status

Gatsby is in maintenance mode after Netlify acquisition + Gatsby Cloud sunset. New projects: pick Astro / Next / Remix instead. This guide covers existing Gatsby sites.

## Pixel install

`gatsby-ssr.js` `onRenderBody`:

```js
exports.onRenderBody = ({ setHeadComponents }) => {
  setHeadComponents([
    <script
      key="consent-default"
      dangerouslySetInnerHTML={{
        __html: `window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});`
      }}
    />,
    <script key="ga4-loader" async src="https://www.googletagmanager.com/gtag/js?id=G-XXX" />,
    <script
      key="ga4-init"
      dangerouslySetInnerHTML={{ __html: `window.gtag=window.gtag||function(){dataLayer.push(arguments)};gtag('js', new Date());gtag('config','G-XXX');` }}
    />
  ]);
};
```

## Plugins (community-maintained — verify currency)

- **gatsby-plugin-google-tagmanager** — GTM container.
- **gatsby-plugin-google-gtag** — GA4 + Google Ads.
- **gatsby-plugin-facebook-pixel** — Meta.
- **gatsby-plugin-tiktok-pixel** — TikTok.
- **gatsby-plugin-segment-js** — Segment.

Many plugins have stagnated. The manual `gatsby-ssr.js` pattern is more reliable.

## Server-side CAPI

Gatsby is static-only. CAPI lives elsewhere — Cloudflare Worker, Netlify Functions, Vercel Functions.

`gatsby-plugin-functions` enables Express-style functions in `src/api/`:

```js
// src/api/capi/meta.js
import { sendMetaCapiEvent } from "../../lib/meta-capi";

export default async function handler(req, res) {
  await sendMetaCapiEvent({ ... });
  res.status(200).json({ ok: true });
}
```

## CWV

Static output gives strong CWV. Watch for:
- Heavy GraphQL data fetches → large client bundles. Use `useStaticQuery` selectively.
- `gatsby-plugin-image` with right `formats` (webp, avif).
- Don't ship the entire CMS data tree to the client.

## Migration paths

| To | Effort | Why |
|---|---|---|
| **Astro** | medium — template syntax differs but data layer survives | Best for content-heavy; static-first; great CWV |
| **Next.js** | medium-high — must rewrite GraphQL queries | Best for app-heavy with growing dynamic surface |
| **Remix** | medium — similar React patterns | Best when SSR + edge preferred |

## Verification

`bash ads-ready.sh state site <url>`, `state lighthouse <url>` — Gatsby static is typically 90+ Performance.
