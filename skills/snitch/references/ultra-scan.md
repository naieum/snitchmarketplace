# Ultra Scan — multi-agent audit (mode `ultra` only)

A higher-rigor execution mode for the same audit: parallel scanner subagents find candidates, fresh-context verifier subagents independently confirm the serious ones, then results are merged into the standard report. The methodology is unchanged (Rules 1-7, the evidence format, the scope rule); only the orchestration differs.

Ultra runs only when the user explicitly selects mode `ultra` (its menu entry, `--ultra`, or a "verified" / "multi-agent" request). It is never an automatic upgrade — plain parallel batching (`references/parallel-scanning.md`) is what large scans get by default.

## Capability gate

Use Ultra only when the host can spawn subagents (for example Claude Code's Task tool). If it cannot, tell the user plainly and run the selected categories sequentially instead. Never describe a scan as multi-agent-verified if no verifier subagent ran.

## Phase 1 — Fan-out scanners

Run the standard subagent fan-out per `references/parallel-scanning.md` (batch sizing, scanner prompt contents, structured candidate output). Ultra adds nothing here — the difference is Phase 2.

## Phase 2 — Adversarial verification (the core value)

For every Critical and High candidate (and any Medium a scanner marked Low-confidence), spawn a fresh-context verifier subagent. Its job is to REFUTE:

- Re-run the Rule 7 source-to-sink trace independently from the cited file:line, opening the files itself.
- Return `confirmed`, `refuted`, or `needs-human`, with its own evidence. Default to `refuted` or `needs-human` when uncertain.

A candidate reaches the report only if a verifier confirms it. For Critical and High, optionally run two independent verifiers and confirm on agreement. Fresh-context verification outperforms a scanner grading its own work.

## Phase 3 — Merge and report

1. Dedupe across batches by file:line:CWE; sort by severity.
2. Generate the standard report via `references/report-template.md`.
3. Annotate each surviving finding with how it was verified, e.g. `Verified: 2/2 independent traces confirmed`.
4. List refuted candidates in a "Filtered (verifier-rejected)" appendix with the refutation reason. Visible, not silently dropped.

## Orchestration notes

- Prefer non-blocking dispatch: keep orchestrating while subagents run; intervene if one goes off track or lacks context.
- Apply the progress-audit rule (see SKILL.md "Long-run grounding") to orchestrator status lines.
- Apply Rule 5 defensive framing in every subagent prompt; if a subagent turn is refused, mark that category Incomplete in the report.

## Cost

Ultra spends more tokens (N scanners + M verifiers) to buy higher precision and recall and faster wall-clock. Use it for thorough, pre-deploy, or large scans, not quick checks.
