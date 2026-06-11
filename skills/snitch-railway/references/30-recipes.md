# Recipes — when the user asks X, do Y

Offline mirror of recipes in `SKILL.md`. The agent synthesizes; shell tools provide facts.

## Audit / harden a Railway project

Default to digest mode — every signal needed for first-pass audit:

```
bash snitch-railway.sh doctor                     # CLI + token + jq status (badged stdout)
bash snitch-railway.sh detect                     # cwd signals JSON
bash snitch-railway.sh state workspace            # me + teams summary
bash snitch-railway.sh state project              # project + envs + services count
bash snitch-railway.sh state services             # builders + healthchecks + replicas
bash snitch-railway.sh state env                  # var counts + plaintext-secret heuristics
bash snitch-railway.sh state databases            # DB add-ons + version + EOL
bash snitch-railway.sh state domains              # custom domains + TLS state
bash snitch-railway.sh state tcp-proxies          # public TCP exposures
bash snitch-railway.sh state volumes              # volume inventory
bash snitch-railway.sh state tokens               # project + account tokens
bash snitch-railway.sh state logs                 # retention + drain heuristic
bash snitch-railway.sh state cost                 # plan + sleep + replica summary
```

Run in parallel (single message, multiple Bash calls). Digests are 80–90% smaller than full payloads.

Then:

1. Compare observed `state.services.*` and `state.env.*` against `references/03-services-and-builders.md`, `references/08-secrets-and-env.md`.
2. Group findings by area; emit `OK / WARN / FAIL`.
3. Surface plan-gated items (log drains) as `[locked: pro+]` with one-line value from `references/10-plan-tier-matrix.md`.
4. Fetch slices only when digest says so: `bash snitch-railway.sh state env <pid> <env> vars` for names + classifications without values; `state services full` only for export.
5. Ask which areas to fix. For each: `bash snitch-railway.sh fix <area>`. After: `bash snitch-railway.sh verify` for the delta.

## "Should I move to Railway?"

Works fully offline — no Railway auth required.

```
bash snitch-railway.sh detect                     # stack, databases, native deps, host
bash snitch-railway.sh fit-matrix <stack>         # verdict + caveats
bash snitch-railway.sh stack-docs <stack>         # canonical doc URLs
```

`WebFetch` the URLs from `stack-docs` for current docs. Synthesize the migration plan, verdict at top:

| Verdict | Action |
|---|---|
| `strong` | Render Railway service config + DB add-on plan |
| `partial` | Render the plan, flag every item in `entry.dependencies_to_flag` and `entry.caveats` |
| `not-recommended` | Static-only sites — redirect to Pages/Vercel/Netlify and stop |

Honest verdicts: static sites are not Railway's strength — compute charge is wasted. WordPress works but rarely beats managed hosts. Anything Nixpacks-buildable (Node/Python/Ruby/PHP/Go/Rust/Java/Elixir/Crystal/Deno/Bun) gets `strong`.

End with cost realism (cite `references/14-cost-and-budgets.md`), DNS cutover steps, rollback path.

## "What should I have at 10k users?" / scaling readiness

```
bash snitch-railway.sh state services             # current replica + builder + healthcheck shape
bash snitch-railway.sh state cost                 # always-on vs sleeping summary
bash snitch-railway.sh detect                     # stack signals
```

Read `references/03-services-and-builders.md`, `references/14-cost-and-budgets.md`. Ask user for traffic shape (concurrent users, peak RPS). Render checklist with already-present items as `OK`. Be honest: at multi-region scale Railway is single-region — user may need a CDN in front (Cloudflare) or migrate heavy-traffic services elsewhere.

## Diagnose

Classify the symptom. Then pick tools:

| Symptom | Tools | Reasoning |
|---|---|---|
| slow response / TTFB | `state services` + `railway logs` | replica count, healthcheck timeout, resource limits |
| crashloop | `railway logs --service <svc>` | application errors |
| deploy failing | `railway logs --deployment <id>` | build error, healthcheck failure |
| env var not picked up | `state env <pid> <env> digest` | classification, references vs literal |
| custom domain not active | `state domains` | non-active status; CNAME/AAAA at registrar |
| bill spike | `state cost` | replicas, always-on count, volume size |
| db connection refused | `state databases` + `state tcp-proxies` | check public TCP proxy exposure |
| token leak suspected | `state tokens digest` → `panic revoke-token` | revoke + rotate |

## "We had an incident — what now?"

```
bash snitch-railway.sh state tokens digest                    # check tokens
bash snitch-railway.sh state env <pid> <env> digest           # check secret-shape posture
# user agrees; per recommendation:
bash snitch-railway.sh panic suspend-service <svc>            # halt traffic to a compromised service
bash snitch-railway.sh panic revoke-token <id>                # irreversible
bash snitch-railway.sh panic lockdown-db <svc>                # emits manual rotate steps
# after the incident:
bash snitch-railway.sh panic restore                          # rolls back replica suspends (token revocation NOT reversible)
```

Postmortem: read `references/13-incident-response.md`. Help the user write the timeline.

## Report format — markdown tables only

Render every audit / migrate / roadmap report as a markdown table. No bare `[FAIL] foo` lines.

### Findings

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | databases | Postgres 12 EOL | Upgrade to 17 with: railway up + dump/restore |
| 🟡 WARN | env | 3 plaintext-shaped secrets in service `api` | Move to shared variables |
| ⚪️ N/A | logs | Log drain to SIEM gated behind Pro+ | Upgrade ($20/mo/seat) for SIEM forwarding |
| 🟢 OK | services | All services have healthchecks | — |
```

Status uses one of: `🔴 FAIL`, `🟡 WARN`, `⚪️ N/A` (locked), `🟢 OK`. Sort: 🔴 → 🟡 → ⚪️ → 🟢 — bad news first.

### Architecture inventory

```markdown
| Component | Detail | Source |
|---|---|---|
| api    | Express + Helmet (numReplicas=2) | service `api` |
| worker | Sidekiq (numReplicas=1)           | service `worker` |
| db     | Postgres 16                       | add-on, volume `/var/lib/postgresql/data` |
| cache  | Redis 7                           | add-on |
```

### Cost / scaling

```markdown
| Driver | Current | Watch for |
|---|---|---|
| replicas | 2× api, 1× worker | RPS sustained > 200/s on api → bump to 3 |
| always-on | production only | preview env left always-on → bill spike |
| volumes | 10 GB postgres | growth > 50% / quarter → external DB |
```

### Migration verdict

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| nextjs | 🟢 strong | Nixpacks + node start; healthcheck `/api/health` |
| static-html | 🔴 not-recommended | Use Cloudflare Pages — Railway is wasted compute |
```

Open with one-line verdict. Open with the table. Close with "Next steps" — at most 3 imperative bullets — and explicit prompt asking which fixes to apply. No prose paragraphs between sections except a single transitional sentence.

## Common mistakes

- Don't run deprecated `check` / `migrate` / `roadmap` / `report` / `diagnose` (exit 64).
- Don't pre-load all of `references/`. Read only files relevant to the finding.
- Don't recommend Railway for static sites. Static → Pages.
- Don't mutate state under a read flow. Mutations are explicit: `fix <area>` or `panic <action>`, with user confirmation.
- Don't write inside the user's project directory. Apply emits proposed contents + diff to stdout; you apply via `Edit`/`Write`.
- Don't print plaintext secret values from `state env vars`. Use `digest` for audits.
