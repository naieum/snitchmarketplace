# Vue (plain SPA, not Nuxt) — ads-tracking best practices

## Honest verdict

Plain Vue 3 SPA without Nuxt has the same caveats as Vite SPA (see `vite-spa.md`):

- LCP and CLS hidden behind hydration.
- Schema.org / meta tags don't reach LLM crawlers without prerendering.
- Conversion-relevant routes don't fire page-view events without explicit router wiring.

**If ad spend is meaningful, migrate to Nuxt.** Conversion gain typically pays back the migration within a quarter. The fit-matrix tags this as `partial`.

## If you can't migrate

Pixels live in `index.html` `<head>` (same as Vite SPA). Wire Vue Router to fire page-view per route:

```ts
// main.ts
import { createApp } from "vue";
import { createRouter, createWebHistory } from "vue-router";
import App from "./App.vue";
import { routes } from "./routes";

const router = createRouter({ history: createWebHistory(), routes });

router.afterEach((to) => {
  if (typeof window.gtag === "function") {
    window.gtag("event", "page_view", {
      page_path: to.fullPath,
      page_title: document.title,
      page_location: window.location.href
    });
  }
  if (typeof fbq === "function") fbq("track", "PageView");
  if (typeof ttq === "object") ttq.page();
});

createApp(App).use(router).mount("#app");
```

## Per-component event firing

`onMounted` for view events:

```vue
<script setup>
import { onMounted } from "vue";

onMounted(() => {
  fbq?.("track", "ViewContent", { content_ids: [props.sku], content_type: "product" });
  ttq?.track("ViewContent", { content_id: props.sku });
});
</script>
```

For purchase events: fire from success page's `onMounted` AND server-side CAPI bridge (deduplicated by `event_id`).

## Server-side CAPI

Plain Vue SPA has no server. Same options as Vite SPA: Cloudflare Worker, Vercel/Netlify edge function, or external Node server.

## Migration to Nuxt

Vue 3 → Nuxt is mechanical. Most components transfer; you gain SSR (LCP fixes), file-system routing, Nitro server-routes, built-in head management, module ecosystem.

## Verification

`bash ads-ready.sh state site <url>` — expect partial signal detection unless prerendered. Recommend Nuxt migration in audit Next steps.
