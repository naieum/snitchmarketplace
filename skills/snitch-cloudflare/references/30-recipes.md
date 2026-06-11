# Recipes — when the user asks X, do Y

Offline mirror of `SKILL.md` recipes. Agent does synthesis; shell tools provide facts.

## Audit / harden a Cloudflare site

Run in parallel:

```
bash snitch-cloudflare.sh doctor          # token + tools status
bash snitch-cloudflare.sh detect          # cwd signals JSON
bash snitch-cloudflare.sh state zone      # digest: settings + dns_summary + rulesets_summary + firewall_summary
bash snitch-cloudflare.sh state account   # digest: account + members_summary + tokens_summary
```

Digests are ~85% smaller than full payloads.

If `CFSEC_MCP_PRESENT=1`: pull D1/KV/R2/Workers/Hyperdrive inventories via the typed MCP (`d1_databases_list`, `kv_namespaces_list`, `r2_buckets_list`, `workers_list`, `hyperdrive_configs_list`). Don't curl those.

Then:

1. Compare `state.zone.settings.*` to `02-dns-ssl-tls.md`, `03-waf-and-rules.md`, `05-security-headers.md`.
2. Compare `state.account.members_summary` and `tokens_summary` to `09-account-hardening.md`.
3. Fetch slices only when the digest signals: `state zone <zone> dns` if unproxied A/AAAA; `state zone <zone> rulesets` if WAF mis-shaped; `state account <acct> tokens` if `tokens_summary.no_expiry > 0`. Use `full` only for exports.
4. Group findings by area; emit `OK / WARN / FAIL`. Mark items locked behind `state.zone.plan_tier` with `[locked: <tier>+]` + one-line value from `10-plan-tier-matrix.md`.
5. Ask which areas to fix; run `fix <area>` per agreed area; `verify` for the delta.

## Full-stack "toes-to-top" audit (`audit all`) {#full-stack-audit}

The deepest audit: edge → origin → workers/builds → storage → AI → zero-trust →
CASB → logging/observability → account. One orchestrator emits the new-surface
lenses; you run the existing tools it lists and render one graded report.

```
bash snitch-cloudflare.sh audit all     # envelope: lenses[] + delegated[] + compose_also[]
```

`audit all` returns `cfsec.audit-all`:
- `lenses[]` — the five curl lenses already run (`secevents, dns, ai-gateway, logpush, auditlog`), each `status: ok|locked|error` with its `doc`.
- `delegated[]` — pointers for the MCP lenses (`browser, builds, observability, dex, casb`); `locked:"mcp-absent"` if the server isn't flagged.
- `compose_also[]` — the existing tools you still run to fill each render section.

Steps:
1. Run `audit all`. In parallel run the `compose_also` tools you have access to:
   `score [hosts]` (slow — SSL Labs; run separately), `state zone`, `state account`,
   `analytics zone`, and (if `CFSEC_MCP_PRESENT=1`) Developer-Platform MCP for
   workers/storage inventory.
2. For each `delegated[]` lens whose MCP **is** present, run its recipe in
   `references/32-mcp-surfaces.md#<lens>`. For the rest, render ⚪️ N/A with the
   `install_hint`.
3. Grade per `references/20-validator-grading.md` (locked / mcp-absent =
   **neutral** — never penalize free/pro for absent Enterprise features). Pull the
   matching reference per finding: `33-logging-observability.md`,
   `34-dns-analytics.md`, `35-cicd-builds-security.md`, `36-device-posture-casb.md`,
   `32-mcp-surfaces.md`.
4. Render per "Report format — mandatory" below, one H2 per render-order section,
   gated rows clearly marked. Close with "Next steps".

CASB / DEX / Builds posture step-lists live in `32-mcp-surfaces.md`
(`#casb` / `#dex` / `#builds`) — the delegation pointers link straight there.

## "Should I migrate to Cloudflare?"

Works offline — no API token required.

```
bash snitch-cloudflare.sh detect              # stack, databases, native deps, host provider
bash snitch-cloudflare.sh fit-matrix <stack>  # verdict + caveats
bash snitch-cloudflare.sh stack-docs <stack>  # canonical doc URLs
```

Ground in current docs: prefer `mcp__claude_ai_Cloudflare_Developer_Platform__search_cloudflare_documentation` if MCP loaded; otherwise `WebFetch` each `stack-docs` URL. Also `WebSearch` `<stack> cloudflare security best practices <year>` and `<stack> security advisory <year>`.

Render with verdict at top:

| Verdict | Plan |
|---|---|
| `strong` | Pages/Workers migration with the recommended adapter and DNS cutover |
| `partial` | render plan; flag every item in `entry.dependencies_to_flag` and `entry.caveats` |
| `proxy-only` | Cloudflare-in-front-of-origin only: orange-cloud DNS → Tunnel + WAF + DDoS. Stop. No "but if you really want to replatform" |
| `not-recommended` | same as proxy-only; mention Cloudflare Containers (beta) as the only realistic native compute path |

Database honesty: MySQL → Hyperdrive (keeps existing DB). Postgres → Hyperdrive in front of Neon/Supabase/RDS. D1 is SQLite — never silently suggest as Postgres / MySQL replacement; full rewrite if user opts in. S3 → R2 (rclone, zero egress).

End with cost realism (cite `18-cost-model.md`), DNS cutover (lower TTL → orange cloud → cutover → verify), rollback path.

## Scaling readiness ("what should I have at 10k users?")

```
bash snitch-cloudflare.sh state zone          # current posture
bash snitch-cloudflare.sh detect              # stack signals
bash snitch-cloudflare.sh analytics zone 7d   # traffic shape if a token is available
```

Read `22-scaling-ladder.md` and `23-cost-cliffs.md`. Pick the user's plateau from analytics or by asking. Render the next plateau's checklist with already-present items marked `OK`. If projected bill says Cloudflare is more expensive than user's current host, say so.

## Diagnose

Classify the symptom yourself:

| Symptom | Tools | Reasoning |
|---|---|---|
| slow / latency / TTFB | `analytics zone 24h` | cache hit rate, top paths, colo distribution |
| region X failing | `analytics zone 24h` + `state zone` | per-country requests, country-block rules |
| throttled / rate limited | `events zone 24h` + `state zone` | WAF actions, rate-limit rules |
| under attack now | `events zone 1h` → `panic` | top ASNs/countries; confirm before panic |
| auth probing / cred stuffing | `audit observability` + `audit secevents 24h` | error spikes aligned with WAF blocks; repeated auth/forbidden errors |
| no log/audit evidence | `audit logpush` + `audit auditlog 7d` | missing security datasets; sensitive control-plane events |
| weird DNS volume / enumeration | `audit dns 24h` | NXDOMAIN/SERVFAIL rates, query-type anomalies |
| AI proxy cost/abuse | `audit ai-gateway` | rate-limit/auth disabled, full-payload logging |
| bill spike | `analytics zone 7d` | project monthly via `23-cost-cliffs.md` |
| cert error | `state zone` | `settings.ssl`, `ssl_verification[]`; recommend `fix ssl` or `fix aop` |
| redirect loop | `state zone` | `settings.always_use_https`, custom rules; trace with curl -L |
| email not delivering | `state zone` | DNS TXT for SPF / DKIM / DMARC; recommend `fix email` |

## "We're under attack right now"

```
bash snitch-cloudflare.sh events zone 1h        # top ASNs, countries, paths, IPs
# read top to user
bash snitch-cloudflare.sh panic under-attack    # JS challenge for everyone (after user agrees)
bash snitch-cloudflare.sh panic block ip <ip>   # per top abuser
bash snitch-cloudflare.sh panic block asn <asn>
# after the attack:
bash snitch-cloudflare.sh panic restore         # rolls back every recorded panic action
```

Postmortem: read `13-incident-response.md`.

## Report format — mandatory

Every audit / migrate / roadmap / scaling / diagnose report MUST follow:

1. **One-line verdict** at the top.
2. **Markdown tables only** for findings, inventory, cost, migration verdict (no bare `[FAIL] foo`, no prose paragraphs between sections except a single transitional sentence).
3. **Status column** uses one of `🔴 FAIL`, `🟡 WARN`, `⚪️ N/A`, `🟢 OK`. Sort: 🔴 > 🟡 > ⚪️ > 🟢.
4. **Section bodies are tables**, not prose. H2 headings group sections.
5. **Close with "Next steps"** — at most three imperative bullets ("Apply X", "Run Y", "Confirm Z"). Then prompt for which fixes to apply.

### Findings table

`| Status | Area | Finding | Remediation |`

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | headers | `_headers` has cache rules only; no HSTS/CSP/X-Frame | Merge `templates/_headers.example` via `Edit` |
| 🟡 WARN | account | Auth + content workers share one D1 + one KV namespace | Split into per-domain D1s; rotate KV |
| ⚪️ N/A | page-shield | Page Shield gated behind Pro+ | Upgrade ($25/mo) for client-side script integrity |
| 🟢 OK | containers | Express stack runs in CF Containers behind service bindings | — |
```

### Architecture inventory table

`| Component | Detail | Source |`

```markdown
| Component | Detail | Source |
|---|---|---|
| Workers | vibe-music-auth, content, admin, og, container, company | `wrangler.*.jsonc` |
| D1 | `vibe-music-content` (47b34acd-…) | shared by auth + content |
| R2 | `vibe-music-audio` | bound as `AUDIO_BUCKET` |
```

### Cost / scaling table

`| Driver | Current | Watch for |`

### Migration verdict table

`| Stack detected | Verdict | Recommended path |`

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| laravel | 🔴 proxy-only | Cloudflare in front of origin (Tunnel + WAF + DDoS); don't replatform |
| nextjs | 🟢 strong | Pages with `@cloudflare/next-on-pages` |
```

## Common mistakes

- Don't run `check` / `migrate` / `roadmap` / `report` / `diagnose` / `stacks` — deprecated, exit 64.
- Don't pre-load all of `references/`. Read only what's relevant.
- Don't suggest D1 as a drop-in for MySQL/Postgres. It's SQLite.
- Don't mutate Cloudflare under a read flow. Mutations are explicit (`fix`, `panic`) with confirmation.
- Don't write inside the user's project. `fix project` / `fix gha` / `fix wrangler-lint` / `fix security-txt` emit proposed contents + diff to stdout; apply via `Edit` / `Write`.
