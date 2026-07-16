# Threat-model phase (optional, repo-scoped)

A scan that starts from "grep for sink patterns" finds bugs; a scan that starts from "what is this
system protecting, from whom, across which boundaries" finds the bugs that *matter* and calibrates
severity against real exposure. This optional pre-scan phase builds a short, repository-scoped
threat model that grounds discovery and severity — before any category runs.

It is **repo-scoped, not diff-scoped**: model the whole system's assets and boundaries, so a later
diff scan can ask "does this change weaken a boundary that protects a real asset?" rather than
re-deriving context from the diff alone.

## When surfaced

Optional, offered at scan start for a Full System Scan or when the user asks for a thorough/audit
scan. Skip for a quick single-file or tightly-scoped scan (say so). The output is a short
`THREAT_MODEL.md` (or a section prepended to the report) that the discovery + severity steps read.
It does not add a category and does not gate the scan — it sharpens it.

## What to produce (keep it short — one page)

1. **Assets** — what's worth protecting, from the catalog below. Name the concrete instances
   (e.g., "user PII in `users` table", "signing key in `process.env.JWT_SECRET`", "ability to exec
   on the deploy host").
2. **Trust boundaries** — where data crosses from less-trusted to more-trusted (internet → app,
   app → DB, tenant → tenant, user → admin, client → server, third-party webhook → handler). Each
   boundary is where a finding becomes a *security* finding rather than a bug.
3. **Entry points / attack surface** — the reachable inputs (HTTP routes, CLI args, queue/webhook
   consumers, file uploads, env/config, LLM/agent outputs treated as input). Cross-reference the
   route/entrypoint inventory from `references/scan-planning.md`.
4. **Attacker capabilities / scope** — who's in the model: unauthenticated internet user,
   authenticated low-priv user, another tenant, a malicious dependency, an insider. Out-of-model
   actors (e.g., root on the box already) are noted so findings that require them are de-scoped.
5. **Security objectives + assumptions** — what must hold (authZ on state changes, tenant
   isolation, secret confidentiality) and the assumptions taken on trust (e.g., "WAF terminates
   TLS", "this service is internal-only") — assumptions a finding can later invalidate.

## Controls-and-assets catalog (reference)

Use as a checklist when enumerating assets + the controls that should protect each. A finding is
high-value when it defeats a control protecting a listed asset across a trust boundary.

| Asset class | Typical control(s) that must hold | Snitch cats that test them |
|---|---|---|
| Credentials / secrets / signing keys | Not hardcoded; from env/secret store; least scope | secrets / config cats |
| User PII / regulated data | AuthZ on access; encryption at rest/in transit; tenant isolation | access-control, crypto, data cats |
| Auth / session integrity | AuthZ on every state change; session fixation/CSRF defenses; correct JWT alg | authN/authZ, CSRF, JWT cats |
| Code/command execution surface | No untrusted input to exec/eval/deserialize; safe templating | injection / dangerous-pattern cats |
| File system / storage | Path-traversal guards; upload type/size/location limits | file-upload, path cats |
| Outbound requests | SSRF guards (allow-list, no internal ranges) | SSRF / cloud-metadata cats |
| Tenant / privilege isolation | Server-side authZ; no client-trusted role; IDOR defenses | access-control / IDOR cats |
| Supply chain | Pinned/verified deps; no typosquats; install-script review | SCA / dependency cats |

(Map to the actual snitch category numbers via `references/standards-table.md` /
`references/category-groups.md` — keep the cross-reference accurate; don't invent cat numbers.)

## How it feeds the scan

- **Discovery** prioritizes surfaces that touch listed assets / cross listed boundaries first.
- **Severity** is calibrated against the model: a sink reachable from an in-model attacker across a
  boundary protecting a real asset is high; one requiring an out-of-model actor or no boundary
  crossing is downgraded (pairs with `references/risk-prioritization.md`).
- **Coverage** (`references/coverage-accounting.md`) can report which boundaries/assets were
  exercised vs deferred.

## Forbidden claims

- A threat model invented from assumptions — every asset / boundary / entry point must be grounded
  in repo evidence (a real table, route, env var, config), quoted or pointed to. No speculative
  architecture.
- Using the threat model to *assert* a vulnerability — it scopes and prioritizes; findings still
  require Rule 1 + Rule 7 evidence.
- Treating an assumption ("internal-only") as fact when the repo shows otherwise — that gap is
  itself a finding.

---

*Repo-scoped threat-model phase + controls/assets catalog informed by OpenAI's codex-security
threat-model skill, reimplemented as an optional, evidence-grounded, defensive pre-scan step under
snitch's rules. The produced THREAT_MODEL.md is customer-facing; this spec is internal.*
