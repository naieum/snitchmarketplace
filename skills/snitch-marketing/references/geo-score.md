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
when Cat 82 (AI-search citation) was in scope for the
scan. If none ran, omit the section entirely (do not show a placeholder). Mirrors the inclusion
rule used for field-CWV and the previous-audit comparison.

## Methodology (deduction model)

Start at 100. Deduct per finding by severity. Count each rule once, regardless of how many pages it
recurs on (a site-wide missing-llms.txt is one deduction, not one per page) — and once across
components: every input below comes from a different part of Cat 82, so no finding can be deducted
twice under two component names.

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
- **llms.txt** — Cat 82 Layer 1 (recalibrated severity; see that layer's posture note — a missing
  file is Medium at most, and it deducts here only).
- **Citability + answer fitness** — Cat 82 layer 2 + `references/citability-scoring.md`
  (passages outside their answer-surface band, weak front-loading/definition).
- **Extractability + schema** — Cat 31 (missing JSON-LD) and Cat 32's FAQPage and Organization rows (the markup that backs answer blocks).
- **Brand authority** — Cat 82 layer 3 + `references/brand-authority-platforms.md`.
- **Per-assistant coverage** — Cat 82's per-assistant section (cited by some assistants, absent
  from others where the audience is).

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

*Deduction model adapted from open-source AI-search rule sets; the weighted-percentage composites
those sets publish are intentionally not used, because their weights are unsourced. Internal
reference only; the score itself is customer-facing, this methodology doc is not.*
