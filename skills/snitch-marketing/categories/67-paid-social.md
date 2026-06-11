## CATEGORY 67: Paid social (Meta / LinkedIn / X / TikTok / Reddit Ads)

Paid social is discovery-driven, users aren't searching, they're scrolling. Different mechanic than paid search. Audit covers: is the brand running, on which platforms, with what creative, to what landing surface, with what tracking.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified paid-social presence as `minimal` or `established`. If `none` (Meta Ad Library, LinkedIn Ad Library, TikTok Creative Center all returned no ads from this brand), **Skip** with reason `no paid-social history detected; recommendation pending in STEP 5`. Don't run Evidence Required.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Check public ad libraries:
   - Meta Ad Library: `https://www.facebook.com/ads/library/?search_type=keyword_unordered&q=<brand-name>`
   - LinkedIn Ad Library: `https://www.linkedin.com/ad-library/`
   - TikTok Creative Center: `https://ads.tiktok.com/business/creativecenter/inspiration/topads`
   - Twitter/X Ads Transparency Center (public)
2. Capture: which platforms have active ads, screenshot creative shapes, copy, CTAs.
   - **Tooling caveat:** the ad libraries above are JS-rendered/region-gated — a plain `Fetch` may return a shell or gated page. Use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste/screenshot the library results, else **Skip-with-reason**; do not assert ads you can't see (Rule 1). See `references/ads-detection-matrix.md` for the per-platform checkable spine.
3. For tracked traffic to the brand site: search the site's source for Meta Pixel (`fbq(`), LinkedIn Insight Tag (`_linkedin_partner_id`), TikTok Pixel (`ttq.load`), X Pixel.

**Source mode, required tool calls:**

1. `Grep` for paid-social pixels: `fbq(`, `_linkedin_partner_id`, `ttq.load`, `twq(`, `pinit_pixel`, `redditpixel`. Quote each.
2. For each pixel: confirm consent-gating (cross-reference Cat 56). Pixels firing pre-consent in EU = compliance violation.

### Forbidden claims

- "The brand probably advertises on Meta." Check Meta Ad Library; quote what's there.
- "Tracking pixels probably misconfigured." Source-grep + show.

### Detection

Public ad libraries + source-side pixel detection.

### What to Search For

- `fbq(` (Meta Pixel)
- `_linkedin_partner_id` (LinkedIn Insight Tag)
- `ttq.load` (TikTok Pixel)
- `twq(` (X / Twitter Pixel)
- `pinit_pixel` (Pinterest)
- `redditpixel` (Reddit Pixel)

### Actually Hurts the Marketing Surface

- **Pixel installed but never fires conversion events** (just pageviews).
  Evidence required: pixel install + grep for conversion-event calls (`fbq('track', 'Lead')`, `Purchase`, etc.) returning empty.
- **Ads running with no pixel installed on landing pages** (no conversion tracking).
  Evidence required: ad library shows active ads + landing page source missing pixel.
- **Pixel fires before consent in EU traffic**.
  Evidence required: pixel in source not gated by consent state.
- **Creative messaging conflicts with site messaging**.
  Evidence required: ad copy + site H1 / value prop showing mismatch.
- **Brand on platforms with mismatched audience** (B2B SaaS running TikTok ads to a developer audience that lives on X / GitHub).
  Evidence required: business model + platform fit assessment.

### NOT a Problem

- No paid social by choice (founder-led, content-driven). Note strategy.
- Pixel installed for retargeting only (pageview tracking, no conversion events) IF retargeting is the strategy. Acceptable.

### Context Check

1. Is the audience on the platforms being advertised on?
2. Is the creative format right for the platform? (Static image on TikTok = ineffective; vertical video on LinkedIn = uncommon.)
3. Is consent-mode wired correctly for EU users?
4. Is the conversion event pre-defined or generic? (Custom events let you optimize for the action that matters.)
5. Are the landing pages mobile-optimized? Most paid social traffic is mobile.

### Reference

Meta Ad Library: https://www.facebook.com/ads/library/

LinkedIn Insight Tag: https://www.linkedin.com/help/lms/answer/a427660

TikTok Pixel docs: https://ads.tiktok.com/help/article/get-started-pixel

`references/ads-detection-matrix.md`, per-platform what's-checkable methodology spine (Meta, LinkedIn, TikTok, X, Reddit, Pinterest rows)

Cat 107 (Pixel install completeness), pixel-layer detail across all paid-social platforms

Cat 108 (UTM hygiene), UTM convention audit applies to every paid-social campaign

Cat 109 (Message match audit), per-ad LP scoring across paid-social creatives

**Severity tagging:**
- Pixel firing pre-consent in EU → Critical (compliance).
- Ads running without conversion tracking → High.
- Platform / audience mismatch → Medium.
- Creative / site message mismatch → Medium.

**Fix voice:** `analytics-engineer` (primary) | `tobias-van-schneider` (backup, when fix is creative / brand-shaped).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Install the pixel once globally with consent-gating. Then fire conversion events from the action handlers, not from page loads.
>
> ```tsx
> // Global, consent-gated
> useEffect(() => {
>   if (!consentGranted.marketing) return;
>   fbq('init', 'YOUR_PIXEL_ID');
>   fbq('track', 'PageView');
> }, [consentGranted.marketing]);
>
> // Conversion events from action handlers
> async function onSignup() {
>   if (consentGranted.marketing) {
>     fbq('track', 'CompleteRegistration');
>   }
> }
> ```
>
> Track events meaningful to the business: Lead, Subscribe, Purchase, AddToCart. The pixel optimizes ad delivery against the events you fire; vague pageview-only tracking can't optimize for what matters.
