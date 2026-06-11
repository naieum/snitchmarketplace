## CATEGORY 118: Google Business Profile depth audit (fill-every-field discipline)

Cat 79 audits whether the Google Business Profile exists, is claimed, has NAP consistency, and gets review responses. That's the surface pass. Most local businesses leave 60-80% of GBP's surface area unused: the service description boxes are empty, the Products section is treated as e-commerce-only (it's not), photos lack geo-tagging, the weekly post cadence is dormant, and the listing loses ranking to competitors who fill every field.

This category audits the depth: every box GBP exposes, the cadence of activity, and the competitive position relative to the top 3-5 local rivals.

### Pre-flight: relevance check

Applicable only to local businesses (storefront or service-area) with a Google Business Profile. If Cat 79's pre-flight returned "not a local business; skip", this category also skips with the same reason.

If the business is local but GBP is unclaimed, the depth audit is moot. Route to Cat 79's "GBP unclaimed → Critical" finding first; this category waits for a claimed listing to audit.

### The 5-layer depth audit

| Layer | What it audits | Why it matters |
|---|---|---|
| **1. Service description boxes** | Each listed service has a 300-character description filled with keyword + city + service-area suburbs | Hidden ranking signal; Google's local algorithm reads service descriptions for query matching |
| **2. Products section as services menu** | Service businesses can list services as "products" with name, description, photo, and starting price | Most local businesses skip this entirely; competitors who use it earn a larger SERP footprint |
| **3. Photo geo-data + cadence** | Photos uploaded with intact EXIF lat/long (taken from the job site or storefront), 10+ per quarter | Photos with geo-data signal "real work in real places"; stripped EXIF (e.g., uploaded via web admin) loses the signal |
| **4. Post cadence** | Weekly GBP Posts (offers, updates, events) | Active listings rank higher than dormant ones; weekly is the minimum signal of "real business" |
| **5. Competitive depth gap** | Brand's GBP fields vs top 3 local competitors on the primary category | Out-do the top competitor by 25% on reviews, photo count, post cadence, and service-description completeness |

### Evidence required (do not skip)

**Crawl mode, required tool calls:**

1. Open the brand's GBP via Google Maps. Capture: total photo count, photos-with-geo-tags (sample 10; check Maps' "Sourced from owner" tab for EXIF presence), service count, services-with-descriptions count, products-section presence + entries, last GBP Post date, last 5 GBP Post topics, response rate to reviews (visible on the listing).
2. Search the primary category in Google Maps for the brand's service area. Capture the top 3 competitors' GBPs. For each, record the same fields above.
3. Compare brand's numbers to the top competitor (not the average — the leader). Compute the depth gap per field.
4. Test the primary category's local-3-pack query. Capture brand's position; quote what the competitors rank with.

**Source mode:**

GBP itself is not on-site. Source mode contributes context only — confirm `LocalBusiness` schema on the site mirrors GBP categories + NAP exactly (cross-reference Cat 79 + Cat 31). If schema disagrees with GBP, that's a Cat 79 NAP-inconsistency finding, not this category.

### Forbidden claims

- "Service descriptions are probably empty." Open the listing; quote the count of services with descriptions out of total services.
- "Photo cadence is probably low." Capture the upload date on the most recent 10 photos.
- "GBP Posts are probably stale." Capture the date of the last Post.
- "Competitors probably have more photos." Quote the leader's photo count + the brand's.

### Detection

Google Maps inspection + competitive scan.

### What to search for

Per the brand's GBP:

- Service list with per-service description count (0/N empty vs N/N filled)
- Products section presence; product entries with name + description + photo + price
- Photo total count, recent-upload count (last 90 days), geo-tagged subset (Maps shows EXIF when present)
- GBP Posts: most recent date, last 5 topics, frequency over 90 days
- Review count + rating; response rate; average response latency
- Special hours, attributes (wheelchair accessible, payment methods accepted, etc.), Q&A section answered

Per top 3 competitor GBPs:

- Same fields as above
- Specifically: where the competitor's depth exceeds the brand's by >25%

### Actually hurts the marketing surface

- **Service description boxes empty on >50% of listed services.** Hidden ranking signal forfeited. Critical for businesses with 5+ services.
  - Evidence required: services list quoted with description-status per service.
- **Products section absent on a service business that could use it.** Larger SERP footprint forfeited. High.
  - Evidence required: GBP screenshot or quoted absence + business model justifying the surface (service business with itemized services / prices).
- **Photos all uploaded via web admin (no EXIF geo-data).** Signals "stock photos / not on location"; loses authenticity weight. Medium to High depending on business type (high for visual trades — landscaping, construction, food service).
  - Evidence required: sample 5 recent photos; quote the "Sourced from owner" date stamp vs photo metadata indicating capture location.
- **No GBP Post in the last 30 days.** Listing reads as dormant. Medium.
  - Evidence required: last Post date.
- **No GBP Posts ever.** Critical signal of an unmaintained listing. High.
  - Evidence required: Posts tab quoted as empty.
- **Top competitor exceeds brand on reviews by >25%.** Local-3-pack visibility at risk. High.
  - Evidence required: competitor name + review count + brand's review count + delta calculation.
- **Top competitor exceeds brand on photo count by >25%.** Same risk. Medium.
  - Evidence required: same shape.
- **Q&A section unanswered.** Customer questions left visible without owner response signal absence. Medium.
  - Evidence required: Q&A tab quoted with unanswered entries.
- **Brand absent from the local-3-pack for the primary category + city query.** Critical for storefront brands; revenue-impacting.
  - Evidence required: SERP screenshot or quoted result.

### NOT a problem

- New listings <90 days old with limited photos and posts. Build over time; flag as Low advisory, not High.
- Service-area businesses with no storefront photos (correct configuration); audit photos for job-site / crew / finished-work shots instead.
- B2B-only businesses where GBP is secondary — most B2B leads don't come through Maps. Lower severities accordingly.
- Industries where GBP Posts have low engagement (e.g., professional services where customers don't browse Posts) — keep the cadence audit but lower severity to Low.

### Context check

1. Has the brand been claiming and operating GBP for at least 90 days? Newer listings have legitimate depth gaps.
2. What's the brand's business model — storefront, service-area, or hybrid? Audit shape changes per model.
3. Does the brand have the operational capacity to maintain weekly GBP Posts? If not, recommend monthly cadence first (still better than dormant).
4. Are there top 3 competitors with claimed GBPs in the same service area? If the competitive set is sparse, the 25% out-do rule becomes "match or exceed the highest-quality competitor in an adjacent market."
5. Is the business in a category where Google has Local Service Ads gating the local-3-pack? Some categories (HVAC, plumbing, electrical, locksmith, attorneys) require LSA enrollment for full local visibility — flag as a separate recommendation.

### Pairs with other categories

- **Cat 79 (Local SEO / GBP)** — Cat 79 audits "is GBP claimed and NAP-consistent?" This category audits "is GBP filled at depth?" Run Cat 79 first; if findings include unclaimed or inconsistent NAP, fix those before depth.
- **Cat 31 (JSON-LD presence)** — `LocalBusiness` schema on-site should mirror GBP fields. Discrepancies route to Cat 79; depth gaps inside GBP route here.
- **Cat 96 (Brand SERP defense)** — the local-3-pack appearance for brand-name + city queries is a brand SERP concern; cross-reference.
- **Cat 74 (Customer feedback)** — review acquisition flow affects this category's "reviews exceed competitor" check; route review-strategy fixes there.
- **Cat 117 (Site copy lint)** — GBP service descriptions and Posts should follow the same vague-adjective / unsupported-superlative rules as site copy; cross-reference the lint patterns.

### Severity tagging

- Service descriptions empty on >50% of services → High (Critical for businesses with 5+ services and active competitors).
- Products section absent when business model supports it → High.
- No GBP Posts ever → High.
- No GBP Post in 30 days → Medium.
- Photos missing EXIF geo-data → Medium (High for visual trades).
- Competitive depth gap >25% on reviews or photos → High.
- Brand absent from local-3-pack on primary category + city → Critical (for storefront brands).
- Q&A unanswered → Medium.

### Fix voice

`analytics-engineer` (primary) | `solutions-architect` (backup).

The fix is fill-every-field discipline. Each box GBP exposes is a chance to declare a signal Google's local algorithm uses. The voice for this is operational, not creative — the recommendation is the literal list of fields and the literal copy pattern that goes in each one.

Internal rule: never name the practitioner in the fix prose (per `references/voiced-remediations.md`).

### Worked fix example

> The listing has 60% of its surface area unused. Walk it field by field this week.
>
> Services. Each listed service gets a 300-character description in the box GBP gives you. The pattern: what the service does + the service area (city + adjacent suburbs) + a specific feature that competitors don't mention. "Sod install in Carrollton, Plano, and Frisco. We grade for drainage before the first roll goes down so the lawn doesn't pool after a storm." That description is read by Google's local algorithm for query matching; leaving it blank forfeits the signal.
>
> Products section. Local services use this as the menu. Each service becomes a "product" with a name, a one-paragraph description, a real photo from a job, and a starting price (or "from $X"). Most competitors skip this; the visible SERP card for businesses that use it is roughly twice the size of those that don't.
>
> Photos. Upload from the phone that took them. Web-admin uploads strip EXIF; phone uploads preserve it. Ten photos per quarter, taken at the job site or storefront, with the geo-data intact. The metadata is invisible to humans and load-bearing for Google.
>
> Posts. Weekly. The post can be a 30-second offer ("free brown-patch inspection through July 4"), an update ("crew just finished a 4,000-sqft sod install in Frisco"), or an event ("free yard consultation Saturday in Plano"). Topic doesn't matter as much as cadence. Dormant Posts tabs signal dormant business.
>
> Then look at the top three competitors. The leader on reviews + photos + posts is the bar. Match within 90 days; out-do within 180. The local-3-pack is a ranked position — every field GBP gives you is a chance to take a position the competitor left empty.

Read `references/local-services-playbook.md` for the broader local-services context this cat sits inside.
