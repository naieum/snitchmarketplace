# Vite SPA — ads-tracking best practices

## Honest verdict

Pure Vite SPAs (React + Vite, Vue + Vite without SSR) are a **weak** ads-readiness stack. Reasons:

1. **LCP hidden behind hydration.** Bots and CrUX measure shell paint; conversion-relevant content paints later.
2. **AI search + Schema.org crippled.** Without SSR, JSON-LD and meta tags don't reach LLM crawlers without prerendering.
3. **Page-view events need explicit router wiring.** No native page-load lifecycle.

If ad spend is significant, recommend an SSR migration (Astro for content-heavy, Next/Nuxt for app-heavy) BEFORE refining tracking.

If migration is off the table, here's the best you can do.

## Pixel install

`index.html` `<head>` — same as vanilla HTML. Pixels load with the static shell.

```html
<!doctype html>
<html>
<head>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
  </script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXX"></script>
  <script>
    window.gtag = window.gtag || function(){dataLayer.push(arguments)};
    gtag('js', new Date());
    gtag('config', 'G-XXX', { send_page_view: false });
  </script>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.tsx"></script>
</body>
</html>
```

## SPA route changes — fire page-view manually

React Router:

```tsx
// src/components/RouteTracker.tsx
import { useEffect } from "react";
import { useLocation } from "react-router-dom";

export function RouteTracker() {
  const location = useLocation();
  useEffect(() => {
    window.gtag?.("event", "page_view", {
      page_path: location.pathname + location.search,
      page_location: window.location.href,
      page_title: document.title
    });
  }, [location]);
  return null;
}
```

Mount `<RouteTracker />` once at the root.

Vue Router:

```ts
import { useRouter } from "vue-router";
useRouter().afterEach((to) => {
  window.gtag?.("event", "page_view", { page_path: to.fullPath });
});
```

## Server-side CAPI

A pure SPA has no server. Host CAPI elsewhere: Cloudflare Worker, Vercel / Netlify Edge Functions, or a small Node server. CORS configured on the CAPI origin.

## SSG / prerendering as a halfway house

If you can prerender at least the marketing routes (via `vite-plugin-ssr`, `vite-plugin-prerender-spa`, or moving them to Astro), you'll fix LCP + Schema.org without a full migration.

## CWV expectations

- LCP under 2.5s on mobile is hard for unprerendered SPAs. Aim for sub-3.0s and accept YELLOW.
- INP can be controlled by code-splitting + virtualizing long lists.
- CLS is solvable: reserve space for hero images and fonts.

## Verification

`bash ads-ready.sh state lighthouse <url>` — expect Performance 60-80 unprerendered, 90+ with SSG. `state site <url> structured-data` — expect EMPTY unless prerendered.
