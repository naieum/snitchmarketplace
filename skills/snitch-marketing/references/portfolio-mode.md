# Portfolio Mode

Portfolio mode audits 2+ properties owned by the same brand, company, or agency in a single audit run, then synthesizes the findings into a unified report. The value is in the cross-property pattern detection: which findings are shared (likely a common component, template, or config), and which are divergent (opportunities to apply best practice across the portfolio).

## When to use

- Agency auditing all client sites quarterly
- Parent company with multiple sub-brands
- Founder running multiple SaaS / e-commerce properties
- Internal team responsible for several internal-facing sites
- Multi-site monorepo (e.g., main site + docs + status + blog as separate origins)

## When NOT to use

- A single site with multiple subdirectories — that's a single audit (use STEP 0.5 critical-surfaces section).
- Comparing your site to a competitor's — use comparative mode instead.
- Different SaaS products from different teams that share nothing — audit each individually.

## Workflow

### Phase 1: Target enumeration

Ask the user to list the targets. Each is one of:

- A source-mode working directory (path)
- A crawl-mode URL
- A mix of both

For each target, capture:

- A **friendly name** (used in the report — e.g., "Brand A homepage", "Sub-brand B docs")
- The target (path or URL)
- The mode (source / crawl)

### Phase 2: Per-target audit

Run STEPS 0 through 3 on each target sequentially:

- STEP 0: detect mode + stack
- STEP 0.5: site context discovery
- STEP 0.6: brand maturity (PER target — they may differ widely)
- STEP 0.7: niche & competitor research (if applicable per target)
- STEP 1: scan menu (or use the user's pre-selected preset / categories applied to all targets)
- STEP 2: per-category audit
- STEP 3: per-target report (saved as `SEO_AUDIT_REPORT_<target_name>.md`)

Run targets sequentially, not in parallel — sequential execution preserves the agent's context window for cross-target synthesis.

### Phase 3: Cross-target synthesis

After all per-target reports are written, synthesize into `PORTFOLIO_AUDIT_REPORT.md`:

```markdown
# Portfolio Audit — {brand or owner} — {date}

## Targets audited

| Name | Target | Mode | Stack | Categories scanned |
|---|---|---|---|---|
| Brand A | https://brand-a.com | crawl | Next.js | Quick (10 cats) |
| Brand A docs | /Users/.../brand-a-docs | source | Astro | Quick (10 cats) |
| Brand B | https://brand-b.com | crawl | WordPress | Quick (10 cats) |

## Aggregate severity

| Target | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| Brand A | 1 | 3 | 5 | 2 | 11 |
| Brand A docs | 0 | 2 | 4 | 1 | 7 |
| Brand B | 2 | 4 | 7 | 3 | 16 |
| **Total** | 3 | 9 | 16 | 6 | 34 |

## Shared findings

Findings present on 2+ targets — likely a common cause (shared template, shared component, shared config, shared third-party tool):

### Shared finding 1: Cat 11 — OG image relative URL

Affected targets: Brand A, Brand A docs (both, identical pattern)

Likely cause: shared `OpenGraph.tsx` component used across the brand's properties.

Fix once at the component level; benefits both properties.

### Shared finding 2: Cat 31 — JSON-LD missing on homepage

Affected targets: Brand A, Brand B (different stacks; coincidence vs pattern unclear)

Likely cause: each brand's homepage built independently; the absence is structural, not architectural.

Fix per-target (no shared component).

## Divergent findings (best-practice opportunity)

Findings present on one target but solved on another — apply the working solution across the portfolio:

### Best practice on Brand A: hreflang correctly configured

Brand A has Cat 50 (hreflang) configured correctly across all locales. Brand B has hreflang errors. Brand A's pattern (server-side rendered hreflang block from a shared lookup) should be lifted to Brand B.

### Best practice on Brand A docs: Article schema with Person author

Brand A docs uses Cat 32 (Article schema) with structured `author` referencing a canonical Person profile (Cat 93). Brand A's blog uses string authors. Lift the docs pattern to the blog.

## Cross-target trends

- Brands using Next.js (Brand A) consistently score better on Cat 28 (CLS) than the WordPress brand (Brand B). Likely correlation with the framework's image component.
- All three targets have Cat 56 (consent mode v2) gaps. Coordinated fix across the portfolio recommended.

## Recommendations (cross-portfolio)

1. **Normalize the OG image component** across Brand A + Brand A docs — fix once, deploy twice.
2. **Migrate Brand B's hreflang config to Brand A's pattern** — eliminates a Critical finding on Brand B.
3. **Coordinated consent-mode v2 rollout** across all three targets simultaneously — avoids per-property regulatory exposure.

## Per-target reports

- `SEO_AUDIT_REPORT_brand-a.md` — full report
- `SEO_AUDIT_REPORT_brand-a-docs.md` — full report
- `SEO_AUDIT_REPORT_brand-b.md` — full report
```

### Phase 4: Strategic Recommendations across portfolio (optional)

If STEP 4.5 is enabled, produce a portfolio-level `STRATEGIC_RECOMMENDATIONS.md` that addresses cross-portfolio strategy:

- "Standardize on shared components for cross-property surfaces (OG, Article schema, consent mode)"
- "Consolidate marketing efforts on the strongest property; don't dilute across all three equally"
- "Audit the weakest property quarterly; the strongest only semi-annually"

## Audit cadence considerations

- Full portfolio audit: quarterly is reasonable for 3-5 properties.
- Per-property quick audits: monthly or bi-monthly.
- Diff-mode (CI-driven): per PR per property — independent of portfolio cadence.

## Token cost

Portfolio mode multiplies token cost roughly linearly: 3 targets ≈ 3x single audit cost. Confirm with user before launching. For large portfolios (>5 targets), consider running per-target audits one at a time over multiple sessions and synthesizing manually.

## File outputs

```
working-directory/
├── SEO_AUDIT_REPORT_brand-a.md
├── SEO_AUDIT_REPORT_brand-a-docs.md
├── SEO_AUDIT_REPORT_brand-b.md
└── PORTFOLIO_AUDIT_REPORT.md      # the synthesis
```

If the user wants STEP 4.5 strategic recommendations:

```
└── STRATEGIC_RECOMMENDATIONS.md   # cross-portfolio version
```

## Cross-references

- SKILL.md STEP 1.5 (Audit Mode) — entry point
- SKILL.md STEP 4.5 — strategic recommendations apply at portfolio level too
- `comparative-mode.md` — for site-vs-competitor (different mode)
- `output-formats.md` — for portfolio report format variants
