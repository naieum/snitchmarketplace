# Category Group Mappings

The primary recommendation mechanism is component-based detection (STEP 0.8 + `references/component-cat-map.md`). The named presets in this file (Groups 2-15) are CURATED SHORTCUTS for customers who already know their shape and want a one-tap audit without the per-component reasoning step. They are alternatives, not the default path.

When the user picks "B2B SaaS preset" or "E-commerce preset", the audit uses these curated cat lists directly. When the user picks "run the recommended scan" or doesn't name a preset, the audit uses the component-driven recommendation in STEP 1.5 (which may produce a similar list, but is justified per detected component, not per claimed business model).

The full 134-category catalog is enumerated at the bottom of this file.

## Token cost heuristic

Per-category cost in source mode is roughly **1.5K tokens** (range ~800-2500 depending on detection complexity + evidence quoted + report-finding length). Per-category cost in crawl mode adds ~2-4K tokens per fetched URL. Each scan also has ~5K tokens of overhead (mode detection, STEP 0.5 discovery, STEP 0.6 maturity check, STEP 0.7 niche research, STEP 1.5 recommendation, STEP 1.7 confirm).

Project-size multiplier:
- **Small** (<50 routes): low end of per-cat range
- **Medium** (50-200 routes): mid-range
- **Large** (>200 routes, e.g., programmatic SEO surfaces): high end

Use these heuristics to compute the per-preset token estimate displayed in the scan menu (SKILL.md scan-selection block) and in the STEP 1.7 confirmation prompt.

## Group 2: Technical SEO

Categories: 1, 2, 3, 4, 5, 6, 9, 10, 13, 39, 40, 42, 45, 121, 130

**Token cost: ~22-34K tokens (small/medium site).** 15 cats × ~1.5K + ~5K overhead.

The crawl + indexing surface plus the load-bearing technical bits a search engine cares about most: robots, sitemap, canonical, noindex, soft 404s, redirects, title/meta, favicon, font loading, render-blocking, third-party scripts, viewport, information architecture, IndexNow submission.

## Group 3: Content & Structure

Categories: 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 57, 58, 86, 121, 122, 128, 131, 132

**Token cost: ~26-39K tokens.** 18 cats × ~1.5K + ~5K overhead.

Single H1 + heading hierarchy, semantic HTML, content depth, internal link graph, broken links, anchor quality, breadcrumbs, footer spam, external link rels, topical depth, keyword/intent match, keyword research + intent mapping, information architecture, comparison / alternatives pages, citation gaps, SERP-intent alignment, SERP-overlap clustering. The content cats also draw on the deterministic content-intelligence metrics (Flesch-Kincaid readability, cross-page near-duplicate via Jaccard, keyword cannibalization) in `references/content-intelligence.md` to back judgment calls with quotable figures.

## Group 4: Schema & Structured Data

Categories: 31, 32, 33, 34, 35, 36, 37, 38

**Token cost: ~12-20K tokens.** 8 cats × ~1.5K + ~5K overhead. Many cats Skip via pre-flight when the page-type doesn't apply (e.g., Article schema skipped on a SaaS without `/blog/`).

All schema.org JSON-LD categories. Run on a per-page-type basis (only check Article schema on blog posts, only Product on PDPs, etc.).

## Group 5: Conversion & Trust

Categories: 25, 26, 27, 28, 29, 30, 47, 48, 49, 53, 54, 55, 56, 60, 107, 108, 117, 120, 122, 123

**Token cost: ~31-49K tokens.** 20 cats × ~1.5K + ~5K overhead. Cats 53-56 (analytics) cost less when no analytics is installed (fast Skip). Cat 120 (Meta ads structure) auto-skips when no Meta Pixel detected.

Image quality + a11y as conversion signals + analytics setup + pixel install completeness + UTM hygiene + CTAs / forms / trust signals / 404 pages + site copy lint (vague adjectives, unsupported superlatives, dark-pattern urgency, hidden price, weak social proof) + comparison / alternatives pages + lead-magnet acquisition assets + Meta ads account structure health (campaign topology, learning-phase respect, hook-variation depth).

## Group 6: International

Categories: 50, 51, 52, 133

**Token cost: ~6-10K tokens.** 4 cats. Skips quickly on single-locale sites.

Hreflang correctness, locale canonicals, html lang attribute, machine-translation quality drift. Small group; only useful when site has multiple locales.

## Group 7: Email & Transactional

Categories: 61, 62, 63, 64, 65

**Token cost: ~10-18K tokens.** 5 cats × ~1.5K + ~5K overhead.

The full email audit surface: inventory (what gets sent + when), content (copy / merge tags / stale references), deliverability (SPF / DKIM / DMARC), design + accessibility (cross-client rendering, dark mode, alt text), compliance (unsubscribe, physical address, CAN-SPAM / GDPR / Gmail-Yahoo bulk-sender requirements).

Skip in pure crawl mode (server-side sends aren't visible). Source mode required.

## Group 8: Off-site & Channels

Categories: 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 109, 118, 119

**Token cost: ~33-55K tokens at full presence.** ~12-22K when STEP 0.6 brand-maturity gates most cats to Skip (typical for new brands). 19 cats × ~1.5K + crawl-mode SERP fetches add ~2-4K each. Cats 118 and 119 auto-skip on non-local brands per their pre-flight checks.

Off-site marketing surfaces + channel/strategy: paid search, paid social, organic social, backlinks, content marketing, lifecycle email, community, CRO signals, customer feedback / reviews, brand consistency, partnerships, PR/launches, affiliate, local SEO, product-led growth, market positioning.

Most of this preset depends on the brand-maturity check (STEP 0.6) — categories with `none` presence on their channel auto-Skip. The synthesis (STEP 4.5) turns those Skips into "start here" recommendations.

## Group 9: 2026 Modern Marketing

Categories: 82, 83, 84, 85, 106, 134

**Token cost: ~11-20K tokens.** 6 cats × ~1.5K + ~5K overhead. Cat 82 (AI-search citation) adds 2-4K for ChatGPT / Claude / Perplexity test queries.

The 2026-and-forward channel set. Different from Group 8 because these reflect what's actually working post-AI-overview, post-creator-economy: AI-search citation (the new TOFU), mid-tier creator partnerships (replacing macro-influencer), founder-led brand channel (replacing brand-account posting for early/indie brands), niche newsletter + podcast sponsorships (replacing display ads), llms.txt, and agent operability (can an AI agent complete the primary action).

The GEO surface here is backed by several cross-cutting references: `references/citability-scoring.md` (passage citability + answer-length fitness), `references/ai-crawler-registry.md` (the full AI-crawler fleet), `references/brand-authority-platforms.md` (off-site authority sweep), and `references/schema-deprecations.md` (so the schema cats don't recommend dead rich results). When Cat 82 / 102 / 106 are in scope, the report can render an optional GEO readiness score (`references/geo-score.md`) — a transparent deduction rollup, not a vanity number.

## Group 10: Full Audit

All 134 categories.

**Token cost: ~185-260K tokens.** 134 cats × ~1.5K + ~10K full-discovery overhead. Crawl-mode adds 2-4K per fetched URL on top.

**REQUIRE explicit user confirmation** before launching. The 5-step pre-flight (STEP 0/0.5/0.6/0.7) typically runs as part of the budget. Suggest STEP 1.7's "skip N,N" affordance to cut cats that obviously don't apply (e.g., Cat 87 Recipe schema on a SaaS).

## Group 11: B2B SaaS preset

Categories: 9, 10, 11, 12, 31, 37, 60, 73, 74, 75, 81, 91, 96, 99, 102, 110, 111, 112, 114, 115, 116, 121, 122, 123, 124

**Token cost: ~38-53K tokens.** 25 cats × ~1.5K + ~5K overhead.

The B2B SaaS audit surface: title/meta + Open Graph for share-worthy content; Organization + WebSite + SoftwareApplication schema; conversion + trust signals; CRO measurement; customer feedback / case studies; brand consistency; positioning; brand SERP defense; conversion funnel deep-audit; multi-LLM citation differentiation; buying-committee / stakeholder coverage (does the surface equip the user, the economic buyer, the champion, and the security/procurement skeptic, not just one persona). Skip channels (Group 8) unless brand maturity is `established` per STEP 0.6.

The preset reflects what a top-1% B2B SaaS team checks before each major launch: does the marketing surface match the positioning, does the funnel convert, does AI search cite us, can a buyer answer "is this credible" in <30 seconds.

## Group 12: E-commerce preset

Categories: 7, 9, 10, 11, 12, 22, 25, 27, 28, 29, 31, 33, 34, 73, 74, 87, 91, 94, 99, 101, 121, 122, 129, 134

**Token cost: ~37-62K tokens.** 24 cats × ~1.5K + ~5K overhead. Image-heavy cats (25, 27, 28, 29) cost more on PDP-heavy stores.

The e-commerce audit surface: pagination + faceted-nav/parameter indexation control; title/meta + Open Graph; image quality + dimensions + format; breadcrumbs + BreadcrumbList schema; Product / Recipe / Software / Review schema; CRO; customer feedback; conversion funnel deep-audit; information architecture; comparison / alternatives pages; AI-image provenance; AI-agent commerce signals; agent operability.

**Faceted navigation / URL-parameter indexation is covered by Cat 7** (pagination, which carries the filter+sort canonical logic). Without it, a store with thousands of indexable `?color=`/`?size=`/`?sort=` URLs passes clean while bleeding crawl budget and creating duplicate-content competition — Cat 7 is the only cat that audits canonical handling of those faceted/parameter URLs, so it belongs in every e-commerce run.

Run with the brand-maturity check (STEP 0.6) gating off-site channels. Add Group 4 (Schema) for full per-product structured-data depth.

## Group 13: Local business preset

Categories: 1, 2, 3, 9, 10, 22, 23, 25, 31, 33, 37, 49, 50, 53, 60, 75, 79, 92, 96, 118, 119, 127

**Token cost: ~34-57K tokens.** 22 cats × ~1.5K + ~5K overhead. Cat 79 (GBP) + Cat 96 (brand SERP) + Cat 118 (GBP depth) require crawl-mode SERP / Maps fetches; add 2-4K each.

The local business audit: crawl + indexing fundamentals; on-site LocalBusiness schema (Cat 92) AND off-site GBP audit (Cat 79); NAP consistency; brand consistency; brand SERP defense; GBP depth + hyper-local landing pages (Cats 118, 119); GBP feature-deprecation exposure (Cat 127); analytics; international (if multi-locale); accessibility (often legally required for public-sector / healthcare local businesses).

NAP integrity is the load-bearing concern. Cross-reference Cat 79 GBP listing against Cat 92 on-site schema against the visible footer NAP — drift across these surfaces costs local rank.

## Group 14: Publisher / media preset

Categories: 2, 3, 9, 10, 16, 17, 18, 22, 30, 32, 33, 38, 42, 43, 53, 56, 57, 59, 70, 82, 93, 97, 125, 128, 132

**Token cost: ~39-67K tokens.** 25 cats × ~1.5K + ~5K overhead. Content-volume cats (18 thin content, 57 topical depth, 97 content decay) cost more on high-volume sites.

The publisher audit: sitemap + canonical (high stakes for content sites); single H1 + heading hierarchy (navigation map); semantic HTML; thin content; breadcrumbs; video sitemap; Article + BreadcrumbList + VideoObject schema; third-party scripts (ad-tech weight); image weight; analytics; consent mode; topical depth + AI content tells; content strategy; AI-search citation; Person/Author schema for E-E-A-T; content decay & refresh; site-reputation-abuse risk; citation gaps; SERP-overlap clustering + cannibalization.

Publishers with high content velocity also benefit from Group 9 (2026 Modern Marketing) for the AI-search + creator + founder-led layers.

## Group 15: Accessibility deep-dive preset

Categories: 17, 25, 26, 28, 45, 46, 47, 48, 49, 52, 103, 104, 105, 113

**Token cost: ~22-38K tokens.** 14 cats × ~1.5K + ~5K overhead. Cats 103-105 (deep WCAG / keyboard / screen reader) cost more on interactive-heavy sites.

The full a11y audit: semantic HTML; image alt presence + quality; CLS / explicit dimensions; viewport; touch targets; readable text; ARIA labels; color contrast; lang attribute; WCAG 2.2 AA conformance; keyboard navigation + focus management; screen reader semantics; color-blind safe design (redundant-channel audit, distinct from contrast).

Run when the brand has legal accessibility obligations (public-sector, healthcare, education, EAA-covered EU commerce, ADA exposure) OR the brand markets accessibility as a value.

## Quick Audit (menu Option 1)

Quick Audit always includes: 1 (robots.txt), 2 (sitemap.xml), 3 (canonical), 4 (indexability), 9 (title tag), 10 (meta description), 11 (Open Graph), 15 (single H1), 25 (image alt presence), 31 (JSON-LD presence).

Then adds 2-3 more based on stack detection (`references/smart-detection.md`):

- Next.js / TanStack Start / Astro / Remix detected: add 16 (heading hierarchy), 39 (font loading), 44 (JS bundle weight)
- WordPress detected: add 32 (Article schema), 53 (GA4), 22 (breadcrumbs)
- Shopify / Webflow / Wix detected: add 34 (Product schema if PDP), 32 (Article schema if blog), 60 (conversion/CTA)
- E-commerce signal (`/cart`, `/checkout`, `/products` routes): force-add 34 (Product schema)

## Full 134-category catalog (locked numbering)

### Crawl & indexing (1-8)
1. Robots.txt
2. Sitemap.xml
3. Canonical URL
4. Indexability (noindex / nofollow / nosnippet)
5. Soft 404 detection
6. Redirect chains
7. Pagination (rel=prev/next)
8. Meta refresh anti-pattern

### Title & meta (9-14)
9. Title tag (presence + length)
10. Meta description (presence + length)
11. Open Graph tags
12. Twitter Card tags
13. Favicon set (favicon.ico + apple-touch-icon + manifest icons)
14. Web app manifest

### Heading & content structure (15-18)
15. Single H1 per page
16. Heading hierarchy (no skipped levels)
17. Semantic HTML (article / section / nav / aside / main)
18. Thin content (word count + content depth)

### Links & navigation (19-24)
19. Internal link graph (orphan pages)
20. Broken internal links
21. Anchor text quality
22. Breadcrumb markup
23. Footer link spam
24. External link rel attributes (nofollow / sponsored / ugc)

### Images & media (25-30)
25. Image alt presence
26. Image alt quality
27. Image format (webp / avif)
28. Explicit width / height (CLS prevention)
29. Lazy-load directives
30. Video sitemap presence

### Schema.org / structured data (31-38)
31. JSON-LD presence
32. Article schema
33. BreadcrumbList schema
34. Product schema
35. FAQ schema
36. HowTo schema
37. Organization / WebSite schema
38. VideoObject schema

### Performance signals (39-44)
39. Font loading strategy (font-display)
40. Render-blocking CSS / JS
41. Critical-path CSS
42. Third-party script audit
43. Image weight
44. JS bundle weight per route

### Mobile & a11y as SEO (45-49)
45. Viewport meta
46. Touch target size
47. Readable text without zoom
48. ARIA labels on interactive elements
49. Color contrast on text

### International (50-52)
50. Hreflang correctness
51. Locale-specific canonicals
52. Lang attribute on html element

### Analytics & tracking (53-56)
53. GA4 install
54. GTM hygiene
55. Event taxonomy
56. Consent-mode setup

### Content quality / judgment (57-60)
57. Topical depth & content gaps
58. Keyword targeting / intent match
59. AI-content tells (over-hedged language, generic transitions, made-up stats)
60. Conversion & trust (CTAs, form friction + a11y/autofill, decision-moment trust signals, 404 recovery + soft-404 status)

### Email & Transactional (61-65)
61. Transactional email inventory (what gets sent, when, by whom, from where)
62. Email content quality (copy, voice, merge tags, stale references)
63. Email deliverability (SPF, DKIM, DMARC DNS records)
64. Email design + accessibility (cross-client rendering, dark mode, alt text)
65. Email compliance (unsubscribe, physical address, CAN-SPAM / GDPR / bulk-sender headers)

### Off-site & Channels (66-81)
66. Paid search (Google / Bing Ads)
67. Paid social (Meta / LinkedIn / X / TikTok / Reddit)
68. Organic social presence (X / LinkedIn / Instagram / YouTube / TikTok)
69. Backlink profile + link-building (now also AI-citation signal)
70. Content marketing strategy (distribution-first, AI-extraction-aware)
71. Lifecycle / drip / newsletter marketing
72. Community building (Discord / Slack / subreddit / forum)
73. CRO signals (experimentation rigor, A/B test infra, heatmaps/VoC, funnel analytics, anti-flicker & consent integrity)
74. Customer feedback & social proof (reviews, testimonials, NPS, case studies)
75. Brand consistency across channels
76. Partnerships, integrations, co-marketing
77. PR, launches, press surface (HN / PH / creator-led launch sequence)
78. Affiliate / referral programs
79. Local SEO + Google Business Profile (local biz only)
80. Product-led growth signals (free tier, viral loops, in-product invites)
81. Market positioning (differentiation, value-prop, audience clarity)

### 2026 Modern Marketing (82-85)
82. AI-search citation optimization (ChatGPT / Perplexity / Claude / Gemini citations)
83. Creator partnerships (mid-tier niche creators)
84. Founder-led brand channel (founder as primary distribution)
85. Newsletter & podcast sponsorships (niche-vertical earned-media)

### Strategy primitives (86)
86. Keyword research + intent mapping (capture demand, classify intent, cluster by SERP overlap, prioritize by leverage)

### Schema.org coverage extension (87-94)
87. Recipe schema
88. Course schema
89. Event schema
90. JobPosting schema
91. SoftwareApplication schema
92. LocalBusiness schema (on-site markup; pairs with Cat 79 off-site GBP)
93. Person / Author schema (E-E-A-T trust signal)
94. Review / AggregateRating schema (rating-honesty audit across surfaces)

### Methodology depth (95-99)
95. Programmatic SEO audit
96. Brand-SERP defense
97. Content decay & refresh audit
98. Internal site search audit
99. Conversion funnel deep-audit (journey trace + two-tier evidence: structure/instrumentation detectable vs drop-off analytics-gated; new/returning, mobile, cross-device, attribution, B2B dark funnel)

### Future-aware / 2027+ (100-102)
100. Cookieless analytics readiness (server-side, CAPI, consent mode v2)
101. AI-agent commerce signals (agent-readable product surfaces)
102. Multi-LLM citation differentiation (per-LLM citation rate auditing)

### Accessibility deep-dive (103-105)
103. WCAG 2.2 AA conformance audit
104. Keyboard navigation + focus management
105. Screen reader semantics audit

### AI-crawler standards (106)
106. llms.txt (AI-crawler-friendly site description; standalone audit, cross-referenced from Cat 82)

### Ads measurement methodology (107-109)
107. Pixel install completeness (cross-platform pixel inventory + CAPI pairing + consent gating)
108. UTM hygiene + parameter consistency (convention, casing, redirect preservation, internal-nav stripping)
109. Landing-page-to-ad message match audit (per-ad scorecard across search/social/display/YouTube)

### Strategic synthesis (110-112)
110. ICP wedge scoring (score 3-6 candidate segments on Pain / Reach / Switching cost / WTP fit)
111. Trust artifact audit (founder face, named testimonials, changelog, honest privacy, "not for", status page)
112. Pricing strategic read (annual / lifetime / team / discount strategy synthesis)

### Accessibility (113)
113. Color-blind safe design (WCAG 1.4.1; redundant-channel audit, distinct from Cat 49 contrast)

### Persuasion psychology (114-116)
114. Persuasion architecture (7-section holistic audit, 0-175 score: First Impression, Trust, Motivation, Friction, Emotional Resonance, Decision Support, Follow-Through; + ethics/dark-pattern overlay & model validity-tiering)
115. Pricing psychology tactical (charm vs rounded, decoy effect, anchoring order, mental accounting frames, Rule of 100, strike-through provenance)
116. Retention psychology (activation energy, endowment, peak-end design, switching costs, exit / cancellation flow, streak ethics)

### Copy quality (117)
117. Site copy lint (vague adjectives, unsupported superlatives, dark-pattern urgency, hidden price, weak social proof, buzzword density)

### Local services depth (118-119)
118. Google Business Profile depth audit (fill-every-field discipline: 300-char service descriptions, Products section, photo geo-data, weekly Post cadence, 25%-out-do competitor rule)
119. Hyper-local landing page completeness (named landmarks, neighborhood-tagged photos, embedded map, LocalBusiness schema with coordinates, city-specific testimonials, hub-and-spoke linking)

### Paid ads account structure (120)
120. Meta ads account structure health (one CBO per goal, ad-set count + age, creative refresh cadence, hook-variation depth, 40/40/20 audience-offer-creative attribution, learning-phase respect)

### Acquisition & structure (121-123)
121. Information architecture & site structure (click-depth to money pages, hub-and-spoke clustering, faceted-nav crawl traps, URL taxonomy, nav breadth)
122. Comparison / alternatives / "vs" page strategy (decision-stage capture, honest comparison tables, conversion path, comparison/Product schema)
123. Lead-magnet / free-tool acquisition assets (on-ramp presence, value exchange, capture hygiene, nurture tie-in, ICP relevance)

### B2B buying committee (124)
124. Buying-committee / stakeholder coverage (does the marketing surface equip the user, economic buyer, champion, and security/procurement skeptic, not just one persona; B2B / sales-led / considered-purchase only)

### Risk & policy exposure (125-127)
125. Parasite SEO / site-reputation-abuse risk (own-site sections that match Google's site-reputation-abuse pattern)
126. Domain heritage / expired-domain abuse risk (registration age + topical drift; pre-acquisition due diligence)
127. Google Business Profile feature-deprecation audit (reliance on retired GBP features; local only)

### Content trust, media & indexing (128-130)
128. Citation-gap audit (verifiable claims with no nearby source; E-E-A-T + AI-citability trust gate)
129. AI-image provenance & licensing metadata (IPTC/XMP DigitalSourceType + creator/credit/license)
130. IndexNow / indexing-submission readiness (Bing / Yandex / Seznam / Naver; Google not supported)

### Search-fit, clustering & localization (131-133)
131. SXO, page-type / SERP-intent alignment (is the page even the type of result the SERP rewards)
132. SERP-overlap topic clustering + cannibalization (cluster by shared SERP, catch self-competition)
133. Machine-translation quality drift (localized content quality, distinct from hreflang syntax)

### Agent-era operability (134)
134. Agent operability (accessibility-tree / machine-actionability; can an AI agent complete the primary action)
