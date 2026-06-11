# Parallel category scanning (subagent fan-out)

When 4 or more categories are selected and the host can spawn subagents, scan batches in parallel for faster, higher-quality results. This is the batching primitive used by the Ultra Scan flow (`references/ultra-scan.md`); on its own it speeds up any large scan.

## Approach

1. Group selected categories into batches of 3-5.
2. Spawn one scanner subagent per batch. Give each subagent its batch's category guidance file(s), Rules 1-7, the finding format, and the scope rule.
3. Each subagent runs its own Grep/Glob/Read and returns structured candidate findings (file:line, quoted evidence, Rule 7 trace, severity, CWE, confidence) plus evidenced Passes.
4. Collect all batches, then proceed to verification + merge.

A subagent applying Rule 7 per category is the point. Do not replace it with a bare shell `grep` fan-out, which finds matches but cannot trace source-to-sink or judge context.

## Batching strategy

- 4-7 categories: 2 batches
- 8-14 categories: 3 batches
- 15+ categories: 4-5 batches

## Merging results

After all batches return:

1. Collect all candidates into a single list.
2. For a verified scan, run the Phase 2 verifier step in `references/ultra-scan.md` before reporting.
3. Sort by severity (Critical > High > Medium > Low).
4. Remove exact duplicates (same file:line:CWE) and group identical CWE + pattern findings.
5. Proceed to report generation with the merged list.

## When NOT to use

- 3 or fewer categories: sequential is fine.
- Host has no subagent support: scan sequentially.
- Diff-only scan: usually fast enough sequentially.
