# Phase: finalize (narrative wrap-up + strategic recommendations)

> Single source of truth for the finalize phase. Streamed via
> `snitch marketing step --phase=finalize` and consumed by the CLI wrap-up call
> (`runWrapUp`). Mirrors SKILL.md STEP 3 (executive snapshot) + STEP 4.5
> (Strategic Recommendations) and `references/strategic-recommendations.md`.
> The mechanical sections (severity counts, finding tables, what's-working,
> skipped) are stitched in code — write ONLY the narrative sections below.

You are given recon context (site, components, brand maturity, niche research),
severity counts, and the top findings ranked by priority. Produce these sections, in
this exact order, with these exact headers:

## Executive snapshot

One short paragraph (3-5 sentences): the bottleneck (one sentence), the fix (one
sentence), the this-week action (one sentence). Concrete, no sycophancy. Customers
triaging the report read just this and act, so name the single highest-leverage move.

## Recommendations

P0 + P1 grouped recommendations drawn from the top findings; max 6 bullets, verb-first,
each referencing the findings (Cat numbers, severity) it derives from. When off-site
cats or competitor research ran, tier the channel work by readiness: Tier 1 (this
week), Tier 2 (30 days), Tier 3 (not yet). Each recommendation cites audit findings +
competitor evidence from the niche-research phase, and declares an observable,
time-bound kill rule (when to stop/pivot/narrow if it isn't working).

## What NOT to do

Max 4 bullets: premature or wrong fixes to avoid right now (e.g., chasing off-site
channels before activation works, rewriting a brand palette without a request,
optimizing a penalized or non-indexed domain).

## The single most important thing

One paragraph: if the team does only one thing this quarter, what — and why it
dominates the rest, grounded in the findings + the wedge from niche research.

Brand voice: em dashes in moderation (under ~1 per 200 words; never `--`); no
practitioner names in user-visible body; no sycophantic adjectives; reference findings
concretely. When off-site cats ran, also write the 30/60/90-day checklist and the
pre-committed kill/pivot/narrow rules into `STRATEGIC_RECOMMENDATIONS.md` per
`references/strategic-recommendations.md`. Limit to "start here" surfaces when brand
maturity flagged the brand as too new for off-site optimization.
