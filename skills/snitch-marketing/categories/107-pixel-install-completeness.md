## CATEGORY 107: Pixel install completeness

A consolidated audit of every ad-platform pixel installed on the brand's site, where each is fired, whether each is consent-gated, and whether each has a matching server-side / Conversions API backend pair. Today this surface is touched in pieces across Cat 67 (paid social), Cat 100 (cookieless analytics), and Cat 56 (consent mode). Cat 107 produces ONE clean inventory the brand can act on.

This category does not assume the brand IS running paid, it audits the pixel layer as installed, and the recommendation in STEP 4.5 is what to add when paid expands.

### Pre-flight: relevance check

Run on every site that has any analytics or ad infrastructure. Skip with reason `not applicable` only on a static brand site with zero JS-loaded analytics or marketing tags (extremely rare in 2026).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for each ad-platform pixel signature (web-only platforms, per `references/ads-detection-matrix.md`):
   - **Google Ads**: `gtag\\('config',\\s*['"]AW-`, `gtag\\('event',\\s*'conversion'`
   - **Bing / Microsoft**: `UET-`, `window\\.uetq`
   - **Meta (Facebook + Instagram)**: `fbq\\(`, `_fbq`, `fbevents.js`
   - **LinkedIn**: `_linkedin_partner_id`, `_bizo_data_partner_id`, `lintrk\\(`
   - **TikTok**: `tiktokPixel`, `ttq\\.`, `ttq\\.load`, `ttq\\.track`
   - **X (Twitter)**: `twq\\(`, `static\\.ads-twitter\\.com`
   - **Reddit**: `rdt\\(`, `redditstatic\\.com/ads`
   - **Pinterest**: `pintrk\\(`, `s\\.pinimg\\.com/ct`
2. Quote each pixel's location (file:line), the pixel ID (redacted to `XXXX...` per Rule 5), and the events fired.
3. For each installed pixel, look for a matching Conversions API / server-side counterpart in the backend code (per `ads-detection-matrix.md`). Quote the backend POST endpoint or note its absence.
4. Cross-reference Cat 56 (consent mode), does the pixel fire pre-consent or wait for consent state?

**Crawl mode, required tool calls:**

1. `Fetch` the homepage and 2-3 representative pages.
2. Inspect rendered HTML for inline pixel code AND `<script src=...>` references to ad-platform CDNs.
3. If browser-runtime inspection is available, sample the network tab on initial page load: list every request to `connect.facebook.net`, `googleadservices.com`, `analytics.tiktok.com`, `px.ads.linkedin.com`, etc., quote which fire BEFORE consent vs AFTER.
4. For each detected pixel, check whether the site has installed a corresponding consent-mode v2 declaration (`gtag('consent', 'default', ...)` matching the platforms).

### Forbidden claims

- "Meta Pixel may be missing." Run the grep / fetch; quote presence or absence with location.
- "Pixel may fire pre-consent." Sample the network tab or read the consent-gating logic; quote.
- "CAPI may not be implemented." Check the backend code; quote the POST or its absence.

### Detection

Looking for ad-platform pixels installed in source / rendered HTML, paired (or unpaired) with their server-side Conversions API equivalents.

### What to Search For

- Pixel initialization calls (`fbq('init', ...)`, `gtag('config', 'AW-...')`, etc.)
- Pixel CDN script tags (`<script src="https://connect.facebook.net/...">` etc.)
- Backend POST endpoints to ad-platform Conversions APIs
- Consent-mode declarations: `gtag('consent', 'default', ...)` and `gtag('consent', 'update', ...)`
- Pixel-firing gates: `if (consent.granted)` or equivalent
- Tag manager containers that load pixels indirectly (`<script src="https://www.googletagmanager.com/gtm.js?id=GTM-...`)

### Actually Hurts the Marketing Surface

- **Pixel installed but no Conversions API backend pair** (browser pixel only, Safari + Firefox + iOS will block 30-50% of these events).
  Evidence required: pixel install file:line + missing backend POST.
- **Pixel installed but unused** (the pixel loads on every page, fires no events; pure overhead with no measurement value).
  Evidence required: pixel init present + missing `track` / `event` calls.
- **Pixel fires before consent banner** (regulatory risk + measurement gap on EU traffic).
  Evidence required: network-tab observation of pixel call before consent acceptance OR source code without consent-gating logic.
- **Pixel ID hardcoded in client-side bundle** (when env-var pattern would be safer, especially across staging/prod).
  Evidence required: hardcoded ID in source vs env-var pattern visible elsewhere in the codebase.
- **Pixel loaded via a tag manager but the tag manager has no consent integration** (consent banner exists; tag manager fires pixels regardless).
  Evidence required: GTM container present + consent state not wired to firing rules.
- **Multiple installs of the same pixel** (a refactor left two `fbq('init')` calls; events double-fire; metrics inflate).
  Evidence required: 2+ init calls for the same platform.
- **Conversions API installed but no event_id deduplication** (browser pixel + CAPI both fire; without `event_id` matching, conversions double-count).
  Evidence required: CAPI backend code without `event_id` field; matching pixel fire without `eventID`.
- **Pixel installed for a platform the brand has never run ads on** (often legacy from a prior agency engagement; pure third-party-script weight cost, Cat 42 cross-ref).
  Evidence required: pixel install + no ad activity in that platform's transparency surface.

### NOT a Problem

- A pixel installed AND firing AND consent-gated AND CAPI-paired AND event_id-deduplicated, correct.
- A site with no ad pixels because the brand explicitly avoids paid acquisition, flag in audit metadata, not as a finding.
- A pixel installed for one platform without CAPI when the platform doesn't offer one (rare in 2026; most major platforms do).
- GA4 alone without ad pixels, that's analytics, not advertising; Cat 53 covers GA4.

### Context Check

1. Which platforms is the brand actually running paid on (per Cat 66, 67, public ad libraries)? The pixel inventory should match, pixels for live programs, not for legacy ones.
2. Is consent mode v2 declared and propagating to pixel firing rules?
3. Are server-side / CAPI pairs present for every browser pixel that supports them?
4. Are pixel IDs redacted in any reports / logs that may be shared externally?
5. Is the GTM container (if used) consent-aware? Many teams install consent banners but never wire them into GTM.

### Reference

`references/ads-detection-matrix.md`, per-platform pixel signatures + CAPI endpoints

Cat 56 (Consent mode), consent-gating logic

Cat 67 (Paid social), channel-level audit; this cat is the pixel-layer detail

Cat 100 (Cookieless analytics readiness), server-side measurement layer

Cat 42 (Third-party scripts), bundle weight implications of unused pixels

Meta CAPI docs: https://developers.facebook.com/docs/marketing-api/conversions-api

Google Enhanced Conversions: https://support.google.com/google-ads/answer/9888656

LinkedIn Conversions API: https://learn.microsoft.com/en-us/linkedin/marketing/conversions-api

**Severity tagging:**

- Pixel installed but no Conversions API pair → High (under-attribution + over-spend risk on paid).
- Pixel fires before consent on EU traffic → Critical (regulatory + measurement).
- Multiple installs of the same pixel (event double-fire) → High.
- Pixel for a platform with no active ad program → Medium (script weight; Cat 42).
- CAPI without event_id deduplication → High (conversion double-count).
- Pixel ID hardcoded vs env-var pattern → Low.
- Pixel installed but unused (no events fired) → Medium.

**Fix voice:** `analytics-engineer` (primary) | `security-engineer` (backup, for the pre-consent firing angle).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> The pixel layer is the foundation of paid measurement. Get it wrong once and every paid program built on top inherits the error, under-attribution shrinks reported ROAS, double-counting inflates it. Build the foundation cleanly.
>
> The contract for every installed pixel:
>
> 1. **Browser pixel + Conversions API pair**, deduplicated by `event_id`. Browser pixels are blocked by Safari + Firefox + iOS at scale; CAPI fills the gap. Without dedup, both fire and conversions double-count.
> 2. **Consent-gated firing**. The pixel waits for consent state before firing on EU traffic. Consent mode v2 propagates the signal across all installed tags.
> 3. **Env-var pixel IDs**, never hardcoded. Different IDs for staging vs prod; one source of truth in environment config.
>
> ```ts
> // src/lib/pixels.ts, single point of pixel orchestration
> import { hasConsent } from "./consent";
>
> export function trackConversion(event: ConversionEvent) {
>   const eventId = generateEventId();
>
>   // browser pixel, only when consent allows
>   if (hasConsent("ad_storage")) {
>     fbq("track", event.name, event.data, { eventID: eventId });
>     gtag("event", "conversion", { send_to: process.env.GADS_AW_ID, ...event.data });
>   }
>
>   // CAPI, server-side, deduplicated against the browser fire
>   void fetch("/api/track-conversion", {
>     method: "POST",
>     body: JSON.stringify({ ...event, eventId }),
>   });
> }
> ```
>
> ```ts
> // backend POST handler, fires CAPI for every registered ad platform
> async function trackConversion(event, eventId) {
>   await metaCAPI.send({ event_id: eventId, ...event });
>   await googleEnhancedConversions.send({ ...event });
>   if (env.LINKEDIN_PARTNER_ID) await linkedInCAPI.send({ ...event });
>   // each platform's CAPI fires server-side; event_id matches the browser fire
> }
> ```
>
> Then audit the inventory: every pixel installed maps to an active platform program; every browser pixel has a CAPI pair; every fire is consent-gated; every event_id deduplicates. The pixel layer becomes a reliable foundation rather than a tangle of half-implementations.
