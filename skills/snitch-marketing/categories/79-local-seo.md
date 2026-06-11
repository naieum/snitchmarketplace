## CATEGORY 79: Local SEO + Google Business Profile

Applicable only to local businesses (cafe, dentist, plumber, agency with physical address, retail with stores). For pure-online SaaS / e-commerce, **Skip** with reason `not a local business; local SEO not applicable`.

### Pre-flight: local relevance check

Determine if the brand is a local business. Signals:
- Physical address on `/contact` or footer
- "Find us" / "Visit us" / "Hours" copy
- Service area mentioned (city, region)
- Industry inherently local (restaurants, services, retail)

If none → **Skip** with reason `not a local business; local SEO categories not applicable`.

### Evidence required (do not skip, only when local business confirmed)

**Crawl mode, required tool calls:**

1. Search for the brand on Google Maps. Confirm GBP exists. Capture: name, address, phone, hours, photo count, review count, rating, response rate to reviews.
2. Check GBP categories (primary + secondary) match the actual business.
3. Search `"<business name>" "<city>"` and capture the SERP, does the brand appear in the local-3-pack?

**Source mode, required tool calls:**

1. `Grep` for `LocalBusiness` schema (cross-reference Cat 31, 37). Quote.
2. Check for NAP (name, address, phone) consistency across site footer, contact page, schema.

### Forbidden claims

- "GBP may be unclaimed." Search; quote what's there or what isn't.
- "NAP probably inconsistent." Show where it differs.

### Detection

Google Maps + on-site NAP audit + schema check.

### What to Search For

- Address patterns (street, city, ZIP)
- Phone-number patterns
- `LocalBusiness` schema
- "Hours", "Visit", "Find us", "Address"

### Actually Hurts the Marketing Surface

- **GBP not claimed**.
  Evidence required: Google Maps search returning unmanaged listing.
- **GBP claimed but incomplete** (no photos, no hours, no description).
  Evidence required: GBP profile inspection.
- **NAP inconsistent** across site footer, contact page, GBP, third-party directories.
  Evidence required: each location's NAP quoted.
- **No `LocalBusiness` schema on site**.
  Evidence required: source / HTML scan.
- **Reviews unanswered** (visible reviews on GBP without owner response).
  Evidence required: GBP profile inspection.
- **Business missing from key local directories** (Yelp, Apple Maps, Bing Places).
  Evidence required: directory search.

### NOT a Problem

- Pure-online business (not local). Skip via pre-flight.
- Service-area business (no storefront) with proper "service-area" GBP setup. Acceptable.
- Recently-claimed GBP without all photos yet. Build over time.

### Context Check

1. Is the business actually local or pure-online?
2. Service-area or storefront?
3. Is there a process to ask happy customers for GBP reviews?
4. Is the team responding to reviews within 24-48 hours?

### Pairs with Cat 118 (GBP depth audit) and Cat 119 (Hyper-local landing pages)

This category is the foundation pass — is GBP claimed, is NAP consistent, are reviews getting responses? Two other categories extend it:

- **Cat 118 (GBP depth audit)** — fill-every-field discipline (300-char service descriptions, Products section as services menu, EXIF geo-data on photos, weekly Post cadence, the 25%-out-do-competitors rule on reviews / photos / posts). Run Cat 118 after Cat 79 confirms the foundation is in place; trying to fill GBP at depth on an unclaimed or NAP-inconsistent listing wastes effort until those fixes ship first.
- **Cat 119 (Hyper-local landing pages)** — for brands with multi-city coverage, the on-site city / neighborhood pages compound with GBP signals. Cat 79 audits GBP; Cat 119 audits the on-site mirror.

The full local-services context — service-radius targeting, neighborhood tiers (Tier 1 prove-out / Tier 2 expansion / Tier 3 aspirational), seasonal rotation, review acquisition timing (the 2-hour-post-visit window vs the on-site penalty risk), community-platform presence — lives in `references/local-services-playbook.md`. Load that playbook when the audit produces multiple local-SEO findings; the prioritization rules there decide which fix ships first.

### Service-radius targeting baseline

The conventional default service radius for home services is roughly 30 minutes' drive-time from the brand's base. Refine by cost-to-serve (some services tolerate 45-minute radii; others need 20-minute radii for crew efficiency) and by competitive intensity (sometimes the highest-leverage expansion is a less-contested adjacent area, not the home market). Audit application: confirm the brand's GBP service area setting, on-site service-area copy, and paid-ads geographic targeting all describe the same radius. Mismatched radii leak budget against an inconsistent footprint.

### Reference

Google Business Profile help: https://support.google.com/business/

Local SEO guide (Moz): https://moz.com/learn/seo/local

`references/local-services-playbook.md` (full local-services context)

**Severity tagging:**
- GBP unclaimed → Critical (lost local-pack visibility).
- NAP inconsistency → High.
- No `LocalBusiness` schema → High.
- Reviews unanswered → Medium.
- Missing from key local directories → Medium.
- Service-radius mismatch across GBP / on-site / paid-ads targeting → Medium.

**Fix voice:** `solutions-architect` (primary) | `mike-monteiro` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Claim the GBP. Verify the listing (postcard / phone / video). Complete every field: name, address, phone, hours, primary category, secondary categories, services / products, photos (10+), opening / closing photos.
>
> Then standardize NAP across every surface:
> - Site footer
> - `/contact` page
> - `LocalBusiness` JSON-LD on the homepage
> - GBP
> - Yelp, Apple Maps, Bing Places, Yellow Pages
>
> Same exact spelling, same address format, same phone format. Inconsistencies confuse Google's local algorithm and dilute the listing's authority.
>
> Reply to every review within 48 hours. Thank positive reviewers, respond to negative reviews professionally with a path to resolution. The response rate IS a ranking factor in the local algorithm.
