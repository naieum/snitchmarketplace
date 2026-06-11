# Cloudflare API Token — minimum permissions checklist

Create the token at the dashboard: **https://dash.cloudflare.com/profile/api-tokens** → "Create Token" → "Custom Token".

This skill **refuses** to operate when the legacy Global API Key (`X-Auth-Email` + `X-Auth-Key`) is in use. Always use a scoped token.

---

## Required permissions (full skill functionality)

### Zone-level (per-zone or "All zones" — see scoping below)

- [ ] **Zone — Zone:Read** — list zones, read zone metadata + plan tier.
- [ ] **Zone — Zone Settings:Edit** — SSL mode, HSTS, Min TLS, Always Use HTTPS, etc.
- [ ] **Zone — DNS:Edit** — read + create + update DNS records (SPF/DKIM/DMARC, CAA, proxy toggle).
- [ ] **Zone — SSL and Certificates:Edit** — Universal SSL, Authenticated Origin Pulls, edge certs.
- [ ] **Zone — Firewall Services:Edit** — IP Access Rules (panic block ip|asn|country).
- [ ] **Zone — WAF:Edit** — Custom Rules, Managed Rulesets, Rate Limiting Rules.
- [ ] **Zone — Transform Rules:Edit** — security headers transform.
- [ ] **Zone — Cache Rules:Edit** — cache TTLs, bypass on auth cookie.
- [ ] **Zone — Config Rules:Edit** — per-request setting overrides.

### Account-level

- [ ] **Account — Account Settings:Read** — list accounts, read 2FA enforcement state.
- [ ] **Account — Workers Scripts:Edit** — read/write Workers, secrets metadata.
- [ ] **Account — Workers KV Storage:Edit** — list namespaces, read keys (for KV usage audit).
- [ ] **Account — D1:Edit** — list D1 databases, read schema for prepared-statement audit.
- [ ] **Account — Workers R2 Storage:Edit** — list buckets, read CORS, scoped object policies.
- [ ] **Account — Cloudflare Tunnel:Edit** — list/create tunnels.
- [ ] **Account — Access: Apps and Policies:Edit** — Access apps in front of preview/staging.
- [ ] **Account — API Tokens:Read** — audit other tokens (token-lifecycle features).

---

## Scoping rules (apply ALL of these)

### Resources

- [ ] Limit **Zone Resources** to specific zones if you can — "Include → Specific zone → example.com". Avoid "All zones from an account" unless the skill is managing the entire account.
- [ ] Limit **Account Resources** to a single account — "Include → Specific account". Don't use "All accounts".

### Client IP filtering

- [ ] Add an **IP Address Filtering** rule to restrict the token to your office/VPN egress IP(s) or your CI runner's egress IP(s).
- [ ] If you can't pin an IP (laptop on cell, dynamic ISP), at least restrict to your country.

### TTL

- [ ] Set **TTL ≤ 1 year**. Recommended: 90 days for human-used tokens, 30 days for CI tokens. Calendar-event a renewal so it doesn't expire mid-incident.
- [ ] If the token is ever lost or leaked, **revoke immediately** (same dashboard URL) — DO NOT wait for expiry.

---

## Tier-restricted scopes (only if you use these features)

Add these as needed; otherwise leave them off so a leaked token has narrower blast radius.

- [ ] Account — Workers AI:Read (only if the skill audits Workers AI usage).
- [ ] Account — Vectorize:Edit (only if you run Vectorize indexes).
- [ ] Account — Hyperdrive:Edit (only if you use Hyperdrive).
- [ ] Account — AI Gateway:Edit (only if you use AI Gateway).
- [ ] Account — Pages:Edit (only if you use Cloudflare Pages — needed for Access on previews).
- [ ] Account — Logs:Read (Logpush — Enterprise).
- [ ] Account — Stream:Read (only if you use Cloudflare Stream).

---

## Read-only token (CI / GitHub Actions PR check)

For the `cf-secure-on-pr.yml` workflow, create a SECOND, separate token with only the `:Read` scopes from each line above. The PR workflow audits but never mutates — it should never have edit scopes.

Recommended scopes for the read-only token:

- Zone — Zone:Read
- Zone — Zone Settings:Read
- Zone — DNS:Read
- Zone — SSL and Certificates:Read
- Zone — Firewall Services:Read
- Zone — WAF:Read
- Account — Account Settings:Read
- Account — Workers Scripts:Read
- Account — D1:Read
- Account — Workers R2 Storage:Read
- Account — API Tokens:Read

Store as a GitHub Actions repo secret named `CLOUDFLARE_API_TOKEN`.

---

## Verify the token

After creating, run:

```bash
curl -fsSL -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  https://api.cloudflare.com/client/v4/user/tokens/verify | jq .
```

Expected: `result.status == "active"` and the listed scopes match what you selected.

`bash snitch-cloudflare.sh check` runs this verification automatically on every invocation and prints any missing scopes against this checklist.

---

## Red flags — revoke immediately

- Token committed to a public repo (assume compromised within minutes — GitHub secret scanning notifies attackers' bots faster than it notifies you).
- Token in a Slack message (Slack searches it; admins can read it).
- Token in a screen-share recording.
- Token used from an unexpected IP in the audit log.
- Token still "Active" but the human who created it left the team.

Revocation: dashboard → API Tokens → … → Delete. Then create a fresh one and update wherever it was stored.
