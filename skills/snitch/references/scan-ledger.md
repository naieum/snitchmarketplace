# Scan ledger (phase receipts)

A long scan loses context: an agent that scanned 60 files and got interrupted shouldn't restart
from zero, and a reader shouldn't have to trust that every candidate was actually validated. The
scan ledger is a lightweight, append-only record of what happened to each surface and each
candidate finding — making scans **resumable** and coverage **auditable**, without a database.

It records the phases snitch already runs (discovery → Rule 7 trace → verification); it does not
introduce a new assessment model. It's the durable receipt layer under
`references/coverage-accounting.md`.

## When surfaced

Optional, valuable for Full System Scans, Ultra scans (`references/ultra-scan.md`), and any scan
likely to span multiple turns or risk interruption. Skip for quick single-file scans. Lives under
`.snitch/` next to `references/scan-memory.md` (it is scan state, not durable cross-scan lessons —
keep the two separate).

## Layout

```
.snitch/scans/<scan-id>/
  manifest.jsonl      # one row: scan-id, mode, target, started-at, categories, status
  surfaces.jsonl      # one row per in-scope surface: its disposition (see coverage-accounting)
  findings/<fingerprint>/ledger.jsonl   # receipts for one candidate, keyed by finding identity
```
Append-only JSONL — never rewrite a row; add a new one. `<fingerprint>` comes from
`references/finding-identity.md`. Timestamps are stamped by the caller (skills can't read the
clock); if unavailable, use the scan-id ordinal.

## Receipts (rows in a finding's ledger)

Each candidate accumulates up to three receipt rows as it moves through the phases:

| Phase | Receipt records |
|---|---|
| **discovery** | candidate found: `ruleId`, `anchor`, surface, the sink matched, why it's a candidate |
| **trace** (Rule 7) | source classification (literal / validated / user-controlled / un-traceable), the traced path, sanitizers crossed, confidence |
| **verification** | disposition: `reportable` / `pass` (traced clean) / `suppressed` (FP, with reason) / `deferred` (needs human verification, with the proof gap). For Ultra: the independent verifier's vote. |

A candidate that reaches the report must have a discovery + trace receipt and a verification
disposition, **or** an explicit `deferred` row with a reason. A candidate with no verification row
is an unfinished scan, not a clean one (ties to the no-silent-sampling rule).

## Resume

On a re-invocation with the same scan-id: read `surfaces.jsonl` + the finding ledgers, treat any
surface with a terminal disposition and any finding with a verification row as **done**, and
continue from the first surface without one. The final report + Coverage section are projected from
the ledger, so an interrupted scan reconstructs its completed work instead of rescanning.

## Relationship to existing files

- `scan-memory.md` (`.snitch/memory.md`) — durable, cross-scan lessons (FP patterns, sanitizer
  locations). The ledger is per-scan state. Don't conflate.
- `coverage-accounting.md` — the Coverage section is a projection of `surfaces.jsonl` + dispositions.
- `finding-identity.md` — supplies the `<fingerprint>` key + enables delta vs the previous scan's
  ledger.
- Never write secrets or PII into the ledger (same rule as scan-memory); redact per Rule 5.

## Forbidden claims

- Reporting a finding "verified" with no verification receipt behind it.
- Marking a scan complete while finding ledgers lack verification/deferred rows.
- Storing raw secrets/PII in ledger rows.

---

*Phase-receipt / resumable-coverage concept informed by codex-security's candidate-ledger model,
reimplemented as a lightweight append-only JSONL layer over snitch's existing discovery/Rule-7/
verification phases. Internal reference; ledger files are local scan state, never shipped.*
