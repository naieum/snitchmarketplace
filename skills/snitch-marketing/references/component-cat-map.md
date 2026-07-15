# Component to Category Map

This file is the declarative mapping between observable components (output of STEP 0.8) and the categories that apply when each component is detected. STEP 1.5 reads this map to build the recommended scan.

The map replaces hardcoded business-archetype decision tables. A site is the union of its components, not a single label.

## How the map works

Every detected component contributes some cats. The recommended scan is the UNION of all contributed cats, deduplicated. Cats can be tagged as `core` (always run when the component is present) or `conditional` (run only when a secondary signal is also present).

Universal-foundation cats run regardless of components and are listed at the top.

## Universal-foundation cats

These run for every audit, regardless of detected components:

- Cat 1, robots.txt
- Cat 2, sitemap.xml
- Cat 3, canonical URL
- Cat 4, indexability
- Cat 9, title tag
- Cat 10, meta description
- Cat 11, Open Graph
- Cat 12, Twitter Card
- Cat 15, single H1
- Cat 16, heading hierarchy
- Cat 17, semantic HTML
- Cat 21, anchor text quality
- Cat 31, JSON-LD presence
- Cat 37, Organization / WebSite schema
- Cat 39, font loading
- Cat 45, viewport
- Cat 49, color contrast
- Cat 52, lang attribute
- Cat 81, market positioning
- Cat 96, brand SERP defense
- Cat 106, llms.txt
- Cat 108, UTM hygiene
- Cat 111, trust artifact audit (universal: every brand has a trust gap to audit)
- Cat 117, site copy lint (universal: every brand has site copy; every line either substantiates its claim or it doesn't)

These ~23 cats cover roughly ~31-36K tokens at the low end, regardless of what else is detected.

## Per-component cat additions

### Surface: homepage

Always present. Adds:
- Cat 13, favicon set
- Cat 14, web manifest
- Cat 60, conversion and trust (CTA + trust signals at hero)
- Cat 82, AI-search citation (homepage is the most-cited page)
- Cat 117, site copy lint (hero, subhead, CTA label are the densest vague-adjective surfaces; already in the universal set, listed here as the primary surface it scores against)

### Surface: /pricing (with tiered offers)

Adds:
- Cat 91, SoftwareApplication schema (for SaaS-shaped offers)
- Cat 60, conversion and trust (pricing is a conversion surface)
- Cat 99, conversion funnel deep-audit (pricing is a step in the funnel)
- Cat 73, CRO signals (conditional: only if A/B test infra detected)
- Cat 112, pricing strategic read (synthesizes the pricing mix into 3-bucket recommendation)
- Cat 117, site copy lint (pricing page is the #1 surface for "starting at" with no number; already universal, listed here as a high-priority surface)
- Cat 124, buying-committee / stakeholder coverage (conditional: only if the pricing path is sales-led — "Contact sales", demo-gated, or an enterprise/custom tier — signalling a multi-stakeholder purchase)
- Cat 131, SXO page-type / SERP-intent alignment (conditional: only if the pricing page targets a ranking query)

### Surface: /blog, /posts, /articles, /writings

Adds:
- Cat 18, thin content
- Cat 32, Article schema
- Cat 33, BreadcrumbList schema
- Cat 57, topical depth
- Cat 58, keyword/intent match
- Cat 59, AI-content tells
- Cat 70, content marketing strategy
- Cat 86, keyword research and intent mapping
- Cat 93, Person/Author schema (conditional: only if author bylines detected)
- Cat 97, content decay and refresh (conditional: only if 30+ posts and 12+ months publish history)
- Cat 102, multi-LLM citation (content is the surface that gets cited)
- Cat 121, information architecture (conditional: only if 25+ posts; hub-and-spoke clustering)
- Cat 128, citation-gap audit (verifiable claims need nearby sources for E-E-A-T + AI-citability)
- Cat 132, SERP-overlap topic clustering + cannibalization (conditional: only if 25+ posts/target queries)
- Cat 125, parasite SEO / site-reputation-abuse risk (conditional: only if sponsored / guest / third-party bylines in the section)
- Cat 130, IndexNow / indexing-submission readiness (conditional: only on high publish velocity where fast Bing/Yandex discovery matters)

### Surface: /docs

Adds:
- Cat 17, semantic HTML (already universal; reinforced)
- Cat 36, HowTo schema (conditional: only if step-by-step content detected)
- Cat 19, internal link graph (docs are highly interlinked)
- Cat 22, breadcrumb markup
- Cat 33, BreadcrumbList schema
- Cat 121, information architecture (docs depth + click-depth to key pages)

### Surface: /faq

Adds:
- Cat 35, FAQ schema (FAQPage)

### Surface: /about

Adds:
- Cat 93, Person/Author schema (named people on the page)
- Cat 84, founder-led brand (conditional: only if founder is named and has external presence)

### Surface: /customers, /case-studies, /customer-stories

Adds:
- Cat 74, customer feedback / social proof
- Cat 75, brand consistency

### Surface: /talks, /speaking, /appearances

Adds:
- Cat 89, Event schema (conditional: only if upcoming or recent talks detailed)
- Cat 111, Speaker / talk-appearance audit (NEW)

### Surface: /products, /catalog, /shop, /store

Adds:
- Cat 22, breadcrumb markup
- Cat 25, image alt presence
- Cat 26, image alt quality
- Cat 27, image format (webp / avif)
- Cat 28, explicit image dimensions (CLS prevention)
- Cat 29, lazy loading
- Cat 33, BreadcrumbList schema
- Cat 34, Product schema
- Cat 43, image weight
- Cat 94, Review / AggregateRating schema (conditional: only if review surface present)
- Cat 99, conversion funnel deep
- Cat 101, AI-agent commerce signals
- Cat 121, information architecture (catalog taxonomy + faceted-nav crawl traps)
- Cat 129, AI-image provenance metadata (conditional: only if product images are AI-generated)
- Cat 131, SXO page-type / SERP-intent alignment (does the PDP match the SERP consensus for its query)
- Cat 134, agent operability (can a shopping agent complete add-to-cart / the primary action)

### Surface: /cart, /checkout

Adds:
- Cat 60, conversion and trust (deep)
- Cat 99, conversion funnel deep
- Cat 101, AI-agent commerce signals
- Cat 134, agent operability (the checkout's primary actions must be machine-operable, not div-onclick)

### Surface: /courses, /cohort, /learn

Adds:
- Cat 88, Course schema
- Cat 99, conversion funnel deep (course signup is its own funnel)

### Surface: /services, /work-with-me, /coaching

Adds:
- Cat 110, Service schema (NEW)
- Cat 60, conversion and trust
- Cat 99, conversion funnel deep
- Cat 81, market positioning (services = positioning-heavy)

### Surface: /integrations (programmatic, 5+ entries)

Adds:
- Cat 22, breadcrumb markup
- Cat 33, BreadcrumbList schema
- Cat 76, partnerships / integrations
- Cat 95, programmatic SEO audit
- Cat 18, thin content (programmatic surfaces are at risk)

### Surface: /compare, /vs, /alternatives (competitor comparison pages)

Adds:
- Cat 22, breadcrumb markup
- Cat 33, BreadcrumbList schema
- Cat 95, programmatic SEO audit (conditional: only if 5+ programmatic entries)
- Cat 18, thin content
- Cat 81, market positioning
- Cat 96, brand SERP defense (already universal; reinforced)
- Cat 122, comparison / alternatives page strategy (credibility, conversion, schema)
- Cat 131, SXO page-type / SERP-intent alignment (does the page type match the SERP for "X vs Y" / "alternatives to X")

### Surface: /for/{audience}, /use-cases/{case} (programmatic)

Adds:
- Cat 22, breadcrumb markup
- Cat 33, BreadcrumbList schema
- Cat 95, programmatic SEO audit (if 5+ entries)
- Cat 18, thin content

### Surface: /careers, /jobs, /hiring

Adds:
- Cat 90, JobPosting schema

### Surface: /locations, address-in-footer, NAP signals

Adds:
- Cat 79, Local SEO + Google Business Profile (off-site)
- Cat 92, LocalBusiness schema
- Cat 96, brand SERP defense (local-flavored)
- Cat 118, Google Business Profile depth audit (conditional: only when GBP is claimed per Cat 79's pre-flight; the depth audit waits for the foundation)
- Cat 119, Hyper-local landing page completeness (conditional: only when the brand has multi-city coverage detected — `/locations/[city]`, `/{city}-{service}` routes, or 5+ individual city pages)
- Cat 127, GBP feature-deprecation audit (reliance on retired GBP features: chat, *.business.site, Q&A)

### Surface: /newsletter, /tools, /free, /templates, /resources, lead-capture forms

Adds:
- Cat 71, lifecycle email
- Cat 123, lead-magnet / free-tool acquisition assets (value exchange, capture hygiene, nurture tie-in, ICP relevance)
- Cat 85, newsletter and podcast sponsorships (conditional: only if brand also has subscriber base or sponsorship surface)

### Content shape: author bylines on content

Adds:
- Cat 93, Person/Author schema
- Cat 84, founder-led brand (conditional)

### Content shape: recipe pages (ingredients + instructions + yield)

Adds:
- Cat 87, Recipe schema

### Content shape: event pages (start dates + locations)

Adds:
- Cat 89, Event schema

### Content shape: book content (ISBN, retailer links, dedicated `/books/`)

Adds:
- Cat 112, Book / publication schema (NEW)
- Cat 32, Article schema (already added if /blog detected)

### Content shape: video embeds, /videos/, /watch/

Adds:
- Cat 30, video sitemap
- Cat 38, VideoObject schema

### Content shape: podcast embeds or /podcast route

Adds:
- Cat 38, VideoObject schema (podcasts ride VideoObject in Google's feature surface)
- Cat 85, newsletter and podcast sponsorships (conditional)

### Entity shape: domain matches a person's name OR hero in first-person singular

Personal-brand entity signal. Adds:
- Cat 93, Person/Author schema (already added if other content components present; reinforced)
- Cat 84, founder-led brand
- Cat 96, brand SERP defense (the brand SERP is the person's name; high-stakes)
- Cat 110, ICP wedge scoring (personal brands often serve multiple audiences without naming the wedge)

### Entity shape: corporate "we" hero copy AND multiple team members on /about

Organization signal. Adds:
- Cat 37, Organization schema (already universal; reinforced)
- Cat 93, Person/Author schema for each named team member
- Cat 110, ICP wedge scoring (conditional: only if homepage names 3+ buyer types in one sentence; then wedge selection is needed)
- Cat 124, buying-committee / stakeholder coverage (conditional: only on a B2B / sales-led / considered-purchase motion — demo-gated CTA, "contact sales", enterprise tier, or a security/compliance page detected; skip for single-buyer self-serve)

### Infrastructure: GA4, GTM, or any analytics installed

Adds:
- Cat 53, GA4 install
- Cat 54, GTM hygiene
- Cat 55, event taxonomy
- Cat 56, consent mode
- Cat 100, cookieless analytics readiness

### Infrastructure: ad pixels installed (any platform)

Adds:
- Cat 67, paid social (channel-level)
- Cat 100, cookieless analytics readiness
- Cat 107, pixel install completeness
- Cat 108, UTM hygiene (already universal; reinforced)
- Cat 109, message match audit (conditional: only if active ads detected in transparency centers)
- Cat 120, Meta ads account structure health (conditional: only when Meta Pixel or Conversions API is detected; campaign-topology audit requires ad-account access for full coverage, partial audit otherwise)

### Infrastructure: email service installed (Resend, Postmark, etc.)

Adds:
- Cat 61, transactional email inventory
- Cat 62, email content quality
- Cat 63, email deliverability
- Cat 64, email design + accessibility
- Cat 65, email compliance

### Infrastructure: Stripe / commerce payment

Adds:
- Cat 91, SoftwareApplication schema (if SaaS)
- Cat 99, conversion funnel deep
- Cat 60, conversion and trust (already added if /pricing; reinforced)

### Infrastructure: multi-locale routing or i18n config

Adds:
- Cat 50, hreflang correctness
- Cat 51, locale-specific canonicals
- Cat 133, machine-translation quality drift (is the localized content actually good, not just correctly targeted)

### Infrastructure: account-system / auth library

Adds:
- Cat 99, conversion funnel deep (signup → activation flow)
- Cat 123, lead-magnet / acquisition assets (conditional: only if the only CTAs are hard asks — demo/buy/contact — with no lighter on-ramp)

### Infrastructure: llms.txt at site root

Adds:
- Cat 106, llms.txt audit (already universal)
- Cat 82, AI-search citation (foundational; reinforced)

### Off-site: any organic social presence

Adds:
- Cat 68, organic social presence
- Cat 75, brand consistency

### Off-site: paid presence (any platform)

Adds:
- Cat 66, paid search OR Cat 67, paid social per platform
- Cat 107, pixel install completeness (already added if pixels detected)
- Cat 108, UTM hygiene (already universal)
- Cat 109, message match audit
- Cat 78, affiliate / referral (conditional: only if affiliate program detected)

### Off-site: community channel (Discord, Slack, subreddit, forum)

Adds:
- Cat 72, community building

### Off-site: PR / press coverage detected

Adds:
- Cat 77, PR launches and press surface

### Off-site: Google Business Profile

Adds:
- Cat 79, Local SEO + GBP
- Cat 127, GBP feature-deprecation audit (reliance on retired GBP features: chat, *.business.site, Q&A)

### Entity shape: aged or recently-acquired domain

Acquired-domain or aged-domain signal (a domain bought from a broker, a rebrand onto a previously-owned domain, or a registration that far predates the current brand). Adds:
- Cat 126, domain heritage / expired-domain abuse risk (conditional: only when an acquisition or aged-domain signal is present; this is a proactive / pre-acquisition check, not a default scan)

## How the map is consumed by STEP 1.5

```
recommended_cats = set(universal_foundation_cats)
for component in step_0_8_inventory:
    recommended_cats.update(component_cat_map[component].core)
    for conditional in component_cat_map[component].conditional:
        if conditional.signal_present():
            recommended_cats.update(conditional.cats)

# Deduplicate, sort
final_recommended = sorted(set(recommended_cats))
```

STEP 1.5 surfaces the resulting list to the user with the per-component reasoning visible (so the customer can audit which components drove which cats), then passes to STEP 1.7 (Confirm Categories) where the customer can drop or add.

## Adding a new component type

When a new component type appears in real-world audits (e.g., a new schema.org type, a new infrastructure pattern, a new content shape), add it here as a new section. Each addition is a small declarative change, no code edits required elsewhere. STEP 0.8 detection logic is updated in SKILL.md to detect the new component; STEP 1.5 picks up the new mapping automatically.

## Adding a new category

When a new cat is added to the catalog (e.g., Cat 113), it's mapped here under the components it applies to. If a cat is universally relevant (e.g., a new technical-SEO foundational), add it to the Universal-foundation list at the top. If it's component-specific, add it under the relevant component sections.

## Cross-references

- `references/category-groups.md`, contains the named presets (B2B SaaS, e-commerce, local, publisher, accessibility) which now serve as curated shortcuts rather than the primary recommendation mechanism. Customers who know their shape can pick a named preset directly; the default path is component-detection-driven.
- `references/custom-selection.md`, custom selection picker for power users.
- `references/voice-mapping.md`, internal voice-to-cat mapping (which soul writes the fix prose for each cat).
- SKILL.md STEP 0.8, the detection logic that produces the input to this map.
- SKILL.md STEP 1.5, the synthesizer that turns this map plus STEP 0.8 inventory into the recommended scan.
