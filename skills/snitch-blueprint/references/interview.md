# The Interview

One round of questions, asked only after detection, answered into `BLUEPRINT.md`. The
interview's job is to force the handful of decisions everything downstream inherits — not to
be a discovery workshop. Ten minutes of the user's attention, spent only on what the
workspace can't answer.

## Detection checklist (run first, ask nothing yet)

Record each as a **Fact** with evidence before any question:

- **Repo state:** greenfield (no code) / scaffold-only (framework init, no product code) /
  brownfield (real surfaces exist). Brownfield changes the interview: derive answers from
  what exists, then interview only the *contradictions and gaps* ("the homepage sells to
  one audience, an inner page is written for a different one — which is it?").
- **Stack:** framework, hosting target, existing analytics/tag IDs, existing schema.org
  markup, existing metadata approach.
- **Prior contracts:** existing `BLUEPRINT.md`, `marketing/` foundation (snitch-cmo),
  `.claude/seo-config.md` or similar onboarding files, CLAUDE.md product notes. Inherit
  facts and decisions from these; never re-ask them.
- **The business itself,** if a URL or name is given: what the live site or listing already
  declares (services, area, prices, hours). Live-site claims are evidence of what's
  *declared*, not of what's true — mark them inherited-unverified if the user isn't asked.

## Universal core (every archetype, in this order)

Each question ships with a labeled default so "you decide" still yields a decision. Record
verbatim answers as **Decision**; applied defaults as **Default** with the reason.

1. **Who buys, in one sentence?** Not a persona deck — the person and the moment: who
   they are, what just happened that makes them look, in the user's own words. *No
   default — this one blocks. A build with no buyer is decoration.*
2. **What do they use today instead?** The alternative defines the wedge: a competitor, a
   spreadsheet, a phone book, doing nothing. *Default: "doing nothing / a general-purpose
   tool" — the most common honest answer.*
3. **What is the ONE conversion action?** The single thing a visitor does that the business
   counts as won: a call, a booking, a signup, a purchase, an install, a `pip install`.
   Every surface will point at this; it gets instrumented before the first visitor.
   *Default: per archetype file (local service → tap-to-call; SaaS → signup start; etc.).*
   Multiple candidates → force a rank. Two co-equal conversion actions is the root cause of
   the pages snitch-ux later flags as "three CTAs, no hierarchy."
4. **What can this project honestly claim today?** Years in business, licenses, review
   counts, customers, benchmarks — only what's real right now. This is the claim inventory
   every surface draws from; anything not on it doesn't get written. *No default — an empty
   list is a valid, honest answer and shapes the build (no social-proof section yet).*
5. **Constraints:** budget posture (free-tier only / modest / funded), who maintains this
   after launch and how technical they are, timeline, channels or tactics the user refuses.
   *Default: free-tier, non-technical maintainer, no refusals recorded.*
6. **Name, domain, and locale(s).** Taken as given if decided; recorded as an open question
   if not (naming is out of scope — flag it, don't run a naming workshop).
7. **Stack and hosting — greenfield only** (brownfield: detection answered this; never
   ask). One question shaped by the constraint answers: does the user have a stack they
   want, or should the skill pick? *Default: the simplest stack that renders the
   archetype's surfaces statically or server-side, deploys on the user's existing host if
   one exists, and that the named maintainer can actually edit — recorded with the
   reason, like every default. A hosted platform is a legitimate answer, and scopes the
   build to what the platform lets the user control.*

## Archetype branches (ask only the matching set)

### Local service business
- Service list, ranked by margin — the top 2-3 get dedicated pages first, not all twelve.
- Service area: which cities/neighborhoods, and which ONE is the prove-out market (most
  jobs today, most reviews). *Default: a 30-minute drive-time radius around the shop,
  prove-out = the city with the most completed jobs.*
- Urgent/after-hours work, where the category has it? (Changes the header, the CTA, and
  the schema `openingHours`.)
- Whatever credentials the category carries (licenses, certifications, insurance), years
  in business, real review count and where reviews live today — the claim inventory,
  localized. Ask for the category's own trust currency; don't assume it.
- Booking mechanics: phone-only, form, or a scheduler the business will actually answer.

### SaaS / web app
- The wedge in one sentence: for whom, replacing what, unlike what. Fuzzy answer → record
  as open question and flag that the homepage hero will be a placeholder until 10 customer
  conversations happen (per the discovery discipline snitch-marketing's trees enforce).
- Time-to-first-value budget: what can a new user *see working* in the first 60 seconds,
  before any real setup? (Sample data, demo project, hosted playground.)
- Pricing posture today: free-only / free + paid tiers / sales-led / undecided. Undecided
  is fine — it defers the pricing page, it doesn't block the build.
- Self-serve or demo-gated? (Decides whether the conversion action is signup or booked call.)

### E-commerce
- Catalog size and shape: how many products, how many real variant axes.
- Fulfillment truths: shipping regions, times, returns window — checkout-page facts that
  must exist before checkout does.
- Platform posture: custom build vs. hosted platform vs. headless. (If hosted, the
  blueprint scopes to theme/content/schema decisions, not checkout architecture.)
- Where product photography stands. No photos → photography enters the build order ahead
  of any page that needs them.

### Content site
- The entity behind the content: a person, a brand, a team? (Bylines, about page, and
  author schema hang on this.)
- 3-5 topic pillars, and the one the first ten pieces concentrate on.
- The conversion action for a reader: newsletter, RSS, product referral, portfolio inquiry.
- Publishing cadence the user can actually sustain (the honest number, not the aspiration).

### Mobile app
- Stores targeted (Apple / Play / both) and account status — developer accounts take days;
  they enter the build order at day one, not submission week.
- The permission budget: which sensitive permissions the core flow truly needs. Every
  permission is a review risk and a drop-off point; "we might use it later" = not now.
- Login-before-value? If yes, what breaks if the first session runs without an account
  (stores penalize forced login pre-value; so do users).
- Monetization: paid / IAP / subscription / free — decides which store policy floor from
  snitch-storeready applies from the first line of billing code.

### CLI / library / API
- Runtime and package channel (npm / PyPI / crates / Homebrew / container) — the install
  one-liner is the conversion action; pick its channel now.
- The 60-second proof: the smallest command-plus-output that shows the tool working,
  destined for the top of the README.
- Versioning and breakage posture: semver commitment, pre-1.0 honesty.
- Telemetry: none / opt-in. *Default: none — trust is the currency of dev tools.*

## Rules

- **One round.** Batch every question; follow-ups only for contradictions.
- **Never ask what detection answered.** Re-asking teaches the user the skill doesn't read.
- **Offer the default inline** with each question, so answering is accept-or-override.
- **Record refusals too.** "User declined to pick a prove-out city" is a decision — the
  build order adapts (generic pages first, city pages deferred) instead of stalling.
