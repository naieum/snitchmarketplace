# Category Manifest

The single source of truth for category identity and attributes. Every rule elsewhere that
depends on "which categories" resolves against this table — never against hardcoded number lists.

**Rules derived from Type.** The security skill's types classify code defects; SEO/marketing has no
equivalent axis, so these types classify **where the evidence lives and what a finding is allowed to
claim**. Twelve types, each carrying one obligation:

- `crawl-index` — can be Critical on its own (the page is being excluded from search); verify against the served response (status + headers + rendered HTML), never source alone.
- `on-page` — per-page markup; every finding quotes the current value at `file:line` or URL+selector.
- `schema` — page-type pre-flight is REQUIRED (Skip when the page type doesn't exist); impact ceiling comes from the rich-result table in `references/standards-table.md`; check `references/schema-deprecations.md` before recommending a rich result.
- `content` — editorial judgment, backed by the deterministic metrics in `references/content-intelligence.md` (readability, Jaccard near-duplicate, cannibalization) rather than adjectives.
- `performance` — Core Web Vitals *contributors*, not scores; a field claim requires CrUX/PSI per `references/field-cwv.md`, otherwise the finding is labeled static/lab.
- `accessibility` — cite the WCAG 2.2 success criterion the finding fails. Only the rows judged against search and machine readability are typed this way here: Cat 45 (viewport, and the zoom it blocks) and Cat 52 (`lang` as a machine-readability signal). The WCAG 2.2 AA conformance sweep itself — the criterion table, the pass sequence, the contrast evidence format and the legal-exposure read — lives in snitch-ada; call the Skill tool with "snitch-ada" for it. A barrier judged against one user finishing a task, rather than against the criterion, is handed to snitch-ux.
- `measurement` — instrumentation correctness only; never assert traffic, conversion, or revenue figures that would require access to the analytics account.
- `conversion` — hypothesis plus mechanism; never a predicted lift percentage.
- `email` — source mode required (server-side sends are invisible to a crawl); deliverability findings come from DNS lookups, not from the HTML.
- `off-site` — evidence lives outside the audited site; gated by the brand-maturity check (STEP 0.6) — `none` presence Skips, and STEP 4 turns that Skip into a "start here".
- `ai-search` — GEO surface; assistant test queries are sampled evidence, not a rank; score via `references/geo-score.md` and `references/citability-scoring.md` when in scope.
- `risk` — reports exposure against a named policy; state the policy and the observed pattern, never assert that a penalty has been applied.

Type is orthogonal to Groups. A group is what a customer buys in one tap; a type is how the finding
must be written. Cat 119 sits in the `channels` group but is typed `content`, because its evidence is
on-site.

**Groups** are the preset audit groups (`references/category-groups.md`, which owns the ID lists).
Slug → preset: `quick-core` = Quick Audit (menu Option 1), `technical-seo` = Group 2,
`content-structure` = Group 3, `structured-data` = Group 4, `conversion-trust` = Group 5,
`international` = Group 6, `email-transactional` = Group 7, `channels` = Group 8,
`modern-marketing` = Group 9, `b2b-saas` = Group 11, `ecommerce` = Group 12, `local` = Group 13,
`publisher` = Group 14. Group 10 (Full Audit) is every row, so it is not listed per-row.
Group 15 (accessibility deep-dive) is retired: the conformance sweep it existed for now lives in
snitch-ada, so no row carries an `a11y-deep` slug any more. Its heading stays in
`references/category-groups.md` as a handoff so old reports still read. `quick-core` categories are
always in a Quick Audit; smart detection adds 2-3 more per detected stack
(`references/smart-detection.md`). A `—` means the category is reached only by Full Audit, Custom
selection, or component-based detection (`references/component-cat-map.md`).

**Standards** is the external authority a finding cites when one exists. `—` means the category is a
judgment call with no governing spec; those findings carry the Impact tier from
`references/standards-table.md` and nothing more.

**Status.** Four values, and the ID is permanent under all four — a number is never reused,
reordered, or deleted:

- `active` — auditable. The file exists and the audit runs it.
- `merged→NN` — the category's checks now live in category `NN`. The row stays so the number
  stays reserved and old reports remain readable; the file is reduced to a short redirect stub,
  no scan selects the ID, and any cross-reference to it is rewritten to point at `NN`.
- `moved→snitch-<skill>` — the judge for these findings belongs to a sibling skill, so the checks
  live there now. The row stays reserved; marketing hands off by calling the Skill tool with
  `snitch-<skill>` rather than auditing it here.
- `deleted` — the checks were out of scope for this skill and no sibling took them, so they are
  gone. The row stays so the number stays reserved and old reports stay readable; the file is
  removed, no scan selects the ID, and no cross-reference to it survives anywhere.

A row's Status is what decides whether it runs. Nothing selects a category by number range, so a
row changing to `merged→NN`, `moved→snitch-<skill>` or `deleted` needs no edit anywhere that reads
this manifest by attribute. Anything that states a category *count* is a separate, manual update: the
"Active categories" line below, `SKILL.md`'s count, and `references/category-groups.md`'s ID lists.

Active categories: 93 of 134 rows. Thirteen rows carry `merged→32`: the per-type schema categories
(33-38, 87-93) now run as rows of the per-type table in `references/standards-table.md`, driven by
Cat 32 (Schema type validation). One carries `merged→60`: the trust artifacts now run as Cat 60's
trust half. Two carry `merged→61`: email content and email design now
run as the content and design halves of Cat 61, over one template inventory. Three carry
`merged→76`: affiliate-referral, creator and sponsorship programs now run as rows of Cat 76's
program-type table, which audits presence, partner-facing surface and attribution for all four
program types. Two carry `merged→79`: the GBP depth audit and the GBP feature-deprecation audit now
run as the Depth and Retired-features sections of Cat 79. Three carry `merged→53`: tag-manager
hygiene, event taxonomy and UTM hygiene now run as passes of Cat 53 (Analytics instrumentation),
which reads them all out of the same source; the north-star metric that fell out of the taxonomy
moved to `references/strategic-recommendations.md`. Two carry `merged→82`: the multi-assistant
citation audit and the llms.txt audit now run as Cat 82's per-assistant section and its Layer 1,
so a missing `llms.txt` deducts once rather than twice. One carries `merged→66`: paid social now
runs as the social side of Cat 66 (Paid channel presence), which audits presence and message and
hands pixel wiring to snitch-adsready.

Eight rows carry `moved→snitch-ada`: accessibility conformance (103) and the seven rows it had
absorbed — touch targets (46), readable text (47), ARIA labels (48), color contrast (49), keyboard
navigation (104), screen-reader semantics (105) and color-blind safe design (113). The judge for all
eight is WCAG 2.2 AA conformance and the legal exposure a failure carries, and that judge belongs to
the accessibility skill, which also owns i18n readiness. Marketing keeps the same elements where the
judge is search and traffic: image alt as a search signal (25, 26), viewport (45), `lang` as a
machine-readability signal (52), hreflang and locale canonicals (50, 51), translated-page content
quality (133) and agent operability (134).

Three rows carry `moved→snitch-adsready`: consent mode, cookieless-analytics readiness and pixel
install completeness are judged against ad-platform requirements, and the ads-readiness skill
already owns that surface and can verify firing against the platform APIs. Two carry
`moved→snitch-cmo`: ICP wedge scoring and the pricing strategic read produce strategy rather than
findings a site can be graded against. One carries `deleted`: the Meta ads account structure audit
was campaign management, which `SKILL.md` and the router both put outside this skill; nothing
inherited it. Every merged and moved number stays reserved and its file is a redirect stub; the
deleted number stays reserved and its file is gone.

| ID | Slug | Title | Type | Groups | Standards | Status |
|----|------|-------|------|--------|-----------|--------|
| 01 | robots | Robots.txt | crawl-index | quick-core, technical-seo, local | RFC 9309 (robots.txt) | active |
| 02 | sitemap | Sitemap.xml | crawl-index | quick-core, technical-seo, local, publisher | sitemaps.org 0.9 | active |
| 03 | canonical-url | Canonical URL | crawl-index | quick-core, technical-seo, local, publisher | RFC 6596 | active |
| 04 | indexability | Indexability (noindex / nofollow / nosnippet) | crawl-index | quick-core, technical-seo | Google Search Essentials | active |
| 05 | soft-404 | Soft 404 detection | crawl-index | technical-seo | RFC 9110 (404/410) | active |
| 06 | redirect-chains | Redirect chains | crawl-index | technical-seo | RFC 9110 (3xx) | active |
| 07 | pagination | Pagination (per-page canonical) | crawl-index | ecommerce | Google Search Essentials | active |
| 08 | meta-refresh | Meta refresh anti-pattern | crawl-index | — | Google Search Essentials | active |
| 09 | title-tag | Title tag | on-page | quick-core, technical-seo, b2b-saas, ecommerce, local, publisher | Google Search Essentials | active |
| 10 | meta-description | Meta description | on-page | quick-core, technical-seo, b2b-saas, ecommerce, local, publisher | Google Search Essentials | active |
| 11 | open-graph | Open Graph tags | on-page | quick-core, b2b-saas, ecommerce | Open Graph protocol | active |
| 12 | twitter-card | Twitter Card tags | on-page | b2b-saas, ecommerce | X Cards spec | active |
| 13 | favicon | Favicon set | on-page | technical-seo | Google favicon guidelines | active |
| 14 | web-manifest | Web app manifest | on-page | — | W3C Web App Manifest | active |
| 15 | single-h1 | Single H1 per page | on-page | quick-core, content-structure | HTML Living Standard | active |
| 16 | heading-hierarchy | Heading hierarchy | on-page | content-structure, publisher | WCAG 2.2 1.3.1 | active |
| 17 | semantic-html | Semantic HTML | on-page | content-structure, publisher | HTML Living Standard | active |
| 18 | thin-content | Thin content (word count + content depth) | content | content-structure, publisher | Google Search Essentials | active |
| 19 | internal-link-graph | Internal link graph (orphan pages) | on-page | content-structure | Google Search Essentials | active |
| 20 | broken-internal-links | Broken internal links | on-page | content-structure | RFC 9110 (404/410) | active |
| 21 | anchor-text | Anchor text quality | on-page | content-structure | Google Search Essentials | active |
| 22 | breadcrumb-markup | Breadcrumb markup | on-page | content-structure, ecommerce, local, publisher | schema.org/BreadcrumbList | active |
| 23 | footer-link-spam | Footer link spam | on-page | content-structure, local | Google spam policies (link spam) | active |
| 24 | external-link-rel | External link rel attributes (nofollow / sponsored / ugc) | on-page | content-structure | Google link attributes (nofollow/sponsored/ugc) | active |
| 25 | image-alt-presence | Image alt presence | on-page | quick-core, conversion-trust, ecommerce, local | — | active |
| 26 | image-alt-quality | Image alt quality | on-page | conversion-trust | — | active |
| 27 | image-format | Image format (webp / avif) | performance | conversion-trust, ecommerce | Core Web Vitals LCP | active |
| 28 | explicit-image-dimensions | Explicit width / height (CLS prevention) | performance | conversion-trust, ecommerce | Core Web Vitals CLS | active |
| 29 | lazy-loading | Lazy-load directives | performance | conversion-trust, ecommerce | Core Web Vitals LCP | active |
| 30 | video-sitemap | Video sitemap presence | crawl-index | conversion-trust, publisher | Google video sitemap spec | active |
| 31 | jsonld-presence | JSON-LD presence | schema | quick-core, structured-data, b2b-saas, ecommerce, local | schema.org | active |
| 32 | schema-type-validation | Schema type validation | schema | structured-data, b2b-saas, ecommerce, local, publisher | schema.org | active |
| 33 | breadcrumblist-schema | BreadcrumbList schema | schema | — | schema.org/BreadcrumbList | merged→32 |
| 34 | product-schema | Product schema | schema | — | schema.org/Product | merged→32 |
| 35 | faq-schema | FAQ schema | schema | — | schema.org/FAQPage | merged→32 |
| 36 | howto-schema | HowTo schema | schema | — | schema.org/HowTo | merged→32 |
| 37 | organization-website-schema | Organization / WebSite schema | schema | — | schema.org/Organization | merged→32 |
| 38 | videoobject-schema | VideoObject schema | schema | — | schema.org/VideoObject | merged→32 |
| 39 | font-loading | Font loading strategy | performance | technical-seo | Core Web Vitals LCP | active |
| 40 | render-blocking | Render-blocking CSS / JS | performance | technical-seo | Core Web Vitals LCP | active |
| 41 | critical-css | Critical-path CSS | performance | — | Core Web Vitals LCP | active |
| 42 | third-party-scripts | Third-party script audit | performance | technical-seo, publisher | Core Web Vitals INP | active |
| 43 | image-weight | Image weight | performance | publisher | Core Web Vitals LCP | active |
| 44 | bundle-weight | JS bundle weight per route | performance | — | Core Web Vitals INP | active |
| 45 | viewport | Viewport meta | accessibility | technical-seo | WCAG 2.2 1.4.10 | active |
| 46 | touch-targets | Touch target size | accessibility | — | WCAG 2.2 2.5.8 | moved→snitch-ada |
| 47 | readable-text | Readable text without zoom | accessibility | — | — | moved→snitch-ada |
| 48 | aria-labels | ARIA labels on interactive elements | accessibility | — | WCAG 2.2 4.1.2 | moved→snitch-ada |
| 49 | color-contrast | Color contrast on text | accessibility | — | WCAG 2.2 1.4.3 | moved→snitch-ada |
| 50 | hreflang | Hreflang correctness | crawl-index | international, local | Google hreflang spec (RFC 5646 tags) | active |
| 51 | locale-canonicals | Locale-specific canonicals | crawl-index | international | RFC 6596 | active |
| 52 | lang-attribute | Lang attribute on html element | accessibility | international | WCAG 2.2 3.1.1 | active |
| 53 | analytics-instrumentation | Analytics instrumentation (install, tag manager, event taxonomy, UTM) | measurement | conversion-trust, local, publisher | — | active |
| 54 | gtm-hygiene | GTM hygiene | measurement | — | — | merged→53 |
| 55 | event-taxonomy | Event taxonomy | measurement | — | — | merged→53 |
| 56 | consent-mode | Consent-mode setup | measurement | — | Consent Mode v2 / IAB TCF 2.2 | moved→snitch-adsready |
| 57 | topical-depth | Topical depth & content gaps | content | content-structure, publisher | Google QRG (E-E-A-T) | active |
| 58 | keyword-intent-match | Keyword targeting / intent match | content | content-structure | — | active |
| 59 | ai-content-tells | AI-content tells | content | publisher | Google spam policies (scaled content) | active |
| 60 | conversion-trust | Conversion & trust (CTAs, forms, trust signals, trust artifacts, 404 recovery) | conversion | conversion-trust, b2b-saas, local | WCAG 2.2 1.3.5 | active |
| 61 | email-inventory | Transactional email inventory & templates (content, rendering, accessibility) | email | email-transactional | WCAG 2.2 1.1.1 | active |
| 62 | email-content | Email content quality | email | — | — | merged→61 |
| 63 | email-deliverability | Email deliverability (SPF, DKIM, DMARC) | email | email-transactional | RFC 7208 / 6376 / 7489 | active |
| 64 | email-design | Email design + accessibility | email | — | WCAG 2.2 1.1.1 | merged→61 |
| 65 | email-compliance | Email compliance (CAN-SPAM, GDPR, CASL, unsubscribe) | email | email-transactional | CAN-SPAM / GDPR / CASL | active |
| 66 | paid-channel-presence | Paid channel presence (search + social: ad-library presence, competitor copy, defensive brand bid) | off-site | channels | — | active |
| 67 | paid-social | Paid social (Meta / LinkedIn / X / TikTok / Reddit Ads) | off-site | — | — | merged→66 |
| 68 | organic-social | Organic social presence (X, LinkedIn, Instagram, YouTube, TikTok, Threads) | off-site | channels | — | active |
| 69 | backlink-profile | Backlink profile + link-building | off-site | channels | Google spam policies (link spam) | active |
| 70 | content-strategy | Content marketing strategy | off-site | channels, publisher | — | active |
| 71 | lifecycle-email | Lifecycle / drip / newsletter marketing | email | channels | CAN-SPAM / GDPR | active |
| 72 | community-building | Community building (Discord, Slack, subreddit, forum) | off-site | channels | — | active |
| 73 | cro-signals | CRO (conversion-rate optimization) signals | conversion | channels, b2b-saas, ecommerce | — | active |
| 74 | customer-feedback | Customer feedback & social proof (reviews, testimonials, NPS, case studies) | off-site | channels, b2b-saas, ecommerce | FTC Endorsement Guides | active |
| 75 | brand-consistency | Brand consistency across channels | off-site | channels, b2b-saas, local | — | active |
| 76 | partnerships | Partner & sponsorship program attribution (partnership, affiliate-referral, creator, newsletter-podcast) | off-site | channels, modern-marketing | FTC Endorsement Guides | active |
| 77 | pr-launches | PR, launches, press surface | off-site | channels | — | active |
| 78 | affiliate-referral | Affiliate / referral programs | off-site | — | FTC Endorsement Guides | merged→76 |
| 79 | local-seo | Local SEO + Google Business Profile (foundation, depth, retired features) | off-site | channels, local | Google Business Profile guidelines | active |
| 80 | product-led-growth | Product-led growth signals | off-site | channels | — | active |
| 81 | market-positioning | Market positioning (differentiation, value-prop strength, audience clarity) | conversion | channels, b2b-saas | — | active |
| 82 | ai-search-citation | AI-search citation optimization (crawler access, llms.txt, per-assistant coverage) | ai-search | modern-marketing, publisher, b2b-saas | — | active |
| 83 | creator-partnerships | Creator partnerships (mid-tier niche creators) | off-site | — | FTC Endorsement Guides | merged→76 |
| 84 | founder-led-brand | Founder-led brand channel | off-site | modern-marketing | — | active |
| 85 | newsletter-podcast-sponsorships | Newsletter & podcast sponsorships (niche-vertical earned-media) | off-site | — | FTC Endorsement Guides | merged→76 |
| 86 | keyword-research | Keyword research + intent mapping | content | content-structure | — | active |
| 87 | recipe-schema | Recipe schema | schema | — | schema.org/Recipe | merged→32 |
| 88 | course-schema | Course schema | schema | — | schema.org/Course | merged→32 |
| 89 | event-schema | Event schema | schema | — | schema.org/Event | merged→32 |
| 90 | jobposting-schema | JobPosting schema | schema | — | schema.org/JobPosting | merged→32 |
| 91 | softwareapplication-schema | SoftwareApplication schema | schema | — | schema.org/SoftwareApplication | merged→32 |
| 92 | localbusiness-schema | LocalBusiness schema | schema | — | schema.org/LocalBusiness | merged→32 |
| 93 | person-schema | Person / Author schema | schema | — | schema.org/Person | merged→32 |
| 94 | review-aggregaterating-schema | Review / AggregateRating schema | schema | structured-data, ecommerce | schema.org/AggregateRating | active |
| 95 | programmatic-seo | Programmatic SEO audit | content | — | Google spam policies (scaled content) | active |
| 96 | brand-serp-defense | Brand-SERP defense | off-site | b2b-saas, local | — | active |
| 97 | content-decay-refresh | Content decay & refresh audit | content | publisher | — | active |
| 98 | internal-site-search | Internal site search audit | content | — | — | active |
| 99 | conversion-funnel-deep | Conversion funnel deep-audit | conversion | b2b-saas, ecommerce | — | active |
| 100 | cookieless-analytics | Cookieless analytics readiness | measurement | — | GDPR / ePrivacy | moved→snitch-adsready |
| 101 | ai-agent-commerce | AI-agent commerce signals | ai-search | ecommerce | — | active |
| 102 | multi-llm-citation | Multi-LLM citation differentiation | ai-search | — | — | merged→82 |
| 103 | accessibility-conformance | Accessibility conformance (WCAG 2.2 AA + legal exposure) | accessibility | — | WCAG 2.2 AA | moved→snitch-ada |
| 104 | keyboard-navigation | Keyboard navigation + focus management | accessibility | — | WCAG 2.2 2.1.1 | moved→snitch-ada |
| 105 | screen-reader-semantics | Screen reader semantics audit | accessibility | — | WCAG 2.2 4.1.2 | moved→snitch-ada |
| 106 | llms-txt | llms.txt (AI-crawler-friendly site description) | ai-search | — | llms.txt proposal | merged→82 |
| 107 | pixel-install-completeness | Pixel install completeness | measurement | — | Consent Mode v2 | moved→snitch-adsready |
| 108 | utm-hygiene | UTM hygiene + parameter consistency | measurement | — | — | merged→53 |
| 109 | message-match-audit | Landing-page-to-ad message match audit | off-site | channels | — | active |
| 110 | icp-wedge-scoring | ICP wedge scoring | conversion | — | — | moved→snitch-cmo |
| 111 | trust-artifact-audit | Trust artifact audit | conversion | — | — | merged→60 |
| 112 | pricing-strategic-read | Pricing strategic read | conversion | — | — | moved→snitch-cmo |
| 113 | colorblind-safe-design | Color-blind safe design | accessibility | — | WCAG 2.2 1.4.1 | moved→snitch-ada |
| 114 | persuasion-architecture | Persuasion architecture (holistic psychology audit) | conversion | b2b-saas | — | active |
| 115 | pricing-psychology-tactical | Pricing psychology (tactical display) | conversion | b2b-saas | FTC pricing claims | active |
| 116 | retention-psychology | Retention psychology (activation, endowment, peak-end, exit) | conversion | b2b-saas | — | active |
| 117 | copy-lint | Site copy lint (vague adjectives, unsupported superlatives, dark patterns, hidden price, weak social proof) | content | conversion-trust | FTC ad substantiation | active |
| 118 | gbp-depth-audit | Google Business Profile depth audit (fill-every-field discipline) | off-site | — | Google Business Profile guidelines | merged→79 |
| 119 | hyperlocal-landing-page-completeness | Hyper-local landing page completeness | content | channels, local | — | active |
| 120 | meta-ads-account-structure-health | Meta ads account structure health | off-site | — | — | deleted |
| 121 | information-architecture | Information architecture & site structure | on-page | technical-seo, content-structure, b2b-saas, ecommerce | — | active |
| 122 | comparison-alternatives-pages | Comparison / alternatives / "vs" page strategy | content | content-structure, conversion-trust, b2b-saas, ecommerce | FTC ad substantiation | active |
| 123 | lead-magnet-acquisition-assets | Lead-magnet / free-tool acquisition assets | conversion | conversion-trust, b2b-saas | — | active |
| 124 | buying-committee-coverage | Buying-committee / stakeholder coverage (B2B multi-stakeholder messaging) | conversion | b2b-saas | — | active |
| 125 | parasite-seo-risk | Parasite SEO / site-reputation-abuse risk | risk | publisher | Google site-reputation-abuse policy | active |
| 126 | domain-heritage-risk | Domain heritage / expired-domain abuse risk | risk | — | Google expired-domain-abuse policy | active |
| 127 | gbp-deprecation-audit | Google Business Profile feature-deprecation audit (reliance on retired GBP features) | off-site | — | Google Business Profile guidelines | merged→79 |
| 128 | citation-gap-audit | Citation-gap audit (uncited verifiable claims) | content | content-structure, publisher | Google QRG (E-E-A-T) | active |
| 129 | ai-image-provenance | AI-image provenance & licensing metadata (IPTC/XMP) | risk | ecommerce | IPTC DigitalSourceType | active |
| 130 | indexnow-submission | IndexNow / indexing-submission readiness | crawl-index | technical-seo | IndexNow protocol | active |
| 131 | sxo-serp-intent-alignment | SXO — page-type / SERP-intent alignment | content | content-structure | — | active |
| 132 | serp-topic-clustering | SERP-overlap topic clustering + cannibalization | content | content-structure, publisher | — | active |
| 133 | machine-translation-drift | Machine-translation quality drift (localized content quality) | content | international | — | active |
| 134 | agent-operability | Agent operability (accessibility-tree / machine-actionability) | ai-search | modern-marketing, ecommerce | WCAG 2.2 4.1.2 | active |

Notes:
- Numbers are locked: never reused, never reordered. Adding a category = one row here + one file in
  `categories/`, named `<ID>-<slug>.md`. Retiring one = a Status change to `merged→NN` or
  `moved→snitch-<skill>` plus the count updates named above, never a deleted row.
- Group ID lists are owned by `references/category-groups.md`; this table mirrors them per-row. If the
  two ever disagree, that file wins and this one is stale.
- Several entries in the Standards column no longer produce a rich result (HowTo, WebSite
  `SearchAction`). The column records what governs the markup, not what Google still renders — read
  `references/schema-deprecations.md` before writing the recommendation.
