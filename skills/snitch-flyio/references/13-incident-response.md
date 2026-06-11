# 13 — Incident response

## 1. App is dead (5xx everywhere)

```sh
fly status -a <app>
fly machines list -a <app> --json
fly logs -a <app> | tail -100
```

If machines crashed:

```sh
fly machines start <id> -a <app>
fly scale count <n> -a <app>
fly releases -a <app>
fly releases rollback -a <app>            # revert if a deploy broke it
```

If health checks fail:

| Cause | Action |
|---|---|
| Last release made `/health` fail | Rollback. |
| Database down | `fly postgres connect -a <db>`. |
| OOM | `fly scale memory <mb>`; check `fly logs` for OOM. |

## 2. Suspected compromise

```sh
# 1. Revoke token
bash snitch-flyio.sh panic revoke-token <token-id>
# Or: fly tokens revoke <token-id>

# 2. Rotate every secret
fly secrets list -a <app> --json
fly secrets set NAME=<NEW> -a <app>

# 3. Rotate DB password (if leaked)
fly pg revoke -a <db-app> --user <user>
fly postgres attach <db-app> -a <app>

# 4. Force redeploy
fly deploy -a <app> --force-machines

# 5. Audit log
# https://fly.io/dashboard/<org>/audit-log
```

## 3. Bill spike

```sh
bash snitch-flyio.sh state cost <org>
fly machines list -a <app>                # GPU? unexpected count?
fly volumes list -a <app>                 # large volumes?
```

Mitigations:

```sh
bash snitch-flyio.sh panic suspend <app>
bash snitch-flyio.sh panic scale-to-zero <app>
fly volumes destroy <id> -a <app>
fly machines list -a <app> --json | jq '.[] | select(.config.processes==null)'   # orphans
```

After: set billing alerts in dashboard.

## 4. DDoS / abuse

```sh
fly scale count 10 -a <app>               # absorb the wave
bash snitch-flyio.sh panic suspend <app>         # OR pause while investigating
```

Long-term: put **Cloudflare in front** for L7 WAF / rate limiting / bot fight. Fly has no L7 WAF.

## 5. Region failure

Single-region recovery:

```sh
fly machines clone <id> --region <other> -a <app>
```

Multi-region steady state:

```toml
primary_region = "iad"
# Deploy to multiple: fly deploy --regions iad,fra,syd
```

DNS resolves anycast; clients hit nearest healthy machine.

## panic restore

`bash snitch-flyio.sh panic restore` replays inverse of every recorded panic action since the last restore. Per-action JSON written to `.state/panic-<ts>.json`.

NOTE: token revocation is irreversible — mint a new token.

## Postmortem template

| Section | Content |
|---|---|
| Timeline (UTC) | Start of impact, detection, mitigation, resolution. |
| Root cause | What broke; what triggered it. |
| Blast radius | Apps / users / regions / duration. |
| Mitigations | Sequence of commands. |
| Long-term fix | What prevents recurrence. |
| Follow-ups | Tickets, audit log review, rotation reminders. |

Keep it ego-free. Distinguish: Fly outage vs your app crash vs human error vs auth compromise.
