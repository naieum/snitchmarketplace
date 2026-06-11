# Scan Presets & Menu Behavior

The interactive scan-selection menu, the per-option behavior, and the rules for when the menu must fire vs may be bypassed.

## Scan Selection Menu

Display this menu when no arguments are provided:

```
SEO & Marketing Audit for [project-name or domain]

What would you like to scan?

[1]  Quick Audit (Recommended), 10-13 highest-impact cats. ~15-25K tokens. ~5-10 min small / ~15-30 min large
[2]  Technical SEO, 13 cats (crawl & indexing, title/meta, performance, mobile/a11y). ~20-30K tokens. ~15-30 min
[3]  Content & Structure, 13 cats (headings, content quality, internal linking, E-E-A-T, keyword research). ~20-30K tokens. ~15-30 min
[4]  Schema & Structured Data, 8 cats (schema.org JSON-LD across all supported types). ~12-20K tokens. ~10-20 min
[5]  Conversion & Trust, 16 cats (CTAs, forms, trust signals, 404 pages, analytics, pixel install completeness, UTM hygiene). ~25-40K tokens. ~25-45 min
[6]  International, 3 cats (hreflang, locale canonicals, lang attribute). ~5-8K tokens. ~5-10 min
[7]  Email & Transactional, 5 cats (inventory, content, deliverability, design, compliance). ~10-18K tokens. ~15-30 min
[8]  Off-site & Channels, 17 cats. ~30-50K tokens. ~50-95 min
[9]  2026 Modern Marketing, 5 cats (AI-search citation, creator partnerships, founder-led brand, newsletter/podcast sponsorships, llms.txt). ~10-18K tokens. ~20-35 min
[10] Full Audit, all 123 categories. ~165-235K tokens. ~150-280 min. **CONFIRM BUDGET FIRST**
[11] Custom Selection, pick categories by name or number
[12] Diff Mode, audit changes since previous run (source mode: changed files since last commit; crawl mode: delta vs previous snitchfindings/{slug}/ report). Cost scales with diff size

Vertical presets (curated subsets per business type):
[13] B2B SaaS preset, 15 cats. ~25-40K tokens. ~30-60 min
[14] E-commerce preset, 19 cats. ~30-50K tokens. ~30-60 min
[15] Local business preset, 19 cats. ~30-50K tokens. ~30-50 min
[16] Publisher / media preset, 22 cats. ~35-60K tokens. ~45-75 min
[17] Accessibility deep-dive, 13 cats (WCAG 2.2 AA, keyboard, screen reader). ~20-35K tokens. ~30-60 min

Toggles (apply to whichever option you pick):
[c]  Confidence floor, current: all (toggle: all / medium+ / high+only, high+only suppresses Low/Medium findings from the report)
[r]  Rationale, current: on (toggle: print "why these cats?" before scanning)
[v]  Confirm Categories, current: on (toggle: show resolved cat list with skip/only options before scanning)

[0]  Exit

Enter your choice (0-17, c, r, v):
```

**Token cost note:** estimates assume ~1.5K tokens per category in source mode + ~5K overhead per scan. Crawl-mode adds 2-4K per fetched URL. Project size multiplies: small site (<50 routes) hits the low end of each range; large site (>200 routes) hits the high end.

## Menu Behavior

- **0 (Exit):** Display "SEO audit cancelled. No changes made." and exit.
- **1 (Quick Audit):** Run stack detection (`references/smart-detection.md`), pick 8-12 categories that map to the detected stack. Always include: 01 (title & meta), 02 (canonical & indexing), 06 (single H1 / heading hierarchy), 14 (image alt presence), 21 (schema.org JSON-LD presence).
- **2-9 (Presets):** Scan the predefined category group. Read `references/category-groups.md` for group → category mappings.
- **10 (Full):** All 123 categories. Warn user about token cost. **Require explicit confirmation** ("yes, I confirm the ~160-230K token budget") before launching.
- **11 (Custom):** Present the category picker. Read `references/custom-selection.md` for the menu.
- **12 (Diff):** Two paths depending on mode:
  - **Source mode**: run `git diff HEAD --name-only`, scan only changed files plus their declared route layouts / heads.
  - **Crawl mode**: detect previous report at `{working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md`. If found, parse the previous findings list, run the same selected cats fresh, then synthesize a delta report with: resolved findings, new findings, unchanged findings, severity-changed findings. Archive the previous report to `SEO_AUDIT_REPORT.{prev_date_iso}.md` in the same directory before overwriting. The new report's "Comparison to previous audit" section gets populated automatically (per `references/report-template.md`'s INCLUSION RULE).
  - **No previous report in either mode**: fall back to the current preset selection or to Quick Audit. The user is informed that this is a first-time scan; diff mode produces nothing meaningful without a baseline.
- **13-17 (Vertical presets):** B2B SaaS / E-commerce / Local business / Publisher / Accessibility. Read `references/category-groups.md` for Group 11-15 → category mappings. Pick the preset that matches the brand's business model from STEP 0.5.
- **c (Confidence floor):** Toggle between `all` / `medium+` / `high+only`. Persist for this scan only. When set to `high+only`, suppress Medium / Low findings from the report (still run detection so passed-checks evidence is captured) and note "X findings filtered" in metadata.
- **r (Rationale):** Toggle whether the executor prints "Selected categories X, Y, Z because [stack signal]" before scanning. Default: on.
- **v (Confirm Categories):** Toggle whether STEP 1.7 displays the resolved cat list with skip/only options before scanning. Default: on. Disable for batch / CI runs.
- **Invalid input:** Display "Invalid choice. Please enter 0-17, c, r, or v." and re-display menu.
- **Arguments provided:** Skip menu, parse arguments, proceed to scan.

## When the menu MUST fire vs MAY be bypassed

The menu fires by default when no preset is named. The user's words decide:

- **Authorize bypass (preset is explicit):** "run quick", "run full", "full audit", "run technical SEO", "schema audit", "B2B SaaS audit", "diff mode", "crawl mode", "audit at high+only confidence", "audit cats 1-10". The user named the preset OR the explicit category list — proceed without showing the menu, but still show the resolved cat list per STEP 1.7 unless `[v]` is off.
- **Require menu (instruction is ambiguous):** "run it", "audit", "scan", "go ahead", "check it out", "what does it find", "let's see", "what should we do here". The user wants something audited but didn't pick a scope — show the menu, suggest a preset per STEP 1.5, wait for selection.

When in doubt, show the menu. Tokens spent on a bad scope are far more expensive than the 30 seconds the menu costs.
