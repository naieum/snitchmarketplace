---
name: snitch-adsready
description: Audit and set up paid-media ad readiness across Google, Meta, Microsoft / Bing, LinkedIn, TikTok, X, Pinterest, Reddit, Snapchat, and Apple Search Ads. Thin tools for the agent to compose. Audits pixel coverage, conversion tracking, Consent Mode v2, ads.txt, structured data, Core Web Vitals, security headers; offers idempotent fixes; recommends external tools (CMP, server-side GTM, CAPI helpers) and free business-listing profiles by goal (local customers, AI recommendations, word-of-mouth, contractor). Triggers on audit my ads readiness, is my Meta Pixel installed, set up Google Ads conversion tracking, is my consent mode v2 wired up, should I add LinkedIn tracking, ads.txt audit, Core Web Vitals for ads, audit my Google/Meta/TikTok pixel, verify tag firing, what tools do I need for ads, what free listings should I claim, how do I get AI to recommend my business. Do NOT use for security review (use snitch), SEO / marketing audits (use snitch-marketing), or general code review.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills. The bundled shell tools need bash, curl, and jq; platform API reads are optional and env-gated.
metadata:
  author: Snitch
  version: 0.2.0
  homepage: https://snitchplugin.com
---

# ads-ready

`~/.claude/skills/ads-ready/ads-ready.sh` exposes thin tools. Read tools emit JSON; mutating tools (`fix`) are explicit and idempotent. Run `bash ads-ready.sh help` for the full surface.

## Setup

- No mandatory secrets. Public-URL audits use curl + jq.
- Optional, raises quotas / unlocks platform reads:
  - `PSI_API_KEY` — PageSpeed Insights (CrUX + Lighthouse scores).
  - `lighthouse` CLI — `npm i -g lighthouse` for full audit JSON.
  - `GOOGLE_GSC_AUTH`, `GA4_AUTH` — Search Console / GA4 refresh-token JSON.
  - Per-platform Marketing API env (see `prereqs`): `GOOGLE_ADS_*`, `META_ACCESS_TOKEN` + `META_AD_ACCOUNT_ID`, `MICROSOFT_ADS_*`, `LINKEDIN_ADS_*`, `TIKTOK_ADS_*`, `X_ADS_*`, `PINTEREST_ADS_*`, `REDDIT_ADS_*`, `SNAPCHAT_ADS_*`, `APPLE_SEARCH_ADS_*`.
- Refuses any global / legacy `API_KEY` env — see Guardrails.

## Tools

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | env health (curl, jq, lighthouse, PSI key, per-platform auth) |
| `detect` | cwd signals: `stacks[]`, `pixel_libs[]`, `pixel_snippets[]`, `consent_libs[]`, `vertical_hints[]`, `hostnames[]`, `package_managers[]`, `current_host_provider`, `project_kind` |
| `state site <url> [slice]` | site fetch + parse for ALL 10 platforms in one pass. Slices: `digest` (default), `html`, `headers`, `pixels`, `consent`, `structured-data`, `robots`, `sitemap`, `ads-txt`, `lead-capture`, `full` |
| `state crux <url> [mobile\|desktop]` | CrUX + Lighthouse category scores via PSI |
| `state lighthouse <url>` | full Lighthouse audit JSON if CLI installed; PSI fallback otherwise |
| `state platform <name> [account-id]` | per-platform Marketing API state. `<name>` ∈ `google\|meta\|microsoft\|linkedin\|tiktok\|x\|pinterest\|reddit\|snapchat\|apple`. Emits `{locked:"<platform>-api"}` when auth env unset. |
| `state gsc [property]` | Search Console state if `GOOGLE_GSC_AUTH` set |
| `analytics ga4 <property-id>` | GA4 Data API report if `GA4_AUTH` set |
| `fit-matrix [stack]` | per-stack ads-readiness verdict |
| `stack-docs [stack]` | canonical doc URLs (for WebFetch) |
| `score <url>` | composite readiness score: pixel × CWV × consent × structured data × headers × ads.txt |

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [platform]` | apply one area for one platform (or all detected). Areas: `pixel-install consent-mode capi-stub ads-txt robots structured-data security-headers mobile-meta verification-meta all` |

Setup help:

| Subcommand | Behavior |
|---|---|
| `setup <area> [platform]` | stepped JSON walkthrough: pre-checks → ordered steps (auto via `fix`, manual dashboard, external-tool installs) → verification |
| `recommend <area>` | tool catalogs: `cmp`, `gtm-server`, `capi-helpers`, `lighthouse-runner`, `cwv-monitoring`, `listings` (free business-listing profiles by goal: local, AI recommendations, word-of-mouth, contractor). Each option: name, vendor, pricing, install, pros, cons, recommended-for. |
| `prereqs` | local CLI / platform accounts needed, with per-OS install hints |

Utility: `export`, `verify`, `refresh-docs`, `help`.

There is no `panic` — ads readiness is rarely an active-incident scenario. For an actual ad-account compromise, use the platform's native security tooling.

## MCP / CLI division of labor

No first-party MCP exists for any of the 10 ad platforms today. The skill uses:

- **curl** for site-side analysis (no auth needed).
- **curl + Authorization** for each platform's Marketing API (auth gated per platform).
- **lighthouse CLI** when installed for deep field-data audits.
- **PSI API** as universal CWV fallback.

If a platform ships an MCP later, honor `ADSEC_MCP_<platform>_PRESENT=1` and prefer the MCP for that platform's calls.

## How to use

1. Classify intent (audit, set up tracking, verify a fix, recommend a tool, plan a migration).
2. Call the smallest set of tools. Prefer `state site <url>` digest first (covers all 10 platforms in one fetch); add `state crux` and `score` only when CWV / composite grade are needed.
3. Lazy-load references that match findings: `30-recipes.md` for orchestration, `<NN>-<area>.md` per finding, `references/platforms/<name>.md` per platform that surfaced a finding.
4. Synthesize the report. Group by area; mark `OK / WARN / FAIL`; sort FAIL → WARN → OK.
5. **For every FAIL, offer to set it up.** `references/30-recipes.md` mandates the prompt: "Want help setting this up? I can run `setup <area> [platform]` for a stepped plan."
6. When the user accepts, call `setup <area> [platform]` for the JSON plan, present each step in order, get confirmation per step, chain `fix` calls for auto steps, link to dashboards for manual ones.
7. For project file changes (`fix pixel-install`, `fix consent-mode`, `fix capi-stub`, `fix ads-txt`, `fix robots`, `fix structured-data`, `fix security-headers`, `fix mobile-meta`, `fix verification-meta`), the tool emits proposed contents + unified diff:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` / `Write` after user confirms. The skill never writes inside the user's project. For platform-side secrets (CAPI tokens, MP secrets), the tool emits the dashboard URL + env-var name — never type secret values yourself.

## Recipes

`references/30-recipes.md` — read for any specific recipe (audit, setup-walkthrough, recommend-and-pick, platform-add, migrate, verify-after-fix).

## Other references

- `references/09-platform-dashboards.md` — where each setting lives in each platform's UI, for manual steps.
- `references/10-capability-matrix.md` — per platform, which features are free vs paid vs API-gated; sets expectations before a fix is recommended.
- `references/18-mobile-and-international.md` — mobile meta, hreflang, and multi-region ad readiness.
- `references/31-tool-contracts.md` — the JSON shape every subcommand emits.
- `references/32-mcp-cli-division.md` — when to prefer an MCP server over the bundled CLI calls.

## Guardrails

- Refuses generic / global API key shapes (`API_KEY=` without a platform prefix, `*_GLOBAL_KEY`); redirects to scoped OAuth refresh tokens or service-account credentials per platform.
- `fix` is idempotent — re-runs no-op when target state already met.
- Site-side parsers don't store fetched HTML on disk by default; the `html` slice prints the body but doesn't cache it.
- Respects `robots.txt` on the audited site; identifies as `ads-ready-skill/1`.
- Honest verdicts: a heavily client-side SPA with no SSR will fail Pixel + CWV; `fit-matrix` says so — surface that first instead of hiding behind "it depends."
- Apple Search Ads / SKAdNetwork is iOS-only; if the user has no iOS app, mark `apple` as N/A — don't manufacture work.
