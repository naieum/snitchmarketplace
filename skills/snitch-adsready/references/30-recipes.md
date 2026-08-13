# Recipes — when the user asks X, do Y

Offline mirror of `SKILL.md` recipes. Agent does synthesis; shell tools provide facts.

## Audit / readiness check on a website

Run in parallel:

```
bash ads-ready.sh doctor          # env health
bash ads-ready.sh detect          # cwd signals
bash ads-ready.sh state site <url>      # all 10 platforms in one fetch
bash ads-ready.sh state crux <url> mobile     # CrUX field data
bash ads-ready.sh score <url>     # composite grade
```

Then:

1. Compare `state site` digest to `references/platforms/<name>.md` for each platform the user runs.
2. Compare `state crux` to `06-core-web-vitals.md` targets.
3. Group findings by area; emit `🔴 FAIL`, `🟡 WARN`, `⚪ N/A`, `🟢 OK`.
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
bash ads-ready.sh setup structured-data
```

## "Should I add platform X?"

Works offline.

```
bash ads-ready.sh detect                # stack signals
bash ads-ready.sh fit-matrix <stack>    # readiness verdict
bash ads-ready.sh stack-docs <stack>    # canonical doc URLs
bash ads-ready.sh state site <url>      # see if pixel already installed
```

| Verdict | Plan |
|---|---|
| `strong` | install pixel + CAPI, ship it |
| `partial` | install but plan migration to a stronger stack — see fit-matrix entry |
| `weak` | don't add; recommend stack-level work first (SSR migration, headless) |

A B2C SaaS doesn't need LinkedIn. An iOS-only app doesn't need ads.txt. Mark N/A explicitly.

## Verify after a fix

```
bash ads-ready.sh state site <url>     # re-fetch + re-parse
bash ads-ready.sh score <url>          # grade delta vs prior
bash ads-ready.sh verify               # diff vs last snapshot
```

If the fix didn't take effect, ask: did the user deploy? Is the finding `Pixel signature absent in source` (deploy didn't ship) or `Pixel signature present but platform shows no fires` (CSP / consent)? Use `references/platforms/<name>.md` to verify in the platform UI.

## Recommend a tool when the audit can't auto-fix it

```
bash ads-ready.sh recommend <area>    # cmp | gtm-server | capi-helpers | lighthouse-runner | cwv-monitoring | listings
```

Render as comparison table. Let user pick. Then `setup <area>` for the install path.

Areas that always need an external tool: consent management, server-side GTM hosting, real-user monitoring beyond web-vitals JS.

For `listings`, filter the catalog by the user's goal before rendering — the `recommended_for` entries carry `goal:` tags (local customers, AI recommendations, word-of-mouth, contractor). Don't dump all 11 options on someone who asked one question; see `references/recommendations/listings.md` for the goal → shortlist mapping.

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
3. **Status column** uses one of `🔴 FAIL`, `🟡 WARN`, `⚪ N/A`, `🟢 OK`. Sort: 🔴 > 🟡 > ⚪ > 🟢.
4. **Section bodies are tables**, not prose. H2 headings group sections.
5. **Close with "Next steps"** — at most three imperative bullets ("Apply X", "Run Y", "Confirm Z").
6. **MANDATORY: every 🔴 FAIL row gets a "Want help setting this up?" prompt in the agent's reply.** Format: after the findings table, list each FAIL row with two concrete options. Example:
   - "Meta Pixel missing — Want help setting this up? I can: (a) `setup pixel-install meta` for a stepped plan, or (b) `recommend capi-helpers` if you'd rather start with the server-side path."
   - "No CMP detected — Want help setting this up? I can: (a) `recommend cmp` to compare options, or (b) `setup consent-mode` if you've already picked one."

   This prompt is THE differentiator from cloud-secure: actionable, not just diagnostic. Surface it even if the user did not ask.

### Findings table

`| Status | Area | Platform | Finding | Remediation |`

```markdown
| Status | Area | Platform | Finding | Remediation |
|---|---|---|---|---|
| 🔴 FAIL | pixels | meta | No fbq init found in source | `fix pixel-install meta` |
| 🔴 FAIL | consent | — | No CMP detected; site has EU traffic | `recommend cmp` |
| 🟡 WARN | core-web-vitals | — | LCP 3.2s on mobile (target 2.5s) | See `06-core-web-vitals.md` |
| ⚪ N/A | apple | apple | iOS-only; site is web-only | — |
| 🟢 OK | structured-data | — | Organization + WebSite + BreadcrumbList JSON-LD valid | — |
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

`| Component | Grade | Points | Notes |`

```markdown
| Component | Grade | Points | Notes |
|---|---|---|---|
| Pixel coverage | 🟡 B | 12/20 | 4 of 10 platforms detected |
| CWV (mobile) | 🟢 A | 18/20 | LCP 2.1s, INP 180ms, CLS 0.05 |
| Consent | 🔴 D | 2/15 | no CMP detected |
| Structured data | 🟡 B | 8/10 | Article + Organization missing |
| Security headers | 🟢 A | 14/15 | CSP + HSTS + Referrer-Policy present |
| ads.txt | ⚪ N/A | n/a | site is advertiser, not publisher |
| **Composite** | **🟡 C+** | **54/80** | — |
```

### Migration verdict table

`| Stack detected | Verdict | Recommended path |`

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| nextjs | 🟢 strong | install pixels via @next/third-parties; CAPI via App Router routes |
| vue (plain SPA) | 🟡 partial | migrate to Nuxt for SSR before scaling ad spend |
```

## Common mistakes

- Don't pre-load all of `references/`. Read only what's relevant per finding.
- Don't suggest CAPI when spend doesn't justify the engineering cost.
- Don't surface 🔴 for features the user's vertical doesn't need (e.g., ads.txt for advertisers).
- Don't mutate without showing the proposed `=== FILE/DIFF/CONTENT ===` first.
- Don't skip the "Want help setting this up?" prompt on FAILs — it's mandatory.
- Don't say "should be straightforward" — concrete steps via `setup` only.
