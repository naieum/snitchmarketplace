# 09 — Account Hardening

## 2FA

Per-user (`/profile/authentication`):
- TOTP minimum acceptable; SMS = WARN (SIM-swap).
- WebAuthn / hardware keys preferred.
- Best practice: 2 physical keys (one carried, one safe), TOTP fallback, offline backup codes.

Account-level enforce: `Members → Enforce 2FA`. Free.

```
PUT /accounts/{id}  body: {"settings":{"enforce_twofactor":true}}
```

User without 2FA = FAIL.

Sources: https://developers.cloudflare.com/fundamentals/account/account-security/2fa/ , https://developers.cloudflare.com/fundamentals/account/account-security/2fa/configure-2fa/

## SSO (Enterprise)

SAML / OIDC via Okta / Azure AD / Google Workspace / OneLogin. SCIM provisioning. Required at 100k+. Non-SSO Enterprise = WARN.

Source: https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/dash-sso-apps/

## Audit logs

`GET /accounts/{id}/audit_logs?since=...&action.type=...&actor.email=...`. Retention: 18 months (Free/Pro/Biz); + Logpush export (Ent).

Spot checks (last 30 days):
- `*.delete` by non-owner → INFO.
- `api_token.create` → INFO.
- `member.add` → INFO.
- Login from unfamiliar country → WARN.

Source: https://developers.cloudflare.com/fundamentals/account/account-security/review-audit-logs/

## Member roles

Common: Super Administrator, Administrator, Administrator Read Only, Cloudflare Access, Workers Admin/Edit/Read, DNS, Custom (Ent).

Skill checks:
- Super Admins > 3 → WARN.
- Members with no recent login → WARN.
- Members on personal-domain email when org uses corp domain → INFO.

Source: https://developers.cloudflare.com/fundamentals/account/account-security/account-roles/

## Token audit

`GET /user/tokens`. Per-token flags:
- No `expires_on` → WARN.
- `expires_on` < 30 days → INFO.
- IP allowlist empty → INFO.
- Last used > 90 days ago → WARN.

Global API key in audit log → WARN.

See `01-auth-and-tokens.md`.

## Account-level WAF (Enterprise)

`/accounts/{id}/rulesets`. Write once, applies to every zone. Useful for orgs with many domains.

Source: https://developers.cloudflare.com/waf/account/

## Notifications (skill defaults)

| Alert | Type | Mechanism | Plan |
|---|---|---|---|
| Cert expiry | `universal_ssl_event_type` | email | Free |
| L7 DDoS | `dos_attack_l7` | email | Free |
| L4 DDoS | `dos_attack_l4` | email | Free |
| WAF block spike | `traffic_anomalies_alert` | email | Free |
| Bot attack | `bot_attack` | email + webhook | Free |
| Workers usage threshold | `workers_request_event` | email | Workers Paid |
| R2 bucket usage | `r2_bucket_event` | email | Free |
| Audit-log activity | `audit_log_added` | email | Pro+ |
| Tunnel health degraded | `cf_tunnel_health` | email + webhook | Free |
| Real-origin-IP exposure | `real_origin_monitoring` | email | Free |

Mechanisms: `email`, `webhook`, `pagerduty`, `discord` (via webhook).

API: `POST /accounts/{id}/alerting/v3/policies` body `{name, alert_type, enabled, mechanisms, filters}`.

Source: https://developers.cloudflare.com/notifications/

## Skill targets

- 2FA enforced at account level: FAIL if not.
- Super Admin count ≤ 3: WARN if more.
- Global API key not in use: FAIL on audit-log evidence.
- Scoped tokens reviewed for expiry/usage every run.
- 5+ critical notifications subscribed: WARN if fewer.
- SSO enforced (Ent): WARN if not.
