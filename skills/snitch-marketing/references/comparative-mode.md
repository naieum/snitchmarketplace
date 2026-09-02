# Comparative Mode

Comparative mode audits the user's site AND a named competitor's site, then surfaces findings side-by-side. The value is twofold: (1) the user sees specifically where the competitor outperforms them on auditable signals, and (2) the user sees where they outperform the competitor — defensible advantages worth preserving and amplifying.

This mode is distinct from STEP 0.7 (Niche & Competitor Research), which captures qualitative competitor positioning. Comparative mode runs the full Snitch: Marketing audit on the competitor's site under the same evidence rules and produces structured comparison.

## When to use

- Pre-launch positioning work — confirming we're at parity or better on technical signals before announcing
- Post-launch competitive response — competitor just shipped a redesign; how does it stack up?
- Sales-prep — auditor needs concrete "we have X, they don't" or "they do Y better, we should match" claims
- Acquisition due diligence — auditing a target's site as part of M&A diligence
- Agency pitching — proving the auditor knows the prospect's competitor landscape

## When NOT to use

- General competitor research — use STEP 0.7 (qualitative; faster).
- More than 2 competitors at once — running full audits on 3+ targets is more cost than benefit; pick the most relevant 1.
- Internal portfolio comparison — use portfolio mode instead.

## Workflow

### Phase 1: Target capture

Ask the user:

- **Self target**: working directory (source mode) OR URL (crawl mode)
- **Competitor target**: URL (almost always crawl mode; you don't have source access to a competitor)

If self target is source mode, run source for self and crawl for competitor — this is the typical case. Note in the report that the comparison is mode-mixed (some categories source-fixable for self, only crawl-detectable for competitor).

### Phase 2: Category selection

Comparative mode benefits from a focused audit, not a full one. Recommended subsets:

- **Default**: Group 2 (Technical SEO) + Group 4 (Schema) + Group 9 (2026 Modern Marketing) — 22 categories. Captures the externally observable structural signals.
- **Conversion-focused**: Group 5 (Conversion & Trust) + Cat 99 (Conversion funnel deep-audit) — for sales-prep / pre-launch.
- **Content-focused**: Group 3 (Content & Structure) + Cat 70 (Content strategy) + Cat 86 (Keyword research) — for editorial competitive analysis.
- **Custom**: user-selected categories.

### Phase 3: Per-target audit

Run STEPS 0-3 on self, then on competitor, with the same selected categories. Save:

- `SEO_AUDIT_REPORT_self.md`
- `SEO_AUDIT_REPORT_competitor.md`

### Phase 4: Side-by-side synthesis

Produce `COMPARATIVE_AUDIT_REPORT.md`:

```markdown
# Comparative Audit — {self brand} vs {competitor brand} — {date}

## Targets

| | Target | Mode | Stack |
|---|---|---|---|
| **Self** | {self} | source | TanStack Start |
| **Competitor** | {competitor} | crawl | Next.js (App Router) |

## Categories scanned

{count} categories: {category numbers + names}

## Severity comparison

| | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| Self | 1 | 3 | 5 | 2 | 11 |
| Competitor | 0 | 2 | 6 | 1 | 9 |

## Where competitor outperforms (priority fix list)

For each category where the competitor has a clean Pass and self has a finding:

### Cat 11: Open Graph

- **Self**: OG image is a relative URL (`/og.png`); some social platforms reject.
- **Competitor**: OG image is absolute, dimensioned (`1200x630`), per-page.
- **Action**: Match the competitor's pattern. Specific: render absolute OG URLs server-side from a shared layout component.

### Cat 31: JSON-LD presence

- **Self**: Homepage missing Organization + WebSite schema.
- **Competitor**: Homepage has both, with `sameAs` referencing 8 social profiles.
- **Action**: Add Organization + WebSite to homepage head; populate `sameAs`.

(... continue per category)

## Where self outperforms (defensive moat)

For each category where self has a clean Pass and competitor has a finding:

### Cat 41: Critical-path CSS

- **Self**: Critical CSS inlined; non-critical deferred.
- **Competitor**: All CSS render-blocking; LCP score 2.4s.
- **Action**: Preserve the advantage; don't regress in upcoming refactor.

### Cat 32: Schema type validation (Person row)

- **Self**: Every blog post has Article schema with structured Person author + canonical profile.
- **Competitor**: Article schema with author as plain string.
- **Action**: Marketing surface highlighting authorship as a trust signal — it's a real differentiator.

(... continue per category)

## Tied (no action; both clean OR both have similar findings)

{Cat numbers + brief note}

## SERP-visible signals competitor wins on

(Findings that affect what users see in SERP — eligible for highlighting in the report's executive summary.)

- Competitor has FAQ schema rich result; self does not.
- Competitor's title tags consistently ~52 chars; self's vary 30-78.
- Competitor's hreflang covers 8 locales; self covers 3.

## SERP-visible signals self wins on

- Self has BreadcrumbList schema sitewide; competitor does not on blog routes.
- Self uses lazy-loading with `<picture>` srcset; competitor ships full-size.
- Self has consent mode v2 implemented; competitor's banner blocks tags but doesn't propagate consent state.

## Strategic implications

1. **Highest-leverage gap to close**: {one specific category where competitor's advantage translates to direct SERP / conversion benefit}
2. **Highest-leverage advantage to amplify**: {one area where self is genuinely better; surface in marketing}
3. **Areas where both have the same gap**: {opportunity for self to leapfrog}

## Per-target reports

- `SEO_AUDIT_REPORT_self.md` — full
- `SEO_AUDIT_REPORT_competitor.md` — full
```

## Evidence integrity in comparative mode

Comparative mode is the easiest mode to slip on Rule 1 (no findings without evidence). Tempting to write "competitor probably does X better" without checking. Don't.

Every finding for the competitor must come from the same Read / Fetch evidence as findings for self. If a category can't be audited on the competitor (e.g., source-only category like Cat 39 font-loading on a competitor where you only have crawl), mark it as Skip with reason `not auditable in crawl-only mode for competitor; comparison incomplete for this category`.

## Honesty constraints

Don't pad the "where self outperforms" section to make the user feel good. If the competitor is genuinely better across the board, say so — that's the actionable signal.

Don't pad the "where competitor outperforms" section either. If the gap is small or arguable, mark it Low confidence.

## Token cost

Roughly 2x single audit. Confirm with user before launching.

## File outputs

```
working-directory/
├── SEO_AUDIT_REPORT_self.md
├── SEO_AUDIT_REPORT_competitor.md
└── COMPARATIVE_AUDIT_REPORT.md
```

If the user wants STEP 4 strategic recommendations:

```
└── STRATEGIC_RECOMMENDATIONS.md   # synthesizes both audits + competitive deltas
```

## Cross-references

- SKILL.md STEP 1.5 (Audit Mode) — entry point
- SKILL.md STEP 0.7 — qualitative competitor research (lighter-weight alternative)
- SKILL.md STEP 4 — strategic recommendations from comparative findings
- `portfolio-mode.md` — for multi-property internal audit (different mode)
- `output-formats.md` — for comparative report format variants
