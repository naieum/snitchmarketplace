# 21 — Already on Cloudflare

For projects whose domain is already in the user's CF account. Renders a prioritized improvement plan.

## Detection

Cross-reference: domains from `wrangler.toml` routes / `pages_build_output_dir` / `package.json` deploy scripts / `_redirects` / source URLs / README mentions, against zones the token sees (`GET /zones`).

| Signal | Render |
|---|---|
| Match | "Already on Cloudflare for `<domain>` (`<plan>`)" |
| No match but token sees zones | "You have a CF account but this project isn't in it. See `fit-matrix`." |
| Token sees no zones | prompt user |
| `vercel.json` / `netlify.toml` / `app.yaml` / `Procfile` / `fly.toml` present | "Currently hosted on `<host>`. See migrate flow." |

## Four buckets (sorted by impact × ease)

### Do today (free, < 10 min each)

- HSTS (`max-age=86400`, ramp to 1y over 2 weeks).
- SSL = strict; min TLS 1.2.
- Always Use HTTPS; Automatic HTTPS Rewrites.
- Bot Fight Mode on.
- Free Managed WAF Ruleset on.
- Subscribe to L7 DDoS, cert expiry, traffic anomaly notifications.
- `_headers` file (Pages) with security set.
- 2FA enforced at account level.
- Disable `workers.dev` for production Workers.
- `.dev.vars` and `.env*` in `.gitignore`.

### Do this week (free, takes thought)

- DNSSEC + paste DS at registrar.
- CAA records.
- Foreign-tech WAF rule.
- 1 Rate Limiting Rule on `/login`.
- SPF / DKIM / DMARC `p=none` ramp.
- Cloudflare Tunnel from origin.
- AOP (Global cert).
- Scoped tokens; rotate or remove global API key.
- Access on staging / preview.
- `score` for SSL Labs / MDN HTTP Observatory.
- `/.well-known/security.txt` (RFC 9116).
- Subdomain takeover scan + remediation.
- Cookie audit.
- Live exposure probe.

### Worth paying for

| Tier | Value |
|---|---|
| Pro $25/mo | CF Managed Ruleset + OWASP CRS + Super BFM + Log action + Page Shield script monitor — stops next OWASP Top-10 zero-day automatically |
| Pro + ACM ($25 + $10/mo) | longer-validity certs, CA preference, multi-host SAN |
| Workers Paid $5/mo | 30s CPU/req, 10M req/mo, Cron Triggers, Hyperdrive, DOs, Vectorize, Smart Placement |
| Business $250/mo | regex in custom rules, payload logging, 100 custom rules, Page Shield connection monitor, Custom Certs |
| Enterprise | API Shield, Bot Management ML, account-level WAF, SSO, Logpush, Aegis |
| Zero Trust > 50 seats $7/seat | Gateway HTTP filtering, Browser Isolation, advanced device posture |

### Strategic (multi-day / org lifts)

- S3 → R2 migration (zero egress).
- External Postgres/MySQL behind Hyperdrive.
- AI Gateway in front of all external LLM calls.
- Replace third-party scripts with Zaraz.
- GA4 → CFWA where event-tracking depth not needed.
- Prod/staging multi-account separation (`26-multi-zone-org.md`).
- Health Checks + LB with maintenance-page standby.
- GitHub Actions PR-blocking `cf-secure-on-pr.yml`.
- Logpush → SIEM (Ent) or webhooks (free).
- Terraform via `snitch-cloudflare.sh terraform`.
- Migrate from Vercel/Netlify if cost/control argues.

## Recurrence

Roadmap regenerates as plan tier, traffic shape, new CF features, and stack deps change. Run monthly for active projects, quarterly for stable.

Cross-refs: `22-scaling-ladder.md`, `23-cost-cliffs.md`, `24-decision-trees.md`.
