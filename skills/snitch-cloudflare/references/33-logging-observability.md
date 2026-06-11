# 33 — Logging, audit trail & observability (security-as-evidence)

Security you can't see, you can't prove. This covers the audit lenses that assess
**evidence coverage**: account audit logs, Logpush export, AI Gateway log
governance, and Workers error observability. Tools: `audit auditlog`,
`audit logpush`, `audit ai-gateway`, `audit observability`.

## Audit logs — `audit auditlog [acct] [window]`

Emits `cfsec.audit-auditlog`: counts `by_action_type` / `by_actor` / `top_actor_ips`
plus a `sensitive_events[]` subset over the window (24h|7d|30d). Audit logs are
available on **all plans** (18-month retention), so a 403 means the token lacks
**Account Audit Logs Read**, not a plan lock.

Grade the `sensitive_events` subset (the lens matches token/member/delete/2FA/SSO/
login/role/owner actions):
- `api_token.create` / `*token*` → **INFO** (expected during setup; **WARN** if unexpected actor).
- `member.add` / `member.update` / role changes → **INFO**, **WARN** if non-owner actor.
- any `*.delete` by a non-owner → **WARN**.
- `account.update` touching `enforce_twofactor` / SSO → **WARN** (governance change).
- logins from many distinct / unfamiliar countries (`top_actor_ips`, actor country) → **WARN**.
- legacy global-API-key auth seen in any entry → **FAIL** (rotate to scoped tokens; see `01-auth-and-tokens.md`).

## Logpush coverage — `audit logpush [acct]`

Emits `cfsec.audit-logpush`: `jobs[]` (destinations **redacted** — creds stripped),
and `coverage{datasets_shipped, security_datasets, missing_security_datasets}`.
Logpush is **Enterprise** → `{locked:"enterprise"}` on free/pro (render N/A; the
audit-log digest above still gives an on-platform trail).

Security-relevant datasets (the `security_datasets` reference set):

| Dataset | Why it matters | Scope |
|---|---|---|
| `http_requests` | request-level forensics, WAF context | zone |
| `firewall_events` | what the WAF/rules blocked & why | zone |
| `audit_logs` | off-platform control-plane trail | account |
| `dns_logs` | query forensics, exfil/tunneling | account |
| `access_requests` | Zero-Trust app access trail | account |
| `gateway_dns` / `gateway_http` / `gateway_network` | Zero-Trust egress | account |
| `casb_findings` / `device_posture_results` / `zero_trust_network_sessions` | ZT posture evidence | account |
| `nel_reports` | network-error / connectivity tampering | zone |

Grade:
- `firewall_events` / `http_requests` not shipped while WAF is in use → **WARN** (no security-log export).
- `audit_logs` not shipped → **WARN** (no off-platform control-plane trail).
- any job `enabled:false`, `last_error` non-null, or `last_complete` stale (>24h) → **WARN**.
- `destination_has_secret:true` (a bare secret in the returned `destination_conf`) → **FAIL** (rotate; prefer Access/OIDC or a secret-free destination).

## AI Gateway log governance — `audit ai-gateway [acct]`

Emits `cfsec.audit-ai-gateway`: per-gateway **config flags only** (never log
bodies — those carry prompt/response PII). Free tier exists → gate is on presence
(`{locked:"not-configured"}` when no gateway). Grade (see `17-workers-ai-security.md`):
- `collect_logs:true` with full-payload retention on PII-likely prompts → **WARN** (privacy; prefer metadata-only).
- `authentication_enabled:false` on a browser-reachable gateway → **WARN** (open proxy / cost abuse).
- `rate_limiting_enabled:false` → **WARN** (unbounded spend; see `23-cost-cliffs.md`).
- logs retained indefinitely → **WARN** (retention hygiene).

## Workers observability — `audit observability`

MCP-preferred (see `32-mcp-surfaces.md#observability`). Errors as an attack
signal: exception spikes aligned with WAF blocks (`audit secevents`) → probing;
repeated auth/forbidden errors → cred stuffing/IDOR; stack traces to clients →
info disclosure. Fallback: GraphQL `workersInvocationsAdaptive` counts.

Cross-refs: `09-account-hardening.md`, `17-workers-ai-security.md`,
`16-page-shield-supply-chain.md`, `18-cost-model.md`, `23-cost-cliffs.md`.
