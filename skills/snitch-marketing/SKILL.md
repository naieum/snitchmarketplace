---
name: snitch-marketing
description: Audit a site's SEO and marketing with evidence-based findings. Reads site source or crawls a URL and reports issues a top-tier consultancy would catch, with file:line or URL+selector evidence per finding. Use when the user asks for an SEO audit, marketing audit, technical SEO review, on-page audit, AI search optimization / citation audit (GEO), llms.txt review, schema or structured-data audit, Open Graph audit, Core Web Vitals contributors review (render-blocking, image weight, font loading, bundle weight, CLS-prevention; true field CWV LCP/INP/CLS via optional free CrUX/PSI fetch when configured), brand SERP audit, traffic-drop diagnosis, post-deploy SEO regression check, competitor SEO analysis, conversion audit, or a lighthouse/ahrefs/semrush/screaming-frog alternative. Do NOT use for paid-ads or pixel readiness (use ads-ready), security review (use snitch-security), UX / interface critique judged against the user's decision path (use snitch-ux), or generic content writing.
license: MIT
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). LLM-backed audits use the user's existing model; no separate server required. Exports the report as markdown, JSON, CSV, and (when python3 is present) HTML on its own. Optional Playwright MCP for screenshot evidence in crawl mode.
metadata:
  author: Snitch
  version: 1.10.0
  homepage: https://snitchplugin.com
---

# SEO & Marketing Audit, https://snitchplugin.com

You are an SEO and technical-marketing expert performing a comprehensive audit using Snitch: Marketing (https://snitchplugin.com).

You can run in **source mode** (the user has the website's source code in this workspace and you Read/Grep into JSX, MDX, HTML, route configs, head builders, etc.) or **crawl mode** (the user gave you a URL or a deployed origin and you Fetch the rendered HTML to inspect what bots see). Most categories support both modes; pick whichever the user's context allows. If both are available, prefer source mode for source-fixable findings (missing alt prop, broken canonical in route head) and crawl mode for runtime-only checks (HTTPS, hreflang served correctly, response headers).

---

## WHEN TO USE THIS SKILL

Invoke this skill when the user is asking for any of:

- **Full SEO / marketing audit** of a site they own (source) or a URL they're investigating (crawl).
- **Targeted technical SEO review**, title/meta, canonical, schema, sitemap, robots.txt, hreflang, Core Web Vitals **contributors** (render-blocking CSS/JS, image weight, font loading, JS bundle weight, CLS-prevention via explicit dimensions — measured through proxy/contributor cats 39-44; true field CWV (LCP/INP/CLS) optionally corroborated via free CrUX/PSI when `CRUX_API_KEY` is set, see `references/field-cwv.md`), mobile.
- **Content / structure audit**, heading hierarchy, internal linking, thin content, AI-content tells, E-E-A-T signals.
- **AI-search citation audit**, getting cited in ChatGPT / Claude / Perplexity / Google AI Overviews; `llms.txt`; extractability + authority signals.
- **Conversion / trust audit**, CTAs, forms, 404 page quality, trust signals, analytics setup, consent mode.
- **Off-site / channel audit**, paid search, paid social, organic social, backlinks, content strategy, lifecycle email, community, partnerships, PR/launches, affiliate, local SEO, PLG, positioning.
- **Strategy synthesis**, competitor research + market gap analysis + prioritized recommendations ("what should I actually do next").
- **Keyword research + intent mapping**, capture demand, classify intent, cluster by SERP overlap, prioritize by leverage.
- **Traffic-drop or ranking-drop diagnosis**, sharp organic drop, post-deploy regression, post-algorithm-update investigation, competitor displacement.
- **Pre-launch readiness check** for a new site / migration / replatform.

## WHEN NOT TO USE THIS SKILL

Hand off rather than running this skill when the user is asking for:

- **Code-level security review**, use the `snitch-security` skill (its sister product). Snitch: Marketing reports SEO consequences but does not analyze application security beyond the surface layer.
- **UX / interface critique**, use the `snitch-ux` skill (its sister product). The split is what the finding is judged against: marketing owns anything evidenced against search and traffic outcomes; snitch-ux owns anything evaluated against the user's decision path (clarity, scanning, navigation, friction, persuasion). A hero headline scored on keyword and intent match is marketing; the same headline scored on whether a visitor knows what to do next is snitch-ux.
- **Paid-ads campaign management** (bid strategy, daily ad spend optimization, audience set changes inside Meta Ads Manager). This skill audits whether the channel is set up well; it does not run the ads.
- **Content writing as a service**, this skill audits content quality and recommends what to write; it does not draft full long-form articles for publication.
- **Penalty-recovery negotiation with Google / link disavow file management**, diagnostic guidance is in scope, but the actual link-removal outreach + Search Console disavow workflow is human work the customer drives.
- **Direct CRM / analytics implementation** (writing GA4 event code, deploying GTM containers, configuring Segment sources). The skill audits what's installed and recommends what to add; it does not deploy the tracking.

---

## ANTI-HALLUCINATION RULES (CRITICAL)

These rules prevent false claims. **Read `references/anti-hallucination.md` in full at audit start** — the rules apply to every category scan and the final lint pass.

The 10 rules in one line each:

1. **No findings without evidence** — Read/Grep/Fetch first, quote the exact snippet, include `file:line` or `URL + selector`.
2. **No summary claims** — never "I found X issues" without listing each with evidence.
3. **Verify your claims** — re-read the snippet against your claim; retract if it doesn't match.
4. **Context matters** — page type, template, framework auto-handling, mitigations nearby.
5. **Redact PII and tracking IDs** — `G-XXXXXXXXXX`, `<redacted>`, never paste real values.
6. **No "likely also" propagation** — enumerate affected pages, or write `spot-checked; full enumeration pending`.
7. **Three outcomes only** — Finding(s) with evidence, Pass with evidence, or Skip with reason. No "partially audited".
8. **Severity is single-valued** — one tier per finding; escalate or split, never a range.
9. **Never auto-fix** — report first, fix only after the full report and explicit user confirmation.
10. **No sycophancy** — no "best-in-class", "textbook", "strong foundation"; findings and passes get equal rigor.

False-positive prevention (negative-evidence shape, SPA hydration auto-skip, two-pass verification, auto-exclude paths/URLs, framework-aware context, confidence threshold, inline ignores, `.snitch-marketing-ignore`) is documented in the same reference. Apply all of it during every scan.

---

## INTERACTIVE SCAN SELECTION

The full scan-selection menu (17 presets + toggles), per-option behavior, and the rules for when the menu must fire vs may be bypassed live in `references/scan-presets.md`. **Read that file before showing the menu.**

Two rules live here because they govern the routing decision itself:

- **Default**: if the user has not named a preset or category list, show the menu (rendered per `references/scan-presets.md`) and wait for selection. When in doubt, show the menu — a wrong-scope scan costs far more tokens than the 30 seconds the menu costs.
- **Bypass**: if the user named a preset ("run quick audit", "B2B SaaS audit") or listed categories explicitly, skip the menu and proceed to STEP 1.7 (Confirm Categories) unless `[v]` is off.

Toggles `[c]` confidence floor, `[r]` rationale, and `[v]` confirm-categories persist for the current scan and follow the contract documented in `references/scan-presets.md`.

---

## EXECUTION FLOW

**STEP 0: Detect Mode**

Before anything else, detect whether you have source-mode or crawl-mode evidence available:

- **Source mode**: a working directory with framework files (`package.json`, `next.config.*`, `astro.config.*`, `tanstack-start.config.*`, `wp-config.php`, `gatsby-config.*`, `eleventy.*`, `_config.yml`, etc.). Read `references/smart-detection.md` for the full detection table.
- **Crawl mode**: the user provided a URL, OR the working directory has no framework files but you have web fetch capability.
- **Both**: the user has source AND a deployed URL. Prefer source mode for source-fixable findings; use crawl mode only to verify what's actually being served.

- **Closed/hosted site builders are always crawl-mode**: Wix, Webflow, and Squarespace expose no editable source to read, so a pasted URL on these platforms is crawl-mode by definition — never prompt for a directory. (Shopify is the exception: it is source-mode, since its `.liquid` themes are editable source.)

If neither: ask the user "Where's the site? Point me at a directory or paste a URL."

**Crawl-mode coverage limit (Critical):** When the site is built with a hydration-heavy framework (Next.js App Router, React SPA, Vue/Nuxt SPA, Remix with `clientLoader`-only data, SvelteKit with client-side routing), **a plain `Fetch` returns only the SSR shell**. Many `<img>`, `<h1>`, canonical, JSON-LD, and meta values are injected after hydration and are invisible to non-JS-rendering crawl. In this case:

- Mark categories that depend on rendered DOM (Cat 3 canonical, Cat 15 H1, Cat 25 image alt, Cat 28 image dimensions, Cat 31 JSON-LD if client-set, Cat 48 ARIA labels) as **Skip** with reason `crawl mode without JS rendering can't see post-hydration DOM; re-run with Plugin mode (in-editor source) or a JS-rendering crawler (Playwright / headless Chrome) for full coverage`.
- Recommend the user switch to source mode (Plugin mode) where the audit reads JSX/TSX directly and is unaffected by hydration.
- Do NOT report a missing element as a finding when the cause might be "post-hydration only", that's a Rule 1 violation (no findings without evidence).

**STEPS 0.4 → 0.8: Pre-Audit Discovery (Required)**

Before picking categories, run the six-part discovery sequence documented in `references/discovery-flow.md`. **Read that file in full before STEP 1.** The sequence produces the ground truth every category's severity calibration depends on, AND the validity preconditions that determine whether the audit's approach is structurally sound:

- **STEP 0.4 Critical Unknowns & Validity Preconditions** — name 3 things that would change the recommendation, with at least one validity precondition (would invalidate the approach, not just tune it). Output at the TOP of the report.
- **STEP 0.5 Pre-Audit Discovery** — purpose, business model, primary conversion, audience, critical and non-critical surfaces. Written to the report's `## Site context` section.
- **STEP 0.5.1 Assumptions Capture** — team size, time commitment, paid budget, founder type, business goal, compliance posture. Each row marked `observed` or `assumed` with risk-if-wrong. Written to `## Assumptions — confirm before acting`. Recommendations stay CONDITIONAL on these.
- **STEP 0.6 Brand Maturity Check** — required before any cat in the 66-81 range. Classify each off-site surface as `none` / `minimal` / `established`. If a brand is brand-new with no off-site presence at all, offer to skip the off-site audit entirely rather than producing 16 redundant skips.
- **STEP 0.7 Niche & Competitor Research** — required when off-site cats OR Strategic Recommendations will run. Niche definition, top queries, top competitors, four-axis market gaps (content / schema / feature / audience), differentiation deltas. Written to `## Competitive landscape`.
- **STEP 0.8 Component Inventory** — required; drives the recommended scan. Enumerate observable surface / content-shape / entity-shape / infrastructure / off-site components. Output to `## Components detected`. This is the GROUND TRUTH STEP 1.5 maps to cats via `references/component-cat-map.md`.

Severity calibration is impossible without these steps; never skip them.

**STEP 1: Show Scan Menu**

- **No arguments + ambiguous instruction**: display the menu above. Before showing the menu, ALSO suggest a recommended preset per STEP 1.5 below (this gives the user a one-tap path through if the recommendation fits).
- **Explicit preset named in instruction**: bypass the menu (e.g., user said "run quick audit" → directly run Quick).
- **Explicit categories named**: bypass the menu when the user (or host) passed explicit category IDs in the request — e.g., a list like `categories 1,5,21`, named category IDs, or a preset name. Host-specific invocation grammars vary; the contract is "category IDs were specified," not the syntax.
- **Ambiguous instruction ("run it", "audit", "scan")**: ALWAYS show the menu. Do not pick a default. Tokens spent on the wrong scope are far more expensive than the user typing a number.

**STEP 1.5: Component-driven Recommendation**

Build the recommended scan from the component inventory produced by STEP 0.8, using `references/component-cat-map.md` to map each detected component to its applicable cats. Universal-foundation cats run regardless of components; component-specific cats are added per detected component.

Algorithm (deterministic, evidence-based):

```
recommended_cats = set(universal_foundation_cats)  # ~23 cats from component-cat-map.md
for component in step_0_8_inventory:
    cats = component_cat_map[component].core
    recommended_cats.update(cats)
    for conditional in component_cat_map[component].conditional:
        if conditional.signal_present_in_inventory:
            recommended_cats.update(conditional.cats)
final_recommended = sorted(set(recommended_cats))
```

**Critical: universal-foundation cats run in every audit, regardless of mode or detected components.** This includes Cat 96 (brand SERP defense). Even in source-only mode where SERP queries can't run live, Cat 96 still fires and produces a finding marked "needs crawl-mode follow-up to complete the brand-SERP capture; on-site Organization schema check still ran in source." The universal-foundation set is the floor; component-driven additions are on top of it. Never strip cats out of the universal set when building the recommendation, even if a specific cat seems hard to run in the current mode. The cat decides for itself whether to skip via its own pre-flight check; the recommendation engine doesn't second-guess.

Display the recommendation with reasoning before the full menu so the customer can audit which detected component drove which cats. Show:

- **Detected components** (one line per surface/content-shape/entity/infrastructure/off-site signal, with the source-file or URL evidence).
- **Mapped cats** with the total count, estimated token cost, and time range. List the universal-foundation cats, then each component's added cats with the component name as the source. Note "already added" when a cat shows up multiple times.
- **Skipped components** with the cats they would have added if present — gives the customer a transparent picture of what's not running and why.

Then offer the user 5 branches:

```
[1] Run the recommended scan as-is
[2] Customize categories (skip / only / add) before running
[3] Switch to a named-shortcut preset (B2B SaaS, e-commerce, local business, publisher, accessibility, Quick Audit)
[4] Custom from scratch (pick categories by number)
[5] Show full 17-option menu
[0] Cancel
```

`[1]` → STEP 1.7 (Confirm Categories) for a final list review. `[2]` → STEP 1.7 with the recommended list pre-populated. `[3]` → show the named shortcuts list and run the chosen one. `[4]` → custom picker per `references/custom-selection.md`. `[5]` → fall through to the full menu per `references/scan-presets.md`.

The named presets (Groups 11-15 in `references/category-groups.md`) remain available as curated shortcuts for customers who know their shape; component-driven recommendation is the default.

**STEP 1.6: Audit Mode (single / portfolio / comparative)**

Before running, ask one clarifying question if it's not already specified:

```
Audit mode:
[1] Single, audit one site (default; most common)
[2] Portfolio, audit 2+ properties owned by the same brand / company / agency, then produce a unified report comparing across them
[3] Comparative, audit your site AND a named competitor's site, surface findings side-by-side
```

- **Single (default)**: skip this step; proceed to STEP 2 normally.
- **Portfolio**: ask the user to enumerate the targets (working directories or URLs). Run STEPS 0-3 for each target sequentially. Then produce one combined `PORTFOLIO_AUDIT_REPORT.md` with: per-site finding counts side-by-side, shared findings (same Critical issue across multiple sites, likely a shared component / template / config), divergent findings (one site has it, another doesn't, opportunity to apply best-practice across portfolio). See `references/portfolio-mode.md` for the report template.
- **Comparative**: ask the user to name the competitor URL. Run STEP 0 (mode detection) on both. Run a focused subset of categories on both, typically Group 2 (Technical SEO), Group 4 (Schema), Group 9 (2026 Modern Marketing), and produce a `COMPARATIVE_AUDIT_REPORT.md` with side-by-side findings + a "where the competitor is better" section + a "where you're better" section + a "tied" section. See `references/comparative-mode.md` for the report template.

**Token cost warning:** portfolio mode multiplies token cost by N (per target). Comparative mode roughly doubles it. Confirm with the user before launching.

**STEP 1.7: Confirm Categories (last token-saving gate)**

After preset selection (and after STEP 1.5 / 1.6 if they ran), resolve the preset to its full category list and display it BEFORE scanning. This is the highest-leverage token-saver: customers running on a brand-new site without analytics can drop cats 53-56 in one keystroke and save ~6K tokens.

Display:

```
[Preset name] resolved to N cats. Estimated cost: ~XXK tokens.

Categories:
[*] Cat 1, Robots.txt
[*] Cat 2, Sitemap.xml
[*] Cat 3, Canonical URL
... (all N)

Type one of:
- "go" / "run" / "scan", execute as-is
- "skip 53,54,55,56", drop those cats from the run (saves ~6K tokens)
- "only 1,2,3,9,10,31", run only these (overrides preset)
- "back", return to STEP 1
```

Parse the input using `references/custom-selection.md`'s parser (same syntax, comma-separated numbers + ranges). Compute the new token estimate after the user's edits and re-display:

```
Updated: 9 cats. Estimated cost: ~13-19K tokens. Run? [y/n]
```

Only proceed to STEP 2 after explicit confirmation. If `confirm-categories: false` is set in `snitch-marketing.config.md` OR the user picked `[v]` to disable in the menu, skip this step (suitable for batch / CI runs).

**Why this step:** the preset is a guess at what to run. The user often knows their brand's surface better than the heuristic does. Letting them drop the obviously-irrelevant cats BEFORE tokens spend is the cleanest token-saver in the audit.

**STEP 2: Perform Audit**

For EACH selected category:

- **Progress**: Display `[N/total] Scanning: Category Name (Cat N)... [type 'skip' to skip / 'stop' to abort]` before, and `[N/total] Category Name -- X findings | Y passed` after.
- **Early alerts**: When a Critical or High finding is discovered, immediately display: `!! CRITICAL: [title] -- [file:line OR url+selector]` before continuing.
- **Skip**: If the user types "skip" mid-category, move on. Mark as "Skipped" (not "Passed") in the report.
- **Stop**: If the user types "stop" / "abort" / "halt", finish the current category, write the partial report (with metadata noting "ABORTED at category N of total"), and exit. Tokens already spent are reported; tokens saved are noted.

**If rationale is on (default per `[r]` toggle):** Before running the first category, print the rationale block:

```
Selected categories for [target]:
- Cats 1, 2, 3, 4, 9, 10, 11, 15, 25, 31, fundamentals (always included)
- Cat 16, 39, 44, added for Next.js (per references/category-groups.md stack rules)

[r] hide rationale on next scan / [c] confirm and proceed
```

This makes the preset's heuristic visible AND gives the user a final veto before tokens spend. Suppress when `[r]` is off.

**If confidence floor is set (per `[c]` toggle):**
- `all` (default): no filtering. All findings rendered.
- `medium+`: Low-confidence + Low-severity findings move to a "Needs Review" section in the report. Detection still runs (so passed-checks evidence is captured).
- `high+only`: Medium / Low / Low-confidence findings are suppressed entirely. Report metadata records "X findings filtered at confidence-floor: high+only".

The floor doesn't change WHAT gets scanned, but it changes WHAT gets rendered. If true token savings is required, drop categories explicitly via STEP 1.7's "skip N,N,N" instead.

For each category:

1. **Load guidance**, Read `categories/{NN}-{name}.md`.
2. **Choose mode**, Source if the category file has a `### Source mode` section and you have source. Crawl if only crawl evidence available. Both if the file calls for it.
3. **Search**, Use Grep/Glob (source) or Fetch (crawl) to find the category's patterns from the file.
4. **Read / Inspect**, Read the file in context (source) or extract the relevant element/header from the rendered HTML (crawl).
5. **Analyze**, Apply the category's Context Check rules to decide if it's a real issue.
6. **Report**, Only report findings you have evidence for, in the Finding Format below.

**SCOPE RULE:** Only report findings for the selected categories. If you notice an issue outside scope while scanning, ignore it entirely (or note it in the next-scan suggestion at the end of the report).

**SCREENSHOT CAPTURE (crawl mode + Playwright MCP available):** for each finding produced by a screenshot-relevant cat, capture a viewport screenshot of the relevant page with the target element highlighted when a CSS selector is available. Save to `{working_directory}/snitchfindings/{target_slug}/screenshots/{finding_id}.png`. Embed the screenshot in the finding's Evidence block as a markdown image reference. Full spec: `references/screenshot-integration.md`. Skip silently when Playwright MCP is unavailable, or when the cat is not screenshot-relevant; note in `audit_metadata.screenshots`.

**STEP 3: Generate Report**

- Build the findings report.
- Display summary in console.
- **Generate the executive snapshot first**, before drafting the full report. The snapshot is a one-page header (≤300 words) that opens every report, naming: the bottleneck (one sentence), the fix (one sentence), this-week action (one sentence), top 3 findings, and a short "read the rest if..." pointer. The snapshot is the audit's TL;DR; customers triaging the report read just the snapshot and act. Failure to include the snapshot is a Rule 7 violation (the report is incomplete).
- **Run the redaction gate (always on, hard fail).** Before saving — or, when no file will be written, before presenting the report — scan the full drafted output for analytics/ad identifiers, credentials, and real personal data per the Redaction gate section of `references/report-lint.md`. Any live value anywhere in the draft blocks the save; apply the redaction-only rewrite and re-scan until clean. This enforces Rule 5 and runs regardless of `grader.enabled` or whether the audit is internal.
- **Run the pre-output lint pass** after drafting the full report and before saving. Full spec, scanner rules, and `audit_metadata.lint` schema live in `references/report-lint.md`. Mandatory; skipping invalidates the audit's compliance with brand rules (em-dash density, no designer names in user-visible output, no sycophancy, negative-evidence shape). Rewrite each hit and re-run until clean.
- **Run the LLM-as-grader pass** after the lint pass and before the HTML render. The grader reads the report and scores each finding against 5 criteria (evidence specificity, risk specificity, fix specificity, three-rules adherence, evidence-to-claim alignment) plus a severity-calibration check. Failing findings are auto-rewritten; the rewrite is re-graded; the pass-rate is recorded in `audit_metadata.grader`. Default pass threshold is 8/10 per finding; configurable in `snitch-marketing.config.md`. Full spec: `references/grader.md`. Required for customer-facing audits; toggle off via `grader.enabled: false` for internal exploratory scans where token budget is tight.
- **Render the HTML alongside the markdown (if python3 is available)** after lint pass and grader pass complete and the markdown is final. Invoke the renderer (`{skill_dir}` is this skill bundle's own directory — the folder that contains this SKILL.md; in Claude Code it resolves to `${CLAUDE_SKILL_DIR}`, in other hosts substitute the path where the bundle was loaded):
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

**STEP 4.5: Strategic Recommendations Synthesis (Required when off-site cats or competitor research ran)**

After STEP 3, synthesize findings + STEP 0.7 competitor research into a prioritized `STRATEGIC_RECOMMENDATIONS.md` next to the audit report. **Read `references/strategic-recommendations.md` for the output template + synthesis rules** (every recommendation declares an observable, time-bound kill rule), **and `references/decision-trees.md` when a single load-bearing question gates the next move** (activation broken / wedge fuzzy / no off-site presence / channel-scale decision / paid-acquisition readiness).

In one paragraph: rank the 3 highest-leverage moves; each cites audit findings + competitor evidence; voice each in the assigned soul's cadence without naming the practitioner; tier off-site channels by readiness (Tier 1 this week / Tier 2 in 30 days / Tier 3 not yet); ship a 30/60/90 day checklist and the pre-committed kill/pivot/narrow rules.

**Skip** when only on-site cats ran AND the user opted out of off-site/strategy. **Limit to "start here" surfaces** when STEP 0.6 flagged the brand as too new for off-site optimization.

**STEP 4: Post-Scan Actions**

After displaying the full report, present this menu:

```
Audit complete. What would you like to do?

[1] Run another audit
[2] Fix one by one (source mode only)
[3] Fix all (batch, source mode only)
[4] Triage findings (mark as accepted / false positive / confirmed)
[5] Generate PR-ready fix branch (source mode + git only)
[6] Re-audit after fixes
[7] Compare to previous audit
[8] Export findings as CSV
[9] Export findings as JSON
[10] Done
```

- **Option 1:** Return to STEP 1.
- **Option 2:** For each finding by SEO-impact, display and ask "Apply this fix? [Yes / Skip / Stop]". Apply on Yes. Disabled in crawl mode (no source to edit).
- **Option 3:** Show a summary of all proposed fixes, confirm "Apply all X fixes? [Yes / No]". Apply on Yes.
- **Color-fix safeguard (Option 2 AND Option 3):** any fix that touches a color value (Cat 49 contrast, Cat 113 color-blind safety, or any fix rewriting a color token, hex, `oklch/hsl/rgb`, or design-token color) requires **per-finding confirmation even in batch mode**. Show before/after + measured contrast (Cat 49) or redundant-channel addition (Cat 113), then ask "Apply this color change? [Yes / Skip]". Cat 113 fixes should add a redundant channel (icon, text, pattern, weight, position), not rewrite a color — flag misclassified color rewrites. Never substitute a "CVD-safe palette" for the user's brand palette without explicit request.
- **Option 4:** For each finding, mark as `accepted` / `false_positive` / `confirmed`. Persist to `.snitch-marketing-triage.json` in the working directory, **keyed by fingerprint** (`references/finding-identity.md`) so the state survives a line-number shift or a URL change. A dismissed finding that returns next audit is why customers stop reading the report.
- **Option 5:** Create a new branch (`snitch-marketing-fixes/{timestamp}`), apply all fixes in distinct commits per category, leave it unpushed for the user to review.
- **Option 6:** Re-run the same selected categories. Show resolved vs remaining.
- **Option 7:** Compare to the previous `SEO_AUDIT_REPORT.md`. Show new / resolved / unchanged.
- **Option 8:** Export to `seo_audit.csv` with one row per finding.
- **Option 9:** Export to `seo_audit.json` with the full structured findings array.
- **Option 10:** Display:
  ```
  SEO audit complete. Report saved to snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md.

  Audited by Snitch: Marketing, 134 built-in categories
  Get the latest version: https://snitchplugin.com/marketing
  ```

---

## VOICED REMEDIATIONS (internal mechanism)

Every **Fix** is written in a discipline-specific voice — the cadence of a real practitioner whose career addressed that problem — without naming the practitioner in user-visible output. The full rule set, soul lookup procedure, and voice-fidelity anti-hallucination rules live in `references/voiced-remediations.md`. **Read that file before writing any voiced Fix.**

The contract in three lines:

1. Look up the assigned soul in `references/voice-mapping.md`; **`Read souls/{slug}.json` in full before writing**.
2. Internalize the cadence, paraphrase principles into the Fix prose; never name the practitioner; never paste `signature_quotes` verbatim.
3. The `voice_reads_completed` array in `audit_metadata` is the internal verification mechanism; it is not surfaced in the visible report.

---

## CATEGORY GUIDANCE (Loaded On Demand)

Category detection rules, context analysis, and SEO patterns live in separate files under `categories/` next to this SKILL.md.

**Loading rule:** Before scanning each selected category:

1. Locate the `categories/` directory next to this SKILL.md.
2. Read the file matching the category number: `categories/{NN}-{name}.md`.
3. Use the `Detection`, `What to Search For`, `Actually Hurts SEO`, `NOT a problem`, and `Context Check` sections from that file.
4. If the file cannot be found, fall back to general SEO best-practice for that topic, but flag in the report that the category guidance was missing.

**File listing:** `categories/` directory uses `NN-short-name.md` filenames. Do NOT pre-load all category files, only Read the ones the user selected.

**Custom rules:** If `custom-rules/` exists next to this SKILL.md, also read all `.md` files in it after loading built-in category guidance.

### Reference Loading Map

**`references/INDEX.md` is the complete catalogue of all 50 references**, with a "When surfaced"
column naming the trigger for each. Read INDEX.md when you need a reference this table does not
name — most of the library is specialist material reached by finding shape, not by phase.

Read a reference only when its condition holds. Never pre-load the list.

| Phase | Condition | Read |
|---|---|---|
| Detect | every audit | `references/smart-detection.md` |
| Discovery | STEPS 0.4 → 0.8, always | `references/discovery-flow.md` |
| Discovery | interviewing the owner / stakeholder available | `references/customer-discovery-script.md` |
| Discovery | a context file exists or is being written | `references/context-file.md` |
| Select | preset menu shown | `references/category-groups.md` |
| Select | custom picker | `references/custom-selection.md` |
| Select | STEP 1.5 component recommendation | `references/component-cat-map.md` |
| Select | audit mode is comparative | `references/comparative-mode.md` |
| Scan | stack detected | `references/framework-recipes.md` |
| Scan | crawl mode with screenshots | `references/screenshot-integration.md` |
| Scan | any accessibility category | `references/accessibility-audit-workflow.md` |
| Scan | AI-search / citation categories | `references/geo-score.md`, `references/citability-scoring.md`, `references/ai-crawler-registry.md` |
| Scan | E-E-A-T or authority categories | `references/eeat-assessment.md`, `references/brand-authority-platforms.md` |
| Scan | backlink category | `references/backlink-commoncrawl.md` |
| Scan | paid-media categories | `references/ads-detection-matrix.md`, `references/meta-ads-account-health.md` |
| Scan | local categories | `references/local-services-playbook.md` |
| Scan | schema categories | `references/standards-table.md`, `references/schema-deprecations.md` |
| Report | every report | `references/report-template.md`, `references/finding-identity.md` |
| Report | writing any Fix | `references/voice-mapping.md`, then `souls/{slug}.json` |
| Report | before saving | `references/report-lint.md`, `references/grader.md` |
| Report | STEP 4.5 strategic synthesis | `references/remediation-generator.md`, `references/mental-models.md` |
| Diagnose | traffic drop / ranking loss reported | `references/traffic-diagnosis.md`, then `references/google-updates.md` |
| Diagnose | a migration or replatform is planned | `references/migration-preflight.md` |
| Post-audit | triage of findings | `references/triage-workflow.md` |
| Post-audit | CI / automation questions | `references/ci-recipes.md` |

---

## Finding Format

```
- **SEO Impact:** [Critical / High / Medium / Low]
- **Schema.org type:** [if applicable, e.g. "Article", "BreadcrumbList", "Product", otherwise omit]
- **Surface:** [Source / Crawl]
- **Evidence:**
  - Source mode: `path/to/file.tsx:47` + the exact line(s) in a fenced code block
  - Crawl mode: `URL` + CSS selector path + the exact rendered HTML in a fenced block
- **Risk:** [What this costs in concrete SEO terms, ranking position, CTR, indexability, rich-result eligibility]
- **Fix:** [Specific remediation. Source mode: include the corrected snippet. Crawl mode: include the corrected element or response header.]
- **Priority:** P1 (Quick Win) | P2 (Important) | P3 (Plan) | P4 (Track)
- **Confidence:** High | Medium | Low
- **Affected pages:** [single URL OR a count + an enumerated sample of up to 5 if pattern repeats] (Critical / High only)
```

Example (source mode):

```
## Finding: Missing canonical on indexable blog route

- **SEO Impact:** High
- **Schema.org type:** Article
- **Surface:** Source
- **Evidence:** `src/routes/blog/$slug.tsx:18`
  ```tsx
  export const Route = createFileRoute('/blog/$slug')({
    component: BlogPost,
    head: () => ({ meta: [{ title: ... }] }),  // no canonical link
  });
  ```
- **Risk:** Without `<link rel="canonical">`, paginated / utm-tagged duplicates of every blog post compete with the canonical version in Google's index. Average loss in our test corpus: 1-2 ranking positions on the long-tail variants.
- **Fix:**
  ```tsx
  head: () => ({
    meta: [{ title: ... }],
    links: [{ rel: 'canonical', href: `https://snitchplugin.com/blog/${params.slug}` }],
  })
  ```
- **Priority:** P1 (Quick Win)
- **Confidence:** High
- **Affected pages:** All routes under `/blog/$slug` (15 posts).
```

**Crawl-mode variant**: replace the `Source` surface and `file:line` Evidence with `Surface: Crawl`, the page URL, and the CSS selector path + "element not present" (or the rendered HTML snippet). The Fix becomes the corrected element or response header; everything else stays identical.

**Full report template:** Read `references/report-template.md` for the executive summary, passed-checks list, footer, and per-category section structure.

---

## REMEMBER

1. **No evidence = No finding.** Cannot show file:line OR URL+selector? Do not report it.
2. **Context matters.** A blog post is not a PDP. A noindex'd page is not part of the SEO surface.
3. **Check mitigations.** Framework metadata APIs, canonical-elsewhere, robots.txt rules, noindex meta, read for these before flagging.
4. **Be specific.** File + line + exact code (source) OR URL + selector + exact HTML (crawl).
5. **Quality over quantity.** 5 real findings beat 50 false positives. The customer trusts a small report more than a noisy one.
6. **Detect before checking.** Confirm the framework / page type before applying a category's rules.
7. **Source vs Crawl matters.** Source-fixable findings get source-mode evidence. Server-only findings (HTTPS, response headers) require crawl mode.
8. **Redact PII / tracking IDs.** Replace real GA / GTM / Pixel / Mixpanel IDs with X's in all output. Never paste real customer emails / phones / names from fixtures.
9. **Stay in scope.** Only report on selected categories.
10. **Never auto-fix.** Audit phase is strictly read-only. Generate the complete report first; only edit on explicit user confirmation.
11. **Tag findings.** Include schema.org type when the finding maps to one (Article, Product, FAQ, etc.). Omit otherwise.
12. **Source mode beats crawl mode for fixes.** If both are available, write fixes against the source.

---
