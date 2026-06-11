# SaaS / multi-tenant

Detection: subdomain routing (`{tenant}.example.com`), `tenantId` / `organizationId` in code, B2B auth libs.

Cross-tenant data leakage is the #1 risk.

## DigitalOcean overlay

- **Per-tenant rate limit keyed on tenant ID**, not IP — IP collapses across users in the same office.
- **Wildcard DNS** is supported, but DO managed DNS does not provide free wildcard certs at the LB layer. Use App Platform with a wildcard domain or Cloudflare in front.
- **Subdomain takeover paranoia**: HEAD-check every CNAME-to-third-party against the provider's "doesn't exist" fingerprint.
- **Admin path separated**: `admin.example.com` or `/internal/*` IP-allowlisted via Cloud Firewall (Droplets) or behind a separate App Platform component with stricter envs.
- **Audit logs**: ship app-level events to a separate Spaces bucket (and/or SIEM). DO's Activity feed only covers infra changes.
- **Tenant-isolated query layer**: every query MUST include `tenantId`. Code-level `SELECT FOR UPDATE` of tenant context — never trust `req.body.tenantId`.

## Static checks

| Check | Status |
|---|---|
| Every DB query has a `tenantId` filter | 🟡 WARN if missing |
| Tenant context from `req.user.tenantId` not `req.body.tenantId` | 🟡 WARN otherwise |
| Cross-tenant join queries | 🟡 WARN |

## Plan recommendation

- Production-tier Managed Postgres (HA + PITR). Standard tier is dev/staging only.
- App Platform Pro for production traffic.
- DOKS HA control plane for k8s-based SaaS.

## Skill checklist

- Wildcard DNS proxied through Cloudflare for free wildcard cert + WAF.
- Subdomain takeover scan clean.
- Per-tenant rate limit on heavy endpoints.
- Admin paths IP-allowlisted or behind SSO.
- Tenant filter in every DB query.
- `req.user.tenantId`, never `req.body.tenantId`.
- PITR enabled on the order/customer DB.
- Daily backups + monthly restore drill.
