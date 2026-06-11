# 10 — Plan Tier Matrix

Pricing 2026-05; check `https://www.cloudflare.com/plans/` for current.

| Feature | Free | Pro ($25/mo) | Business ($250/mo) | Enterprise (sales) |
|---|---|---|---|---|
| **DNS / TLS** | | | | |
| Universal SSL | yes | yes | yes | yes |
| Advanced Cert Manager | no | $10/mo add-on | $10/mo add-on | included |
| Custom Cert upload | no | no | yes | yes |
| CT monitoring | basic email | email | email + UI | API + webhooks |
| DNSSEC | yes | yes | yes | yes |
| AOP — Global cert | yes | yes | yes | yes |
| AOP — Per-zone cert | no | yes | yes | yes |
| AOP — Per-hostname | no | no | no | yes |
| HSTS | yes | yes | yes | yes |
| Min TLS version | yes | yes | yes | yes |
| **WAF** | | | | |
| Free Managed Ruleset | yes | replaced | replaced | replaced |
| Cloudflare Managed | no | yes | yes | yes |
| OWASP Core | no | yes | yes | yes |
| Custom rules count | 5 | 20 | 100 | 1000+ |
| Regex in custom rules | no | no | yes | yes |
| Payload logging | no | no | yes | yes |
| Log action | no | yes | yes | yes |
| Exposed-credentials check | no | yes | yes | yes |
| Sensitive-data DLP | no | no | yes | yes |
| API Shield (schema, JWT) | no | no | partial | yes |
| API Shield (mTLS, sequence) | no | no | no | yes |
| Account-level WAF | no | no | no | yes |
| **Bots** | | | | |
| Bot Fight Mode | yes | replaced | replaced | replaced |
| Super Bot Fight Mode | no | yes | yes | replaced |
| Bot Management (ML) | no | no | no | yes |
| **Rate Limiting** | | | | |
| Rate Limiting Rules | 1 | 10 | 100 | 1000+ |
| Workers Rate Limiting binding | yes | yes | yes | yes |
| Advanced Rate Limiting | no | no | yes | yes |
| **DDoS** | | | | |
| L3/L4 protection | yes | yes | yes | yes |
| L7 managed ruleset | yes (locked) | tunable | tunable | tunable + custom |
| Magic Transit | no | no | no | yes (add-on) |
| **Performance / Cache** | | | | |
| Tiered Cache | yes | yes | yes | yes |
| Smart Tiered Cache | no | yes | yes | yes |
| Cache Reserve | no | yes (Workers Paid) | yes | yes |
| Argo Smart Routing | usage-billed | usage-billed | usage-billed | usage-billed |
| Polish | no | yes (lossy) | yes (lossless+lossy) | yes |
| Mirage | no | yes | yes | yes |
| **Page Shield** | | | | |
| Script monitor | no | yes | yes | yes |
| Connection monitor | no | no | yes | yes |
| CSP report-uri | no | yes | yes | yes |
| **Workers** | | | | |
| Workers Free | 100k req/day | 100k req/day | 100k req/day | 100k req/day |
| Workers Paid ($5/mo) | yes | yes | yes | yes |
| Workers Logs (free retention) | 200k events/day | 200k events/day | 200k events/day | 200k events/day |
| Logpush | no | no | no | yes |
| Smart Placement | yes (Workers Paid) | yes | yes | yes |
| Cron Triggers | yes (Workers Paid) | yes | yes | yes |
| **Pages** | | | | |
| Pages Free | yes | yes | yes | yes |
| Pages Functions | yes (Workers limits) | yes | yes | yes |
| Pages preview Access | yes (≤50 users) | yes | yes | yes |
| **Storage** | | | | |
| R2 | yes (10 GB/mo free) | yes | yes | yes |
| KV | yes (free tier) | yes | yes | yes |
| D1 | yes (free tier) | yes | yes | yes |
| Hyperdrive | yes (Workers Paid) | yes | yes | yes |
| Durable Objects | yes (Workers Paid) | yes | yes | yes |
| **Zero Trust** | | | | |
| Cloudflare Tunnel | yes | yes | yes | yes |
| Access (≤ 50 seats) | yes | yes | yes | yes |
| Access (> 50 seats) | $7/seat/mo | $7/seat/mo | $7/seat/mo | included up to neg. |
| Service Tokens | yes | yes | yes | yes |
| Gateway DNS | ≤ 50 users | yes | yes | yes |
| Gateway HTTP filtering | no | $7/seat/mo | $7/seat/mo | yes |
| WARP | yes | yes | yes | yes |
| Browser Isolation | no | partial paid | partial paid | yes |
| Device posture (advanced) | basic | full | full | full |
| **Account** | | | | |
| 2FA enforcement | yes | yes | yes | yes |
| SSO enforcement | no | no | no | yes |
| Audit logs (18 months) | yes | yes | yes | yes |
| Logpush audit logs | no | no | no | yes |
| Notifications (most) | yes | yes | yes | yes |
| **Other** | | | | |
| Aegis (dedicated egress IPs) | no | no | no | yes (add-on) |
| Magic WAN | no | no | no | yes |
| Spectrum (TCP/UDP proxy) | no | no | no | yes |
| Stream / Images | usage-billed | usage-billed | usage-billed | usage-billed |
| AI Gateway | yes (free tier) | yes | yes | yes |
| Workers AI / Vectorize / AutoRAG / Browser Rendering | usage / Workers Paid | yes | yes | yes |
| Web Analytics / Zaraz | yes | yes | yes | yes |

Source: https://www.cloudflare.com/plans/

## Audit-lens gating (`audit <lens>`)

How the new audit lenses auto-gate (see `31-tool-contracts.md` locked convention):

| Lens | Gate | Locked value when unavailable |
|---|---|---|
| `audit logpush` | Enterprise | `enterprise` (403/404) |
| `audit ai-gateway` | free tier exists → gate on presence | `not-configured` (no gateway) |
| `audit auditlog` | all plans (needs token scope) | — (403 = scope error, not a lock) |
| `audit dns` / `audit secevents` | needs Analytics scope | — (GraphQL-unavailable stub) |
| `audit casb` | Enterprise Zero Trust (CASB add-on) | `mcp-absent` / empty integrations |
| `audit dex` | Zero Trust (WARP/DEX) | `mcp-absent` / not deployed |
| `audit builds` | Workers Builds (connected repo) | `mcp-absent` |

Locked/absent lenses are **neutral-scored** in `audit all` — see `20-validator-grading.md`.

## Notes

- Pro is $25/mo as of 2026; older docs may say $20.
- Business is per-zone.
- Enterprise pricing is per-deal; never quote a number.
- Workers Paid is $5/mo account-wide, not per-Worker. Overages extra.
- "Free up to 50 users" appears in multiple places (Access, Gateway DNS).
- Add-ons (ACM, Stream, Images, Magic WAN) bill separately.

## How the skill uses this

`lib/plan.sh` reads `plan.legacy_id` from `GET /zones/{id}` and maps to `free`, `pro`, `business`, `enterprise`. Each `<area>_run` check is annotated with `min_tier`. If `min_tier > active_tier`, the check uses `log_locked` instead of running.
