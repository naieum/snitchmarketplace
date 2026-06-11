# 01 — Auth and Tokens

## Scoped tokens only

Skill refuses Global API Key + Email (legacy). Tokens go to `Authorization: Bearer <token>`. Create at https://dash.cloudflare.com/profile/api-tokens via "Create Custom Token" — never the templated "Read All Resources" (over-scoped).

Source: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/

## Minimum scope set

Scope to specific zones + a specific account.

Zone-scoped: `Zone:Read`, `Zone Settings:Edit`, `DNS:Edit`, `SSL and Certificates:Edit`, `Firewall Services:Edit`, `Zone WAF:Edit`, `Transform Rules:Edit`, `Cache Rules:Edit`, `Config Rules:Edit`, `Page Rules:Edit` (legacy only).

Account-scoped: `Account Settings:Read`, `Workers Scripts:Edit`, `Workers KV Storage:Edit`, `D1:Edit`, `Workers R2 Storage:Edit`, `Cloudflare Tunnel:Edit`, `Access: Apps and Policies:Edit`, `API Tokens:Read`, `Audit Logs:Read`.

Never asks for: `User Details:Edit`, `Memberships:Edit`, `Billing:Edit`.

Source: https://developers.cloudflare.com/api/tokens/create/permissions/ . Mirror: `templates/token-permissions.checklist.md`.

## IP allowlist + TTL

- Client IP filter: limit to source CIDR. Workers can't use this — too many egress IPs.
- TTL: 90 days for active operator + CI tokens; 1 year max. No-expiry = WARN.

Verify:

```sh
curl -sS https://api.cloudflare.com/client/v4/user/tokens/verify \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" | jq '.result'
```

Skill prints `expires_on` and warns within 30 days.

## Source-scan defenses

`lib/tokens.sh`:
- `grep -r 'cfut_[A-Za-z0-9_-]\+' .` — flags committed tokens (`cfut_` prefix; older are 40-char base62).
- `env | grep -E 'cfut_'` — informs which env var holds the token.
- `.gitignore` check for `.env`, `.env.*`, `.dev.vars`.

Skips: `node_modules`, `.git`, `dist`, `.next`, `.svelte-kit`, `references/`.

## Rotation flow (`fix tokens rotate`)

1. List existing (`GET /user/tokens`).
2. Create new with same `policies` (`POST /user/tokens`); surface cleartext `value` once, no logging.
3. After user confirms via `verify`, disable old: `PUT /user/tokens/{old_id}` `status: "disabled"`.
4. Confirm via audit log.

Skill never auto-deletes — disabled is reversible.

Source: https://developers.cloudflare.com/api/operations/user-api-tokens-update-token

## Audit-log usage

`fix tokens` filters audit log by `actor.token` to find unused tokens (0 entries in 90d → recommend revoke).

Source: https://developers.cloudflare.com/fundamentals/account/account-security/review-audit-logs/

## Refusing dangerous defaults

Skill exits `2` and refuses when:
- `CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL` both set (global key).
- Token scope contains `*` over an account when a zone-scoped equivalent exists.
- Token has `User:Edit`.

User shown dashboard URL + checklist + scope-down guidance. No mutation occurs.

## Scope quick-ref

| Operation | Scope |
|---|---|
| List zones | `Zone:Read` |
| Set SSL mode | `Zone Settings:Edit` |
| Edit DNS | `DNS:Edit` |
| Manage WAF custom rules | `Zone WAF:Edit` |
| Enable AOP | `SSL and Certificates:Edit` |
| Manage Tunnel | `Cloudflare Tunnel:Edit` |
| Manage Access apps | `Access: Apps and Policies:Edit` |
| Read audit logs | `Audit Logs:Read` |
| Bot Management overrides (Ent) | `Zone WAF:Edit` |
