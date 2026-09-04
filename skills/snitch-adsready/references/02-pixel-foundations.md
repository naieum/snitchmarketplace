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
1. dataLayer = window.dataLayer || []; define the gtag queue helper
2. Consent Mode v2 default (denied), before measurement config/events
3. CMP / consent banner script and its consent updates
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

The per-platform dedup-field table is in `03-conversion-tracking.md` — one copy, read it there.

If reporting shows 2× expected, dedup is broken — usually a different `event_id` between client and server.

## Pixel inventory audit

`state site <url> pixels` returns the installed set per platform; in source mode `detect`'s
`pixel_snippets[]` plus a grep for each platform's init call gives the same inventory with
`file:line`. Read the whole inventory once, then run these checks against it — never report
one platform in isolation.

| Check | Finding when | Evidence to quote |
|---|---|---|
| CAPI pair | an agreed or required server-side conversion path is demonstrably missing/broken; browser-only tracking alone is not a defect | requirement + effective event path and scoped absence evidence |
| Duplicate init | two `init` calls for the same platform | both `file:line`s |
| Loaded but silent | the library loads and no `track` / `event` call exists anywhere | init `file:line` + the empty grep for that platform's track call |
| Orphan pixel | a pixel for a platform with no active ad program | pixel `file:line` + the platform's own dashboard or transparency surface showing no activity |
| Hardcoded ID | the pixel ID is a literal in the client bundle while the codebase uses env vars elsewhere | the literal + a sibling env-var read |
| Consent gating | the pixel fires before the consent decision | the ordering, per `04-consent-and-cmp.md` |
| Dedup | client and server both fire with no shared id | the two call sites and the missing id field (`03-conversion-tracking.md` has the per-platform field) |

Redact pixel IDs to a trailing-digits form in anything the user may forward. The ID is not
secret, but a report that travels does not need it.

An orphan pixel is a Medium at most — it costs third-party script weight, not measurement.
Browser-only tracking can lose events under browser restrictions or blockers. CAPI is a
possible improvement when justified by measurement needs and cost, not a mandatory counterpart
or proof of a particular spend error. Inspect existing integrations before proposing one.

## Common failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Pixel "no fires" in dashboard | snippet in `<body>` not `<head>`; CSP blocks platform domain | move to `<head>`; check console for `Refused to load`; update CSP per `templates/security-headers-for-ads.template.txt` |
| Inflated conversions | client + server both fire without dedup ID | populate `event_id` in both with the same value (UUID per order works) |
| Works in dev, broken in prod | consent default = denied, CMP not loaded in prod | check CMP script tag URL; ensure `gtag('consent','update', ...)` runs after grant |
| Mobile conversions missing | iOS ITP / SKAdNetwork; no CAPI | add CAPI per platform; for iOS, configure SKAdNetwork postback URL |
