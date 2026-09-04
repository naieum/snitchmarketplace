# Recipes — when the user asks X, do Y

The orchestration playbook: which tools to run for a given ask, in what order, and how to report the result. Agent does synthesis; shell tools provide facts.

## Audit / readiness check on a website

Start with supplied evidence or the smallest relevant tools. These are options, not a
mandatory batch: `score` already fetches site and performance data, so avoid duplicate calls.

```
bash ads-ready.sh doctor          # env health — badges, not JSON
bash ads-ready.sh detect          # cwd signals
bash ads-ready.sh state site <url>          # all 10 platforms in one fetch
bash ads-ready.sh state crux <url> mobile   # CrUX field data
bash ads-ready.sh score <url>     # heuristic composite
```

`doctor` prints status badges; everything else prints one JSON document. Don't pipe `doctor`
into `jq`.

Then:

1. Compare `state site` digest to `references/platforms/<name>.md` for each platform the user runs.
2. Compare `state crux` to `06-core-web-vitals.md` targets.
3. Group findings by area; emit `🔴 FAIL`, `🟡 WARN`, `⚪ SKIP`, `🟢 PASS`, each with its evidence.
4. Render the report per the format below.

## Set up tracking from scratch on a new site

```
bash ads-ready.sh detect              # confirm stack
bash ads-ready.sh prereqs             # CLI tools + auth env
bash ads-ready.sh recommend cmp       # consent options
bash ads-ready.sh setup consent-mode  # stepped plan
bash ads-ready.sh setup pixel-install <platform>   # repeat per platform
bash ads-ready.sh setup capi-stub <platform>
bash ads-ready.sh setup security-headers
bash ads-ready.sh setup structured-data       # only when a shopping / catalog feed exists
```

## "Should I add platform X?"

Stack inspection works offline; site checks and current vendor recommendations need access.

```
bash ads-ready.sh detect                # stack signals
bash ads-ready.sh fit-matrix <stack>    # readiness verdict
bash ads-ready.sh stack-docs <stack>    # canonical doc URLs
bash ads-ready.sh state site <url>      # see if pixel already installed
```

| Verdict | Plan |
|---|---|
| `strong` | Integration starting point; verify the required platform and runtime behavior |
| `partial` | Inspect actual gaps; no automatic migration |
| `weak` | Historical caution only; measure before recommending stack work |

A B2C SaaS doesn't need LinkedIn. An iOS-only app doesn't need ads.txt. Mark those ⚪ SKIP with the reason — never a silent omission and never a 🔴.

## Verify after a fix

```
bash ads-ready.sh state site <url>     # re-fetch + re-parse
bash ads-ready.sh score <url>          # score delta vs prior
bash ads-ready.sh verify <url>         # re-fetch, then diff vs last snapshot
```

`verify` takes the same URL as `state site` — it re-runs the fetch, diffs the badge findings
against the last snapshot, and writes a new one. It fails with `E_USAGE` if you leave the URL
off, and reports a Skip when there is no baseline yet. The findings it diffs come from the
badge tools, so run `doctor` or the relevant `fix` in the same session for a useful diff.

If the fix didn't take effect, ask: did the user deploy? Is the finding `Pixel signature absent in source` (deploy didn't ship) or `Pixel signature present but platform shows no fires` (CSP / consent)? Use `references/platforms/<name>.md` to verify in the platform UI.

## Recommend a tool when the audit can't auto-fix it

```
bash ads-ready.sh recommend <area>    # cmp | gtm-server | capi-helpers | lighthouse-runner | cwv-monitoring
```

Render as comparison table. Let user pick. Then `setup <area>` for the install path.

Areas that always need an external tool: consent management, server-side GTM hosting, real-user monitoring beyond web-vitals JS.

Free business-listing profiles (Google Business Profile, Bing Places, Yelp, and the rest) are a
local-search surface, not an ads catalog: **call the Skill tool with "snitch-marketing"** when
the user asks which listings to claim.

## Diagnose a tracking incident

```
bash ads-ready.sh state site <url>             # pixels in source?
bash ads-ready.sh state site <url> headers     # CSP / HSTS still in place?
bash ads-ready.sh state site <url> consent     # default flipping correctly?
bash ads-ready.sh state crux <url>             # CWV regression?
```

Then read `13-incident-response.md` for symptom → cause mapping.

## Report format — mandatory

Every audit / readiness / verify / diagnose report MUST follow:

1. **One-line verdict** at the top.
2. **Markdown tables only** for findings, inventory, cost, migration verdict. No bare `[FAIL] foo`. No prose paragraphs between sections except a single transitional sentence.
3. **Status column** uses one of `🔴 FAIL`, `🟡 WARN`, `⚪ SKIP`, `🟢 PASS`. Sort: 🔴 > 🟡 > ⚪ > 🟢.
   Every row carries evidence in its own column — see "Evidence rule" below. FAIL and WARN are
   Findings, PASS is a Pass-with-evidence, SKIP is a Skip-with-reason. There is no fifth
   outcome and no "partially audited".
4. **Section bodies are tables**, not prose. H2 headings group sections.
5. **Close with "Next steps"** — at most three imperative bullets ("Apply X", "Run Y", "Confirm Z").
6. **MANDATORY: every 🔴 FAIL row gets a "Want help setting this up?" prompt in the agent's reply.** Format: after the findings table, list each FAIL row with two concrete options. Example:
   - "Meta Pixel missing — Want help setting this up? I can: (a) `setup pixel-install meta` for a stepped plan, or (b) `recommend capi-helpers` if you'd rather start with the server-side path."
   - "No CMP detected — Want help setting this up? I can: (a) `recommend cmp` to compare options, or (b) `setup consent-mode` if you've already picked one."

   The prompt is what makes the report actionable rather than merely diagnostic. Surface it even if the user did not ask.

### Evidence rule

Every row is checkable or it does not ship.

- **Crawl mode** (a URL was fetched): evidence is the URL plus the exact field the verdict came
  from in the `state site` JSON — e.g. `https://x.com/ → .pixels.meta.detected = false`. Quote
  the field path and its value, not a summary of it.
- **Source mode** (the workspace was read): evidence is `file:line` plus the matched snippet —
  what `detect` and the `fix` idempotency check report.
- **A Pass carries proof it ran**: name what was read and what came back clean. A bare "OK" is
  not a Pass.
- **A Skip carries a reason and what would unblock it**: "no `PSI_API_KEY` and the anonymous
  quota returned 000 — set `PSI_API_KEY` and re-run `state crux`", not a bare "N/A".
- **Absence claims name the sweep**: say which slice was read and what would have satisfied it.

### Findings table

`| Status | Area | Platform | Finding | Evidence | Remediation |`

```markdown
| Status | Area | Platform | Finding | Evidence | Remediation |
|---|---|---|---|---|---|
| ⚪ SKIP | pixels | meta | Initial-HTML signature absent; runtime install unverified | `state site https://example.com` → `.pixels.meta.detected = false`, `.pixels.meta.ids = []` | Confirm platform need, consent state, container and runtime events |
| ⚪ SKIP | consent | — | Static signature absent; consent behavior unverified | `.consent = {platform:"none", consent_mode_v2:false, has_data_layer:false}` | Inspect actual consent states and applicable requirements |
| 🟡 WARN | core-web-vitals | — | LCP p75 3.2s on mobile (target 2.5s) | `state crux https://example.com mobile` → `.data.field_data.metrics.LARGEST_CONTENTFUL_PAINT_MS.percentile = 3200` | See `06-core-web-vitals.md` |
| ⚪ SKIP | apple | apple | Apple Search Ads not evaluated — no iOS app | no App Store link in `.robots.body`/head, `APPLE_SEARCH_ADS_*` unset. Unblock: point the skill at the app's site or set the env | — |
| 🟢 PASS | security-headers | — | HSTS and CSP both served | `.security_headers.strict_transport_security = "max-age=63072000; includeSubDomains"`, `.content_security_policy` non-null | — |
```

### Coverage / inventory table

`| Platform | Pixel | CAPI | Consent integration | Notes |`

```markdown
| Platform | Pixel | CAPI | Consent integration | Notes |
|---|---|---|---|---|
| Google | 🟢 GA4 + AW | 🟡 client only | 🟢 Consent Mode v2 | needs server-side conversions |
| Meta | 🟢 fbq | 🔴 not wired | 🟡 partial | run setup capi-stub meta |
```

### Score table (composite output)

`score` is a **heuristic composite, not a finding.** The letter grade is arithmetic on six
0-100 component scores, not an evidenced verdict — never report a grade in place of a Finding,
and never let it override what the digest actually shows. Its value is the delta between two
runs. Show the weights so the reader can check the arithmetic; they are in the JSON.

Score schema v2: CWV and overall score are `null` with grade `UNRATED` when complete URL
field data is unavailable. Lab/origin results remain separate evidence, not substitutes.
Otherwise `.components.<name>` are integers 0-100, `.weights.<name>` are the percentages,
`.overall_score` is 0-100 and `.overall_grade` is a letter (A ≥ 90, B ≥ 75, C ≥ 60, D ≥ 40,
else F). There are no `composite_*` keys and no `/80` denominator.

`| Component | Score | Weight | Notes |`

```markdown
| Component | Score | Weight | Notes |
|---|---|---|---|
| Pixel coverage | 66 | 25% | 2 of the 3 platforms the score expects (2 x 100 / 3) |
| CWV (mobile) | 88 | 20% | field LCP FAST, INP AVERAGE, CLS FAST -> (100 + 65 + 100) / 3 |
| Consent | 0 | 20% | no CMP detected |
| Structured data | 80 | 15% | 3 JSON-LD blocks, 2 types (Organization + WebSite); no Product |
| Security headers | 83 | 15% | 5 of the 6 canonical headers present |
| ads.txt | 0 | 5% | absent; site is an advertiser, so this is Skip, not Fail |
| **Overall** | **58 (D)** | — | heuristic composite; the Findings table is the audit |
```

### Migration verdict table

`| Stack detected | Verdict | Recommended path |`

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| nextjs | 🟢 strong | install pixels via @next/third-parties; CAPI via App Router routes |
| vue (plain SPA) | 🟡 partial | verify routing, consent, conversions, and measured performance |
```

## Run `score` in CI

The skill ships no workflow file. If the runner already has the skill on disk, three lines do it:

```bash
bash "$SKILL_DIR/ads-ready.sh" score "$URL" > score.json
jq -r '"snitch-adsready score: \(.overall_grade) (\(.overall_score)/100)"' score.json
jq -e '.overall_score != null and .overall_score >= 60' score.json
# A false result may mean unavailable data, not a readiness defect. Inspect before gating.
```

## Common mistakes

- Don't pre-load all of `references/`. Read only what's relevant per finding.
- Don't suggest CAPI when spend doesn't justify the engineering cost.
- Don't surface 🔴 for features the user's vertical doesn't need (e.g., ads.txt for advertisers) — that is a ⚪ SKIP with the reason.
- Don't mutate without showing the proposed `=== FILE/DIFF/CONTENT ===` first.
- Don't skip the "Want help setting this up?" prompt on FAILs — it's mandatory.
- Don't say "should be straightforward" — concrete steps via `setup` only.
- Don't report a status without its evidence cell, and don't report `score`'s letter as a finding.
