# Ads Detection Matrix

Most ad campaigns live behind a login (Google Ads Manager, Meta Ads Manager, LinkedIn Campaign Manager). The audit cannot read into those surfaces directly. What the audit CAN read is a mix of public ad libraries, the SERP itself, the brand's own source code, and the runtime HTML/network behavior on the brand's site.

This matrix formalizes per-platform what's checkable, what's inferrable, and what's invisible — so every ads-related finding traces back to a clear evidence source, and every "we can't tell" is honest.

## How to read the matrix

Four columns per platform:

| Column | Meaning |
|---|---|
| **Publicly visible** | Surfaces a third party (or the audit) can fetch without authenticating: ad libraries, SERPs, transparency dashboards |
| **Source-checkable** | What's readable from the brand's own source code or rendered HTML: pixels, conversion code, UTM handling, landing pages |
| **Inferrable** | Conclusions drawn from cross-referencing the visible + source signals (e.g., "pixel installed AND ads in transparency = active paid program") |
| **Invisible** | What's structurally not visible to the audit: spend amounts, ROAS, audience definitions, internal A/B tests |

A finding's evidence MUST come from "Publicly visible" or "Source-checkable" columns. "Inferrable" findings must cite both inputs that produced the inference. "Invisible" items are flagged as out-of-scope; the audit recommends the customer pull those numbers from the platform itself.

## Per-platform matrix

### Google Ads (search)

| Column | Specifics |
|---|---|
| Publicly visible | Google Ads Transparency Center (`https://adstransparency.google.com`) — historical and current ads by advertiser; SERP for the brand name + commercial keywords |
| Source-checkable | `gtag('config', 'AW-XXXXXXX')` conversion-tracking pixel; `gtag('event', 'conversion', { send_to: ... })`; Floodlight tags; landing page directories (`/lp/`, `/landing/`, `/ads/`); UTM-parsing logic in route loaders; `gclid` / `gbraid` / `wbraid` parameter handling |
| Inferrable | "Active paid search program" = ads in Transparency Center + AW pixel installed + dedicated landing pages exist; "Defensive bid missing" = competitor ad on brand-name SERP + no brand ad in Transparency Center for the brand-name query |
| Invisible | Per-keyword spend, CPC, quality score, conversion rate, ROAS, audience targeting, ad-group structure |

### Bing / Microsoft Ads

| Column | Specifics |
|---|---|
| Publicly visible | Limited public ad library; Bing SERP for brand and competitors |
| Source-checkable | Microsoft UET tag (`UET-XXXXX`); `mscklid` parameter handling; landing pages; Microsoft Ads conversion goals in source |
| Inferrable | Same shape as Google Ads but with weaker public ad-library signal |
| Invisible | Spend, CPC, conversion rate, ROAS, audience targeting |

### Meta (Facebook + Instagram)

| Column | Specifics |
|---|---|
| Publicly visible | Meta Ad Library (`https://www.facebook.com/ads/library/`) — currently active and recently active ads, with creative + landing page URL; ad spend disclosed on EU traffic per DSA |
| Source-checkable | `fbq('init', 'PIXEL_ID')` + `fbq('track', 'EventName')`; backend Meta CAPI POSTs to `graph.facebook.com/v.../events`; `_fbp` / `_fbc` cookie handling; `fbclid` parameter handling |
| Inferrable | "Active paid social program" = ads in Ad Library + Pixel installed + CAPI installed; "Pixel firing pre-consent" = network-tab observation of pixel call BEFORE consent banner accept |
| Invisible | Spend (outside EU), audience custom-list definitions, conversion windows, attribution model used internally, lookalike-audience seed data |

### LinkedIn Ads

| Column | Specifics |
|---|---|
| Publicly visible | LinkedIn Ad Library — public in EU under DSA; partial elsewhere; LinkedIn Sales Navigator may surface targeting hints (out of scope) |
| Source-checkable | LinkedIn Insight Tag (`_linkedin_partner_id`, `_bizo_data_partner_id`); LinkedIn conversion events via `lintrk('track', { conversion_id: ... })`; backend Conversions API POSTs |
| Inferrable | Same shape as Meta but with thinner public ad library outside EU |
| Invisible | Spend (outside EU), account-list targeting, audience definitions, ROAS |

### TikTok Ads

| Column | Specifics |
|---|---|
| Publicly visible | TikTok Creative Center (`https://ads.tiktok.com/business/creativecenter/`) — partial ad inspiration / library; aggregate trend data |
| Source-checkable | TikTok Pixel (`tiktokPixel.init('PIXEL_ID')`); `ttq.load(...)` initialization; backend Events API POSTs to `business-api.tiktok.com`; `ttclid` parameter handling |
| Inferrable | Standard active-program shape |
| Invisible | Spend, CPM, conversion rates, audience targeting |

### X (Twitter) Ads

| Column | Specifics |
|---|---|
| Publicly visible | Minimal public ad library; X Ads transparency limited |
| Source-checkable | X Pixel (`twq('init', 'PIXEL_ID')`, `twq('track', '...')`); backend X conversion events |
| Inferrable | Active paid program inferred only from pixel + landing page evidence; SERP visibility limited |
| Invisible | Almost everything operational |

### Reddit Ads

| Column | Specifics |
|---|---|
| Publicly visible | Minimal public ad library |
| Source-checkable | Reddit Pixel (`rdt('init', 'PIXEL_ID')`, `rdt('track', '...')`); backend Reddit Conversions API |
| Inferrable | Active paid program inferred from pixel + landing page evidence |
| Invisible | Spend, subreddit targeting, audience |

### Pinterest Ads

| Column | Specifics |
|---|---|
| Publicly visible | Pinterest Ad Library partial |
| Source-checkable | Pinterest Tag (`pintrk('load', 'TAG_ID')`, `pintrk('track', '...')`); backend Pinterest Conversions API |
| Inferrable | Active paid program inferred from pixel + landing pages |
| Invisible | Spend, board-level targeting, audience |

### YouTube Ads

| Column | Specifics |
|---|---|
| Publicly visible | Google Ads Transparency Center (covers YouTube ads with creative URLs) — TrueView, in-stream, bumpers, masthead |
| Source-checkable | Same Google Ads conversion-tracking surface as search; `_gcl_aw` cookie; YouTube embed analytics; Google Ads remarketing tag |
| Inferrable | YouTube ads in Transparency + GAds pixel installed = active video advertising program |
| Invisible | Per-creative view rate, click-through rate, view-through conversion |

### Display / programmatic / native (GDN, Taboola, Outbrain, Nativo)

| Column | Specifics |
|---|---|
| Publicly visible | Google Ads Transparency Center for GDN; very limited for Taboola / Outbrain / Nativo (visible only by spotting ads on real publisher pages); `https://adstransparency.google.com` includes display creatives |
| Source-checkable | Google Ads remarketing tag; Floodlight; Taboola pixel (`_tfa`); Outbrain pixel (`obApi`); native landing-page parameters; image asset specs (display ads have specific size requirements: 728x90, 300x250, 320x50, 970x250 — landing page hero should align visually) |
| Inferrable | "Display program active" = Transparency-visible display creatives + remarketing tag installed + landing pages with display-specific UTMs |
| Invisible | Network-by-network spend, placement-level performance, viewability rates |

## Cross-platform: what we CAN do without paid third-party tools

The audit, working with no paid tools, can:

1. **Inventory installed pixels** across all platforms (Source-checkable)
2. **Verify conversion tracking** is present where pixels claim to fire (Source-checkable)
3. **Walk visible ad creatives** from public ad libraries to their landing pages and audit the message match (Cat 109)
4. **Verify CAPI / Conversions API** backends exist alongside browser pixels (Source-checkable, requires backend code access)
5. **Detect pre-consent pixel fires** by sampling network tab (Crawl mode runtime check)
6. **Detect UTM hygiene problems** in source code and runtime navigation (Cat 53)
7. **Detect missing defensive brand-name bid** by SERP-searching the brand and seeing competitor ads above no brand ad (Publicly visible)
8. **Detect message mismatches** between visible ads and their landing pages (Cat 109)

## Cross-platform: what requires paid third-party tools

If the customer has Semrush, Ahrefs, Pathmatics, SpyFu, or similar API access, the audit can additionally surface:

- Estimated competitor ad spend (per-keyword, per-placement)
- Historical ad copy archives (older than the public Transparency Center's window)
- Estimated competitor traffic per channel
- Domain authority + backlink data informing organic-vs-paid recommendations

Without those tools, the audit is honest about its limits: it reports "active program present / absent" rather than spend volumes; it reports "competitor ad detected" rather than "competitor outspending you."

## Cross-platform: invisible without platform login

The audit cannot, without authenticated access to the brand's own platform accounts:

- Per-keyword / per-creative / per-audience performance
- Custom audience definitions (uploaded customer lists, lookalikes, retargeting segments)
- Frequency caps + budget pacing
- Internal A/B test results
- Quality score / relevance score / health metrics
- Account-level fraud / invalid traffic exposure

For these, the audit recommends pulling the data from the platform itself and including it as input for STEP 4 Strategic Recommendations.

## Practical methodology — 4 phases, every ads cat

This is the canonical pattern every ads-related cat (66, 109, and Cat 53's UTM pass) follows:

1. **Brand-maturity gate (STEP 0.6)**. If no presence on the channel, Skip and route to "start here" recommendation in STEP 4.
2. **Public-visibility scan**. Fetch the relevant ad library / Transparency Center / SERP. Quote what's visible (or quote the absence + the search performed).
3. **Source-side scan**. Read pixel installations, conversion code, UTM handling, landing pages from the brand's own source. Quote evidence with file:line.
4. **Cross-reference**. Match what's visible publicly with what's installed on-site. Findings live in the gap between them: ads visible but no pixel; pixel installed but no ads; ads going to homepage instead of landing page; landing page that doesn't match the ad.

The methodology is the same; the platform-specific knowledge is the matrix above.

## Cross-references

- Cat 66 (Paid channel presence) — its search side uses this matrix's Google + Bing rows, its social side the Meta + LinkedIn + TikTok + X + Reddit + Pinterest rows
- Cat 53 (Analytics instrumentation) — its UTM pass applies to every platform's UTM-handling
- Cat 109 (Message match audit) — the cross-reference step in phase 4 above
