# Snitch: Marketing — config

Edit this file to tune the audit behavior. The skill reads it at scan start.

## min-confidence

Findings below this threshold land in a "Needs Review" section instead of the main report.

```
min-confidence: medium
```

Valid values: `low` (everything in main report), `medium` (default), `high` (only high-confidence findings in main report).

## report-output

Where the markdown report is written. Default: `snitchfindings/` subdirectory of the working directory, with a per-target subfolder.

```
report-output: snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md
```

The `{target_slug}` token is derived as follows:

- **Source mode**: derived from `package.json` `name` field if present, otherwise from the working-directory basename. e.g., `arktest`, `snitch`, `myproject`.
- **Crawl mode**: derived from the target domain. Strip protocol and trailing slash. Strip leading `www.`. Replace dots with hyphens for multi-word TLDs (or just take the second-level domain). e.g., `https://quadslab.io` → `quadslab`, `https://snitchplugin.com` → `snitchplugin`, `https://www.atlasforms.app` → `atlasforms`.
- If the audit produces secondary outputs (Cat 96 SERP addendum, Strategic Recommendations, JSON / CSV / HTML exports), they all land in the same `snitchfindings/{target_slug}/` directory.

Override pattern: set this config explicitly to a literal path if a different layout is preferred. For example, `report-output: audit-output/seo.md` writes to that fixed path regardless of target.

The `snitchfindings/` directory should be added to the project's `.gitignore` if the user does not want audit outputs committed to source control. Most teams treat the `snitchfindings/` folder as local-only.

## triage-store

Where the per-finding triage state lives (used when the user marks findings as accepted / false positive / confirmed via Post-Scan Option 4).

```
triage-store: .snitch-marketing-triage.json
```

## ignore-file

Path to the project-level ignore file. Format: one entry per line, either `path:line+CAT` (source) or `url+CAT` (crawl).

```
ignore-file: .snitch-marketing-ignore
```

## crawl-timeout-ms

Per-URL fetch timeout when running in crawl mode.

```
crawl-timeout-ms: 5000
```

## crawl-max-pages

Hard cap on URLs fetched per audit when running in crawl mode (protects against accidental site-wide crawls).

```
crawl-max-pages: 50
```

## diff-base

Git ref to diff against when running in Diff Mode (menu option 9).

```
diff-base: HEAD
```

## confidence-floor

Hides findings below the named tier from the main report. Set per-scan via menu `[c]` toggle, or persist here as the default.

```
confidence-floor: all
```

Valid values:
- `all` — render every finding (default).
- `medium+` — Low-severity / Low-confidence findings move to a "Needs Review" section.
- `high+only` — Medium + Low findings suppressed entirely; metadata records the filter count.

Note: this is a RENDER-time filter. It doesn't reduce scan token cost — it reduces report-rendering token cost AND focuses user attention. For real scan-time savings, drop categories explicitly via STEP 1.7's "skip N,N" syntax.

## confirm-categories

Whether STEP 1.7 (Confirm Categories) displays the resolved cat list with skip/only options before scanning. Default `true`. Disable for batch / CI runs where user interaction isn't possible.

```
confirm-categories: true
```

## recommend-preset

Whether STEP 1.5 (Recommended Preset) suggests a preset based on STEP 0.5 + 0.6 data before the full menu. Default `true`. Disable to always show the full 17-option menu.

```
recommend-preset: true
```

## explain-rationale

Whether STEP 2 prints the "selected categories for [target]" rationale before the first scan starts. Default `true`. Set per-scan via menu `[r]` toggle.

```
explain-rationale: true
```

## skip-stop-prompt

Whether progress lines include the `[type 'skip' to skip / 'stop' to abort]` affordance. Default `true`. Set to `false` for cleaner CI logs.

```
skip-stop-prompt: true
```

## grader

The LLM-as-grader meta-evaluation pass. Runs after the lint pass and before the HTML render. Scores each finding against 5 criteria (evidence specificity, risk specificity, fix specificity, three-rules adherence, evidence-to-claim alignment) plus severity calibration. Failing findings are auto-rewritten and re-graded. Full spec: `references/grader.md`.

```yaml
grader:
  enabled: true
  pass_threshold: 8         # findings need >= this score to pass (max 10)
  rewrite_failures: true    # auto-rewrite findings below threshold
  fail_severity_threshold: low  # findings at this severity or below skip grader
```

Token cost is typically 10-20% of the original audit. Toggle off (`enabled: false`) for token-tight runs.

## confidential

If `true`, the HTML renderer adds a "CONFIDENTIAL — DO NOT DISTRIBUTE" footer banner to the rendered report. Useful for agency engagements under NDA.

```
confidential: false
```

## screenshot-retention-days

When screenshot capture is enabled (Playwright MCP available, screenshot-relevant cat), screenshots accumulate in `snitchfindings/{slug}/screenshots/`. This flag governs cleanup: screenshots older than the retention period are offered for deletion on the next audit run. Default 90 days.

```
screenshot-retention-days: 90
```
