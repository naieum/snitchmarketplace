# Vertical: SaaS / multi-tenant

Detection: subdomain routing (`{tenant}.example.com`), `tenantId` / `organizationId` in code, B2B auth libs (`@workos-inc/*`, `auth0`, `clerk`, Firebase with custom claims), shared DB with tenant column.

Cross-tenant data leakage is the #1 risk. CF role: keep blast radius small (per-tenant rate limits, takeover paranoia on customer DNS), enforce admin isolation at edge, standardize white-label custom domains.

## Cloudflare overlay

- Per-tenant rate limit keyed on tenant ID (not IP — IP collapses across users in the same office). Workers Rate Limiting binding:

  ```ts
  const { success } = await env.RATE_LIMITER.limit({ key: `tenant:${tenantId}` });
  ```

  ```toml
  [[unsafe.bindings]]
  name = "RATE_LIMITER"; type = "ratelimit"
  namespace_id = "9001"; simple = { limit = 10000, period = 3600 }
  ```

  Per-feature quotas: wrap with logic that reads plan from KV/D1.
- Wildcard DNS proxied: `*.example.com → CNAME → app.example.com`. Universal SSL covers `*.example.com`. Per-subdomain WAF via Custom Rules with `http.host` matching.
- Subdomain takeover paranoia is extra-strict — every CNAME-to-third-party HEAD-checked against the provider's "doesn't exist" fingerprint; customer-controlled CNAMEs audited continuously. See `27-takeover-cookie-probe.md`.
- Cloudflare Access on internal admin (`admin.example.com`, `/internal/*`) — company-email-domain policy, optional mTLS for service-to-service. Customer-facing tenant admin (`/admin/`) stays on app-level auth.
- Cloudflare for SaaS / Custom Hostnames for white-label tenant domains (`app.tenant-a.com → cf-saas.example.com`). Per-tenant edge cert via API; per-tenant WAF / rate limit / cache via Custom Rules with `http.host`. https://developers.cloudflare.com/cloudflare-for-platforms/cloudflare-for-saas/
- Audit log retention beyond CF default (18mo): Logpush to S3 / Splunk if compliance demands.

## Tenant-isolation static checks

- Every DB query has a `tenantId` filter. WARN if missing.
- Tenant context from `req.user.tenantId`, never `req.body.tenantId`. WARN otherwise.
- Cross-tenant join queries: WARN.
- Webhook URLs include tenant ID and validate against payload.

## Plan recommendation

| Tier | Use |
|---|---|
| Pro ($25/mo) | minimum. Managed Ruleset, OWASP CRS, exposed-credentials |
| Business ($250/mo) | regex in custom rules, payload logging |
| Enterprise | API Shield, SSO, account-level WAF, Logpush. Recommended for regulated data |

## Skill checklist

- [ ] Wildcard DNS proxied if multi-tenant subdomains.
- [ ] Subdomain takeover scan clean.
- [ ] Per-tenant rate limit (Workers binding) on heavy endpoints.
- [ ] Access on internal admin paths.
- [ ] Tenant filter in every DB query.
- [ ] `req.user.tenantId`, never `req.body.tenantId`.
- [ ] Custom domains via Cloudflare for SaaS if applicable.
- [ ] Outbound webhook signing.

Source: https://developers.cloudflare.com/cloudflare-for-platforms/cloudflare-for-saas/
