# Phase: niche-research (niche + competitor research)

> Single source of truth for the niche-research phase. Consumed by the CLI
> recon pass and streamed via `snitch marketing step --phase=niche-research`.
> Mirrors SKILL.md STEP 0.7 and `references/discovery-flow.md`. Required when
> off-site categories OR Strategic Recommendations will run; skip only if the
> user opts out of both.

The audit answers "what's broken on this site." Niche + competitor research adds "and
what to do about it, given who you're competing with." Without it, recommendations are
generic ("write more content!") instead of specific ("competitor X owns query Y with a
4000-word piece + FAQ schema; ship the equivalent").

Capture (the "## Niche research" / "## Competitive landscape" output):

1. **Niche definition** (1-2 sentences): the category the brand competes in. Specific,
   not "developer tools." Pull from discovery + the homepage hero.
2. **Top 3-5 target queries**: derive from positioning + likely audience search
   behavior (homepage H1 + value prop as input). Quote them.
3. **Top 3-5 direct competitors**: who consistently ranks top-5 for those queries.
   Quote each domain + their positioning H1. Skip aspirational 10x-larger competitors
   unless they're the only ones ranking.
4. **What each competitor does well** (~3 bullets each): content depth, schema
   completeness, converting CTAs, design polish, niche owned. Fetch each homepage + a
   representative inner page; capture concrete observations.
5. **Market gaps** — what NO top-5 competitor owns, labelled by the four axes (each
   routes to a different recommendation):
   - **Content gap**: a topic / query cluster / format nobody owns. Quote query + SERP.
   - **Schema gap**: a schema.org type competitors omit where they'd qualify for a SERP
     feature. Quote competitor URL + missing schema.
   - **Feature/product gap**: a use-case / integration / workflow / audience-feature
     competitors don't address.
   - **Audience gap**: a segment (geo, company size, role, vertical, skill level,
     language) competitors don't speak to. Quote messaging + the unaddressed signal.
   Gaps without one of these four labels are too vague to act on — tighten or drop.
6. **Differentiation deltas**: what THIS brand does that competitors don't (the wedge).

**Tooling note:** without paid SEO data (Ahrefs / Semrush / Similarweb), competitor
rank/traffic is approximate. SERP inspection gives partial visibility — mark
approximations as such; never claim "competitor X gets 100K monthly visits" without a
source. Every STEP 4.5 recommendation cites this section.
