# 02 — Pixel foundations

Read when adding a first pixel, troubleshooting "pixel doesn't fire," or auditing why all 10 platforms register zero events.

## What a pixel is

A small JS snippet (sometimes paired with a 1×1 GIF beacon) the ad platform asks the publisher to embed in `<head>`. On every page load it:

1. Initializes the platform's global function (`gtag`, `fbq`, `uetq`, `_linkedin_partner_id`, `ttq`, `twq`, `pintrk`, `rdt`, `snaptr`).
2. Loads a small JS library from the platform's CDN.
3. Records a page-view tied to the platform's identifier (cookies, fingerprints, gclid/fbclid).
4. Listens for `track` calls fired on user actions (`AddToCart`, `Purchase`, `Lead`).

Pixels work on first-party visits and post-click attribution from ads.

## Init order

Canonical order in `<head>`:

```
1. Consent Mode v2 default (denied)
2. CMP / consent banner script (OneTrust, Cookiebot, etc.)
3. dataLayer = window.dataLayer || [];
4. Tag manager bootstrap (gtag.js or GTM container)
5. Per-platform pixels (fbq init, ttq init, ...)
6. Page-specific tracking
```

If a pixel loads before the consent default, the platform may record the page-view as consented — GDPR / CCPA risk and platform disablement (Google EEA + UK enforcement is strict).

## dataLayer pattern

`dataLayer` is a global array on `window` that ad-platform tag managers read:

```js
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  event: "purchase",
  ecommerce: { value: 49.99, currency: "USD", transaction_id: "TX-1234" }
});
```

Google (gtag/GTM) and Adobe Launch read this. Other platforms have their own track-call shapes — fire each platform's track call from the same click handler that pushes to dataLayer.

## Pixel + CAPI deduplication

The same conversion fires client-side (pixel) and server-side (CAPI) so the platform recovers from ad-blockers, ITP, ETP. Both events ship with a shared dedup ID:

| Platform | Pixel call | CAPI call | Dedup field |
|---|---|---|---|
| Google Ads | `gtag('event','conversion',{transaction_id})` | Enhanced Conversions / Offline Adjustments | `transaction_id` + `gclid` |
| GA4 | `gtag('event', name, {transaction_id})` | Measurement Protocol | `transaction_id` |
| Meta | `fbq('track','Purchase',{...},{eventID:'evt-123'})` | `event_id: 'evt-123'` | `event_id` |
| TikTok | `ttq.track('CompletePayment',{...},{event_id:'evt-123'})` | `event_id` | `event_id` |
| Pinterest | `pintrk('track','checkout',{event_id})` | `event_id` | `event_id` |
| LinkedIn | `lintrk('track',{conversion_id})` | `eventId` | `eventId` |
| Snap | `snaptr('track','PURCHASE',{client_dedup_id})` | `event_id` | `event_id` ↔ `client_dedup_id` |
| Reddit | `rdt('track','Purchase',{conversionId})` | `conversion_id` | `conversion_id` |
| X | `twq('event','tw-xxx',{conversion_id})` | `event_id` | `event_id` |
| Apple Search Ads | n/a (SKAdNetwork postbacks) | postback verification | conversion-value bits |

If reporting shows 2× expected, dedup is broken — usually a different `event_id` between client and server.

## Common failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Pixel "no fires" in dashboard | snippet in `<body>` not `<head>`; CSP blocks platform domain | move to `<head>`; check console for `Refused to load`; update CSP per `templates/security-headers-for-ads.template.txt` |
| Inflated conversions | client + server both fire without dedup ID | populate `event_id` in both with the same value (UUID per order works) |
| Works in dev, broken in prod | consent default = denied, CMP not loaded in prod | check CMP script tag URL; ensure `gtag('consent','update', ...)` runs after grant |
| Mobile conversions missing | iOS ITP / SKAdNetwork; no CAPI | add CAPI per platform; for iOS, configure SKAdNetwork postback URL |
