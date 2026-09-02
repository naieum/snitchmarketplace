---
name: snitch-adsready
description: Audit and set up paid-media ad readiness across Google, Meta, Microsoft / Bing, LinkedIn, TikTok, X, Pinterest, Reddit, Snapchat, and Apple Search Ads. Thin tools for the agent to compose. Audits pixel coverage, conversion tracking, Consent Mode v2, ads.txt, ad-crawler access, Core Web Vitals as a Quality Score input, the CSP / security-header changes a pixel needs, and the Product/Offer markup a shopping feed reads; offers idempotent fixes; recommends external tools (CMP, server-side GTM, CAPI helpers, Lighthouse and CWV monitoring). Triggers on audit my ads readiness, is my Meta Pixel installed, set up Google Ads conversion tracking, is my consent mode v2 wired up, should I add LinkedIn tracking, ads.txt audit, Core Web Vitals for ads, audit my Google/Meta/TikTok pixel, verify tag firing, what tools do I need for ads, is my site ready for ChatGPT ads. Do NOT use for security review (use snitch-security), SEO / marketing audits, SEO structured data, llms.txt / AI search, hreflang, local listings (use snitch-marketing), app-store privacy manifests or store declarations (use snitch-storeready), or general code review.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills. The bundled shell tools need bash, curl, and jq; platform API reads are optional and env-gated.
metadata:
  author: Snitch
  version: 0.4.0
  homepage: https://snitchplugin.com
---

# snitch-adsready

The `ads-ready.sh` beside this SKILL.md exposes thin tools. Read tools emit JSON on stdout;
`doctor` and the mutating `fix` tools emit status badges instead. Run
`bash "${CLAUDE_SKILL_DIR}/ads-ready.sh" help` for the full surface.

Ten platforms are tool-backed: Google, Meta, Microsoft, LinkedIn, TikTok, X, Pinterest, Reddit,
Snapchat, Apple. One more — ChatGPT ads — is presence-only: no pixel exists, so readiness there
is crawlability and page quality (`references/10-capability-matrix.md`).

## Setup

- No mandatory secrets. Public-URL audits use curl + jq.
- Optional, raises quotas / unlocks platform reads:
  - `PSI_API_KEY` — PageSpeed Insights (CrUX + Lighthouse scores). Without it the anonymous
    quota runs out fast and `state crux` returns `E_PSI` with status 429.
  - `lighthouse` CLI — `npm i -g lighthouse` for full audit JSON.
  - `GOOGLE_GSC_AUTH`, `GA4_AUTH` — Search Console / GA4 refresh-token JSON.
  - Per-platform Marketing API env (see `prereqs` for the exact names): `GOOGLE_ADS_*`,
    `META_ACCESS_TOKEN` + `META_AD_ACCOUNT_ID`, `MICROSOFT_ADS_*`, `LINKEDIN_ADS_*`,
    `TIKTOK_ADS_*`, `X_ADS_*`, `PINTEREST_ADS_*`, `REDDIT_ADS_*`, `SNAPCHAT_ADS_*`,
    `APPLE_SEARCH_ADS_*`.
- Refuses any global / legacy `API_KEY` env — see Guardrails.
- Runtime state (findings, the API call log, snapshots, the `refresh-docs` cache) is written to
  `${XDG_STATE_HOME:-$HOME/.local/state}/snitch-adsready`, never into the skill folder.

## Tools

Read-only, JSON on stdout, errors as JSON on stderr:

| Subcommand | Returns |
|---|---|
| `detect` | cwd signals: `stacks[]`, `pixel_libs[]`, `pixel_snippets[]`, `consent_libs[]`, `vertical_hints[]`, `hostnames[]`, `package_managers[]`, `current_host_provider`, `project_kind` |
| `state site <url> [slice]` | site fetch + parse for all 10 platforms in one pass. Slices: `digest` (default), `html`, `headers`, `pixels`, `consent`, `structured-data`, `robots`, `sitemap`, `ads-txt`, `lead-capture`, `full` |
| `state crux <url> [mobile\|desktop]` | CrUX field data + Lighthouse lab scores via PSI |
| `state lighthouse <url>` | full Lighthouse audit JSON if the CLI is installed; a nested `state crux` document otherwise |
| `state platform <name> [account-id]` | per-platform Marketing API state. `<name>` ∈ `google\|meta\|microsoft\|linkedin\|tiktok\|x\|pinterest\|reddit\|snapchat\|apple`. Emits `{locked:"<platform>-api"}` when the auth env is unset — that is a Skip, not a Finding |
| `state gsc [property]` | Search Console state if `GOOGLE_GSC_AUTH` is set |
| `analytics ga4 <property-id>` | GA4 Data API report if `GA4_AUTH` is set |
| `fit-matrix [stack]` | per-stack ads-readiness verdict |
| `stack-docs [stack]` | canonical doc URLs (for WebFetch) |
| `score <url>` | heuristic composite: pixel × CWV × consent × structured data × headers × ads.txt |

Badges on stdout, not JSON — never pipe these into `jq`:

| Subcommand | Behavior |
|---|---|
| `doctor` | env health (curl, jq, lighthouse, PSI key, per-platform auth), one badge per check |
| `fix <area> [platform]` | apply one area for one platform (or all detected). Areas: `pixel-install consent-mode capi-stub ads-txt robots structured-data security-headers mobile-meta verification-meta all`. No flags — `fix structured-data` emits the `Product`/`Offer` feed starter and takes `ecommerce` as a positional to force it |

Setup help:

| Subcommand | Behavior |
|---|---|
| `setup <area> [platform]` | stepped JSON walkthrough: pre-checks → ordered steps (auto via `fix`, manual dashboard, external-tool installs) → verification |
| `recommend <area>` | tool catalogs: `cmp`, `gtm-server`, `capi-helpers`, `lighthouse-runner`, `cwv-monitoring`. Each option: name, vendor, pricing, install, pros, cons, recommended-for |
| `prereqs` | local CLI / platform accounts needed, with per-OS install hints |

Utility: `export <url>`, `verify <url>`, `refresh-docs`, `help`. `export` and `verify` both
require a URL and fail with `E_USAGE` without one.

## Evidence rule

Three outcomes per check — Finding, Pass, or Skip — and each one carries its proof.

1. **Every row cites where the verdict came from.** In crawl mode that is the URL plus the exact
   JSON field and its value (`.pixels.meta.detected = false`). In source mode it is `file:line`
   plus the matched snippet. Quote the field, not a paraphrase of it.
2. **A Pass carries evidence too** — what was read and what came back clean. A bare "OK" is not
   a Pass.
3. **A Skip carries the reason and what would unblock it** — `{locked:"meta-api"}` means "set
   `META_ACCESS_TOKEN`", not "N/A".

`score` is a heuristic composite, not a Finding: report the components and weights so the
reader can check the arithmetic, and never let a letter grade stand in for evidence.
`references/30-recipes.md` carries the full report format.

## How to use

1. Classify intent (audit, set up tracking, verify a fix, recommend a tool, plan a migration).
2. Call the smallest set of tools. Prefer `state site <url>` digest first — it covers all 10
   platforms in one fetch. Add `state crux` and `score` only when CWV or a composite is needed.
3. Lazy-load the reference for each finding — see the area map below.
4. Synthesize the report per `references/30-recipes.md`. Group by area; sort
   🔴 FAIL → 🟡 WARN → ⚪ SKIP → 🟢 PASS.
5. **For every FAIL, offer to set it up.** The mandated prompt is: "Want help setting this up? I
   can run `setup <area> [platform]` for a stepped plan."
6. When the user accepts, call `setup <area> [platform]` for the JSON plan, present each step in
   order, get confirmation per step, chain `fix` calls for auto steps, link to dashboards for
   manual ones.
7. For project file changes (`fix pixel-install`, `fix consent-mode`, `fix capi-stub`,
   `fix ads-txt`, `fix robots`, `fix structured-data`, `fix security-headers`,
   `fix mobile-meta`, `fix verification-meta`), the tool emits proposed contents + a diff:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` / `Write` after the user confirms. The skill never writes inside the user's
   project. For platform-side secrets (CAPI tokens, MP secrets), the tool emits the dashboard
   URL and the env-var name — never type secret values yourself.

## Area → reference map

Read the file whose area produced a finding. Nothing else.

| Area | Reference |
|---|---|
| orchestration, report format, evidence rule | `references/30-recipes.md` |
| the JSON each subcommand emits | `references/31-tool-contracts.md` |
| auth, tokens, per-platform API versioning | `references/01-auth-and-tokens.md` |
| pixel install, load order, dedup | `references/02-pixel-foundations.md` |
| conversion events, CAPI, offline import | `references/03-conversion-tracking.md` |
| consent, CMP, Consent Mode v2 | `references/04-consent-and-cmp.md` |
| Quality Score and engagement signals | `references/05-quality-and-engagement-signals.md` |
| Core Web Vitals targets and fixes | `references/06-core-web-vitals.md` |
| `Product`/`Offer` markup a shopping feed reads | `references/07-structured-data.md` |
| ads.txt / app-ads.txt | `references/08-ads-txt.md` |
| where a setting lives in each platform UI | `references/09-platform-dashboards.md` |
| what is free vs paid vs API-gated | `references/10-capability-matrix.md` |
| Google API specifics | `references/11-google-apis-cheatsheet.md` |
| tracking incidents, status pages | `references/13-incident-response.md` |
| API quotas and where the bill lands | `references/14-cost-and-budgets.md` |
| per-framework install patterns | `references/15-stack-best-practices/<stack>.md` |
| server-side tag manager | `references/16-tag-manager-server-side.md` |
| AI crawler access, the ChatGPT-ads surface | `references/17-ai-crawler-access.md` |
| mobile meta, per-region ad rules | `references/18-mobile-and-international.md` |
| per-vertical expectations | `references/25-verticals/<vertical>.md` |
| one platform's specifics | `references/platforms/<name>.md` |
| a stepped setup walkthrough | `references/setup/<area>.md` |
| a tool catalog | `references/recommendations/<area>.md` |

## Guardrails

- Refuses generic / global API key shapes (`API_KEY=` without a platform prefix,
  `*_GLOBAL_KEY`); redirects to scoped OAuth refresh tokens or service-account credentials per
  platform.
- **No pixel before consent.** `fix pixel-install` refuses to propose a tracking pixel into a
  project with no consent banner / CMP signal — it FAILs and points at `fix consent-mode` and
  `recommend cmp` instead. `fix all` runs consent before pixels for the same reason.
- **Never lowers posture in a `fix`.** No removing an existing CSP, no overwriting an existing
  `ads.txt` with fewer lines. A fix adds or it stops.
- **Never mutates ad campaigns.** No pausing, no bid changes, no creative. The skill reads, and
  sets up tracking. Campaign management belongs in the platform UI.
- **Never verifies billing.** It audits readiness, not whether a charge succeeded.
- **Search surfaces are not judged here.** Schema beyond the `Product`/`Offer` a shopping feed
  reads, llms.txt and AI-search content, hreflang and localized landing pages, AI-crawler
  policy for the non-ad assistants, and free business-listing profiles all belong to the
  marketing audit — when a finding lands there, call the Skill tool with "snitch-marketing"
  instead of grading it.
- `fix` is idempotent — a re-run no-ops when the target state is already met.
- Site-side parsers don't store fetched HTML on disk; the `html` slice prints the body but does
  not cache it.
- Respects `robots.txt` on the audited site; identifies as `ads-ready-skill/1`.
- Honest verdicts: a heavily client-side SPA with no SSR will fail Pixel + CWV; `fit-matrix`
  says so — surface that first instead of hiding behind "it depends."
- Apple Search Ads / SKAdNetwork is iOS-only; with no iOS app, mark `apple` ⚪ SKIP with the
  reason — don't manufacture work.
- For an actual ad-account compromise, use the platform's native security tooling. Tracking
  incidents (conversions stopped, pixel stopped firing) are in scope — see
  `references/13-incident-response.md`.
