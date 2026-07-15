# Brand-authority platform sweep

Off-site presence is a load-bearing AI-citation signal: assistants weight whether a brand/entity
is discussed across the open web, not just what the brand says on its own site. This is the
authority layer of Cat 82 (AI-search citation, layer 3) and the off-site half of Cat 96
(brand-SERP defense, social + sameAs).

This is a presence/recency/sentiment checklist, not a weighted score. Snitch does not assign
correlation coefficients to platforms — there is no published, reproducible figure to cite, and
fabricating one violates Rule 1. Report what is present, how recent, and whether it is brand-owned
or third-party.

## When surfaced

Loaded when Cat 82 layer 3 (authority) runs or when Cat 96 layer 4 (social + sameAs) audits the
off-site footprint.

## Tooling caveat (Critical)

Most of these platforms are consent-walled or JS-app surfaces that a plain `Fetch`/`curl` cannot
read. Capture method per platform is noted below. When a platform needs a tool not present this
run, mark that platform **Skip** with reason `off-site presence check requires a WebSearch/browser
tool or user-supplied evidence` — never assert a presence/absence you did not observe (Rule 1).

## The sweep

| Platform | What to check | Capture method |
|---|---|---|
| **Wikipedia** | Entity page exists; facts current; not flagged for notability/sources | Plain Fetch (article is server-rendered) |
| **YouTube** | Brand channel + third-party videos discussing the category; recency | WebSearch / browser |
| **Reddit** | Brand mentioned in relevant subreddits; sentiment; unanswered complaints | WebSearch / browser |
| **LinkedIn** | Company page complete; founder/exec presence; post recency | WebSearch / browser (auth-walled) |
| **Quora** | Category questions where the brand is (or should be) named | WebSearch / browser |
| **Stack Overflow** | For dev tools: tag presence, answered questions, official account | Plain Fetch (questions are server-rendered) |
| **GitHub** | For dev/OSS brands: org presence, stars, active repos, README quality | Plain Fetch |
| **Crunchbase** | Company profile present and current (funding, team, links) | WebSearch / browser |
| **Product Hunt** | Launch presence + reviews (relevant for SaaS/tools) | WebSearch / browser |
| **G2** | Category listing, review volume/recency, response coverage | WebSearch / browser |
| **Trustpilot** | Review volume, rating trend, response coverage | WebSearch / browser |

Not every platform applies to every brand — a local plumber needs Trustpilot/Reddit/Wikipedia far
more than Stack Overflow. Use STEP 0 niche definition to pick the 4–6 that matter and skip the rest
with reason `not applicable to this brand's category`.

## What a finding looks like

- "No Wikipedia entity page (Fetched `en.wikipedia.org/wiki/{Brand}` → 404); competitors {X},{Y}
  have current entries. Authority gap on the surface assistants weight most." (presence)
- "G2 listing exists but last review is 14 months old and 3 negative reviews are unanswered."
  (recency + sentiment + response coverage)
- "`sameAs` in Organization schema lists a LinkedIn URL that 404s." (cross-checks Cat 96 / Cat 37)

## Forbidden claims

- Any platform weighting expressed as a percentage or correlation. Not measurable; do not state.
- "The brand has no Reddit presence" without the search query run and its result.
- Asserting sentiment without quoting representative posts/reviews.

---

*Platform set adapted from the MIT-licensed geo-seo-claude and claude-seo projects; the correlation
weights those projects publish are intentionally NOT imported (unsourced). Internal reference only;
not surfaced in reports.*
