# Report pipeline — STEP 3, the full contract

The full text of every report-generation stage: display blocks, schemas, gates, and
degradation rules. SKILL.md carries the ordered stage list; this file is authoritative.
Read it before drafting the report.

**STEP 3: Generate Report**

- Build the findings report.
- Display summary in console.
- **Generate the executive snapshot first**, before drafting the full report. The snapshot is a one-page header (≤300 words) that opens every report, naming: the bottleneck (one sentence), the fix (one sentence), this-week action (one sentence), top 3 findings, and a short "read the rest if..." pointer. The snapshot is the audit's TL;DR; customers triaging the report read just the snapshot and act. The snapshot is required by `references/report-template.md`; a report without it is incomplete and does not save.
- **Run the redaction gate (always on, hard fail).** Before saving — or, when no file will be written, before presenting the report — scan the full drafted output for analytics/ad identifiers, credentials, and real personal data per the Redaction gate section of `references/report-lint.md`. Any live value anywhere in the draft blocks the save; apply the redaction-only rewrite and re-scan until clean. This enforces Rule 5 and runs regardless of `grader.enabled` or whether the audit is internal.
- **Run the pre-output lint pass** after drafting the full report and before saving. Full spec, scanner rules, and `audit_metadata.lint` schema live in `references/report-lint.md`. Mandatory; skipping invalidates the audit's compliance with brand rules (em-dash density, no practitioner or source names in user-visible output, no sycophancy, negative-evidence shape). Rewrite each hit and re-run until clean.
- **Run the copy-mechanics lint** after the report-lint pass and before the grader, so the grader grades final prose. Score the drafted report's narrative prose with the deterministic linter (`references/writing-system.md` has the rules; the script's preprocessor skips code blocks and the `audit_metadata` block itself):
  ```bash
  python3 {skill_dir}/scripts/copy-lint.py --mode strict --json {working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md
  ```
  Rewrite the worst offenders and re-run until the score is at or under `copy-lint.max-report-score` (`snitch-marketing.config.md`, default 2.0 violations per 100 words), then record the result in `audit_metadata.lint.copy_lint` (schema in `references/report-lint.md`). **If `python3` is unavailable, apply rules W1-W14 by hand** — call the Skill tool with "snitch-ux" for the rule table (`references/writing-system.md` explains the handoff) — and record `runner: manual` — the same degradation contract as the HTML render. Skip entirely only when `copy-lint.enabled: false`.
- **Run the LLM-as-grader pass** after the lint pass and before the HTML render. The grader reads the report and scores each finding against 5 criteria (evidence specificity, risk specificity, fix specificity, three-rules adherence, evidence-to-claim alignment) plus a severity-calibration check. Failing findings are auto-rewritten; the rewrite is re-graded; the pass-rate is recorded in `audit_metadata.grader`. Default pass threshold is 8/10 per finding; configurable in `snitch-marketing.config.md`. Full spec: `references/grader.md`. Required for customer-facing audits; toggle off via `grader.enabled: false` for internal exploratory scans where token budget is tight.
- **Render the HTML alongside the markdown (if python3 is available)** after lint pass and grader pass complete and the markdown is final. Invoke the renderer (`{skill_dir}` is defined in SKILL.md's category-guidance section):
  ```bash
  python3 {skill_dir}/scripts/render-report.py {working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md
  ```
  Pass `--confidential` if `snitch-marketing.config.md` has `confidential: true`. The script writes `SEO_AUDIT_REPORT.html` next to the markdown. **If `python3` is unavailable (e.g., python-less hosts like Claude.ai web or ChatGPT), skip the HTML render and note it in `audit_metadata`** (e.g., `html_render: "skipped — python3 unavailable on this host"`), mirroring how Cat 11 marks a missing `file`/`curl` tool as Skip-with-reason rather than failing. The markdown report stays the canonical artifact regardless. The HTML is a derived view; the markdown is the canonical artifact. Customers who prefer markdown ignore the HTML; customers who want a formatted, in-browser, printable report open the HTML. See `references/html-template.md` for the template structure and `references/output-formats.md` for the broader output-format options.
- Save to `{working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md`. Create the `snitchfindings/` parent and the per-target subfolder if they don't yet exist. The path is always relative to the user's current working directory at invocation, never a hardcoded absolute path. The `{target_slug}` is derived per `snitch-marketing.config.md` (source mode: `package.json` name or directory basename; crawl mode: the target domain's second-level name). Secondary outputs (STRATEGIC_RECOMMENDATIONS.md, CAT_96_BRAND_SERP_ADDENDUM.md, JSON / CSV / HTML exports, PORTFOLIO_AUDIT_REPORT.md) all land in the same `snitchfindings/{target_slug}/` directory.
- **Stable finding identity**: every finding carries `ruleId` + a semantic `anchor` (+ `instance` for siblings) per `references/finding-identity.md`. In crawl mode the anchor is a route *pattern* plus selector, so one bad template on a 400-page site is one finding with 400 instances, not 400 findings.
- **Scan comparison**: If a previous `SEO_AUDIT_REPORT.md` exists in the same `snitchfindings/{target_slug}/` directory, reconcile **by fingerprint** — not by count — and add: `Previous: X findings | This audit: Y | Resolved: Z | New: W`. Counts are not identity: two fixed and two new reads as "Resolved: 0" if you subtract totals. For element-level regression beyond finding counts (a canonical that silently changed, JSON-LD that vanished from a template, a `noindex` that shipped by accident), see `references/seo-drift.md` — it writes a small baseline artifact on one run and diffs it on the next using only Read/Write, no database.
- On first run, suggest the user add `snitchfindings/` to their `.gitignore` if the directory is inside a git repository. Audit outputs are typically local-only and shouldn't be tracked.
- **Coverage section (required).** Every audit states its denominator: URLs **discovered** vs URLs
  **actually fetched**, and per-category completeness of `complete` / `partial` / `unknown`. A crawl
  that stopped at `crawl-max-pages` (default 50) is `partial` — say so, give both numbers, and name
  the cap as the reason. **No silent sampling.**
  A category that audits a standard against a **subset** of its criteria reports `partial`, names the
  subset, and lists the criteria outside it as Skips. Cat 45 and Cat 52 each cite one WCAG success
  criterion as a search / machine-readability signal and are not a conformance sweep, so the report
  never presents them as WCAG coverage; the full A/AA denominator belongs to the accessibility skill,
  reached by calling the Skill tool with "snitch-ada".
  This is not report hygiene, it is validity. Categories 9, 10, 19 and 20 compute *negative* claims
  from the crawl set — "no duplicate titles", "no orphan pages", "no broken links". A negative claim
  drawn from 50 of 400 URLs is not a weaker finding, it is an invalid one: the duplicate may simply
  be on page 51. Where the cap bound the crawl, report the positive findings normally and state the
  negative ones as "none found in the N URLs fetched", never as "none".
  When the sitemap is larger than the cap, say what the remaining URLs would cost to check and let
  the user raise `crawl-max-pages` — a bounded audit the reader can see the edges of is worth more
  than a complete-looking one they cannot.
- **SCOPE RULE for the report**: Only reference selected categories. No passed-checks list for unscanned categories.
- Include metadata at the top:
  - `audit_mode_detected` (source / crawl / both)
  - `stack_detected` (Next.js 15 / Astro 5 / WordPress + Yoast / static HTML / etc.)
  - `categories_scanned` (numbers + names)
  - `target` (working directory path OR URL)
