# Risk prioritization overlay (severity × likelihood)

Severity answers "how bad if exploited." It does not answer "which of these 30 findings do I fix
first." This overlay adds an **exploitability/likelihood** axis — drawn from the Rule 7 data-flow
trace that already ran, not guessed — and crosses it with severity to produce a fix-ordering tier.
It is a prioritization aid layered on top of the existing CWE / severity / confidence model, not a
replacement for any of them.

## When surfaced

Optional, post-scan. Offer it when a scan produces many findings and the user asks "what do I fix
first" / "rank these" / "prioritize." Also useful in the report's executive summary to order the
remediation list. Skip for single-finding scans.

## The likelihood axis (from evidence, never guessed)

Likelihood is how reachable and exploitable the finding actually is, read off the trace and context
that Rule 7 already produced. Score 1-5:

| Likelihood | Meaning (all read from the trace / context) |
|---|---|
| **5 — Almost certain** | User-controlled + unsanitized input reaches the sink on an unauthenticated, internet-facing path; no preconditions; High confidence. |
| **4 — Likely** | Reachable + unsanitized but behind light auth, or needs a common precondition (logged-in user, specific but reachable route). |
| **3 — Possible** | Reachable but requires elevated role, a non-default config, or a multi-step precondition; OR confidence is Medium. |
| **2 — Unlikely** | Reachable only by a trusted/internal actor (admin-only, internal service, CI context), or strong compensating control is present but not airtight. |
| **1 — Remote** | Theoretical: sink reached but input is near-trusted, exploitation needs an implausible chain, OR the trace is partial (Low confidence / `needs human verification` caps likelihood here until a human confirms). |

**Hard rule:** a partial trace (Low confidence / `needs human verification`) caps likelihood at **1**
until verified — never inflate likelihood on an incomplete trace (mirrors the Rule 7 confidence rule).
Internet-facing + unauthenticated is the single biggest multiplier; note it explicitly in the finding.

## The impact axis

Reuse the finding's existing severity tier as impact (1-5): Low=1/2, Medium=3, High=4, Critical=5,
adjusted up for blast radius (RCE, auth bypass, mass data exposure → 5) or down for a contained,
single-record effect.

## The matrix → fix-ordering tier

Risk score = Impact × Likelihood (1-25). Map to a tier that drives ordering:

| Score | Tier | What it means for ordering |
|---|---|---|
| **16-25** | **RED** | Fix before next deploy; surface at the top of the report. |
| **10-15** | **ORANGE** | Fix this sprint; assign an owner. |
| **5-9** | **YELLOW** | Backlog with a date; fix opportunistically. |
| **1-4** | **GREEN** | Accept/defer with a documented reason, or fix when touching the code. |

A Critical-severity finding that is only remotely exploitable (e.g., admin-only, internal tool) can
land ORANGE, not RED — that is the point of the overlay: it stops a high-CVSS-but-unreachable issue
from outranking a medium-CVSS-but-trivially-exploitable one. Always show both axes so the ordering
is auditable: `SQL injection (Impact 4 × Likelihood 5 = 20, RED): unauthenticated /api/search, body.q → db.query, no sanitizer (handler.ts:23→47)`.

## How it presents

In the report or post-scan menu, render a prioritized table: Finding | CWE | Impact | Likelihood |
Score | Tier | one-line why. Order by score descending. Never show a tier without its Impact ×
Likelihood derivation and the trace evidence behind the likelihood — an unexplained tier is a
Rule 1 violation.

## Forbidden claims

- A likelihood score not grounded in the finding's trace + context (no guessing exploitability).
- Promoting likelihood above 1 on a partial / Low-confidence trace.
- Presenting the risk tier as a CVSS replacement — it is a fix-ordering overlay; keep the CWE/CVSS.

---

*Severity × likelihood matrix and GREEN/YELLOW/ORANGE/RED tiers adapted from the Apache-2.0
`anthropics/knowledge-work-plugins` (legal/legal-risk-assessment + operations/risk-assessment),
with the likelihood axis re-grounded in Snitch's Rule 7 data-flow trace. Internal reference only.*
