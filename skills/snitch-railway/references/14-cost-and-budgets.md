# Cost and budgets

Railway's pricing is usage-based. The skill cannot read billing detail (no public API), but it surfaces signals you can act on.

## What the skill detects

`state cost` digest reports:

- Plan tier (via `me { plan }`).
- Always-on vs sleeping services count.
- Total replicas (each is a separate compute charge).
- Free-tier exhaustion warning if Trial/Hobby with always-on services.

## Cost drivers

| Driver | Detail |
|---|---|
| vCPU-hours | every replica × every hour. Sleep cuts staging/preview. |
| Memory-hours | same shape, RAM allocation. |
| Volume GB-months | small per GB; stateful services compound. |
| Egress | usually small for API; large for media. |
| DB add-ons | each is a service, billed at compute + volume. |

## Common cost mistakes

- Production = 1 replica, staging = 1 replica, preview = always-on with sleep off → 3× compute for one app.
- Volumes attached "just in case" — billed monthly even if empty.
- `numReplicas` set high (4+) without traffic to justify.

## Budget alerts

Configure in dashboard → team → Usage. Without alerts, runaway loops can rack up usage before notice. Skill surfaces this as `WARN` always (can't read alert state).

## Recommendations

| Env | Settings |
|---|---|
| Production | always-on, replicas tuned to actual traffic |
| Staging | always-on optional; sleep fine |
| Preview | sleep on, auto-delete on PR close |

Set alerts at 50% of expected monthly usage. Run `bash snitch-railway.sh state cost digest` monthly.

## Docs

- https://docs.railway.com/reference/usage
- https://railway.com/pricing
