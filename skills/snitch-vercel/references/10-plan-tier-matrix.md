# Plan tier matrix

Three meaningful tiers: **Hobby** (free), **Pro** ($20/mo per member), **Enterprise** (negotiated).

The skill's `requires_tier` gate uses `hobby < pro < enterprise`. `[locked: pro+]` means Pro and Enterprise; `[locked: enterprise+]` means Enterprise only.

## Feature grid

| Feature | Hobby | Pro | Enterprise |
|---|---|---|---|
| Custom domains | unlimited | unlimited | unlimited |
| HTTPS / TLS | auto | auto | auto |
| Function `maxDuration` | 10s | 60s | 900s (15min) |
| Function memory | 1024MB | 3008MB | 3008MB |
| Concurrent builds | 1 | 12 | unlimited (negotiated) |
| Edge middleware invocations | 1M / mo | 1M / mo (extra metered) | metered |
| Image Optimization source images | 1k / mo | 5k / mo | metered |
| Bandwidth | 100GB / mo | 1TB / mo | metered |
| Vercel Authentication | preview only | preview + production | preview + production |
| Password protection | — | preview + production | preview + production |
| Trusted IPs | — | — | yes |
| SAML SSO | — | — | yes |
| Audit log | last 1 day | 30 days | unlimited / SIEM |
| Log drains | — | yes | yes |
| Cron jobs | — | yes | yes |
| Web Analytics | 2.5k events / mo | 100k / mo | custom |
| Speed Insights | 2.5k data points / mo | 25k / mo | custom |
| Vercel KV | included quota | included + extra | custom |
| Vercel Postgres | included quota | included + extra | custom |
| Vercel Blob | included quota | included + extra | custom |
| Edge Config | 8 KB / config | 512 KB | 512 KB+ |
| DDoS mitigation | basic | basic + Vercel Firewall | dedicated + Firewall + IP block lists |
| Vercel Firewall (custom rules) | basic | yes | advanced |
| Concurrent collaborators | 1 (you) | per-seat | per-seat |
| Commercial use | not allowed | allowed | allowed |

## Skill enforcement

| Rule | Detail |
|---|---|
| `fix log-drains` | Pro+ — surfaces `[N/A locked: pro+]` on Hobby |
| `apply_project preview-auth` | Pro+ |
| `apply_project trusted-ips` | Enterprise |
| `apply_account sso-recommend` | Enterprise |
| DNSSEC | Not provided at any tier — flag regardless |

## Cost-cliff watchlist

| Driver | Watch |
|---|---|
| Bandwidth | Hobby 100GB / Pro 1TB; Pro overage $40 per 100GB |
| Function execution | Long `maxDuration` × high concurrency adds up fast |
| Image Optimization | Every unique source image counts; large galleries blow quota |
| Edge middleware invocations | Unbounded matchers run on assets too |
| KV requests | Pro includes a quota; high-QPS rate-limit middleware can exceed it |

`state cost` surfaces these from `/v1/teams/<id>/usage`. Map raw fields against this table to project the bill.

## Hobby is non-commercial

Vercel's terms restrict Hobby to personal, non-commercial projects. Running a paid product on Hobby is a TOS violation. The skill warns when it detects monetization signals on a Hobby team.

## References

- https://vercel.com/pricing
- https://vercel.com/docs/limits
- https://vercel.com/docs/legal/policies/fair-use
