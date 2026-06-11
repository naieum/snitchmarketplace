# Recipes — when the user asks X, do Y

Offline mirror of the recipes section in `SKILL.md`. The agent synthesizes; the shell tools provide facts.

## Audit / harden a Vercel project

Default to digest mode — every signal needed for a first-pass audit:

```
bash snitch-vercel.sh doctor                 # CLI + token + jq + curl status
bash snitch-vercel.sh detect                 # cwd signals JSON
bash snitch-vercel.sh state account          # user + team summary, 2FA, tokens
bash snitch-vercel.sh state project          # project meta, framework, region, protection digest
bash snitch-vercel.sh state env              # env-var posture + NEXT_PUBLIC_* leaks + plaintext-secret-name flags
bash snitch-vercel.sh state domains          # domains + TLS verification
bash snitch-vercel.sh state protection       # deployment protection (sso, password, trusted ips)
```

Run in parallel (single message, multiple Bash calls). Digests are ~85% smaller than full payloads.

Then:

1. Compare `state.project` to policy in `references/02-deployment-protection.md`, `references/05-headers-via-vercel-json.md`.
2. Compare `state.env.sensitive_summary` to `references/03-env-vars-and-secrets.md`. `next_public_secret_shape` → `FAIL`. `plaintext_with_secret_name` → `WARN`.
3. Compare `state.account.tokens_summary.no_expiry` to `references/01-auth-and-tokens.md`. > 0 → `WARN`.
4. Fetch slices only when the digest signals: `state env <id> production` if many plaintext-secret-named vars in production; `state functions <id>` for runtime/region; `state middleware <id>` to introspect `middleware.ts`.
5. Group findings by area; mark `OK / WARN / FAIL / [N/A locked]`. Use `references/10-plan-tier-matrix.md` for value-statements on locked items.
6. Ask which areas to fix. Per area: `bash snitch-vercel.sh fix <area>`. After: `bash snitch-vercel.sh verify` for the delta.

## "Should I migrate to Vercel?"

Works fully offline — no token required.

```
bash snitch-vercel.sh detect              # stack, databases, native deps, host provider
bash snitch-vercel.sh fit-matrix <stack>  # verdict + caveats per stack
bash snitch-vercel.sh stack-docs <stack>  # canonical doc URLs
```

Synthesize with the verdict at the top:

- `strong` → render a concrete migration plan with the recommended adapter and DNS cutover.
- `partial` → render the plan but flag every item in `entry.dependencies_to_flag` and `entry.caveats`. Be honest about cold-start cost.
- `not-recommended` → say no. Suggest the right host (Fly / Railway / AWS / Render / DO). Optionally: front-end on Vercel calling the API on the right host.

End with cost realism (cite `references/14-cost-and-budgets.md`), DNS cutover steps (lower TTL → switch records → verify → re-raise TTL), rollback path (keep old host live for 24-48h).

## "What should I have at 10k users?" / scaling readiness

```
bash snitch-vercel.sh state project
bash snitch-vercel.sh state functions
bash snitch-vercel.sh state cost 30d
bash snitch-vercel.sh detect
```

Read `references/14-cost-and-budgets.md` and `references/10-plan-tier-matrix.md`. Pick the user's plateau by asking traffic numbers. Render the next plateau's checklist. Be honest if Vercel becomes more expensive than the user's current host at projected scale.

## Diagnose

Classify the symptom yourself; never shell-regex it. Then pick tools:

| Symptom | Tools | Reasoning |
|---|---|---|
| 5xx surge | `state deployments 24h` | bad recent deploy → rollback |
| function timeout | `state functions` | region / memory misconfig |
| cert error | `state domains` | verification or DNS change |
| bill spike | `state cost 30d` | which meter exploded; map to references/14 |
| preview leaking content | `state protection` | enable Vercel Auth on previews |
| secret leak suspicion | `state env` | check `next_public_secret_shape` + plaintext lists |
| env-var pull broken | `state env <id> production` | confirm var lands in target env |

## "We're under attack right now"

```
bash snitch-vercel.sh state cost              # see whether bandwidth or fn invocations spike
# Decide with user: lock production?
bash snitch-vercel.sh panic lock-production   # SSO Auth on all deployments — only signed-in team gets through
# Add stricter middleware (deploy a new middleware.ts).
# After:
bash snitch-vercel.sh panic restore
```

Postmortem: `references/13-incident-response.md`. Help the user write the timeline.

## Report format — always tables

Every audit / migrate / roadmap report MUST:

- Open with a one-line verdict.
- Use markdown tables for findings, architecture, cost, migration verdicts.
- Close with "Next steps" — at most three imperative bullets.
- No prose paragraphs between sections except a single transitional sentence.
- Status badges: 🔴 FAIL, 🟡 WARN, ⚪️ N/A (locked), 🟢 OK. Sort: 🔴 → 🟡 → ⚪️ → 🟢.

### Findings table

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | env | `NEXT_PUBLIC_API_TOKEN` ships to browser | Rename, drop `NEXT_PUBLIC_` prefix |
| 🔴 FAIL | protection | Production has no deployment protection | Pro+: configure preview Auth at minimum |
| 🟡 WARN | account | 2 tokens have no expiry | Rotate via /account/tokens |
| 🟡 WARN | domains | DNSSEC not enabled (Vercel DNS limit) | Delegate DNS to a DNSSEC-supporting registrar |
| ⚪️ N/A  | log-drains | Log drains require Pro+ | Upgrade to retain logs >24h |
| 🟢 OK   | project | Vercel Authentication enabled for previews | — |
```

### Architecture inventory table

```markdown
| Component | Detail | Source |
|---|---|---|
| Stack | Next.js 14 (App Router) | `state project` |
| Region | `iad1` | `state project` |
| Storage | Vercel Postgres + KV | `state kv-postgres-blob` |
```

### Cost / scaling table

```markdown
| Driver | Current | Watch for |
|---|---|---|
| Bandwidth | 80 GB / mo | Pro 1 TB ceiling |
| Edge middleware | 1.2M invocations | Tighten matcher; skip `_next/static` |
```

### Migration verdict table

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| nextjs | strong | Vercel — native runtime |
| express | partial | Per-file `api/` handlers OR move to Fly/Railway |
| rails | not-recommended | Stay on Heroku/Fly; put a Next.js front-end on Vercel |
```

End with "Next steps" (≤3 imperative bullets) and an explicit prompt asking which fixes to apply.

## Common mistakes

- Don't run `bash snitch-vercel.sh check / migrate / roadmap / report / diagnose / stacks` — deprecated, exit 64.
- Don't pre-load all of `references/`. Read only the file relevant to the current finding.
- Don't suggest Vercel KV as a Redis-strong-consistency replacement; it's eventually consistent.
- Don't mutate Vercel under a read flow. Mutations are explicit: `fix <area>` or `panic <action>`, both with user confirmation.
- Don't write inside the user's project directory. `fix headers` / `fix project` emit proposed contents + diff to stdout; apply via `Edit` / `Write`.
