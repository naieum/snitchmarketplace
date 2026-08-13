# Shopify — ads-tracking best practices

## Native marketing app integrations

Shopify has first-party native marketing apps for the major platforms:

| Platform | Shopify app | Setup |
|---|---|---|
| Google | Google & YouTube channel | GA4, Google Ads, Merchant Center |
| Meta | Facebook & Instagram channel | Pixel + CAPI + Catalog auto-sync |
| TikTok | TikTok app | Pixel + Events API |
| Microsoft | Microsoft Channel | UET + offline conversions |
| Pinterest | Pinterest channel | Tag + Catalog |
| Snapchat | Snap App | Pixel + CAPI |

Use these BEFORE the manual snippet path. They handle pixel install, CAPI signing, and product-feed sync automatically.

## Web Pixel API (modern path)

Since 2023, Shopify enforces sandboxed Web Pixels — pixels run in a Web Worker / iframe and can't read DOM directly. Themes can no longer hand-edit `theme.liquid` for tracking.

Custom pixels: Settings → Customer Events → Add custom pixel. Customer privacy preferences (Shopify's CMP analog) gate when the pixel runs.

```js
analytics.subscribe("checkout_completed", (event) => {
  if (typeof fbq === "function") {
    fbq("track", "Purchase", {
      value: event.data.checkout.totalPrice.amount,
      currency: event.data.checkout.totalPrice.currencyCode,
      content_ids: event.data.checkout.lineItems.map(li => li.variant.sku),
      content_type: "product"
    }, { eventID: event.data.checkout.token });
  }
});
```

## Hydrogen (headless Shopify)

Hydrogen is React-based, builds on Remix. For Hydrogen sites:
- Pixel install in `app/root.tsx` head.
- CAPI in `app/routes/api.capi.$platform.tsx` actions.
- Customer privacy preferences from `useShopifyCookies()`.

## CWV

Standard Shopify themes (Dawn, Sense, Refresh) score 80-95 on Lighthouse. CWV failures usually trace to:

1. Heavy 3rd-party apps (review widgets, popups, complex back-in-stock).
2. High-resolution hero images without `loading="eager"` + `fetchpriority="high"`.
3. Dawn theme's font loading — preload primary weight.

Hydrogen scores higher (React + Remix + Vite).

## Server-side CAPI on Shopify

You don't need to roll your own — Shopify's Marketing apps include CAPI. For custom funnels (post-purchase upsells via custom checkout extension), use the standard CAPI templates on a separate origin (Cloudflare Workers, Vercel).

## ads.txt + structured data

Shopify hosts `ads.txt` natively — Settings → Domains → Manage ads.txt. Drop entries from `templates/ads-txt-entries.template.txt`.

Themes ship Product schema by default; use `theme.liquid` snippets to inject Organization + WebSite + BreadcrumbList. Verify with Rich Results Test.

## Verification

`bash ads-ready.sh state site <url>`. Shopify pixel diagnostics live at Settings → Customer Events → each pixel's status.
