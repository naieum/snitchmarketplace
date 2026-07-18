# Content intelligence metrics

Three deterministic content metrics that sharpen the content cats with measured numbers instead of
judgment calls: readability scoring, cross-page near-duplicate detection, and keyword
cannibalization. Each produces a quotable figure so a finding stands on evidence, not opinion.

Word count is deliberately not one of these metrics: length is an answer-fitness question (does
the page cover the subtopics the query demands), never a target number — see Cat 18 for the
calibration evidence in both directions.

## When surfaced

Loaded when Cat 18 (thin content) checks for near-duplicates, Cat 57 (topical depth) judges
readability, Cat 86 (keyword research) checks cannibalization, or Cat 95 (programmatic SEO)
evaluates near-duplication at scale.

## 1. Readability (Flesch-Kincaid)

Compute the Flesch Reading Ease / Flesch-Kincaid grade level on the main content body. Report the
score and what it implies for the audience — not a one-size target.

- The finding is a mismatch: a consumer landing page reading at grade 16 (dense, clause-heavy), or
  a technical reference dumbed down below its audience.
- Quote a representative sentence that drives the score (e.g., a 50-word run-on) so the fix is
  concrete.
- Don't prescribe a universal grade level; B2B/technical audiences tolerate higher grades than
  consumer/local audiences. Calibrate against the brand's ICP (`references/context-file.md`).
- Working default for general/consumer audiences: **grade 6-8** (a widely used practitioner rule
  of thumb). The ICP calibration above still governs — B2B/technical content legitimately reads
  higher; strip only the jargon that isn't earning its place.
- The commonest *editable* driver of a bad score is the transitional-word run-on: long sentences
  chained with "and" / "because" / "that". Quote one and mark the transition words as split
  points — that makes the fix mechanical. Replacing a wordy passage with an image, table, or
  short list is also a legitimate readability fix, not a content cut.

## 2. Cross-page near-duplicate (Jaccard)

Detect pages that are substantially the same content. Compute Jaccard similarity (shingled token
sets) between page bodies; flag pairs above **0.80**.

- The finding: near-duplicate pages compete with each other and dilute crawl/citation signals
  (common on programmatic and templated location/feature pages).
- Quote the two URLs and the similarity figure; name the canonical or consolidation fix
  (cross-ref Cat 3 canonical, Cat 95 programmatic).
- Distinguish intentional boilerplate (nav/footer) from body duplication — shingle the main content
  region, not the chrome.

## 3. Keyword cannibalization

Detect multiple pages targeting the same query/intent, so they split rankings and confuse which
page an engine should cite.

- Cluster pages by primary target term/intent (title + H1 + lead body). Flag clusters where ≥2
  pages target one intent without a clear primary.
- The finding: name the competing URLs, the shared target intent, and which should be the canonical
  authority (the rest consolidated or re-targeted). Cross-ref Cat 58 (intent match), Cat 121 (IA).

## Forbidden claims

- A readability/similarity verdict without the computed figure and a quoted example.
- "Pages are duplicative" without the URL pair and the similarity score.
- "Keyword cannibalization" without naming the competing URLs and the shared intent.

---

*Metrics adapted from the MIT-licensed claude-rank project (Flesch-Kincaid, Jaccard >0.80,
TF-IDF cannibalization). Internal reference only; not surfaced in reports.*
