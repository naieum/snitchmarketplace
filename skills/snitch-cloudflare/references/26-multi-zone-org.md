# 26 — Multi-Zone / Multi-Account Organization

Two concerns: (1) batch-ops across zones in one account, (2) prod/staging in separate accounts to limit blast radius.

## When this matters

- 5+ zones in one account.
- Mixed prod/staging/dev zones in same account → token compromise blast radius.
- Multiple brands sharing CF infra.
- M&A: new zones dumped in.
- Ops team where any token can change anything anywhere.

Skill detects mixed-env via zone name heuristics: `*staging*|*dev*|*qa*|*test*` mixed with prod-shaped names in same account → WARN.

## Multi-zone batch operations

`fix <area>` confirms zone-by-zone — no fan-out blindly. Skill prints summary upfront ("Apply HSTS to 12 zones?") then proceeds. If 10 of 12 succeed and 2 fail (different plan tier, missing scope), reports each cleanly and continues. No transactional all-or-nothing.

Useful for: same-brand zones (same CSP, WAF), universal hygiene (headers, SSL, DNSSEC). Foreign-tech rule is per-stack — apply per zone individually.

## Prod/staging account separation

Production zones in their own Cloudflare account, separate from staging/dev/internal.

Why: token leak from staging can't touch prod (different account); per-account SSO; per-env billing visibility; audit-log noise reduced; less dashboard confusion.

How: dashboard `Settings → Account → Move zone to a different account`. Requires existing membership in destination account.

Caveats:
- Both accounts need a shared Super Admin (or admin in both).
- DNS records retained on move; bindings are not — Workers/R2/KV/D1 stay in original account; migrate via redeploy + export/import.
- Custom rule entrypoints recreated automatically; named rulesets you authored may need recreation.

After move: update tokens to scope new account; re-run audit recipe.

Source: https://developers.cloudflare.com/fundamentals/setup/manage-domains/move-domain/

## Token blast-radius hygiene

Per account:
- One token per role × purpose (CI deploy prod, skill audit prod, Terraform apply prod). Don't reuse.
- IP-allowlisted to operator/runner.
- 90-day expiry.
- Disabled if unused 30+ days.

Per environment:
- Production token NEVER on developer laptop — CI secrets + sealed ops vault.
- Staging token can live on dev laptops.
- Dev token usually unnecessary — devs use dashboard.

`fix tokens` enforces: list every token + scope + last-used; flag 90+ unused for revocation; flag no-expiry; generate new + disable old in one flow.

## Multi-account audit visibility

Per-account audit log + notifications. Subscribe ops to all accounts; prod-only on-call to the prod account.

## Multi-zone WAF strategy

Account-level WAF (Enterprise) = write once, applies everywhere. For non-Ent, skill duplicates the foreign-tech rule into each zone's `http_request_firewall_custom`, tagged with the same description so updates find-and-replace en masse.

Pseudocode per zone: read entrypoint → find rule whose `description` starts with `cloudflare-secure:` → push or replace → PUT.

## CSP / header consolidation

- Single-zone Transform Rule generation from `templates/transform-headers.starter.json`.
- Pages: `_headers` in source.
- Account-level Worker (Pro+): inject headers, mounted on multiple zones via routes.

## Quarterly review (monthly at 100k+)

- Audit recipe per zone.
- `fix tokens` review.
- `lib/drift.sh` posture-decrease report.
- Cost review accumulating Workers Paid/R2/D1 across zones.

## Skill targets

- Single-account-with-mixed-envs detected → WARN.
- Tokens scoped per environment → WARN if a token spans prod+staging.
- Production tokens IP-allowlisted to CI/ops → WARN if not.
- Non-prod and prod zones in separate accounts at 100k+ → WARN recommendation.
- Account-level audit log enabled (free; default): always.
- Account-level WAF for orgs with 5+ similar zones (Ent) → WARN upgrade path.
