# Scan Selection — one contract for choosing what gets scanned

Everything between "the user asked for an audit" and "the categories are locked in" lives here:
the preset menu (STEP 1), the component-driven recommendation (STEP 1.5), the audit-mode fork
(STEP 1.6), the confirm-categories gate (STEP 1.7), and the category picker both the menu and the
gate parse with. SKILL.md carries the summaries; this file is authoritative for the menus,
algorithms, display blocks, and branch handling. **Read it before showing the menu or presenting
the recommendation.**

Category numbers, aliases, and group keywords resolve against `categories/_index.md`, which is the
manifest of record. Preset → category mappings live in `references/category-groups.md`.

# Part 1 — The scan menu (STEP 1)

## Scan Selection Menu

Display this menu when no arguments are provided:

```
SEO & Marketing Audit for [project-name or domain]

What would you like to scan?

[1]  Quick Audit (Recommended), 12-13 highest-impact cats. ~16-27K tokens. ~5-10 min small / ~15-30 min large
[2]  Technical SEO, 15 cats (crawl & indexing, title/meta, performance, mobile/a11y). ~22-34K tokens. ~15-30 min
[3]  Content & Structure, 18 cats (headings, content quality, internal linking, E-E-A-T, keyword research). ~26-39K tokens. ~15-30 min
[4]  Schema & Structured Data, 3 cats (JSON-LD presence, per-type validation across all supported types, rating honesty). ~11-19K tokens. ~10-20 min
[5]  Conversion & Trust, 12 cats (CTAs, forms, trust signals, 404 pages, image quality, accessibility conformance, analytics + UTM hygiene, copy lint, comparison pages, lead magnets). ~21-34K tokens. ~20-40 min
[6]  International, 4 cats (hreflang, locale canonicals, lang attribute, translation quality). ~6-10K tokens. ~5-10 min
[7]  Email & Transactional, 3 cats (inventory + templates, deliverability, compliance). ~8-14K tokens. ~15-30 min
[8]  Off-site & Channels, 16 cats. ~32-53K tokens. ~50-95 min
[9]  2026 Modern Marketing, 4 cats (AI-search citation incl. llms.txt, partner & sponsorship programs, founder-led brand, agent operability). ~10-18K tokens. ~20-35 min
[10] Full Audit, all 94 categories. ~141-198K tokens. ~130-245 min. **CONFIRM BUDGET FIRST**
[11] Custom Selection, pick categories by name or number
[12] Diff Mode, audit changes since previous run (source mode: changed files since last commit; crawl mode: delta vs previous snitchfindings/{slug}/ report). Cost scales with diff size

Vertical presets (curated subsets per business type):
[13] B2B SaaS preset, 21 cats. ~32-45K tokens. ~30-60 min
[14] E-commerce preset, 21 cats. ~34-57K tokens. ~30-60 min
[15] Local business preset, 18 cats. ~29-48K tokens. ~30-50 min
[16] Publisher / media preset, 21 cats. ~33-56K tokens. ~45-75 min
[17] Accessibility deep-dive, 7 cats (WCAG 2.2 AA conformance, semantics, alt text, contrast, viewport). ~14-26K tokens. ~30-60 min

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
- **1 (Quick Audit):** Always include: 1 (robots.txt), 2 (sitemap.xml), 3 (canonical), 4 (indexability), 9 (title tag), 10 (meta description), 11 (Open Graph), 15 (single H1), 25 (image alt presence), 31 (JSON-LD presence). Then run stack detection (`references/smart-detection.md`) and add the 2-3 stack-specific cats listed under "Quick Audit (menu Option 1)" in `references/category-groups.md`.
- **2-9 (Presets):** Scan the predefined category group. Read `references/category-groups.md` for group → category mappings.
- **10 (Full):** All 94 active categories. Warn user about token cost. **Require explicit confirmation** ("yes, I confirm the ~141-198K token budget") before launching.
- **11 (Custom):** Present the category picker in Part 3 of this file.
- **12 (Diff):** Two paths depending on mode:
  - **Source mode**: run `git diff HEAD --name-only`, scan only changed files plus their declared route layouts / heads.
  - **Crawl mode**: detect previous report at `{working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md`. If found, parse the previous findings list, run the same selected cats fresh, then synthesize a delta report with: resolved findings, new findings, unchanged findings, severity-changed findings. Archive the previous report to `SEO_AUDIT_REPORT.{prev_date_iso}.md` in the same directory before overwriting. The new report's "Comparison to previous audit" section gets populated automatically (per `references/report-template.md`'s INCLUSION RULE).
  - **No previous report in either mode**: fall back to the current preset selection or to Quick Audit. The user is informed that this is a first-time scan; diff mode produces nothing meaningful without a baseline.
- **13-17 (Vertical presets):** B2B SaaS / E-commerce / Local business / Publisher / Accessibility. Read `references/category-groups.md` for Group 11-15 → category mappings. Pick the preset that matches the brand's business model from STEP 0.5.
- **c (Confidence floor):** Toggle between `all` / `medium+` / `high+only`, for this scan only. What each level renders is defined once, under `confidence-floor` in `snitch-marketing.config.md`. Detection runs at every level, so passed-checks evidence is always captured; the floor changes what is rendered, not what is scanned.
- **r (Rationale):** Toggle whether the executor prints the "why these cats?" block before the first category scans. Default: on. The block names the selected cats and the signal that added each one, then offers `[r]` (hide next time) / `[c]` (confirm and proceed) — the last veto before tokens spend:

  ```
  Selected categories for [target]:
  - Cats 1, 2, 3, 4, 9, 10, 11, 15, 25, 31, fundamentals (always included)
  - Cat 16, 39, 44, added for Next.js (per references/category-groups.md stack rules)

  [r] hide rationale on next scan / [c] confirm and proceed
  ```
- **v (Confirm Categories):** Toggle whether STEP 1.7 displays the resolved cat list with skip/only options before scanning. Default: on. Disable for batch / CI runs.
- **Invalid input:** Display "Invalid choice. Please enter 0-17, c, r, or v." and re-display menu.
- **Arguments provided:** Skip menu, parse arguments, proceed to scan.

## When the menu MUST fire vs MAY be bypassed

The menu fires by default when no preset is named. The user's words decide:

- **Authorize bypass (preset is explicit):** "run quick", "run full", "full audit", "run technical SEO", "schema audit", "B2B SaaS audit", "diff mode", "crawl mode", "audit at high+only confidence", "audit cats 1-10". The user named the preset OR the explicit category list — proceed without showing the menu, but still show the resolved cat list per STEP 1.7 unless `[v]` is off.
- **Require menu (instruction is ambiguous):** "run it", "audit", "scan", "go ahead", "check it out", "what does it find", "let's see", "what should we do here". The user wants something audited but didn't pick a scope — show the menu, suggest a preset per STEP 1.5, wait for selection.

When in doubt, show the menu. Tokens spent on a bad scope are far more expensive than the 30 seconds the menu costs.

# Part 2 — STEPS 1.5 to 1.7, the full contract

**STEP 1.5: Component-driven Recommendation**

Build the recommended scan from the component inventory produced by STEP 0.8, using `references/component-cat-map.md` to map each detected component to its applicable cats. Universal-foundation cats run regardless of components; component-specific cats are added per detected component.

Algorithm (deterministic, evidence-based):

```
recommended_cats = set(universal_foundation_cats)  # 24 cats from component-cat-map.md
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

`[1]` → STEP 1.7 (Confirm Categories) for a final list review. `[2]` → STEP 1.7 with the recommended list pre-populated. `[3]` → show the named shortcuts list and run the chosen one. `[4]` → the category picker in Part 3. `[5]` → fall through to the full menu in Part 1.

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

After preset selection (and after STEP 1.5 / 1.6 if they ran), resolve the preset to its full category list and display it BEFORE scanning. This is the highest-leverage token-saver: customers running on a brand-new site without analytics can drop the analytics cats in one keystroke and save tokens.

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
- "skip 53,73,99", drop those cats from the run (saves ~5K tokens)
- "only 1,2,3,9,10,31", run only these (overrides preset)
- "back", return to STEP 1
```

Parse the input with the picker parser in Part 3 (same syntax, comma-separated numbers + ranges). Compute the new token estimate after the user's edits and re-display:

```
Updated: 9 cats. Estimated cost: ~13-19K tokens. Run? [y/n]
```

Only proceed to STEP 2 after explicit confirmation. If `confirm-categories: false` is set in `snitch-marketing.config.md` OR the user picked `[v]` to disable in the menu, skip this step (suitable for batch / CI runs).

**Why this step:** the preset is a guess at what to run. The user often knows their brand's surface better than the heuristic does. Letting them drop the obviously-irrelevant cats BEFORE tokens spend is the cleanest token-saver in the audit.

# Part 3 — The category picker (used by the Custom option and by STEP 1.7)

The user picks categories by number, by range, or by name.

## Display this menu

```
Pick categories to scan. Comma-separated numbers, ranges, or names.

Examples:
  1,2,3              -> Cat 1, 2, 3
  1-8                -> all crawl & indexing
  31,32,94          -> the whole schema surface
  title,canonical    -> Cat 9, Cat 3
  schema             -> all schema.org categories (31, 32, 94)
  conversion         -> Cat 60
  perf               -> all performance categories (39-44)

[ enter selection ] >
```

## Name → category number mapping

The picker accepts either category number or a friendly alias. Map:

A per-type schema alias (`product-schema`, `recipe`, `jobposting-schema`, …) resolves to Cat 32,
which runs that type's row from `references/standards-table.md`; the reserved numbers those types
used to carry (33-38, 87-93) are not selectable. If the user types one of those numbers, say which
category now owns the check and select 32.

A `Cat #` cell reading `→ snitch-<skill>` is not a category: the judge for those findings lives in
a sibling skill. Name the skill, then call the Skill tool with it — the same handoff the reserved
number's `moved→snitch-<skill>` row in `categories/_index.md` produces.

| Alias | Cat # | Group keywords |
|---|---|---|
| `robots` / `robots.txt` | 1 | crawl |
| `sitemap` / `sitemap.xml` | 2 | crawl |
| `canonical` | 3 | crawl, dup |
| `noindex` / `indexability` / `meta-robots` | 4 | crawl |
| `soft-404` / `404` | 5 | crawl |
| `redirects` / `redirect-chains` | 6 | crawl |
| `pagination` / `rel-prev-next` | 7 | crawl |
| `meta-refresh` | 8 | crawl |
| `title` / `title-tag` | 9 | meta |
| `meta-description` / `description` | 10 | meta |
| `og` / `open-graph` | 11 | meta, social |
| `twitter` / `twitter-card` | 12 | meta, social |
| `favicon` | 13 | meta |
| `manifest` / `web-manifest` | 14 | meta |
| `h1` / `single-h1` | 15 | structure |
| `headings` / `heading-hierarchy` | 16 | structure |
| `semantic-html` / `semantic` | 17 | structure |
| `thin-content` / `word-count` | 18 | content |
| `internal-links` / `link-graph` / `orphan` | 19 | links |
| `broken-links` / `broken-internal` | 20 | links |
| `anchor` / `anchor-text` | 21 | links |
| `breadcrumbs` / `breadcrumb-markup` | 22 | links, schema |
| `footer-spam` / `footer-links` | 23 | links |
| `external-links` / `nofollow` / `rel-attrs` | 24 | links |
| `alt` / `alt-text` / `image-alt` | 25 | images |
| `alt-quality` | 26 | images |
| `image-format` / `webp` / `avif` | 27 | images, perf |
| `image-dims` / `width-height` / `cls` | 28 | images, perf |
| `lazy-load` / `lazy-loading` | 29 | images, perf |
| `video-sitemap` / `videositemap` | 30 | media |
| `json-ld` / `jsonld` / `structured-data` | 31 | schema |
| `schema-types` / `type-validation` / `article-schema` / `article` / `breadcrumb-schema` / `breadcrumblist` / `product-schema` / `product` / `faq-schema` / `faq` / `howto-schema` / `howto` / `org-schema` / `organization` / `website-schema` / `video-schema` / `videoobject` / `recipe-schema` / `recipe` / `recipe-rich-result` / `course-schema` / `course` / `online-course` / `event-schema` / `event` / `event-rich-result` / `jobposting-schema` / `job-posting` / `google-for-jobs` / `careers-schema` / `softwareapplication-schema` / `app-schema` / `saas-schema` / `webapplication` / `localbusiness-schema` / `local-schema` / `nap-schema` / `person-schema` / `author-schema` / `eeat-author` / `byline-schema` | 32 | schema, media, food, education, events, hiring, saas, local, eeat |
| `font-loading` / `font-display` | 39 | perf |
| `render-blocking` | 40 | perf |
| `critical-css` / `critical-path` | 41 | perf |
| `third-party-scripts` / `third-party` | 42 | perf |
| `image-weight` | 43 | perf, images |
| `bundle-weight` / `js-weight` | 44 | perf |
| `viewport` | 45 | mobile, a11y |
| `touch-targets` / `touch-target-size` | 103 | mobile, a11y |
| `text-zoom` / `readable-text` | 103 | mobile, a11y |
| `aria` / `aria-labels` | 103 | a11y |
| `contrast` / `color-contrast` | 103 | a11y |
| `hreflang` | 50 | i18n |
| `locale-canonical` / `locale-canonicals` | 51 | i18n |
| `lang-attr` / `html-lang` | 52 | i18n |
| `ga4` / `analytics` / `analytics-instrumentation` | 53 | analytics |
| `gtm` / `tag-manager` | 53 | analytics |
| `event-taxonomy` / `events` | 53 | analytics |
| `consent` / `consent-mode` / `cookie-banner` | → snitch-adsready | analytics, privacy |
| `topical-depth` / `topic-depth` | 57 | content |
| `keyword-intent` / `intent` / `keyword-targeting` | 58 | content |
| `ai-content` / `ai-tells` / `slop` | 59 | content |
| `conversion` / `cta` / `trust-signals` | 60 | conversion |
| `email-inventory` / `email-list` / `transactional-list` / `email-templates` | 61 | email |
| `email-content` / `email-copy` | 61 | email |
| `email-deliverability` / `spf` / `dkim` / `dmarc` | 63 | email, deliverability |
| `email-design` / `email-rendering` / `email-a11y` | 61 | email, a11y |
| `email-compliance` / `unsubscribe` / `can-spam` / `bulk-sender` | 65 | email, compliance |
| `paid-search` / `google-ads` / `bing-ads` / `ppc` / `paid-channel-presence` | 66 | paid, off-site |
| `paid-social` / `meta-ads` / `linkedin-ads` / `tiktok-ads` | 66 | paid, off-site |
| `organic-social` / `social-presence` / `linkedin` / `twitter` | 68 | off-site |
| `backlinks` / `link-building` / `referring-domains` | 69 | off-site, seo |
| `content-strategy` / `editorial-cadence` / `blog-strategy` | 70 | off-site, content |
| `lifecycle-email` / `drip` / `newsletter-marketing` | 71 | off-site, email |
| `community` / `discord` / `slack-community` | 72 | off-site |
| `cro` / `conversion-rate` / `ab-test` / `funnel` | 73 | off-site |
| `reviews` / `testimonials` / `social-proof` / `nps` | 74 | off-site |
| `brand-consistency` / `cross-channel-brand` | 75 | off-site, brand |
| `partnerships` / `integrations` / `co-marketing` / `partner-programs` | 76 | off-site, 2026 |
| `pr` / `launches` / `press` / `product-hunt` / `hacker-news` | 77 | off-site |
| `affiliate` / `referral-program` | 76 | off-site |
| `local-seo` / `google-business-profile` / `gbp` / `gbp-depth` / `gbp-deprecation` | 79 | off-site, local |
| `plg` / `product-led-growth` / `viral-loop` | 80 | off-site |
| `positioning` / `value-prop` / `differentiation` | 81 | off-site, brand |
| `ai-search` / `llm-citation` / `chatgpt-cite` / `perplexity` | 82 | 2026, off-site |
| `creator-partnerships` / `creator-marketing` / `mid-tier-influencer` | 76 | 2026, off-site |
| `founder-led` / `personal-brand` / `founder-channel` | 84 | 2026, off-site |
| `sponsorships` / `newsletter-sponsorship` / `podcast-sponsorship` | 76 | 2026, off-site |
| `keyword-research` / `keyword-strategy` / `intent-mapping` / `serp-clustering` / `query-research` | 86 | content, strategy |
| `review-schema` / `aggregate-rating` / `aggregaterating` / `rating-schema` | 94 | schema, reviews |
| `programmatic-seo` / `programmatic` / `templated-pages` / `pseo` | 95 | content, scale |
| `brand-serp-defense` / `brand-serp` / `branded-search-defense` | 96 | brand, off-site |
| `content-decay` / `content-refresh` / `content-pruning` / `content-audit` | 97 | content, lifecycle |
| `internal-site-search` / `site-search` / `search-analytics` | 98 | content, analytics |
| `conversion-funnel-deep` / `funnel-audit` / `journey-audit` / `funnel-walking` | 99 | conversion, journey |
| `cookieless-analytics` / `cookieless` / `server-side-tagging` / `capi` / `enhanced-conversions` / `consent-mode-v2` | → snitch-adsready | analytics |
| `ai-agent-commerce` / `agent-shopping` / `agent-commerce` / `chatgpt-commerce` | 101 | commerce, future |
| `multi-llm-citation` / `per-llm-citation` / `llm-differentiation` | 82 | ai-search, future |
| `wcag22` / `wcag-conformance` / `accessibility-conformance` / `aa-conformance` | 103 | a11y, legal |
| `keyboard-navigation` / `keyboard-a11y` / `focus-management` | 103 | a11y |
| `screen-reader-semantics` / `screen-reader` / `aria-semantics` | 103 | a11y |
| `llms-txt` / `llms.txt` / `llmstxt` / `ai-crawler-file` | 82 | 2026, ai-search |
| `pixel-completeness` / `pixel-install` / `pixel-inventory` / `pixel-audit` / `capi-audit` | → snitch-adsready | ads, measurement |
| `utm-hygiene` / `utm-consistency` / `utm-audit` / `parameter-hygiene` | 53 | ads, measurement |
| `message-match` / `landing-page-match` / `ad-lp-match` / `lp-message-match` | 109 | ads, conversion |
| `icp-scoring` / `icp-wedge` / `wedge-scoring` / `segment-scoring` | → snitch-cmo | strategy, positioning |
| `trust-artifact` / `trust-audit` / `trust-strip` / `founder-face` | 60 | trust, conversion |
| `pricing-strategic` / `pricing-read` / `pricing-strategy` / `pricing-mix` | → snitch-cmo | pricing, strategy |

## Group keywords

These expand to a list of categories:

| Keyword | Expands to |
|---|---|
| `crawl` | 1, 2, 3, 4, 5, 6, 7, 8 |
| `meta` | 9, 10, 11, 12, 13, 14 |
| `structure` | 15, 16, 17, 18 |
| `links` | 19, 20, 21, 22, 23, 24 |
| `images` | 25, 26, 27, 28, 29, 30 |
| `schema` | 31, 32, 94 |
| `perf` | 39, 40, 41, 42, 43, 44 |
| `mobile` | 45, 103 |
| `a11y` | 17, 25, 45, 52, 103 |
| `i18n` | 50, 51, 52 |
| `analytics` | 53, 98 |
| `content` | 18, 57, 58, 59, 86, 97 |
| `strategy` | 70, 81, 86, 95, 96 |
| `trust` | 60, 74, 84, 96 |
| `pricing` | 60, 115 |
| `positioning` | 81 |
| `food` | 32 |
| `education` | 32 |
| `events` | 32 |
| `hiring` | 32 |
| `saas` | 32 |
| `eeat` | 32 |
| `reviews` | 74, 94 |
| `scale` | 95 |
| `lifecycle` | 71, 97 |
| `journey` | 73, 99 |
| `future` | 101 |
| `legal` | 103 |
| `commerce` | 32, 94, 101 |
| `ai-search` | 82 |
| `social` | 11, 12 |
| `conversion` | 60 |
| `dup` | 3, 6, 7, 51 |
| `email` | 61, 63, 65 |
| `deliverability` | 63, 65 |
| `compliance` | 65 |
| `paid` | 66 |
| `off-site` | 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 79, 80, 81, 82, 84 |
| `2026` | 76, 82, 84 |
| `ads` | 66, 76, 109 |
| `measurement` | 53, 109 |
| `brand` | 75, 81, 84 |
| `local` | 79 |

## Parsing rules

- Comma separates items.
- Hyphen between numbers means a range, inclusive.
- A bare name (no number) is looked up in the alias table.
- A bare keyword from the group table expands to its categories.
- Mixed input is allowed: `1, schema, 60` → `[1, 31, 32, 94, 60]`.
- Duplicate numbers across input are deduplicated.
- A number with no row in `categories/_index.md` is rejected with "Cat N is not a valid category. Run with no arguments to see the menu." A number whose row is not `active` is answered with the row's Status: a `merged→NN` number selects `NN` instead and says so; a `moved→snitch-<skill>` number is handed off by calling the Skill tool with that skill; a `deleted` number is answered with "Cat N was retired and nothing inherited it" and dropped from the run. The manifest is the authority for which numbers exist and which of them run; never hardcode the upper bound.
- Unknown names are rejected with "I don't recognize 'foo'. Use a number, or one of: {first 10 alias keywords}."
