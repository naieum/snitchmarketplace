# Coverage accounting

A scan is only trustworthy if the reader knows *what it actually covered*. Findings answer "what's
wrong"; coverage answers "where did you look, and where didn't you." Without it, a clean report is
indistinguishable from a shallow one. This reference defines the coverage discipline that turns
snitch's per-surface Pass-with-evidence (Rule 1 / Rule 7) into an explicit, auditable denominator.

This is the static, evidence-first analogue of the coverage manifests that mature scanners emit —
no new runtime, just honest accounting of the surfaces the scan reached.

## When surfaced

Every scan that produces a report. The Coverage section is rendered per
`references/report-template.md`; this reference defines what goes in it and the hard rule behind it.

## The hard rule: no silent sampling

Every **in-scope surface** must end the scan with one explicit disposition. There is no fourth,
silent state.

| Disposition | Meaning |
|---|---|
| **scanned — pass** | Reached and analyzed; no finding. Carries Rule 7 Pass-evidence per sink. |
| **scanned — finding** | Reached and analyzed; produced ≥1 finding. |
| **deferred — reason** | Deliberately not analyzed this run; the reason is stated (out of scope, time/scope budget, needs a tool not present, generated/vendored, requires human verification). |

A surface that is silently skipped — scanned partially, sampled without saying so, or dropped
because the budget ran out — is a Rule 1 / Rule 6 violation. If you sample instead of enumerate,
say so and mark the rest **deferred**, with the sampling ratio. "Looks clean" is never a coverage
claim; "scanned N of N reachable sinks in these files, all pass with trace evidence" is.

## What the Coverage section records

1. **Mode** — `repository` | `scoped-path` | `diff` | `commit` | `working-tree`
   (cross-reference `references/scan-planning.md`).
2. **Inventory strategy** — how the surface list was built (route map, entrypoint enumeration,
   grep of sink patterns, changed-files for diff mode). Name it so the reader can judge blind spots.
3. **Completeness** — one of:
   - **complete** — every reachable in-scope surface for the selected categories was scanned-pass
     or scanned-finding; zero deferrals.
   - **partial** — some surfaces deferred; each deferral is listed with a reason.
   - **unknown** — the inventory itself couldn't be fully established (e.g., dynamic dispatch /
     reflection / un-openable imports the scan couldn't follow). Say what blocked it.
4. **Surfaces table** — the in-scope surfaces (files / entrypoints / sink sites, at the granularity
   the scan worked) each with its disposition + one-line reason. For large repos, group by
   directory/module and give counts (`scanned 38 / deferred 4 / files 42`) plus the deferred list
   explicitly.
5. **Exclusions** — paths excluded by rule (tests, vendored, generated, `.snitch-ignore`) with the
   rule that excluded them, so an excluded surface is never mistaken for a clean one.

## Categories vs surfaces

Coverage has two axes — keep both honest:
- **Category coverage** — which of the selected categories ran vs Skipped-with-reason (snitch
  already does this; the Coverage section folds it in).
- **Surface coverage** — within each category that ran, which sinks/files were reached. This is the
  axis that's easy to fudge and the one the hard rule protects.

## Forbidden claims

- "Scanned the codebase" / "no issues found" without the surfaces table + completeness label.
- A **complete** label while any surface was sampled, time-boxed, or dropped — that's **partial**.
- Treating an excluded or deferred surface as evidence of safety. Absence of a scan is not a pass.

## Feeds

The Coverage section pairs with `references/scan-ledger.md` (per-surface/finding receipts make the
dispositions reconstructable) and `references/finding-identity.md` (stable IDs let coverage be
compared across runs / in diff mode).

---

*Coverage-accounting discipline informed by the structured coverage model OpenAI's codex-security
popularizes (completeness + per-surface disposition + no silent sampling), reimplemented as a
static, evidence-first reference under snitch's Rule 1/6/7. Internal reference; the Coverage section
it specifies IS customer-facing.*
