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
- `accessibility` — cite the WCAG 2.2 success criterion; follow `references/accessibility-audit-workflow.md`.
- `measurement` — instrumentation correctness only; never assert traffic, conversion, or revenue figures that would require access to the analytics account.
- `conversion` — hypothesis plus mechanism; never a predicted lift percentage.
- `email` — source mode required (server-side sends are invisible to a crawl); deliverability findings come from DNS lookups, not from the HTML.
- `off-site` — evidence lives outside the audited site; gated by the brand-maturity check (STEP 0.6) — `none` presence Skips, and STEP 4.5 turns that Skip into a "start here".
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
`publisher` = Group 14, `a11y-deep` = Group 15. Group 10 (Full Audit) is every row, so it is not
listed per-row. `quick-core` categories are always in a Quick Audit; smart detection adds 2-3 more
per detected stack (`references/smart-detection.md`). A `—` means the category is reached only by
Full Audit, Custom selection, or component-based detection (`references/component-cat-map.md`).

**Standards** is the external authority a finding cites when one exists. `—` means the category is a
judgment call with no governing spec; those findings carry the SEO Impact tier from
`references/standards-table.md` and nothing more.

**Status:** `active` = auditable. The 134-number catalog is locked — no category is merged or retired.

Active categories: 134.

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
| 17 | semantic-html | Semantic HTML | on-page | content-structure, publisher, a11y-deep | HTML Living Standard | active |
| 18 | thin-content | Thin content (word count + content depth) | content | content-structure, publisher | Google Search Essentials | active |
| 19 | internal-link-graph | Internal link graph (orphan pages) | on-page | content-structure | Google Search Essentials | active |
| 20 | broken-internal-links | Broken internal links | on-page | content-structure | RFC 9110 (404/410) | active |
| 21 | anchor-text | Anchor text quality | on-page | content-structure | Google Search Essentials | active |
| 22 | breadcrumb-markup | Breadcrumb markup | on-page | content-structure, ecommerce, local, publisher | schema.org/BreadcrumbList | active |
| 23 | footer-link-spam | Footer link spam | on-page | content-structure, local | Google spam policies (link spam) | active |
| 24 | external-link-rel | External link rel attributes (nofollow / sponsored / ugc) | on-page | content-structure | Google link attributes (nofollow/sponsored/ugc) | active |
| 25 | image-alt-presence | Image alt presence | accessibility | quick-core, conversion-trust, ecommerce, local, a11y-deep | WCAG 2.2 1.1.1 | active |
| 26 | image-alt-quality | Image alt quality | accessibility | conversion-trust, a11y-deep | WCAG 2.2 1.1.1 | active |
| 27 | image-format | Image format (webp / avif) | performance | conversion-trust, ecommerce | Core Web Vitals LCP | active |
| 28 | explicit-image-dimensions | Explicit width / height (CLS prevention) | performance | conversion-trust, ecommerce, a11y-deep | Core Web Vitals CLS | active |
| 29 | lazy-loading | Lazy-load directives | performance | conversion-trust, ecommerce | Core Web Vitals LCP | active |
| 30 | video-sitemap | Video sitemap presence | crawl-index | conversion-trust, publisher | Google video sitemap spec | active |
| 31 | jsonld-presence | JSON-LD presence | schema | quick-core, structured-data, b2b-saas, ecommerce, local | schema.org | active |
| 32 | article-schema | Article schema | schema | structured-data, publisher | schema.org/Article | active |
| 33 | breadcrumblist-schema | BreadcrumbList schema | schema | structured-data, ecommerce, local, publisher | schema.org/BreadcrumbList | active |
| 34 | product-schema | Product schema | schema | structured-data, ecommerce | schema.org/Product | active |
| 35 | faq-schema | FAQ schema | schema | structured-data | schema.org/FAQPage | active |
| 36 | howto-schema | HowTo schema | schema | structured-data | schema.org/HowTo | active |
| 37 | organization-website-schema | Organization / WebSite schema | schema | structured-data, b2b-saas, local | schema.org/Organization | active |
| 38 | videoobject-schema | VideoObject schema | schema | structured-data, publisher | schema.org/VideoObject | active |
| 39 | font-loading | Font loading strategy | performance | technical-seo | Core Web Vitals LCP | active |
| 40 | render-blocking | Render-blocking CSS / JS | performance | technical-seo | Core Web Vitals LCP | active |
| 41 | critical-css | Critical-path CSS | performance | — | Core Web Vitals LCP | active |
| 42 | third-party-scripts | Third-party script audit | performance | technical-seo, publisher | Core Web Vitals INP | active |
| 43 | image-weight | Image weight | performance | publisher | Core Web Vitals LCP | active |
| 44 | bundle-weight | JS bundle weight per route | performance | — | Core Web Vitals INP | active |
| 45 | viewport | Viewport meta | accessibility | technical-seo, a11y-deep | WCAG 2.2 1.4.10 | active |
| 46 | touch-targets | Touch target size | accessibility | a11y-deep | WCAG 2.2 2.5.8 | active |
| 47 | readable-text | Readable text without zoom | accessibility | conversion-trust, a11y-deep | WCAG 2.2 1.4.4 | active |
| 48 | aria-labels | ARIA labels on interactive elements | accessibility | conversion-trust, a11y-deep | WCAG 2.2 4.1.2 | active |
| 49 | color-contrast | Color contrast on text | accessibility | conversion-trust, local, a11y-deep | WCAG 2.2 1.4.3 | active |
| 50 | hreflang | Hreflang correctness | crawl-index | international, local | Google hreflang spec (RFC 5646 tags) | active |
| 51 | locale-canonicals | Locale-specific canonicals | crawl-index | international | RFC 6596 | active |
| 52 | lang-attribute | Lang attribute on html element | accessibility | international, a11y-deep | WCAG 2.2 3.1.1 | active |
| 53 | ga4-install | GA4 install | measurement | conversion-trust, local, publisher | — | active |
| 54 | gtm-hygiene | GTM hygiene | measurement | conversion-trust | — | active |
| 55 | event-taxonomy | Event taxonomy | measurement | conversion-trust | — | active |
| 56 | consent-mode | Consent-mode setup | measurement | conversion-trust, publisher | Consent Mode v2 / IAB TCF 2.2 | active |
| 57 | topical-depth | Topical depth & content gaps | content | content-structure, publisher | Google QRG (E-E-A-T) | active |
| 58 | keyword-intent-match | Keyword targeting / intent match | content | content-structure | — | active |
| 59 | ai-content-tells | AI-content tells | content | publisher | Google spam policies (scaled content) | active |
| 60 | conversion-trust | Conversion & trust (CTAs, forms, trust signals, 404 page) | conversion | conversion-trust, b2b-saas, local | WCAG 2.2 1.3.5 | active |
| 61 | email-inventory | Transactional email inventory | email | email-transactional | — | active |
| 62 | email-content | Email content quality | email | email-transactional | — | active |
| 63 | email-deliverability | Email deliverability (SPF, DKIM, DMARC) | email | email-transactional | RFC 7208 / 6376 / 7489 | active |
| 64 | email-design | Email design + accessibility | email | email-transactional | WCAG 2.2 1.1.1 | active |
| 65 | email-compliance | Email compliance (CAN-SPAM, GDPR, CASL, unsubscribe) | email | email-transactional | CAN-SPAM / GDPR / CASL | active |
| 66 | paid-search | Paid search (Google Ads / Bing Ads) | off-site | channels | — | active |
| 67 | paid-social | Paid social (Meta / LinkedIn / X / TikTok / Reddit Ads) | off-site | channels | — | active |
| 68 | organic-social | Organic social presence (X, LinkedIn, Instagram, YouTube, TikTok, Threads) | off-site | channels | — | active |
| 69 | backlink-profile | Backlink profile + link-building | off-site | channels | Google spam policies (link spam) | active |
| 70 | content-strategy | Content marketing strategy | off-site | channels, publisher | — | active |
| 71 | lifecycle-email | Lifecycle / drip / newsletter marketing | email | channels | CAN-SPAM / GDPR | active |
| 72 | community-building | Community building (Discord, Slack, subreddit, forum) | off-site | channels | — | active |
| 73 | cro-signals | CRO (conversion-rate optimization) signals | conversion | channels, b2b-saas, ecommerce | — | active |
| 74 | customer-feedback | Customer feedback & social proof (reviews, testimonials, NPS, case studies) | off-site | channels, b2b-saas, ecommerce | FTC Endorsement Guides | active |
| 75 | brand-consistency | Brand consistency across channels | off-site | channels, b2b-saas, local | — | active |
| 76 | partnerships | Partnerships, integrations, co-marketing | off-site | channels | — | active |
| 77 | pr-launches | PR, launches, press surface | off-site | channels | — | active |
| 78 | affiliate-referral | Affiliate / referral programs | off-site | channels | FTC Endorsement Guides | active |
| 79 | local-seo | Local SEO + Google Business Profile | off-site | channels, local | Google Business Profile guidelines | active |
| 80 | product-led-growth | Product-led growth signals | off-site | channels | — | active |
| 81 | market-positioning | Market positioning (differentiation, value-prop strength, audience clarity) | conversion | channels, b2b-saas | — | active |
| 82 | ai-search-citation | AI-search citation optimization | ai-search | modern-marketing, publisher | — | active |
| 83 | creator-partnerships | Creator partnerships (mid-tier niche creators) | off-site | modern-marketing | FTC Endorsement Guides | active |
| 84 | founder-led-brand | Founder-led brand channel | off-site | modern-marketing | — | active |
| 85 | newsletter-podcast-sponsorships | Newsletter & podcast sponsorships (niche-vertical earned-media) | off-site | modern-marketing | FTC Endorsement Guides | active |
| 86 | keyword-research | Keyword research + intent mapping | content | content-structure | — | active |
| 87 | recipe-schema | Recipe schema | schema | ecommerce | schema.org/Recipe | active |
| 88 | course-schema | Course schema | schema | — | schema.org/Course | active |
| 89 | event-schema | Event schema | schema | — | schema.org/Event | active |
| 90 | jobposting-schema | JobPosting schema | schema | — | schema.org/JobPosting | active |
| 91 | softwareapplication-schema | SoftwareApplication schema | schema | b2b-saas, ecommerce | schema.org/SoftwareApplication | active |
| 92 | localbusiness-schema | LocalBusiness schema | schema | local | schema.org/LocalBusiness | active |
| 93 | person-schema | Person / Author schema | schema | publisher | schema.org/Person | active |
| 94 | review-aggregaterating-schema | Review / AggregateRating schema | schema | ecommerce | schema.org/AggregateRating | active |
| 95 | programmatic-seo | Programmatic SEO audit | content | — | Google spam policies (scaled content) | active |
| 96 | brand-serp-defense | Brand-SERP defense | off-site | b2b-saas, local | — | active |
| 97 | content-decay-refresh | Content decay & refresh audit | content | publisher | — | active |
| 98 | internal-site-search | Internal site search audit | content | — | — | active |
| 99 | conversion-funnel-deep | Conversion funnel deep-audit | conversion | b2b-saas, ecommerce | — | active |
| 100 | cookieless-analytics | Cookieless analytics readiness | measurement | — | GDPR / ePrivacy | active |
| 101 | ai-agent-commerce | AI-agent commerce signals | ai-search | ecommerce | — | active |
| 102 | multi-llm-citation | Multi-LLM citation differentiation | ai-search | b2b-saas | — | active |
| 103 | wcag22-conformance | WCAG 2.2 AA conformance audit | accessibility | a11y-deep | WCAG 2.2 AA | active |
| 104 | keyboard-navigation | Keyboard navigation + focus management | accessibility | a11y-deep | WCAG 2.2 2.1.1 | active |
| 105 | screen-reader-semantics | Screen reader semantics audit | accessibility | a11y-deep | WCAG 2.2 4.1.2 | active |
| 106 | llms-txt | llms.txt (AI-crawler-friendly site description) | ai-search | modern-marketing | llms.txt proposal | active |
| 107 | pixel-install-completeness | Pixel install completeness | measurement | conversion-trust | Consent Mode v2 | active |
| 108 | utm-hygiene | UTM hygiene + parameter consistency | measurement | conversion-trust | — | active |
| 109 | message-match-audit | Landing-page-to-ad message match audit | off-site | channels | — | active |
| 110 | icp-wedge-scoring | ICP wedge scoring | conversion | b2b-saas | — | active |
| 111 | trust-artifact-audit | Trust artifact audit | conversion | b2b-saas | — | active |
| 112 | pricing-strategic-read | Pricing strategic read | conversion | b2b-saas | — | active |
| 113 | colorblind-safe-design | Color-blind safe design | accessibility | a11y-deep | WCAG 2.2 1.4.1 | active |
| 114 | persuasion-architecture | Persuasion architecture (holistic psychology audit) | conversion | b2b-saas | — | active |
| 115 | pricing-psychology-tactical | Pricing psychology (tactical display) | conversion | b2b-saas | FTC pricing claims | active |
| 116 | retention-psychology | Retention psychology (activation, endowment, peak-end, exit) | conversion | b2b-saas | — | active |
| 117 | copy-lint | Site copy lint (vague adjectives, unsupported superlatives, dark patterns, hidden price, weak social proof) | content | conversion-trust | FTC ad substantiation | active |
| 118 | gbp-depth-audit | Google Business Profile depth audit (fill-every-field discipline) | off-site | channels, local | Google Business Profile guidelines | active |
| 119 | hyperlocal-landing-page-completeness | Hyper-local landing page completeness | content | channels, local | — | active |
| 120 | meta-ads-account-structure-health | Meta ads account structure health | off-site | conversion-trust | — | active |
| 121 | information-architecture | Information architecture & site structure | on-page | technical-seo, content-structure, b2b-saas, ecommerce | — | active |
| 122 | comparison-alternatives-pages | Comparison / alternatives / "vs" page strategy | content | content-structure, conversion-trust, b2b-saas, ecommerce | FTC ad substantiation | active |
| 123 | lead-magnet-acquisition-assets | Lead-magnet / free-tool acquisition assets | conversion | conversion-trust, b2b-saas | — | active |
| 124 | buying-committee-coverage | Buying-committee / stakeholder coverage (B2B multi-stakeholder messaging) | conversion | b2b-saas | — | active |
| 125 | parasite-seo-risk | Parasite SEO / site-reputation-abuse risk | risk | publisher | Google site-reputation-abuse policy | active |
| 126 | domain-heritage-risk | Domain heritage / expired-domain abuse risk | risk | — | Google expired-domain-abuse policy | active |
| 127 | gbp-deprecation-audit | Google Business Profile feature-deprecation audit (reliance on retired GBP features) | off-site | local | Google Business Profile guidelines | active |
| 128 | citation-gap-audit | Citation-gap audit (uncited verifiable claims) | content | content-structure, publisher | Google QRG (E-E-A-T) | active |
| 129 | ai-image-provenance | AI-image provenance & licensing metadata (IPTC/XMP) | risk | ecommerce | IPTC DigitalSourceType | active |
| 130 | indexnow-submission | IndexNow / indexing-submission readiness | crawl-index | technical-seo | IndexNow protocol | active |
| 131 | sxo-serp-intent-alignment | SXO — page-type / SERP-intent alignment | content | content-structure | — | active |
| 132 | serp-topic-clustering | SERP-overlap topic clustering + cannibalization | content | content-structure, publisher | — | active |
| 133 | machine-translation-drift | Machine-translation quality drift (localized content quality) | content | international | — | active |
| 134 | agent-operability | Agent operability (accessibility-tree / machine-actionability) | ai-search | modern-marketing, ecommerce | WCAG 2.2 4.1.2 | active |

Notes:
- Numbers are locked: never reused, never reordered. Adding a category = one row here + one file in
  `categories/`, named `<ID>-<slug>.md`.
- Group ID lists are owned by `references/category-groups.md`; this table mirrors them per-row. If the
  two ever disagree, that file wins and this one is stale.
- Several entries in the Standards column no longer produce a rich result (HowTo, WebSite
  `SearchAction`). The column records what governs the markup, not what Google still renders — read
  `references/schema-deprecations.md` before writing the recommendation.
