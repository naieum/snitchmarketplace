# Parallel category scanning (subagent fan-out)

The fan-out mechanics for scanning category batches across subagents. Any scan mode uses this
automatically when 4 or more categories are selected and the host can spawn subagents; it is also
the Phase 1 primitive of the Ultra flow (`references/ultra-scan.md`).

**Batching is not verification.** This reference makes a scan faster, not more verified. The
adversarial verifier pass (fresh-context subagents attempting to refute each serious candidate)
belongs exclusively to mode `ultra`. Never describe a merely-parallel scan as "verified" or
"multi-agent-verified" — that claim requires ultra's Phase 2 to have actually run.

## Approach

1. Group selected categories into batches of 3-5. Batch size is the invariant; the batch count is derived from it, never capped.
2. Spawn one scanner subagent per batch. Give each subagent its batch's category guidance file(s), Rules 1-7, the finding format, and the scope rule.
3. Each subagent runs its own Grep/Glob/Read and returns structured candidate findings (file:line, quoted evidence, Rule 7 trace, severity, CWE, confidence) plus evidenced Passes — DATA for the orchestrator, not a user-facing report.
4. Collect all batches, then proceed to merge (and to verification only in mode `ultra`).

A subagent applying Rule 7 per category is the point. Do not replace it with a bare shell `grep` fan-out, which finds matches but cannot trace source-to-sink or judge context.

## Batching strategy

- Batch size is the invariant: every batch holds 3-5 categories. Never widen a batch past 5 or shrink
  one below 3 to hit a batch-count target.
- For N selected categories the batch count is any value from `ceil(N / 5)` (fewest batches) to
  `floor(N / 3)` (most), splitting N as evenly as that count allows. Both ends keep every batch inside
  3-5 for every N from 4 upward; pick within that range based on how much concurrency the host offers.
- Worked examples: N=5 → 1 batch of 5. N=8 → 2 batches of 4. N=20 → 4 batches of 5, or up to 6
  (4+4+3+3+3+3). A full scan (N = the manifest's active-category count, 69 at time of writing) → 14
  batches (thirteen of 5, one of 4) up to 23 batches of 3. Recompute from the manifest rather than
  reusing those numbers, and never collapse a full scan into a handful of batches — at N≈69 that puts
  14+ categories in one batch.
- N=4 or 5 resolves to a single batch. That is still this path — one scanner subagent, keeping the
  category sweep out of the orchestrator's context — but nothing runs concurrently until N≥6.
- Dispatch as many batches concurrently as the host allows, and refill each slot as a subagent returns.
  Concurrency limits how fast batches run; it never changes how many categories a batch holds.

## Merging results

After all batches return:

1. Collect all candidates into a single list.
2. In mode `ultra` only: run the Phase 2 verifier step in `references/ultra-scan.md` before reporting.
3. Sort by severity (Critical > High > Medium > Low).
4. Remove exact duplicates (same file:line:CWE) and group identical CWE + pattern findings.
5. Proceed to report generation with the merged list.

## When NOT to use

- 3 or fewer categories: sequential is fine.
- Host has no subagent support: scan sequentially.
- Mode `diff`: usually fast enough sequentially.
