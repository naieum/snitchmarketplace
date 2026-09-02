# Archetype: SaaS / Web App

Anything bought through a signup, where the user must reach value to stay. Adapted
from snitch-marketing's decision trees and funnel categories, flipped to build order: the
trees say "stop marketing until activation works and the wedge is clear" — so the build
puts activation and wedge *first*, and defers everything the trees would tell a launched
product to stop doing.

## The two gates, built in the right order

Every post-launch decision tree bottoms out in the same two questions: *is the wedge clear*
and *does activation work*. Build-time consequence:

1. **Wedge before homepage.** If the interview's wedge answer is fuzzy, the blueprint
   records it as the top open question and the homepage hero ships as an honest placeholder
   — the fix is 10 customer conversations, not better copywriting. Copy polish on a fuzzy
   wedge is the most expensive way to learn nothing.
2. **Activation before acquisition.** The first engineering budget goes to
   time-to-first-value, not to the marketing site. Distribution amplifies a broken product.

## Decisions this archetype forces (from the interview)

- **The 60-second proof.** What a brand-new user *sees working* within 60 seconds of
  signup, before any real setup: sample dataset, demo project, templated first run, hosted
  playground. This is a product surface, specced in the blueprint like a page. Dropoff
  patterns are predictable — build against all four: value visible before setup; setup
  steps minimized (OAuth over forms, defaults over config); the first high-value action
  surfaced in-product; and honest ICP targeting so the users who arrive are ones the
  product actually helps.
- **Self-serve vs. demo-gated** — decides the conversion action (signup start vs. booked
  call) and whether a pricing page exists at launch.
- **Pricing posture.** Undecided pricing defers the pricing page (DEFERRED with trigger:
  first 5 paying conversations); it never blocks the build. Fake placeholder tiers are
  invented claims and fail the decisions gate.

## Conversion action

Default: **signup started** (not completed — instrument both, count started as the
top-of-funnel conversion and activation as the real one). Demo-gated: booked call.
Activation event — the user reaching first value — is named in the blueprint and
instrumented in-product from day one; it is the number every later decision tree runs on.

## Surface inventory and build order

1. **The product's first-run flow** — the 60-second proof. Highest-leverage surface in the
   archetype; specced first, built first.
2. **Homepage** — job: a qualified visitor knows in 5 seconds what this does, who it's
   for, and what changes if they use it. Section order: CLOSER (snitch-focusedcopy), with
   two SaaS-only parameters — the hero states the wedge in customer language (no
   "supercharge your workflow"; the claim inventory rule bans it anyway), and wherever the
   product is shown doing the thing, it's a real screenshot or recording, never a mockup of
   features that don't exist.
3. **Signup → onboarding** — every field and step justified; each setup step removed
   compounds. OAuth if the audience has it.
4. **Pricing page** (if posture decided) — snitch-ux paywall defaults: real tiers, one
   recommended, honest comparison, no fake anchoring or countdowns (ethics gate).
5. **One "how it works" / docs entry** — depth for the evaluator persona; for dev tools
   this is quickstart docs and it may outrank the homepage in build order.
6. **Changelog** — cheap, compounding trust signal; commits the team to visible momentum.
7. **DEFERRED by default:** blog/SEO content (trigger: wedge validated + someone owns
   cadence), comparison/alternatives pages (trigger: losing named deals to a named
   competitor), affiliate/partner pages, second CTA paths. Paid acquisition is not a
   surface but gets a DEFERRED entry anyway with the tree's own gate as trigger:
   activation working AND wedge clear AND one organic channel producing signups.

## Day-one wiring (beyond build-defaults.md)

- Product analytics with the activation event; funnel steps named at build time.
- `SoftwareApplication`/`Organization` schema; OG images that show the product.
- Status/uptime and security pages: DEFERRED with triggers (first paying customer asks),
  not launch blockers.
- Waitlist mode (pre-product): the conversion action is the email capture, and the
  blueprint says what the waitlist will be told and when — a waitlist with no send plan is
  a graveyard.

## Handoffs

snitch-cmo Foundation mode inherits the wedge/audience sections as recorded Decisions, never
re-interviewed; snitch-focusedcopy for the homepage once real traffic shows where it leaks;
snitch-ux for onboarding and paywall depth; snitch-marketing to grade the launched site;
snitch-adsready only when the DEFERRED paid trigger fires.
