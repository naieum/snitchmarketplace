# Local-Services Playbook

Cross-cutting playbook for service businesses (storefront or service-area). Loaded by Cat 79 (Local SEO / GBP), Cat 118 (GBP depth), Cat 119 (Hyper-local landing pages), and surfaced from Strategic Recommendations when the component inventory detects a local-business surface.

The patterns below apply across home services, professional services with physical offices, retail, food service, healthcare, and any business where the buyer makes a "near me" decision.

## What a local-services brand actually competes on

Local discovery happens in three places, in order of buyer-decision weight:

1. **Local-3-pack** — the three map-pin results below Google's AI Overview / above the organic listings on "{service} near me" or "{service} in {city}" queries. The brand either earns a spot in the local-3-pack or it doesn't; #4 is essentially invisible.
2. **Organic-3-pack** — the top three organic results below the local-3-pack. The brand's city / neighborhood landing pages compete here.
3. **Community recommendation surfaces** — Nextdoor, neighborhood Facebook groups, local subreddits. "Anyone know a good landscaper in Frisco?" gets answered by whichever brand has earned recommendations.

A local audit's job is to score the brand's position on each surface and produce a prioritized fix list. The brand wins one at a time, not all three at once.

## Service-radius targeting

The first decision every local-services brand makes is the service area. Get this wrong and every other recommendation runs against the wrong audience.

The 30-minute drive-time radius is the conventional default for home services. Wider radii dilute service quality (travel time eats margin); narrower radii forfeit demand. Refine by:

- **Cost-to-serve.** Some services (e.g., one-truck-roll repairs) tolerate a 45-minute radius; others (e.g., daily lawn maintenance) need a 20-minute radius for crew efficiency.
- **Density of demand.** A 30-minute radius around dense urban geography may contain 200,000 potential customers; the same radius around a rural town may contain 5,000.
- **Competitive intensity.** If the brand's primary service area is saturated with established competitors, expanding the radius to a less-contested adjacent area is sometimes higher-leverage than fighting for share in the home market.

For audit purposes: capture the brand's stated service area, compute the population in that radius (Census or comparable), and check whether the brand's marketing surfaces (GBP service area setting, city landing pages, paid-ads targeting) all match the stated radius. Mismatched surfaces (GBP serves Carrollton + Plano + Frisco, city pages only exist for Carrollton, paid ads target only Plano) leak budget against an inconsistent footprint.

## Neighborhood tiers

When a brand has multiple service cities, treat them in tiers based on revenue concentration and competitive position:

- **Tier 1: prove-out cities** (1-3 cities). The brand's strongest market — most customers, most reviews, easiest local-3-pack visibility. All marketing experiments run here first. If a tactic doesn't work in the prove-out market, it won't work in expansion markets.
- **Tier 2: expansion cities** (3-7 cities). Established service area, partial brand recognition, mixed competitive position. Marketing scales here after Tier 1 produces signal.
- **Tier 3: aspirational cities** (variable). Service area the brand technically covers but has minimal presence in. Marketing here is opportunistic, not planned.

Audit application: the recommended scan prioritizes Tier 1 city pages for completeness (Cat 119) and Tier 1 reviews / posts for GBP depth (Cat 118). Tier 3 cities get a "fix when revenue justifies" annotation, not the same urgency.

## Seasonal campaign rotation

Local-services demand is seasonal in most categories. Lawn care peaks April-October; HVAC repair spikes in heatwaves and cold snaps; tax prep concentrates Jan-April; landscaping renovation lulls in deep winter. The brand's marketing surfaces should rotate with the season; static "summer-themed homepage in January" surfaces signal a dormant operation.

Audit application: capture the brand's current homepage, top GBP Posts, paid-ads creative, and email sends. Compare against the current month's seasonal demand. Surfaces that don't rotate within a 90-day window get a finding. The rotation cadence is roughly:

- **Spring rotation** (March 15 - June 15)
- **Summer rotation** (June 15 - September 15)
- **Fall rotation** (September 15 - December 15)
- **Winter / holiday rotation** (December 15 - March 15)

Categories vary; the principle is "the buyer's reality changes by season, so the marketing should too."

## Review acquisition timing (the penalty-risk window)

The single highest-leverage local-SEO tactic is consistent review acquisition. Most brands underuse it, then ramp incorrectly and trip Google's review-spam filter. The audit checks:

1. **When does the brand ask for reviews?** On-site at the job's close (asking the customer to open Google on their phone while standing on the brand's property) is a penalty-risk pattern. Google's algorithm can correlate review-submission lat/long with the business's location; reviews submitted from within ~50 meters of the business address get silently filtered in some categories. The safe pattern is 2 hours post-visit via SMS or email, after the customer has left.
2. **What's the cadence?** Going from 5 reviews to 50 in one month triggers velocity-anomaly filters. The safe ramp is 1-3 new reviews per week sustained over months.
3. **What's the message?** Generic "please review us" reads as transactional. The pattern that converts: short, named, asks about the specific service ("Hope the install in Plano went smoothly — would a quick Google review help us reach more neighbors?").

Audit application: ask the brand how they currently request reviews (or infer from intake-flow review-request surfaces); flag on-site CTA patterns; recommend the 2-hour post-visit SMS pattern.

## NAP consistency at scale

NAP (name, address, phone) consistency across the brand's web footprint is the foundational local-SEO signal. Inconsistencies dilute the listing's authority because Google's algorithm can't confidently tie the brand to a single canonical entity.

The audit checks NAP across:

- Brand's own site (homepage footer, contact page, schema.org JSON-LD)
- Google Business Profile
- Apple Maps
- Bing Places
- Yelp
- BBB
- Industry-specific directories (Angi, HomeAdvisor, Thumbtack, Houzz for trades; Yelp for restaurants; Healthgrades for medical; Avvo for legal)
- Social profiles (Facebook, Instagram, LinkedIn) when present

Character-for-character match is the target. "Suite 200" vs "Unit 200", "555-1234" vs "(555) 1234", "Loera's Landscaping LLC" vs "Loera's Landscaping" are all dilutive variants. 50+ directory listings is typical for an established local brand; each one a potential inconsistency point.

The audit's role here is to surface the inconsistencies it can detect (the brand's own site + GBP + the top 5-10 directories the audit can fetch). Comprehensive cleanup is a job for a paid citation-management service; the audit recommends one if the inconsistency surface area is large.

## Community platform presence (Nextdoor, neighborhood Facebook)

Local-services brands that ignore community platforms forfeit a high-trust referral channel. The audit checks:

1. **Nextdoor presence.** Does the brand have a Business Page? How many recommendations has it earned? When was the most recent organic post? Active business pages get neighbor recommendations; inactive pages don't.
2. **Neighborhood Facebook groups.** Does the brand participate (organic helpful answers, not spam)? Are there Group posts that mention the brand favorably?
3. **Local subreddits.** Same question — is there organic mention of the brand, and is the brand watching the subreddit for relevant question threads?

The audit doesn't recommend "post in 50 groups." The recommendation is: pick the highest-trust community surface in the brand's service area, build genuine presence over 90 days, then evaluate. The community surfaces compound slowly and degrade quickly when treated as paid distribution channels.

## Voice anchors across channels

A local brand's voice should be the same person across surfaces: the homepage, the GBP service descriptions, the Nextdoor profile, the paid-ads creative, the email signatures. Inconsistency reads as multiple companies with the same name.

Voice anchors are short, locked copy lines that appear across all surfaces. Examples (re-implement in the brand's actual voice, not these placeholders):

- "Family-owned since {year}."
- "We answer the phone. A person, in {city}."
- "If we install it, we stand behind it."
- "Same crew every visit."

The audit captures voice-anchor lines from the brand's strongest existing surface (usually the homepage), then checks adjacent surfaces (GBP, Nextdoor, ad creative, email) for whether those anchors appear consistently. Missing anchors are not findings (the brand can change anchors deliberately); inconsistent anchors are findings (the brand has anchors and didn't propagate them).

Cross-references Cat 75 (Brand consistency).

## Photo geo-data discipline

Photos uploaded to GBP, city pages, and social profiles should preserve EXIF metadata when the photo was actually taken on location. Uploading via web admin strips EXIF; uploading from the phone that took the photo preserves it. The geo-tagged photo is a small signal that compounds across many uploads:

- GBP photos with intact lat/long signal "real work in real places" to Google's local algorithm.
- City landing-page photos with location-named filenames + alt text signal hyper-local relevance.
- Social media photos with geo-tags increase reach in location-based feeds.

Audit application: spot-check 5-10 photos across the brand's surfaces; check for EXIF preservation; flag systematic stripping (every photo uploaded via web admin) as a discipline issue, not a one-off.

## Operational cadence checklist

For each weekly cycle, a local-services brand maintaining local-SEO health hits:

- 1-3 new reviews requested (post-visit SMS / email)
- 1 GBP Post (offer, update, or event)
- 1-2 photos uploaded from real jobs (with EXIF preserved)
- 1 community-surface engagement (Nextdoor recommendation reply, neighborhood Facebook question answer, local subreddit comment)

For each monthly cycle:

- GBP service descriptions reviewed and refreshed if any service changed
- Competitive depth check vs top 3 local competitors (per Cat 118)
- City landing pages reviewed for staleness (no photos older than 12 months for any city page representing an active market)
- Seasonal rotation check (are surfaces aligned with the current season?)

For each quarterly cycle:

- 25%-out-do check: which competitor metric (reviews, photos, posts) does the brand trail on by >25%? Close that gap.
- Tier-1 city pages get one new piece of long-form content (case study, before/after, FAQ for a city-specific question).
- NAP consistency spot-check across top 10 directories.

The audit's job is to score the brand against this cadence and identify where it has fallen behind. The cadence is the standard; deviations are the findings.

## Tier-based budget allocation

When the brand has paid-marketing budget for local growth, the allocation logic:

- Tier 1 cities get 60-70% of paid budget (highest ROAS, established conversion path).
- Tier 2 cities get 20-30% (proving the playbook in new markets).
- Tier 3 cities get 0-10% (testing demand, no scale commitment yet).

Audit application: if the brand is running paid ads geographically uniform across all service cities, that's a budget-leak finding. Concentrate spend where conversion is proven; expand only when Tier 1 is mature.

## Pairs with

- Cat 79 (Local SEO / GBP foundation)
- Cat 118 (GBP depth audit)
- Cat 119 (Hyper-local landing page completeness)
- Cat 75 (Brand consistency — voice anchors)
- Cat 111 (Trust artifact audit — review acquisition timing)
- Cat 74 (Customer feedback inventory)
- Cat 96 (Brand SERP defense — local-3-pack appearance for brand-name queries)
- references/strategic-recommendations.md (Tier 1 / 2 / 3 sequencing in the 30/60/90 day plan)
- references/decision-trees.md (Tree 5: brand-is-brand-new first-move logic when local presence is `none`)
