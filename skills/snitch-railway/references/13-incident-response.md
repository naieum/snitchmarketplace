# Incident response

Fast paths the skill exposes:

| Action | Tool |
|---|---|
| Stop a service from receiving traffic | `bash snitch-railway.sh panic suspend-service <svc>` (sets numReplicas=0) |
| Revoke project token | `bash snitch-railway.sh panic revoke-token <id>` (irreversible) |
| Lock down a database (rotate creds + remove TCP proxy) | `bash snitch-railway.sh panic lockdown-db <svc>` (emits manual steps) |
| Roll back recorded panic actions | `bash snitch-railway.sh panic restore` |

## Triage runbook

1. **Confirm scope**:
   - Compromised token? Suspect deploy? Stolen secret?
   - `bash snitch-railway.sh state tokens digest` and `state env <pid> <env> digest`.
2. **Contain**:
   - Token implicated → `panic revoke-token <id>` immediately.
   - Service compromised → `panic suspend-service <svc>`.
   - DB implicated → `panic lockdown-db <svc>`, follow emitted manual steps (rotate password, remove TCP proxy).
3. **Investigate**:
   - `railway logs --service <svc>` for the compromised window.
   - Audit log in dashboard for variable changes / deploys / member adds.
4. **Restore**:
   - Issue new tokens.
   - Update CI secret stores.
   - Bring services back: `panic restore` reverses recorded actions where possible.
5. **Postmortem**:
   - Document timeline.
   - Identify gap (missing 2FA? overprivileged token? plaintext secret?).
   - File remediation tickets — most likely findings come straight from existing WARN list.

## Limits

- Token revocation is **not reversible**. Issue a new token.
- DB lockdown is partly manual: Railway has no IP-allowlist mutation. Skill emits CLI steps to remove TCP proxy and rotate password.
- Audit log is dashboard-only — no automated dump.

## Comms checklist

- Status page: external (not Railway's — yours).
- Customer notice within 4h if PII may have been exposed.
- Token rotation log: who got new tokens, when.

## Docs

- https://docs.railway.com/reference/logging
- https://railway.com/account/tokens
