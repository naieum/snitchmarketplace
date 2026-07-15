# Citability scoring + answer-fitness

A deterministic, reproducible way to score how citable a content passage is to AI answer
engines (ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews) and how well it fits the
extractable-answer surfaces (featured snippets, People Also Ask, voice). This turns Cat 82's
qualitative "extractability" layer into a scored finding with quoted evidence per passage.

The score is computed from observable text features only (word count, pronoun density, presence
of a leading definition, statistic density, named entities). It is not an opinion and not a
prediction of a citation outcome. Never claim a passage "will be cited" or "will not be cited"
(Rule 1); report the measured features and the one weakest dimension to fix.

## When surfaced

Loaded when Cat 82 (AI-search citation, extractability layer) or Cat 102 (multi-LLM) runs, and
for the answer-fitness table when Cat 35 (FAQ) or Cat 57 (topical depth) evaluates answer blocks.
Cat 70 (content marketing) loads it when judging whether new content is built to be extracted.

## Target length by answer surface

Different surfaces reward different answer lengths. Score each passage against the surface it is
meant to serve.

| Surface | Target answer length | Source |
|---|---|---|
| AI citation passage (self-contained answer block) | **134–167 words** | Google AI Optimization Guide |
| Featured snippet / People Also Ask | **40–60 words** | observed snippet-extraction range |
| Voice answer | **under ~29 words** (conversational) | observed assistant read-aloud range |

A passage far outside its surface's band is the finding (e.g., a 600-word wall where a 40–60 word
snippet answer belongs; a one-line stub where a 134–167 word citation block belongs).

## The rubric (7 observable dimensions, 0–100)

Score 3–5 sampled passages per page (the lead answer block, the most-likely-to-be-cited section,
and any FAQ entries). For each, evaluate:

| # | Dimension | What earns points (all quotable) |
|---|---|---|
| 1 | **Front-loading** | The answer appears in the first ~60 words: a verb of definition (`is`/`are`/`means`) or a concrete number up front, not buried under preamble. |
| 2 | **Definition presence** | An explicit `X is a/an…` / `X means…` statement the engine can lift verbatim. |
| 3 | **Self-containment** | Low pronoun density (the passage reads standalone, few unresolved `it`/`they`/`this`); ≥3 named entities (proper nouns, products, standards) anchoring the claim. |
| 4 | **Statistic density** | Percentages, dollar amounts, dates/years, or measured quantities — each with a visible source or "as of" date. |
| 5 | **Expert attribution** | A named author / credential / first-hand signal (pairs with `references/eeat-assessment.md`). |
| 6 | **Schema presence** | The passage is backed by relevant JSON-LD (FAQPage, Article, Organization) per Cats 31–37. |
| 7 | **Structure** | Question-style heading, list or table where the content is enumerable, clear paragraph breaks — extractable shape, not a prose wall. |

Report each scored passage with: the quoted passage, the measured length vs its surface band, the
dimensions it passes, and the single weakest dimension as the fix. Do not aggregate into a vanity
number here — the rollup lives in `references/geo-score.md`.

## Forbidden claims

- "This passage will be cited / won't be cited." You measured features, not outcomes.
- "The content is too short/long" without quoting the passage and naming the target band.
- A score without the quoted passage it was computed from (Rule 1).

## Detection

Sample passages from rendered content (crawl) or the source content body (source mode). Measure
each dimension from the quoted text.

---

*Methodology adapted from concepts in the MIT-licensed geo-seo-claude, claude-seo, and claude-rank
projects, reimplemented under Snitch's evidence-first constraints. The 134–167 word citation band
is sourced to Google's AI Optimization Guide. Internal reference only; not surfaced in reports.*
