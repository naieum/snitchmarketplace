## CATEGORY 119: Hyper-local landing page completeness

For service businesses with city or neighborhood coverage, the landing pages targeting "{service} in {city}" or "{service} {neighborhood}" queries are the ones that actually win local-pack and organic-3-pack visibility. Most teams ship a single "Service Areas" page listing 30 cities and call it done; that's a thin-content finding (cross-reference Cat 18) and a wasted opportunity. The category audits whether each city / neighborhood landing page is substantive enough to rank for the queries it targets.

Distinct from Cat 79 (does the GBP exist + is NAP consistent) and Cat 118 (is GBP filled at depth) — those are off-site (Google's surface). This category is on-site: the brand's own pages that compound with GBP signals.

### Pre-flight: relevance check

Applicable when the brand's component inventory (STEP 0.8) includes a local-business surface (footer NAP, address, /locations, /find-us route, "Serving {city}" copy on homepage) AND a routes/pages directory shape suggesting city or neighborhood landing pages (e.g., `/locations/[city]`, `/{city}-{service}`, `/service-areas/{city}`, or 5+ individual city pages).

Pure-online businesses skip with reason `no local-business surface detected; hyper-local pages not applicable`. Service-area businesses without per-city pages get a "build them" recommendation rather than a depth audit; see the "no pages exist" branch below.

### The 6-element completeness rubric

Each city / neighborhood landing page is scored against six elements. A page missing 3+ elements is a thin-content finding regardless of word count.

| Element | What the page must include | Why it matters |
|---|---|---|
| **1. Named landmarks** | At least 2-3 specific places, streets, parks, or districts within the city (not just the city name) | Signals "we actually work here"; reads as authentic to local searchers; helps Google disambiguate which city named "Springfield" you mean |
| **2. Neighborhood-tagged photos** | Photos of work performed in the named city / neighborhood, captioned with the location | "Real work in real places" signal; thin-content pages with stock photography fail this check |
| **3. Embedded map** | An interactive map or static-map image showing the service area for this specific city | Visual confirmation of service radius; UX win; reads as legitimate to first-time visitors |
| **4. LocalBusiness schema with coordinates** | JSON-LD with `@type: LocalBusiness` (or sub-type), `address` with this city's `addressLocality`, `geo` with `latitude`/`longitude` for the page's targeted location | Search-engine-readable affirmation that this page represents service in this specific location |
| **5. City-specific testimonials or case studies** | At least 1-3 named customer quotes or case studies from this city | Local proof; generic site-wide testimonials don't count |
| **6. Internal links to/from a hub** | A "Service Areas" hub page that links to each city page, AND each city page links back to the hub + to 2-3 adjacent city pages | Distributes link equity; signals topical authority on "service in [region]" |

### Evidence required (do not skip)

**Source mode:**

1. Identify the city / neighborhood landing pages. Glob `**/locations/**`, `**/cities/**`, `**/{city}-{service}.{ext}`, `**/service-areas/**`, or scan the routes directory for parameterized city routes (`[city]`, `:city`, `$city`).
2. For each detected page (up to 10 in a single audit pass; report the count if more), `Read` the page source. Check each of the 6 elements above. Quote evidence per element (the landmark mention, the photo with caption, the schema block, the testimonial, the internal-link source).
3. Identify the "Service Areas" hub. Confirm it exists at one URL, lists all city pages, and links to each.

**Crawl mode:**

1. Fetch the brand's sitemap.xml. Filter for city / neighborhood URLs.
2. Sample up to 10 pages. `Fetch` each. Extract rendered text + linked images + JSON-LD blocks. Run the 6-element check.
3. Test 2-3 "{service} in {city}" Google queries the page targets. Capture whether the brand's page ranks; quote the SERP position.

### Forbidden claims

- "The page is probably thin." Read it; count words and named landmarks specifically.
- "Schema is probably missing." Quote the JSON-LD block or quote its absence.
- "Photos are probably stock." Open the image; check filename / EXIF / Reverse-Image search if doubtful.
- "Testimonials probably aren't local." Read them; check whether the customer's location is named.

### Detection

Sitemap inspection + per-page rubric scoring.

### What to search for

Per city / neighborhood page:

- City name in `<h1>`, page title, meta description, and URL slug
- Named landmarks (street names, parks, malls, schools, districts) in body copy
- Image alt text or captions mentioning the city / neighborhood
- Embedded map iframe (Google Maps, Mapbox, custom)
- JSON-LD with `@type: LocalBusiness` (or sub-types: `HomeAndConstructionBusiness`, `Plumber`, `Electrician`, `LawnService`, etc.) + `address.addressLocality` matching the page's city + `geo.latitude` / `geo.longitude`
- Testimonial blocks with customer name + city / neighborhood / address
- Internal links pointing TO the hub page; internal links FROM the hub page TO this city
- Internal links to 2-3 adjacent city pages ("Also serving [Plano], [Frisco], [Carrollton]")

### Actually hurts the marketing surface

- **City landing page lists the city in the H1 but the body copy doesn't mention a single landmark, street, district, or neighborhood.** Thin-content finding; reads as templated. Critical.
  - Evidence required: H1 quoted + body content quoted + landmark count = 0.
- **All photos on city pages are stock photography or reused across every city.** Critical for visual trades; High for everything else.
  - Evidence required: image URL + filename + matching identical image across 3+ city pages.
- **No `LocalBusiness` schema on city pages, or schema lacks `geo.latitude` / `geo.longitude`.** Search-engine-readable proof of local presence forfeited. High.
  - Evidence required: page HTML quoted; schema block absent or incomplete.
- **No embedded map.** Lower-severity UX miss. Medium.
  - Evidence required: page content scan showing no `<iframe>` from a map provider and no static map image.
- **No city-specific testimonials; only site-wide generic testimonials reused.** Trust artifact gap (cross-reference Cat 111). Medium to High.
  - Evidence required: testimonial block content + missing city / customer-location attribution.
- **No "Service Areas" hub page, or hub doesn't link to city pages.** Topical authority not consolidated; link equity scattered. High.
  - Evidence required: site search for hub page; if found, quote outbound link inventory; if absent, note.
- **City pages don't internally link to adjacent cities.** Missed cluster-building opportunity. Medium.
  - Evidence required: outbound link inventory per page.
- **One "Service Areas" page lists 30+ cities as a flat list with no individual pages.** Thin-content + missed-opportunity finding rolled into one. Critical for any business with >5 active service cities.
  - Evidence required: the consolidated page content quoted; individual city page count = 0.
- **City pages exist but rank nowhere in the local-3-pack or organic top 10 for "{service} {city}" queries.** May indicate completeness issues OR competitive saturation; route to context check before tagging severity.
  - Evidence required: query + SERP for the targeted query.

### NOT a problem

- Brand with <5 service cities — the audit pattern is still valuable but the volume is small; lower the per-element severity and treat any present page as a starting point.
- Brands with a "Service Areas" hub that lists ALL cities and links each to a deep page; the hub is fine, the per-city depth is what matters.
- Pages that pass 5/6 of the rubric and miss one specific element (e.g., schema in place, photos local, landmarks named, hub linked, testimonials present, but no embedded map) — flag the gap as Low advisory rather than High.
- Brands intentionally consolidating service areas under a regional hub (e.g., "DFW Metroplex" rather than per-city) when the regional positioning is strategic — flag the trade-off rather than the omission.

### Context check

1. How many service cities does the brand actually serve? <5 = build per-city pages as they grow; 5-15 = build all of them now; >15 = prioritize the top revenue cities first.
2. Does the brand have one local case study per city, or do they reuse the same 3 customers across every page? If reuse, the testimonial element fails for all pages.
3. Is the brand's positioning regional or local? "Serving the DFW Metroplex" is a regional positioning; per-city pages still help but the hub matters more.
4. Are competitors ranking with deep city pages? If yes, this audit is high-leverage. If no, brand can win with thinner pages; lower severity per element.
5. Does the brand have operational capacity to maintain pages with quarterly photo refreshes? If not, recommend annual refresh cadence to avoid pages going stale.

### Pairs with other categories

- **Cat 18 (Thin content)** — flat "Service Areas" pages with no depth are thin-content findings; this category gives them the depth rubric to fix against.
- **Cat 31 (JSON-LD presence)** + **Cat 37 (Organization / WebSite schema)** — schema presence is universal; this category audits whether `LocalBusiness` schema appears on city-specific pages with coordinates.
- **Cat 79 (Local SEO / GBP)** — off-site local visibility. City pages compound with GBP; broken GBP can't be saved by perfect city pages, and vice versa.
- **Cat 118 (GBP depth audit)** — sister local-services cat; run both for a complete local-services audit.
- **Cat 74 (Customer feedback)** — testimonial inventory feeds the city-specific testimonial element.
- **Cat 19 (Internal link graph)** — the hub-and-spoke structure is an internal-linking pattern; cross-reference.
- **Cat 86 (Keyword research)** — "{service} {city}" query mapping informs which city pages to prioritize.

### Severity tagging

- City pages exist but don't mention a single landmark / street / district → Critical (thin templated content).
- All stock photography across city pages → Critical for visual trades; High otherwise.
- No `LocalBusiness` schema on city pages → High.
- Schema present but missing `geo` coordinates → Medium.
- No "Service Areas" hub OR hub doesn't link to per-city pages → High.
- No internal links between adjacent city pages → Medium.
- No city-specific testimonials → Medium (High when other trust artifacts also weak per Cat 111).
- One flat "Service Areas" page with 30+ cities and no individual pages → Critical (Cat 18 + this combined).
- No embedded map on city pages → Low (UX advisory).

### Fix voice

`jen-simmons` (primary) | `analytics-engineer` (backup).

The fix is semantic and structural: each city page declares "this is the page for service in this specific city" through every available signal — markup, schema, internal links, content. Jen's intrinsic-web POV applied to local pages.

Internal rule: never name the practitioner in the fix prose (per `references/voiced-remediations.md`).

### Worked fix example

> The page exists, ranks for nothing, and reads like a template because it is one. Six elements close the gap.
>
> Landmarks. Pick two or three places a real customer in this city would know. Specific streets, the local park, the high school, the mall, the freeway exit. Not "the heart of Frisco" — the actual streets. The page proves it's about THIS city by naming the city's geography.
>
> Photos. From real jobs in this city. The photo file gets a descriptive name (`carrollton-front-yard-sod.jpg`, not `IMG_4392.jpg`). The alt text and caption name the location. Stock photography on a city page is the page's first credibility loss.
>
> Map. One embed, showing the service radius. Google Maps embed is free. The map's job is to confirm at a glance that this city is in the service area; it doesn't need to be fancy.
>
> Schema. `LocalBusiness` JSON-LD on each city page with the city in `address.addressLocality` and explicit `geo.latitude` / `geo.longitude` for a real point in the city (the centroid, the office, or a representative job site). Schema is the page's machine-readable declaration that the city page is about the city it names.
>
> ```jsonld
> {
>   "@context": "https://schema.org",
>   "@type": "LawnService",
>   "name": "Loera's Landscaping — Carrollton",
>   "address": {
>     "@type": "PostalAddress",
>     "addressLocality": "Carrollton",
>     "addressRegion": "TX",
>     "postalCode": "75007"
>   },
>   "geo": {
>     "@type": "GeoCoordinates",
>     "latitude": 32.9756,
>     "longitude": -96.8900
>   }
> }
> ```
>
> Testimonials. One named customer per city, with the city named in the attribution. "Jane R., Plano homeowner." Reusing the same site-wide testimonial set across every city page fails this element on every page at once.
>
> Hub-and-spoke. One Service Areas hub page lists every city, links to each. Each city page links back to the hub and to two or three adjacent cities ("Also serving Plano and Frisco"). The link graph compounds the topical authority; the hub becomes the authoritative source for "service in this region."
>
> Then check the SERP. If after the fix the page still ranks nowhere for "{service} {city}", the page is fine and the competitive gap is the lever — that's a GBP depth play (Cat 118), not a content rebuild.

Read `references/local-services-playbook.md` for the broader local-services context and the prioritization rules (which cities to build first, how to budget photographer time, how to source local testimonials).
