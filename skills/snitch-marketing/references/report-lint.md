# Pre-Output Report Lint Pass

The lint pass runs in STEP 3 after drafting the full report and before saving. It scans the report body (executive snapshot through audit metadata, excluding the `audit_metadata` block itself) for the violations below. For each hit, the agent rewrites the offending passage and re-runs the lint until zero hits remain. The lint pass is mandatory; skipping it invalidates the audit's compliance with brand rules.

## What the lint scans for

- **Em dashes** (` — ` or `—`) and word-bounded double-hyphens (`word -- word`) used as substitutes. Em dashes are fine in moderation, not as filler — count them across the report's narrative prose and aim for under one per 200 words. If the density exceeds that threshold, rewrite the worst offenders with commas, semicolons, colons, or parens. Don't substitute em dashes with `--`. (See `categories/59-ai-content-tells.md` for the underlying density heuristic.)
- **Designer / practitioner names**: scan for any soul slug from `souls/*.json` (e.g., "Dieter Rams", "Frank Chimero", "Rob Fitzpatrick", "April Dunford") plus the formatted variants ("Rams", "Dunford" alone). Names that appear in the report body must be rewritten so the framework or principle is described without naming the practitioner. Names appearing in the `audit_metadata.voice_reads_completed` array are internal and stay; the lint excludes that block.
- **Sycophantic adjectives**: forbidden list = "best", "best-in-class", "excellent", "great", "amazing", "world-class", "textbook", "textbook-correct", "comprehensive", "strong foundation", "well-architected", "thoughtful", "reference example", "outstanding", "remarkable", "robust" (when used as praise, not as technical descriptor), "elegant" (similar). Replace with factual descriptions of what is configured.
- **Sycophantic framing patterns**: scan for opening phrases like "Atlas has a strong foundation but...", "The brand has done a great job of...", "The team has thoughtfully...", "Bonus observation:", "Worth highlighting:". Rewrite to lead with severity counts and findings without preamble praise.
- **"Bonus" / "Highlight" sections** that re-praise something already in the "What's working" list. Remove or fold into "What's working" at the same depth.
- **Negative-evidence shape violations**: scan finding Evidence blocks for "missing" / "absent" / "not present" / "not declared" / "no <X> detected" / "zero" claims. Each such claim must be paired (in the same Evidence block) with the literal search command (a `Grep` / `Bash` / `WebFetch` invocation), the result count, AND the scope (which files / URLs were covered). If any of the three is absent, flag the finding for rewrite. Forbidden hedges that fail the shape outright: "most images", "many pages", "appear to", "seem to", "likely also", "probably affects", "may impact" — these all violate Rule 6 (no propagation without enumeration) when paired with a missing/absent claim.

## Record the result in `audit_metadata`

```yaml
lint:
  em_dash_density_per_200_words: 0.0
  em_dash_overuse_rewrites: 0
  designer_names_corrected: 0
  sycophantic_adjectives_corrected: 0
  sycophantic_framing_corrected: 0
  bonus_sections_collapsed: 0
  negative_evidence_shape_violations: 0
  final_pass_clean: true
```
