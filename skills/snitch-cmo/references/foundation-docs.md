# Foundation document schemas

Six documents, written in dependency order. Each schema below gives the doc's purpose, its
inputs, its required sections, and its done-when criteria. Shared rules first:

- **Evidence footnotes.** Every factual section ends with a `> Evidence:` line listing the
  `file:line` refs or fetched URLs (with fetch date) that back it. Strategic judgment
  sections (a positioning choice, a channel ranking) instead end with `> Reasoning:`: one
  or two sentences on why, citing the facts they rest on. A reader should be able to tell at
  a glance which lines are *verified fact* and which are *the CMO's call*.
- **Short beats complete.** These are working docs an agent loads before drafting. Target
  one to two screens per doc. A section that would be long gets summarized with a pointer to
  the source instead.
- **Datestamp.** Each doc's first line after the title: `_Last derived: <date> · mode:
  source|crawl|both_`. Staleness checks key off this.
- **Unknowns are visible.** A section that can't be filled gets `_Unknown — <what would
  answer it>_`, never a plausible guess.

---

## 1. `product-information.md`

**Purpose:** the single source of product truth every other doc and every draft cites.
Nothing persuasive lives here, only what is checkably so.

**Inputs:** repo source, pricing/billing config, README/docs, deployed site (crawl), user
answers for stage/goal only.

**Required sections:**

- `## What it is` — two or three sentences, in plain language, no adjectives that can't be
  evidenced.
- `## Who uses it today` — real current users/segments if known; `_Unknown_` if pre-launch.
- `## Features that matter` — the 5–10 capabilities a buyer would care about, each one line,
  each evidenced. Not a changelog.
- `## Real limits` — caps, quotas, unsupported platforms, known gaps. This section exists so
  drafts never accidentally overclaim (evidence gate rule 4 reads from here).
- `## Pricing` — actual tiers and prices from the billing source of truth, or `_Unknown_`.
- `## Stack & distribution` — how it ships (web app, CLI, plugin...), platforms, license.
- `## Stage` — pre-launch / launched / revenue; rough momentum signals from git history or
  the user.

**Done when:** every line either carries evidence or is marked unknown; a stranger could
read it and not be misled about anything.

---

## 2. `positioning.md`

**Purpose:** the strategic decisions everything else inherits. This is judgment, built on
product-information facts. It is the doc most worth the user's review.

**Inputs:** product-information.md, competitor research (may be drafted before
competitor-analysis.md is complete, then reconciled), user interview. The decision procedures
behind this doc — wedge scoring, the ten-step workshop, the hero drafts, the narrative arc,
and the pricing read — live in `references/positioning-method.md`; read it before writing this
doc, not after.

**Required sections:**

- `## Positioning statement` — one sentence: for [who], who [struggle], [product] is
  [category] that [unique value], unlike [primary alternative]. Built by the ten-step
  workshop in `references/positioning-method.md`, whose steps 8–10 stay with the user's team
  and are reported as their next actions.
- `## Wedge` — the segment this leads with for the next 60–90 days, the scored candidates
  behind the choice (four dimensions, evidence per cell), the two backups, and the pivot
  conditions that would end the commitment. Method and matrix:
  `references/positioning-method.md`. Single-obvious-buyer products record the skip and its
  reason instead.
- `## Who it's for / not for` — the target segment described the way they'd describe
  themselves, and the explicit not-fit (a positioning without a not-fit isn't one). When a
  `BLUEPRINT.md` exists, cite its Audience & wedge lines here as the shared fact rather than
  re-deriving them — a `> Evidence:` pointer to the blueprint, not a second interview.
- `## The alternative we replace` — what the target does today instead (a competitor, a
  spreadsheet, nothing), and what that costs them. Cites BLUEPRINT.md's Audience & wedge
  entry when one exists, the same way.
- `## Unique value` — the one or two things true of this product and not of the
  alternatives, each traceable to product-information features or limits.
- `## Why now` — what makes this buyable today; honest `_Weak_` marker if there's no real
  answer.
- `## The villain` — one line naming the root cause the brand is against, on the customer's
  side of the table, never a named competitor. Rules in
  `references/brand-story-and-collateral.md`. Every draft inherits this line rather than
  inventing an adversary per post.
- `## Pricing posture` — the strategy read, in three short buckets: what's working and must
  survive a redesign, what's worth changing, and what not to do. Method and the evidence each
  bucket needs: `references/positioning-method.md`. This is the shape of the tier mix, not
  the number — a product with no price yet gets its number from snitch-blueprint's
  sensitivity survey (call the Skill tool with "snitch-blueprint"), and this section reads the
  posture back from it. Free-only products mark the section `_Not applicable_`.
- `## Claims we never make` — a pointer to `BLUEPRINT.md`'s Claim inventory when one exists:
  its complement, not a second list (anything absent from that inventory is unwritable here
  too), plus anything the Real limits section additionally forbids. No `BLUEPRINT.md` →
  derive the list from the user interview directly.

**Done when:** the positioning statement reads back true against product-information.md and
distinct against competitor-analysis.md, the wedge names one segment with pivot conditions
attached, and the user has been shown all of it as decisions, not buried in a doc dump.

---

## 3. `competitor-analysis.md`

**Purpose:** who else the buyer considers, evidenced from their actual pages, and the wedge
against each.

**Inputs:** user-named competitors, candidates researched from the product's niche, fetched
homepage + pricing pages per competitor.

**Required sections, per competitor (3–6 competitors; more is research theater):**

- `### <Name>` — one-line what-they-are.
- `**Their positioning:**` — as their homepage states it (quote or close paraphrase).
- `**Pricing:**` — from their pricing page, with fetch date.
- `**Where they win:**` — honest; drafts must never deny a competitor's real strength.
- `**Our wedge:**` — the specific gap or difference this product exploits, tied to
  positioning.md's unique value.
- `> Evidence:` — the URLs fetched, with date.

Plus a closing `## Watchouts` section: competitor moves that would hurt (pricing drops, a
feature landing). This is what to re-check when the doc is refreshed.

**Done when:** every competitor claim has a fetched URL, or the doc's header carries
`unverified — re-run with web access` and each unfetched section is hedged.

---

## 4. `brand-voice.md`

**Purpose:** make every draft sound like the same product, written by a person. The doc
drafting mode loads first.

**Inputs:** existing site/README copy (the voice is usually already half-formed there), user
interview, positioning.md (who it's for constrains register, and its villain line sets what
the voice pushes against). When the user is building assets rather than posts — an About
page, a name, a lead generator, a deck — the story and collateral patterns are in
`references/brand-story-and-collateral.md`.

**Required sections:**

- `## Attributes` — three or four adjectives, each with one sentence of what it means in
  practice ("plain: numbers over adjectives; no exclamation marks").
- `## Sounds like / never sounds like` — 3–5 paired examples, same message written in-voice
  and off-voice. The pairs teach more than the adjectives.
- `## Banned` — words, phrases, and moves this brand never uses (hype phrases, em-dash
  chains, "game-changer", fake urgency, plus the user's additions).
- `## Disclosure identity` — the exact first-person identity used on community channels
  ("I'm the maintainer of X"). The ethics gate's disclosure rule reads from here.
- `## Register by channel` — one line per channel where the default register shifts (X terser,
  LinkedIn fuller, Reddit plainest).

**Done when:** a draft written by someone who read only this doc would be recognizably the
same voice as the existing good copy it was derived from.

---

## 5. `content-strategy.md`

**Purpose:** what to make and why: pillars mapped to buyer intent, at a cadence the user
can actually sustain.

**Inputs:** positioning.md, competitor-analysis.md (gaps → pillar opportunities), user
constraints (hours/week), channel-plan.md (drafted together; reconcile).

**Required sections:**

- `## Pillars` — three to five topic territories, each with: the buyer intent it serves,
  why this product has the right to win it (`> Reasoning:`), its business-potential score
  0–3 (how indispensable the product is to the problem the pillar covers — scoring rules in
  `references/channel-playbooks.md`, Blog), and 3–5 example titles. A set that skews to 0s
  and 1s produces traffic that cannot convert; say so here rather than discovering it later.
- `## Formats` — which content shapes fit the pillars and the user's capacity (long-form,
  threads, show-don't-tell demos...); explicitly cut what doesn't fit the capacity.
- `## Cadence` — honest per-week output the user confirmed they can sustain. A cadence the
  user didn't agree to is fiction.
- `## What working looks like` — the few signals worth watching per pillar (qualified
  signups, citation in AI answers, ranking for a named query), stated checkably. No vanity
  dashboard.

**Done when:** pillars trace to positioning and competitor gaps, and the cadence was
confirmed by the user, not assumed.

---

## 6. `channel-plan.md`

**Purpose:** where the effort goes, ranked, with the honest reason, including the channels
this product should *skip*.

**Inputs:** positioning.md (where the target actually is), content-strategy.md, user
constraints, ethics gate (a channel whose rules the product can't work within honestly
ranks last).

**Required sections:**

- `## Ranked channels` — table: channel · rank · why this product / this audience
  (`> Reasoning:` per row or grouped) · cadence · owner (user or "draft-ready via
  snitch-cmo").
- `## Skipped on purpose` — channels deliberately not worked, with the reason (audience
  mismatch, capacity, ethics-gate conflict). Prevents relitigating every week.
- `## First two weeks` — the concrete starting sequence: which foundation-doc-driven drafts
  to produce first, in order.
- `## Handoffs` — where sibling skills take over: snitch-marketing to grade the site,
  snitch-focusedcopy for the landing page, snitch-adsready if paid ranked.

**Done when:** the top three channels each have a reason a skeptic would accept, and at
least one channel is explicitly skipped (a plan that skips nothing hasn't chosen anything).
