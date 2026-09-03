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
- Cat 32, schema type validation (Organization / WebSite row; universal, every site has a brand entity)
- Cat 39, font loading
- Cat 45, viewport
- Cat 52, lang attribute
- Cat 81, market positioning
- Cat 96, brand SERP defense
- Cat 82, AI-search citation (its Layer 1 llms.txt and crawler-access pass is universal)
- Cat 53, analytics instrumentation (its UTM pass is universal)
- Cat 60, conversion & trust (universal: CTAs, forms, and the trust-artifact inventory every brand has a gap in)
- Cat 117, site copy lint (universal: every brand has site copy; every line either substantiates its claim or it doesn't)

These 23 cats cover roughly ~30-39K tokens at the low end, regardless of what else is detected. WCAG 2.2 AA conformance and the legal exposure a failure carries are not in the universal set: they are audited by the accessibility skill, so call the Skill tool with "snitch-ada" when the user wants them.

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
- Cat 32, schema type validation (SoftwareApplication row, for SaaS-shaped offers)
- Cat 60, conversion and trust (pricing is a conversion surface)
- Cat 99, conversion funnel deep-audit (pricing is a step in the funnel)
- Cat 73, CRO signals (conditional: only if A/B test infra detected)
- Cat 115, pricing psychology tactical (how the tiers are displayed: charm vs rounded, decoy, anchoring order, strike-through provenance)
- Cat 117, site copy lint (pricing page is the #1 surface for "starting at" with no number; already universal, listed here as a high-priority surface)
- Cat 124, buying-committee / stakeholder coverage (conditional: only if the pricing path is sales-led — "Contact sales", demo-gated, or an enterprise/custom tier — signalling a multi-stakeholder purchase)
- Cat 131, SXO page-type / SERP-intent alignment (conditional: only if the pricing page targets a ranking query)

### Surface: /blog, /posts, /articles, /writings

Adds:
- Cat 18, thin content
- Cat 32, schema type validation (Article + BreadcrumbList rows)
- Cat 57, topical depth
- Cat 58, keyword/intent match
- Cat 59, AI-content tells
- Cat 70, content marketing strategy
- Cat 86, keyword research and intent mapping
- Cat 32, schema type validation (Person row; conditional: only if author bylines detected)
- Cat 97, content decay and refresh (conditional: only if 30+ posts and 12+ months publish history)
- Cat 82, AI-search citation (content is the surface that gets cited; adds the per-assistant pass)
- Cat 121, information architecture (conditional: only if 25+ posts; hub-and-spoke clustering)
- Cat 128, citation-gap audit (verifiable claims need nearby sources for E-E-A-T + AI-citability)
- Cat 132, SERP-overlap topic clustering + cannibalization (conditional: only if 25+ posts/target queries)
- Cat 125, parasite SEO / site-reputation-abuse risk (conditional: only if sponsored / guest / third-party bylines in the section)
- Cat 130, IndexNow / indexing-submission readiness (conditional: only on high publish velocity where fast Bing/Yandex discovery matters)

### Surface: /docs

Adds:
- Cat 17, semantic HTML (already universal; reinforced)
- Cat 32, schema type validation (HowTo row; conditional: only if step-by-step content detected)
- Cat 19, internal link graph (docs are highly interlinked)
- Cat 22, breadcrumb markup
- Cat 32, schema type validation (BreadcrumbList row)
- Cat 121, information architecture (docs depth + click-depth to key pages)

### Surface: /faq

Adds:
- Cat 32, schema type validation (FAQPage row)

### Surface: /about

Adds:
- Cat 32, schema type validation (Person row, named people on the page)
- Cat 84, founder-led brand (conditional: only if founder is named and has external presence)

### Surface: /customers, /case-studies, /customer-stories

Adds:
- Cat 74, customer feedback / social proof
- Cat 75, brand consistency

### Surface: /talks, /speaking, /appearances

Adds:
- Cat 32, schema type validation (Event row; conditional: only if upcoming or recent talks detailed)
- Cat 84, founder-led brand (speaker / talk appearances as a founder channel surface)

### Surface: /products, /catalog, /shop, /store

Adds:
- Cat 22, breadcrumb markup
- Cat 25, image alt presence
- Cat 26, image alt quality
- Cat 27, image format (webp / avif)
- Cat 28, explicit image dimensions (CLS prevention)
- Cat 29, lazy loading
- Cat 32, schema type validation (BreadcrumbList + Product rows)
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
- Cat 32, schema type validation (Course row)
- Cat 99, conversion funnel deep (course signup is its own funnel)

### Surface: /services, /work-with-me, /coaching

Adds:
- Cat 32, schema type validation (the row in `references/standards-table.md` that fits the offer's page type)
- Cat 60, conversion and trust
- Cat 99, conversion funnel deep
- Cat 81, market positioning (services = positioning-heavy)

### Surface: /integrations (programmatic, 5+ entries)

Adds:
- Cat 22, breadcrumb markup
- Cat 32, schema type validation (BreadcrumbList row)
- Cat 76, partnerships / integrations
- Cat 95, programmatic SEO audit
- Cat 18, thin content (programmatic surfaces are at risk)

### Surface: /compare, /vs, /alternatives (competitor comparison pages)

Adds:
- Cat 22, breadcrumb markup
- Cat 32, schema type validation (BreadcrumbList row)
- Cat 95, programmatic SEO audit (conditional: only if 5+ programmatic entries)
- Cat 18, thin content
- Cat 81, market positioning
- Cat 96, brand SERP defense (already universal; reinforced)
- Cat 122, comparison / alternatives page strategy (credibility, conversion, schema)
- Cat 131, SXO page-type / SERP-intent alignment (does the page type match the SERP for "X vs Y" / "alternatives to X")

### Surface: /for/{audience}, /use-cases/{case} (programmatic)

Adds:
- Cat 22, breadcrumb markup
- Cat 32, schema type validation (BreadcrumbList row)
- Cat 95, programmatic SEO audit (if 5+ entries)
- Cat 18, thin content

### Surface: /careers, /jobs, /hiring

Adds:
- Cat 32, schema type validation (JobPosting row)

### Surface: /locations, address-in-footer, NAP signals

Adds:
- Cat 79, Local SEO + Google Business Profile (off-site: foundation, then the depth pass once the listing is claimed, then retired-feature dependence)
- Cat 32, schema type validation (LocalBusiness row)
- Cat 96, brand SERP defense (local-flavored)
- Cat 119, Hyper-local landing page completeness (conditional: only when the brand has multi-city coverage detected — `/locations/[city]`, `/{city}-{service}` routes, or 5+ individual city pages)

### Surface: /newsletter, /tools, /free, /templates, /resources, lead-capture forms

Adds:
- Cat 71, lifecycle email
- Cat 123, lead-magnet / free-tool acquisition assets (value exchange, capture hygiene, nurture tie-in, ICP relevance)
- Cat 76, partner & sponsorship program attribution (conditional: only if brand also has a subscriber base or a sponsorship surface — the newsletter-podcast row)

### Content shape: author bylines on content

Adds:
- Cat 32, schema type validation (Person row)
- Cat 84, founder-led brand (conditional)

### Content shape: recipe pages (ingredients + instructions + yield)

Adds:
- Cat 32, schema type validation (Recipe row)

### Content shape: event pages (start dates + locations)

Adds:
- Cat 32, schema type validation (Event row)

### Content shape: book content (ISBN, retailer links, dedicated `/books/`)

Adds:
- Cat 32, schema type validation (Article row; already added if /blog detected)

### Content shape: video embeds, /videos/, /watch/

Adds:
- Cat 30, video sitemap
- Cat 32, schema type validation (VideoObject row)

### Content shape: podcast embeds or /podcast route

Adds:
- Cat 32, schema type validation (VideoObject row; podcasts ride VideoObject in Google's feature surface)
- Cat 76, partner & sponsorship program attribution (conditional: the newsletter-podcast row)

### Entity shape: domain matches a person's name OR hero in first-person singular

Personal-brand entity signal. Adds:
- Cat 32, schema type validation (Person row; already added if other content components present, reinforced)
- Cat 84, founder-led brand
- Cat 96, brand SERP defense (the brand SERP is the person's name; high-stakes)
- Cat 81, market positioning (personal brands often serve multiple audiences without naming one; the wedge itself is generated by calling the Skill tool with "snitch-cmo")

### Entity shape: corporate "we" hero copy AND multiple team members on /about

Organization signal. Adds:
- Cat 32, schema type validation (Organization row; already universal, reinforced)
- Cat 32, schema type validation (Person row for each named team member)
- Cat 81, market positioning (conditional: only if the homepage names 3+ buyer types in one sentence — reported here as umbrella positioning; to choose the wedge, call the Skill tool with "snitch-cmo")
- Cat 124, buying-committee / stakeholder coverage (conditional: only on a B2B / sales-led / considered-purchase motion — demo-gated CTA, "contact sales", enterprise tier, or a security/compliance page detected; skip for single-buyer self-serve)

### Infrastructure: GA4, GTM, or any analytics installed

Adds:
- Cat 53, analytics instrumentation (install, tag manager, event taxonomy, UTM)

Consent gating and server-side/cookieless readiness are not audited here: call the Skill tool with "snitch-adsready".

### Infrastructure: ad pixels installed (any platform)

Adds:
- Cat 66, paid channel presence (channel-level)
- Cat 53, analytics instrumentation (already universal; its UTM pass is reinforced)
- Cat 109, message match audit (conditional: only if active ads detected in transparency centers)

The pixel inventory itself — which pixels fire where, consent gating, CAPI pairing — is not audited here: call the Skill tool with "snitch-adsready".

### Infrastructure: email service installed (Resend, Postmark, etc.)

Adds:
- Cat 61, transactional email inventory & templates (content, rendering, accessibility)
- Cat 63, email deliverability
- Cat 65, email compliance

### Infrastructure: Stripe / commerce payment

Adds:
- Cat 32, schema type validation (SoftwareApplication row, if SaaS)
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
- Cat 82, AI-search citation (already universal; its Layer 1 llms.txt checks are reinforced — format, linked-URL resolution, drift)

### Off-site: any organic social presence

Adds:
- Cat 68, organic social presence
- Cat 75, brand consistency

### Off-site: paid presence (any platform)

Adds:
- Cat 66, paid channel presence (its search side, its social side, or both, per detected platform)
- Cat 53, analytics instrumentation (already universal)
- Cat 109, message match audit
- Cat 76, partner & sponsorship program attribution (conditional: the affiliate-referral row, only if an affiliate program is detected)

### Off-site: community channel (Discord, Slack, subreddit, forum)

Adds:
- Cat 72, community building

### Off-site: PR / press coverage detected

Adds:
- Cat 77, PR launches and press surface

### Off-site: Google Business Profile

Adds:
- Cat 79, Local SEO + GBP (its retired-features pass catches chat CTAs, *.business.site links, and FAQs living in GBP Q&A)

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

When a new cat is added to the catalog, it's mapped here under the components it applies to. If a cat is universally relevant (e.g., a new technical-SEO foundational), add it to the Universal-foundation list at the top. If it's component-specific, add it under the relevant component sections.

## Cross-references

- `references/category-groups.md`, contains the named presets (B2B SaaS, e-commerce, local, publisher, accessibility) which now serve as curated shortcuts rather than the primary recommendation mechanism. Customers who know their shape can pick a named preset directly; the default path is component-detection-driven.
- `references/scan-selection.md`, custom selection picker for power users.
- `references/voice-mapping.md`, internal voice-to-cat mapping (which soul writes the fix prose for each cat).
- SKILL.md STEP 0.8, the detection logic that produces the input to this map.
- SKILL.md STEP 1.5, the synthesizer that turns this map plus STEP 0.8 inventory into the recommended scan.
