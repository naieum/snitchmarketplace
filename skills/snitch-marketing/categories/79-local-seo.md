## CATEGORY 79: Local SEO + Google Business Profile (foundation, depth, retired features)

Applicable only to local businesses (cafe, dentist, plumber, agency with physical address, retail with stores). For pure-online SaaS / e-commerce, **Skip** with reason `not a local business; local SEO not applicable`.

One category, three passes, run in order. **Foundation** asks whether the Google Business Profile exists, is claimed, and agrees with the site (NAP, schema, reviews answered). **Depth** asks whether the claimed listing is actually filled — the boxes GBP exposes, the cadence of activity, the gap against the local leader. **Retired features** asks whether the brand's own surfaces still depend on a GBP feature Google has shut down. Depth is moot on an unclaimed listing, so a Foundation finding of "GBP unclaimed" stops the run there and reports that first.

The thresholds this category needs — review-acquisition cadence and the penalty-risk window, service-radius shape, neighborhood tiers, seasonal rotation, photo geo-data discipline, the operational cadence checklist — live in `references/local-services-playbook.md`. That file is their single home; this category cites it and never restates a number.

### Pre-flight: local relevance check

Determine if the brand is a local business. Signals:
- Physical address on `/contact` or footer
- "Find us" / "Visit us" / "Hours" copy
- Service area mentioned (city, region)
- Industry inherently local (restaurants, services, retail)

If none → **Skip** with reason `not a local business; local SEO categories not applicable`.

### Tooling caveat (applies to every Maps-side step below)

Google Maps and the local SERP are JS-rendered and region-personalized — a plain `Fetch` returns a shell, results differ by the searcher's location, and photo capture metadata is not exposed to any client at all. Use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste or screenshot the listing panels (profile, photos, services, products, posts, competitor listings) and the local-3-pack result, else **Skip-with-reason**. Do not assert listing fields, field counts, photo recency, post cadence, review counts, competitor depth, or a pack position you can't see (Rule 1).

### Evidence required (do not skip, only when local business confirmed)

**Crawl mode, required tool calls:**

1. *Foundation.* Search for the brand on Google Maps. Confirm GBP exists. Capture: name, address, phone, hours, photo count, review count, rating, response rate to reviews.
2. *Foundation.* Check GBP categories (primary + secondary) match the actual business.
3. *Foundation.* Search `"<business name>" "<city>"` and capture the SERP; does the brand appear in the local-3-pack?
4. *Depth (only on a claimed listing).* Capture: service count and services-with-descriptions count, products-section presence + entries, total photo count and the most recent owner-uploaded photo date ("Sourced from owner" tab), last GBP Post date and last 5 Post topics, Q&A answered state, special hours and attributes.
5. *Depth.* Search the primary category in Maps for the brand's service area. Capture the top 3 competitors' GBPs and record the same fields. Compare against the leader, not the average, and report each gap as observed.
6. *Retired features.* Fetch the homepage, `/contact`, and the footer; scan rendered HTML for `business.site` / `negocio.site` links and GBP chat CTAs. Quote the link text + href, or the CTA + selector. Follow any `*.business.site` / `*.negocio.site` link and record the actual response (live, redirect, expired redirect, dead).
7. *Retired features.* Before reporting any feature as retired, confirm its current status in Google Business Profile Help and record the date you checked.

**Source mode, required tool calls:**

1. `Grep` for `LocalBusiness` schema (cross-reference Cat 31, 32). Quote.
2. Check for NAP (name, address, phone) consistency across site footer, contact page, schema. Schema that disagrees with GBP is a NAP finding here, not a depth finding.
3. `Grep` the source for links to `business.site` and `negocio.site` (e.g. `grep -rniE "(business|negocio)\.site"`). Quote each match with file:line. This is the highest-severity retired-feature signal.
4. `Grep` for GBP chat dependence ("Message us on Google", "Chat on Google", embedded GBP messaging widgets, messaging deep-links) and for copy routing core FAQs to GBP Q&A ("ask us on Google", links into the questions panel). Quote with file:line.
5. Check any in-repo automation (scheduled posts, sync scripts) for old Posts / product-post API patterns. Record file:line and the endpoint / format referenced; do not assume an endpoint is dead without verifying its current status.

If a check cannot run (no source access to a given file, automation lives outside the repo), Skip that check with the reason and the path you could not reach. Do not infer dependence you cannot see.

### Known GBP deprecations to check

Each is approximate; verify against Google's current documentation before reporting, and record the date you checked.

- **GBP chat / messaging.** Announced for sunset around July 2024 (approx). A "Message us on Google" CTA or embedded chat widget may now point at a channel that no longer delivers.
- **Google Business "websites" on `*.business.site` / `*.negocio.site`.** The auto-generated Business Profile site builder shut down around early-to-mid 2024, and the temporary redirects to the profile later expired (approx). A brand using one of these as its primary site link is sending customers to a dead or redirect-expired URL.
- **GBP Q&A as the home for core FAQs.** Reported as wound down around late 2025 (approx). Treating GBP Q&A as the canonical home for FAQ content risks that content vanishing with the feature.
- **Old Posts / product-post API patterns.** Legacy Posts API behaviors and product-post formats have changed over time (approx). Automation built on retired endpoints or formats can fail silently.

### Forbidden claims

- "GBP may be unclaimed." Search; quote what's there or what isn't.
- "NAP probably inconsistent." Show where it differs.
- "Service descriptions are probably empty." Open the listing; quote the count of services with descriptions out of total services.
- "GBP Posts are probably stale." Capture the date of the last Post.
- "Competitors probably have more photos." Quote the leader's photo count and the brand's.
- "GBP chat is dead." Name the deprecation, give its approximate date, state that you verified current status against Google's documentation (with the date), and quote the CTA / widget you found. No deprecation claim without that chain.
- "This `business.site` link is broken." Fetch it and record the actual response first. A live or redirecting URL is a different finding from a dead one.

### Detection

Google Maps inspection (foundation fields, depth fields, competitive scan) + on-site NAP and schema audit + on-site grep for retired-feature dependence, each suspect destination fetched for its real response.

### What to Search For

On-site:
- Address patterns (street, city, ZIP), phone-number patterns
- `LocalBusiness` schema
- "Hours", "Visit", "Find us", "Address"
- Links to `business.site` or `negocio.site`, especially as the primary site link or in footer / nav
- "Message us on Google" / "Chat on Google" CTAs, embedded GBP messaging widgets
- Copy routing core FAQ content to GBP Q&A as its canonical home
- Automation or scripts built on old Posts / product-post API patterns; leftover "powered by Google" auto-site badges

On the profile (per the tooling caveat):
- Service list with per-service description count (0/N empty vs N/N filled)
- Products section presence; entries with name + description + photo + price
- Photo total, owner-uploaded recency, customer-contributed share
- Posts: most recent date, last 5 topics, frequency over 90 days
- Review count + rating, response rate, response latency; Q&A answered state
- The same fields on the top 3 competitor listings, and which boxes the leader fills that the brand leaves empty

### Actually Hurts the Marketing Surface

**Foundation**

- **GBP not claimed**. Evidence required: Maps search returning an unmanaged listing.
- **NAP inconsistent** across site footer, contact page, schema, GBP, third-party directories. Evidence required: each location's NAP quoted.
- **No `LocalBusiness` schema on site**. Evidence required: source / HTML scan.
- **Reviews unanswered** (visible reviews without owner response). Evidence required: profile inspection.
- **Business missing from key local directories** (Yelp, Apple Maps, Bing Places). Evidence required: directory search.
- **Apple Maps place card unclaimed or thin** (no owner claim in Apple's business console, missing hours / photos / actions). An unclaimed card forfeits Maps, Siri, Wallet, and Spotlight presence. Apple has consolidated its business tooling and has been rolling out a Maps ad surface that a claimed place card gates; the console name, the rollout markets and the dates move, so confirm the current state at Apple's own business site before stating any of it in a Finding. Evidence required: Apple Maps place lookup; claim state confirmed by the user if not externally visible.
- **Brand absent from the local-3-pack** for the primary category + city query. Evidence required: SERP screenshot or quoted result.

**Depth**

- **Service description boxes empty on most listed services.** The searcher gets a bare service name where the competitor gets a sentence. Evidence required: services list quoted with description status per service.
- **Products section absent on a service business that could use it.** A larger SERP footprint forfeited. Evidence required: quoted absence + the business model that justifies the surface.
- **Photo set stale or stock** (no owner-uploaded photo in months, or the whole set is generic stock on a visual trade). Evidence required: the "Sourced from owner" tab's most recent date stamp. Never assert EXIF geo-data: it is not exposed to a non-browser client and is not a local ranking input.
- **Posts dormant or absent.** A listing whose last post is a year old reads as a closed business. Their ranking effect is not established, so keep post findings advisory. Evidence required: last Post date, or the Posts tab quoted as empty.
- **The leader's listing is filled where the brand's is empty** (reviews, photos, services, products). The finding reports both numbers; any fixed "beat them by N%" target is invented. Evidence required: competitor name + field value + brand's value.
- **Q&A section unanswered.** Customer questions visible without an owner response. Evidence required: Q&A tab quoted with unanswered entries.

**Retired features**

- **A `*.business.site` / `*.negocio.site` URL used as the primary or site link.** Customers are sent to a destination that is dead or whose redirect has expired. Evidence required: the link file:line or href + the actual fetched response + the Help status check with date.
- **A GBP chat / "Message on Google" CTA.** The CTA points customers at a messaging channel Google has sunset, so the message may never arrive. Evidence required: the CTA text + selector or file:line + the deprecation named with its approximate date and the verification date.
- **Core FAQs depending on GBP Q&A.** The canonical home for FAQ answers sits inside a feature being wound down, on someone else's surface. Evidence required: the on-site reference routing users to GBP Q&A + verification of the feature's current status.
- **Automation built on retired Posts / product-post API patterns.** Scheduled local content can fail silently. Evidence required: the script file:line + the endpoint / format referenced + its current status per Google's documentation.

### NOT a Problem

- Pure-online business (not local). Skip via pre-flight.
- Service-area business (no storefront) with proper "service-area" GBP setup, and no storefront photos — audit job-site / crew / finished-work shots instead.
- A listing under 90 days old with limited photos and posts. Build over time; Low advisory, not High.
- B2B-only businesses where Maps is a secondary channel, or categories where Posts see little engagement. Keep the checks, lower the severity.
- A standard Google Maps embed (place embed, directions iframe) and a working profile link (`g.page`, `maps.app.goo.gl`, a Maps place URL that resolves). Neither is a retired feature.
- A real first-party website on the brand's own domain; a GBP that still shows a Q&A panel the brand does not depend on.
- A feature you suspect is retired but cannot confirm against Google's current documentation. Skip with reason rather than reporting an unverified deprecation.

### Context Check

1. Is the business actually local or pure-online? Service-area or storefront?
2. Is the listing claimed, and has it been operated for at least 90 days? Newer listings have legitimate depth gaps.
3. Is there a review-ask process, and does it ask every customer? (Selectively soliciting only positive reviewers, or gating the ask behind a sentiment check, violates Google policy and the FTC rule — detection patterns and the compliant funnel live in Cat 74; the timing window and cadence live in `references/local-services-playbook.md`.)
4. Is the team responding to reviews, and does it have the capacity to sustain a Post cadence? If not, recommend the cadence it can hold rather than the one the playbook describes as ideal.
5. Are there top-3 competitors with claimed listings in the same service area? If the competitive set is sparse, compare against the strongest listing in an adjacent market and say in the Finding which listing the comparison used.
6. Do the GBP service area, the on-site service-area copy, and any paid-ads geographic targeting describe the same footprint? Mismatched radii leak budget against an inconsistent footprint; the radius shape itself is in `references/local-services-playbook.md`.
7. Is the business in a category where Local Service Ads gate the local-3-pack (HVAC, plumbing, electrical, locksmith, attorneys)? Flag LSA enrollment as a separate recommendation.
8. For each suspected retired feature: what is its current status per Google Business Profile Help, and on what date did you check? Does any customer-facing CTA route to a sunset channel with no working fallback?

### Pairs with other categories

- **Cat 119 (Hyper-local landing pages)** — for brands with multi-city coverage, the on-site city / neighborhood pages compound with GBP signals. This category audits the profile; Cat 119 audits the on-site mirror.
- **Cat 31 / Cat 32 (JSON-LD presence, schema type validation)** — `LocalBusiness` schema on-site should mirror the profile's categories and NAP.
- **Cat 96 (Brand SERP defense)** — the local-3-pack appearance for brand-name + city queries is also a brand SERP concern.
- **Cat 74 (Customer feedback)** — review acquisition flow feeds the review checks here; route review-strategy fixes there.
- **Cat 117 (Site copy lint)** — GBP service descriptions and Posts follow the same vague-adjective / unsupported-superlative rules as site copy.

### Reference

Google Business Profile help: https://support.google.com/business/ — the authority on which fields exist, what their limits are, and which features are current. Confirm a field, a character cap, a ranking effect, or a deprecation here before writing the Finding; deprecation dates shift, so treat the approximate dates above as pointers, not settled fact.

`references/local-services-playbook.md` — the single home for review-acquisition cadence and the penalty-risk window, service-radius shape, neighborhood tiers, seasonal rotation, photo geo-data discipline, and the operational cadence checklist. Any threshold this category needs comes from there.

**Severity tagging:**
- GBP unclaimed → Critical (lost local-pack visibility).
- Brand absent from the local-3-pack on primary category + city → Critical for storefront brands.
- NAP inconsistency → High.
- No `LocalBusiness` schema → High.
- A `*.business.site` / `*.negocio.site` URL used as the primary or site link → High (dead or redirect-expired destination for real customers).
- Service descriptions empty on most services → Medium (High with 5+ services and active competitors).
- Products section absent when the business model supports it → Medium.
- Reviews unanswered → Medium. Q&A unanswered → Medium.
- Missing from key local directories → Medium.
- No Posts ever → Medium; no Post in the last 30 days → Low (advisory).
- Photo set stale or stock → Low (Medium for visual trades). Never emit a finding about EXIF geo-data.
- Leader's listing filled where the brand's is empty → Medium on reviews, Low on photos; quote both numbers.
- A "Message on Google" / GBP-chat CTA → Medium (sends customers to a sunset channel).
- Core FAQs depending on GBP Q&A → Medium. Automation on retired Posts / product-post patterns → Medium.
- A minor or legacy reference to a retired feature with no customer-facing impact → Low (cleanup).
- Service-radius mismatch across GBP / on-site / paid-ads targeting → Medium.

**Fix voice:** `solutions-architect` (primary) | `analytics-engineer` (backup, when the fix is the depth or automation pass).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Claim the GBP. Verify the listing (postcard / phone / video). Complete every field: name, address, phone, hours, primary category, secondary categories, services / products, photos, opening / closing photos.
>
> Then standardize NAP across every surface:
> - Site footer
> - `/contact` page
> - `LocalBusiness` JSON-LD on the homepage
> - GBP
> - Apple Maps via Apple Business (business.apple.com) — claim the place card, fill hours / photos / actions; it feeds Siri and Spotlight too, and it's the prerequisite for Apple Maps ads
> - Yelp, Bing Places, Yellow Pages
>
> Same exact spelling, same address format, same phone format. Inconsistencies confuse Google's local algorithm and dilute the listing's authority. Reply to every review; the response rate is part of how the local algorithm reads an operated listing.
>
> With the foundation in place, walk the listing field by field. Each listed service gets a description in the box GBP gives you: what the service does + the service area + a specific detail competitors don't mention. "Sod install in Carrollton, Plano, and Frisco. We grade for drainage before the first roll goes down so the lawn doesn't pool after a storm." A searcher comparing three listings reads that sentence; an empty box gives them nothing to read. Local services use the Products section as the menu — each service becomes an entry with a name, a paragraph, a real job photo, and a starting price. Photos: real ones from the job site, added a few at a time rather than dumped at setup. Geotags do nothing for ranking; a recent photo of finished work does, because it is what the searcher looks at before calling. Posts: hold whatever cadence the team can actually sustain, per the playbook, and stop the tab reading as dormant.
>
> Then clear the retired features, worst first. Fetch the `business.site` URL and record what it returns; if it's dead or the redirect has expired, repoint it to the brand's own domain in the footer, nav, contact page and `LocalBusiness` schema, then confirm the new destination resolves. Replace the "Message on Google" CTA with a contact path you can instrument — a phone link, a form with a submit event, email. Move any FAQ content that only exists in GBP Q&A onto the brand's own page, and let the profile point at it rather than hold it. Confirm each endpoint your automation calls against current documentation before touching it; a job failing silently makes its "posts published" number fiction.
>
> Verify: re-fetch every link you repointed, re-check each feature's status on the date you ship, and keep that date in the record.
