# GEO readiness score

An optional rollup that summarizes the GEO findings into a single 0–100 number, for customers who
want a headline metric to track over time. It is a derived view of findings that already exist in
the report — not a standalone metric and not a prediction of citation rate. Every point movement is
traceable to a specific finding with evidence.

Snitch's default posture is evidence-based findings, not vanity scores. This rollup is therefore
**gated** and **transparent**: it renders only when the GEO categories actually ran, and its
arithmetic is fully shown so a reader can reconstruct it from the findings list.

## When surfaced

Render the `## GEO readiness score` section in the report (per `references/report-template.md`) only
when Cat 82 (AI-search citation), Cat 102 (multi-LLM), or Cat 106 (llms.txt) were in scope for the
scan. If none ran, omit the section entirely (do not show a placeholder). Mirrors the inclusion
rule used for field-CWV and the previous-audit comparison.

## Methodology (deduction model)

Start at 100. Deduct per finding by severity. Count each rule once, regardless of how many pages it
recurs on (a site-wide missing-llms.txt is one deduction, not one per page).

| Severity | Deduction |
|---|---|
| Critical | −20 |
| High | −10 |
| Medium | −5 |
| Low | −2 |

Floor the score at 0. The score is the sum of deductions from the GEO-relevant findings only —
not the whole audit.

## Components (which findings feed the score)

Only findings from these GEO surfaces count toward the GEO score:

- **Crawler access** — Cat 1 + `references/ai-crawler-registry.md` (AI crawler blocked = its
  severity).
- **llms.txt** — Cat 106 (recalibrated severity; see that cat's posture note).
- **Citability + answer fitness** — Cat 82 layer 2 + `references/citability-scoring.md`
  (passages outside their answer-surface band, weak front-loading/definition).
- **Extractability + schema** — Cats 31, 35, 37 (missing JSON-LD that backs answer blocks).
- **Brand authority** — Cat 82 layer 3 + `references/brand-authority-platforms.md`.
- **Multi-LLM coverage** — Cat 102 (cited by some assistants, absent from others).

## Presentation rule

Show the starting 100, an itemized deduction list (each line: finding title + severity +
deduction), and the floored total. The reader must be able to add the deductions and arrive at the
displayed score. Never present the number without the itemized derivation — an unexplained score is
exactly the vanity metric this skill avoids.

## Forbidden claims

- "GEO score predicts your citation rate / AI traffic." It summarizes findings; it predicts nothing.
- A score shown without its deduction itemization.
- Comparing two sites' GEO scores without noting they were scanned with the same category scope.

---

*Deduction model adapted from the MIT-licensed claude-rank project; the weighted-percentage
composite published by geo-seo-claude is intentionally not used (its weights are unsourced).
Internal reference only; the score itself is customer-facing, this methodology doc is not.*
