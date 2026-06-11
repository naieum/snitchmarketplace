# 36 — Device posture (DEX) & SaaS posture (CASB)

Two Zero-Trust-Enterprise lenses, both MCP-only and **auto-gated**: on accounts
without the entitlement (or without WARP/integrations configured), `audit dex` and
`audit casb` return `locked:"mcp-absent"` (no MCP) or the recipe's first call
returns empty/forbidden → render a ⚪️ N/A row. Free/pro users see a clean report;
these never add noise. Recipes + finding taxonomy live in `32-mcp-surfaces.md`.

## DEX — device posture & network health (`audit dex`)

The security question: are the devices and network paths your users rely on
actually healthy and protected? Posture is only as good as its enforcement.

What "good" looks like:
- High fleet WARP-connected % (≈≥90%); few users disabling/tampering with WARP.
- Synthetic tests to critical internal apps passing; latency within norms.
- Traffic egressing through expected Cloudflare colos.

Security reads:
- A spike in WARP-disconnect / `warp_change_events` = posture **bypass** — policies
  that assume WARP is on are silently not applying. **WARN**.
- Failing synthetic tests to internal apps = availability/auth path problem. **WARN**.
- Unexpected egress geography = split-tunnel/misconfig. **INFO**.

## CASB — SaaS misconfiguration posture (`audit casb`)

Extends the audit beyond Cloudflare itself to the SaaS apps (Google Workspace,
Microsoft 365, GitHub, etc.) the org connects. The CASB graph normalizes assets
and findings — there is no public REST equivalent, hence MCP-only.

What "good" looks like:
- No publicly shared sensitive files; least-privilege OAuth grants; admins on MFA;
  integrations connected and current.

Security reads:
- Public "anyone with link" sensitive files → **FAIL** (data exposure).
- Broad third-party OAuth scopes → **WARN** (supply-chain / token risk).
- Admin without MFA → **FAIL**.
- Stale/disconnected integration → **INFO** (blind spot).

## The auto-gate story (why free/pro stays clean)

Both lenses follow the skill's honesty ethos: rather than pretend to assess a
surface that isn't there, they declare it locked/absent with an install or
upgrade hint. In `audit all`, these become ⚪️ N/A rows and are **neutral-scored**
— a free/pro account is never penalized for lacking an Enterprise Zero-Trust
feature (see `20-validator-grading.md`).

Cross-refs: `08-zero-trust-tunnel-access.md`, `32-mcp-surfaces.md` (recipes),
`10-plan-tier-matrix.md` (tiers), `33-logging-observability.md`
(ZT Logpush datasets).
