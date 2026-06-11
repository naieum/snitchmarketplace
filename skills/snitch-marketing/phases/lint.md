# Phase: lint (pre-output report lint)

> Single source of truth for the lint phase. Streamed via
> `snitch marketing step --phase=lint`. Mirrors SKILL.md STEP 3 (lint pass) and
> `references/report-lint.md`. In the CLI pipeline a code-based density linter
> (`runLintPass` / `lintProse`) runs first; this phase is the agent-facing spec
> for the semantic rewrites the code linter can't make.

Run after drafting the full report and before saving. Scan the report body (executive
snapshot through findings, excluding the `audit_metadata` block). For each hit, rewrite
the passage and re-run until zero hits remain. Mandatory.

What the lint scans for:

- **Em-dash density**: count ` — ` / `—` and word-bounded `--` across the narrative
  prose; aim for under one per 200 words. Above that, rewrite the worst offenders with
  commas, semicolons, colons, or parens. Never substitute em dashes with `--`.
- **Designer / practitioner names**: scan for any soul slug from `souls/*.json` (e.g.
  "Dieter Rams," "April Dunford") plus short forms ("Rams," "Dunford"). Rewrite so the
  principle is described without naming the practitioner. Names in the internal
  `audit_metadata.voice_reads_completed` array stay; exclude that block.
- **Sycophantic adjectives**: forbidden — "best," "best-in-class," "excellent,"
  "great," "amazing," "world-class," "textbook," "comprehensive," "strong foundation,"
  "well-architected," "thoughtful," "reference example," "outstanding," "remarkable,"
  "robust" (as praise), "elegant." Replace with a factual description of what's
  configured.
- **Sycophantic framing**: openings like "X has a strong foundation but...," "The team
  has thoughtfully...," "Bonus observation:," "Worth highlighting:." Lead with severity
  counts and findings, no preamble praise.
- **"Bonus" / "Highlight" sections** that re-praise something already in "What's
  working." Remove or fold in at the same depth.
- **Negative-evidence shape**: every "missing / absent / not present / no X detected /
  zero" claim must be paired (same Evidence block) with the literal search command, the
  result count, AND the scope (files/URLs covered). If any of the three is absent, flag
  for rewrite. Hedges that fail outright when paired with a missing/absent claim: "most
  images," "many pages," "appear to," "seem to," "likely also," "probably affects,"
  "may impact" (Rule 6: no propagation without enumeration).

Record the result in `audit_metadata.lint` (em_dash_density_per_200_words,
em_dash_overuse_rewrites, designer_names_corrected, sycophantic_adjectives_corrected,
sycophantic_framing_corrected, bonus_sections_collapsed,
negative_evidence_shape_violations, final_pass_clean).
