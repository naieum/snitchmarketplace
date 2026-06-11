# Recipes — when the user asks X, do Y

Offline mirror of recipes referenced from `SKILL.md`. The agent synthesizes; shell tools provide facts.

## Audit / harden a Fly app

Default to digest mode — covers a first-pass audit:

```
bash snitch-flyio.sh doctor               # flyctl + auth + jq status
bash snitch-flyio.sh detect               # cwd signals JSON
bash snitch-flyio.sh state account        # org tier + member 2FA
bash snitch-flyio.sh state apps           # apps inventory + plaintext-secret hint
bash snitch-flyio.sh state machines [app] # machine state + checks coverage
bash snitch-flyio.sh state services [app] # force_https, checks, internal vs public
bash snitch-flyio.sh state secrets [app]  # local env vs secrets overlap
bash snitch-flyio.sh state volumes [app]  # encryption + retention + region
```

Run in parallel (single message, multiple Bash calls). Digests are ~85% smaller than full payloads.

Then:

1. Compare digest to policy in `references/03-machines-and-apps.md`, `06-services-http-tcp.md`, `08-secrets.md`, `04-volumes-and-storage.md`.
2. Compare account/tokens digests to `references/01-auth-and-tokens.md`.
3. Fetch slices only when digest signals: `bash snitch-flyio.sh state apps <org> full` for per-app config; `bash snitch-flyio.sh state machines <app> full` for per-machine config.
4. Group findings by area; emit `OK / WARN / FAIL`. Mark tier-locked items `[locked: <tier>+]` (rare on Fly — see `references/10-plan-tier-matrix.md`).
5. Ask user which areas to fix. For each: `bash snitch-flyio.sh fix <area>`. After: `bash snitch-flyio.sh verify`.

## "Should I migrate to Fly.io?"

Works fully offline — no `flyctl` auth required for `detect` / `fit-matrix` / `stack-docs`.

```
bash snitch-flyio.sh detect               # stack, databases, native deps, host provider
bash snitch-flyio.sh fit-matrix <stack>   # verdict + caveats per stack
bash snitch-flyio.sh stack-docs <stack>   # canonical doc URLs
```

Ground recommendations in current docs: `WebFetch` each URL from `stack-docs`. Also `WebSearch` `<stack> fly.io best practices <year>` and `<stack> security advisory <year>`. Lead with the verdict:

| Verdict | Action |
|---|---|
| `strong` | Render `fly launch` plan with secrets-move + DB attach. |
| `partial` | Render plan but flag every `entry.dependencies_to_flag` and `entry.caveats`. |
| `not-recommended` | Static / JAMstack: redirect to Pages / Netlify / Vercel. No Fly plan. |

Database honesty:

| From | To |
|---|---|
| Postgres | Fly Managed Postgres or legacy Fly Postgres, same region as app. |
| MySQL | No Managed MySQL on Fly. Self-host on a Machine + volume, or stay external (PlanetScale, RDS). |
| Mongo | No Managed Mongo. Stay on Atlas; use connection string as a fly secret. |
| Redis | Upstash-on-Fly via `fly redis create`. |
| S3 | Tigris (same API, free egress within Fly). |

Close with cost realism (cite `references/14-cost-and-budgets.md`), DNS cutover steps (lower TTL → certs add → cutover → verify), rollback path.

## Scaling readiness ("what at 1k / 10k users?")

```
bash snitch-flyio.sh state apps           # current footprint
bash snitch-flyio.sh state machines [app] # per-app scaling
bash snitch-flyio.sh state cost <org>     # spend signal
bash snitch-flyio.sh detect               # stack signals
```

Read `references/03-machines-and-apps.md` for scaling levers (count, memory, region spread, min_machines_running, autoscale). Ask the user their plateau. Render the next plateau's checklist with already-present items marked `OK`. If projected Fly bill exceeds current host at user's scale, say so.

## Diagnose

Classify the symptom yourself — no shell regex. Then:

| Symptom | Tools | Reasoning |
|---|---|---|
| 5xx everywhere | `state machines` + `fly logs` | Machine state, recent errors. |
| Slow / latency | `state regions` + `state machines` | Region spread, machine count. |
| Bill spike | `state cost` + `state machines` | GPU machines, orphan volumes. |
| Cert error | `fly certs check <host>` | DNS + cert validation. |
| Database slow | `state postgres` + `fly pg connect` | Replica spread, connections. |
| WebSocket drops | `state services` + `state machines` | min_machines_running, region match. |
| Secret leaked | `state secrets` | Overlap with [env]; rotate everything. |

## "We're under attack"

```
bash snitch-flyio.sh state machines <app>      # current footprint
fly logs -a <app> | grep <pattern>      # who's hitting you
# decide: scale up to absorb OR pause
bash snitch-flyio.sh panic suspend <app>       # pause entirely (after user agrees)
fly scale count 10 -a <app>             # OR scale up
# after the attack ends:
bash snitch-flyio.sh panic restore             # surfaces inverse commands
```

Application-layer attack (not volumetric): put **Cloudflare in front**. Fly has no L7 WAF.

## Report format

Every audit / migrate / roadmap / scaling report MUST:

- Open with a one-line verdict.
- Use markdown tables for all structured content.
- Close with "Next steps" — ≤3 imperative bullets.
- No prose paragraphs between sections except a single transitional sentence.

### Findings table

| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | secrets | `STRIPE_SECRET_KEY` in fly.toml [env] | Move to `fly secrets set`; delete from [env]. |
| 🟡 WARN | volumes | snapshot_retention=3 days on prod-db-vol | `fly volumes update <id> --snapshot-retention 14`. |
| ⚪️ N/A | postgres | PITR > 7 days | Managed Postgres only. |
| 🟢 OK | services | force_https=true; /health check defined | — |

Status badges: `🔴 FAIL`, `🟡 WARN`, `⚪️ N/A`, `🟢 OK`. Sort: 🔴 → 🟡 → ⚪️ → 🟢.

### Architecture inventory

| Component | Detail | Source |
|---|---|---|
| Web app | 3× shared-cpu-1x, iad+fra | `state machines` |
| Postgres | Managed, 2 replicas, PITR 7d | `state postgres` |

### Cost / scaling

| Driver | Current | Watch for |
|---|---|---|
| GPU machines | 0 | Bill jump on first A100/H100. |
| Volumes | 30 GB | $0.15/GB-month; orphan volumes still bill. |
| Regions | iad, fra | Cross-region bandwidth free within Fly. |

### Migration verdict

| Stack detected | Verdict | Recommended path |
|---|---|---|
| Phoenix/Elixir | strong | `fly launch` + libcluster + Managed Postgres |

## Common mistakes to avoid

| Mistake | Correction |
|---|---|
| Pre-loading all of `references/`. | Read only files relevant to current findings. |
| Suggesting D1 / KV / R2. | Cloudflare-only. Fly equivalents: Postgres / Redis / Tigris. |
| Mutating Fly state under a read flow. | Mutations are explicit: `fix <area>` or `panic <action>`, both with user confirmation. |
| Writing inside the user's project directory. | `fix apps` / `fix gha` emit proposed contents + diff; agent applies via `Edit` / `Write`. |
| Quoting prices in dollars. | Cite https://fly.io/pricing. |
