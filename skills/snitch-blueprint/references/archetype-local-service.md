# Archetype: Local Service Business

Any business where the buyer makes a "near me" decision — trade and home services,
professional practices, food service, health and personal care, storefront or service-area
alike. The specific trade comes from the interview, never from this file; every template
below takes the business's own facts as parameters. Adapted from snitch-marketing's
local-services playbook, flipped from audit findings to build-time defaults.

## The three surfaces the business actually competes on

Local discovery happens in three places, in buyer-decision order — and only one of them is
the website:

1. **Local-3-pack** (the map results): won by the Google Business Profile — reviews,
   categories, proximity. #4 is invisible.
2. **Organic results**: won by the site's service and city pages.
3. **Community recommendation surfaces** (Nextdoor, neighborhood groups, local subreddits):
   won by earned reputation; the site only has to not embarrass it.

Build-time consequence: the website is necessary but not sufficient, and the blueprint says
so out loud. The GBP setup and the review engine enter the build order as first-class items
alongside pages — a beautiful site with 3 reviews loses to an ugly one with 80.

## Decisions this archetype forces (from the interview)

- **Service area, then tiers.** Default radius: 30-minute drive time, adjusted by
  cost-to-serve (one-truck-roll repairs tolerate 45 min; daily-maintenance routes need 20).
  Tier the cities: **Tier 1 prove-out** (1-3 cities, most jobs and reviews — everything
  builds here first), **Tier 2 expansion** (build after Tier 1 produces signal), **Tier 3
  aspirational** (recorded, deferred). Then keep every surface consistent with it — GBP
  service area, site copy, schema `areaServed`, and any future ads targeting all match the
  declared footprint. Footprint drift is pure audit-finding fuel.
- **Top services by margin, not by menu.** The top 2-3 margin services get dedicated pages
  first. "We do everything" as twelve thin pages ranks for nothing; three deep pages rank.
- **Urgent/after-hours work or not** (where the category has it). Yes → the header CTA is
  the always-on phone number, `openingHours` says so, and an "emergency" service page
  enters the top of the build order (highest intent, highest margin, least price-shopping).

## Conversion action

Default: **tap-to-call** (`href="tel:"`, click instrumented as the conversion event).
Rank-2: a short form (name, phone, one-line problem — nothing more; every extra field costs
real leads) or a scheduler *only if* someone actually answers it. A booking widget nobody
monitors converts worse than a phone number someone picks up.

Placement default: phone number in the header on every page, sticky call button on mobile,
repeated after every persuasion block. This is the archetype where snitch-ux's tap-to-call
findings are most common — build them in.

## Page inventory and build order

1. **Homepage** — job: a Tier-1 visitor knows in 5 seconds *what service, what area, why
   trust, how to convert*. Section order (the CLOSER arc, per snitch-focusedcopy,
   compressed for a skimming local buyer): hero = `{service} serving {Tier-1 area}` + one
   trust fact *from the claim inventory* + the conversion action; top services (the margin
   2-3, linked); why-us from the claim inventory only (credentials, years, insurance,
   real review count — whichever exist); service-area statement; reviews (real ones,
   named with permission); final conversion block. Every value in the hero is a blueprint
   parameter — never emit placeholder cities, ratings, or phone numbers into real pages.
2. **Top 2-3 service pages** — one per margin service. Job: match "{service} {city}"
   intent and convert. Spec: what the service covers, honest price *anchoring* if the user
   allows (ranges beat silence; silence beats invented numbers), what happens when you
   call, service-specific FAQ (real questions from real jobs), phone throughout.
3. **Contact page** — NAP, map, hours, the form. Renders from the same NAP config as the
   footer and schema.
4. **Tier-1 city pages** — only for cities where the claim inventory has local proof (jobs
   done, reviews naming the city). A city page with no local substance is doorway-page
   spam; the tier system exists to prevent building those. Tier 2/3 city pages → DEFERRED
   with the promotion trigger written down.
5. **About page** — the humans and the credentials. Local buyers hire people.
6. **DEFERRED by default:** blog ("local content strategy" without a writer is a graveyard
   — trigger: someone commits to cadence), financing page, careers, per-neighborhood pages.

## Day-one wiring (beyond build-defaults.md)

- Schema: look up the most specific `LocalBusiness` subtype schema.org defines for the
  interviewed category and use it, falling back to bare `LocalBusiness` only when no
  subtype fits — with NAP, `areaServed` matching the declared tiers, `openingHours`,
  `telephone`. NAP from one config source.
- GBP: claim/verify the profile, primary category exactly right, service area matching the
  blueprint, hours, photos of the real work and real people. Enters the build order at
  slot 1-2 — it outranks the website in buyer-decision weight.
- **The review engine, designed at launch:** ask ~2 hours post-job via SMS/email (never
  on-site while the customer stands at the business's location — proximity-filtered),
  named and specific (`Hope the {service} in {city} went well — would a quick Google
  review help us reach more neighbors?`), sustainable cadence (1-3/week beats a
  50-review burst that trips velocity filters). This is a process decision the blueprint
  records, not a plugin.
- Seasonal rotation hook: if the interview says demand is seasonal, note the rotation
  calendar in the blueprint so the homepage hero has an owner and a cadence.

## Handoffs

ads-ready before any paid spend (LSA/Google Ads readiness, call tracking, consent);
snitch-marketing after launch to grade against this blueprint (its local categories and
GBP-depth checks are the verification pass for everything above); snitch-focusedcopy if a
service page underconverts.
