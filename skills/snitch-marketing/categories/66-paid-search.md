## CATEGORY 66: Paid search (Google Ads / Bing Ads)

Is the brand running paid search, what keywords, what landing pages, what's working / breaking? Even sites that don't run paid search benefit from this audit, competitor ad copy reveals which value props are converting on the same queries the site is trying to rank organically.

### Pre-flight: brand maturity check

Before running this category, confirm STEP 0.6 (Brand Maturity Check) classified paid-search presence as `minimal` or `established`. If presence is `none` (Google Ads Transparency Center returned no historical ads for this brand), **Skip this category** with reason `no paid-search history detected; recommendation pending in Strategic Recommendations (STEP 5)`. Do not run the Evidence Required steps below, they would all return empty and waste tokens.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Search the brand name + 3-5 commercial keywords from the site's value-prop in Google. Capture the SERP: are there ads from this brand? Quote the ad headlines + display URLs.
2. Search 3-5 of the same commercial keywords. Capture the top 3 advertisers (competitors). Quote their ad copy.
3. For brand-owned ads: fetch the destination URL. Check it's a dedicated landing page (not the homepage), has clear CTA, matches the ad's promise.
4. Check the brand's `robots.txt` for `/ads/`, `/lp/`, `/landing/` paths, common landing page directory patterns.

**Source mode, required tool calls:**

1. `Glob` for `lp/`, `landing/`, `ads/`, `paid/` directories under routes. Quote file paths.
2. `Grep` for tracking patterns: `gclid`, `gbraid`, `wbraid`, `msclkid`, Google Ads conversion pixels (`AW-XXXXXXX`), Bing UET tag (`UET-XXXXX`).
3. `Read` landing page route components for: form / CTA presence, headline alignment with likely ad copy, social proof, trust signals.

### Forbidden claims

- "The brand probably runs ads." Search the brand + check SERP. Quote what you see.
- "Competitor X is probably outspending." Without ad-spend data (requires Semrush / SpyFu API access), don't claim spend volumes, only claim presence + copy quality.
- "Landing pages probably don't convert." Audit the page; quote CTA, form, trust signals. Don't infer conversion rate.

### Detection

#### Source mode

- Routes named `/lp/`, `/landing/`, `/ads/`, `/promo/`, `/get/`
- Conversion-tracking pixels in source: `gtag('config', 'AW-XXXXX')`, `gtag('event', 'conversion', { ... })`
- UTM-parameter parsing in route loaders (signal that paid traffic is expected)

#### Crawl mode

- SERP results for the brand + commercial keywords
- The brand's published ads in Google Ads Transparency Center (https://adstransparency.google.com)
- Bing Ads competitive intelligence (limited public access)

### Actually Hurts the Marketing Surface

- **Paid traffic lands on the homepage instead of a dedicated landing page**.
  Evidence required: ad URL + the destination URL = homepage URL.
- **Landing page doesn't match the ad's promise**.
  Evidence required: ad headline + landing page H1 / hero. Mismatch is the finding.
- **No conversion tracking on landing pages** (can't measure paid spend efficiency).
  Evidence required: landing page source + missing GA4 / GAds / pixel.
- **Competitor running ads on the brand's own brand name** (defensive bid missing).
  Evidence required: SERP screenshot + competitor's ad on brand-name search.
- **Brand has no paid presence on commercial queries** that competitors dominate.
  Evidence required: SERP for top 3 commercial keywords with no brand ad + competitor ads present.
- **Landing page is mobile-broken** (touch targets, CLS, slow load).
  Evidence required: cross-reference Cat 28 / Cat 46 / Cat 49 on landing page URLs.

### NOT a Problem

- A site that explicitly doesn't run paid search (founder-led, organic-only strategy). Note the strategy; skip the paid-side findings.
- Landing page = homepage on a single-product site where the homepage IS the landing page. Acceptable.
- Competitor ads on broad keywords (commodity industry; expected).

### Context Check

1. Does the brand have budget for paid? If pre-revenue / bootstrapped, paid recommendations should be deprioritized.
2. What's the average customer value? Paid search needs CAC < LTV; low-LTV products often can't afford CPCs.
3. Is the audience search-driven (high intent at SERP) or discovery-driven (better fit for paid social)?
4. Is the competitive landscape ad-saturated? Some niches are pay-to-play.
5. Are there branded vs non-branded keyword opportunities? Branded ads are usually high-ROI defensive plays.

### Reference

Google Ads Transparency Center: https://adstransparency.google.com

Google Ads conversion tracking: https://support.google.com/google-ads/answer/1722022

`references/ads-detection-matrix.md`, per-platform what's-checkable methodology spine

Cat 107 (Pixel install completeness), pixel-layer detail for the Google Ads pixel

Cat 108 (UTM hygiene), UTM convention audit applies to every paid-search campaign

Cat 109 (Message match audit), promotes message match to its own audit pass; this category covers channel-level paid-search posture, Cat 109 covers per-ad LP scoring

**Severity tagging:**
- Brand running paid traffic with no conversion tracking → Critical.
- Paid traffic landing on homepage instead of dedicated LP → High.
- Ad / LP message mismatch → High.
- No defensive brand-name bid when competitors run on brand → Medium.
- No paid presence on top commercial queries (when budget exists) → Medium.

**Fix voice:** `analytics-engineer` (primary) | `sahil-lavingia` (backup, when the fix is "spend less on paid, build organic / product-led instead").

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Paid traffic without measurement is just spending money. Wire the conversion tracking before you ship the next ad.
>
> ```ts
> // Landing page: fire conversion when form submits
> async function onFormSubmit(data) {
>   await fetch('/api/lead', { method: 'POST', body: JSON.stringify(data) });
>   gtag('event', 'conversion', {
>     send_to: 'AW-XXXXXXX/XXXXXXXXX',
>     value: 49.99,
>     currency: 'USD',
>   });
> }
> ```
>
> Then a dedicated landing page per ad group (not the homepage). Headline mirrors the ad's headline word-for-word; the rest of the page proves the promise. Three weeks of data tells you which ad groups convert and which to kill.
