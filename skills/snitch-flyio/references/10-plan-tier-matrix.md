# 10 — Plan / tier matrix

Fly's billing is usage-based, not tiered. The "plan" in `orgs show` is billing posture, not feature gates. Almost everything is universal; cost is what differs.

## Org tiers (rough mapping)

| Tier | Who | Notes |
|---|---|---|
| `personal` | individual signup | Historical $5/mo trial credit; "free"/hobby band. |
| `hobby` | individual paid | Pay-as-you-go on personal account. |
| `pay-as-you-go` | most production users | Standard. Bill grows with usage. |
| `launch` / `scale` | startup tiers | Volume discounts; SLA tiers; priority support. |
| `enterprise` | committed contract | Dedicated capacity, custom regions, support SLAs. |

## What's universal

Available on every tier: Machines (incl. GPU), Volumes, Tigris, Postgres (legacy + managed), Redis (Upstash-on-Fly), WireGuard, anycast IPs, custom domains, log shipping, metrics, audit log, deploy tokens, 6PN.

## What changes by tier

| Item | Tier behavior |
|---|---|
| Volume discounts | Kick in at `launch+`. |
| GPU machine availability | A100/H100 may need quota approval at any tier. |
| Dedicated regions | Enterprise only. |
| Support SLA | Best-effort → business-hours → 24/7 by tier. |
| Multiple-org billing consolidation | `launch+`. |

## When to upgrade

| Trigger | Action |
|---|---|
| Spend > ~$1000/mo | Ask sales for `launch` or `scale` pricing. |
| Need GPU H100s at scale | Enterprise quota. |
| Need dedicated region | Enterprise. |
| Need signed BAA (HIPAA) | Enterprise. |

## What gets `[locked: <tier>+]`

Rare. Examples:

- Cross-region read replicas on Managed Postgres above some plans.
- Higher concurrent build slots at `launch+`.

When in doubt, the skill emits `WARN` not `LOCKED`. Authoritative tier info: https://fly.io/pricing.

Lead with the config fix; mention pricing only when relevant.
