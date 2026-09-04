# Scan memory (`.snitch/memory.md`)

An optional, server-free record of what Snitch learned about THIS repo across scans. Read it at scan start; offer to append to it after the report. It complements `.snitch-ignore` (hard suppressions) with durable, human-readable context.

## When to read it

At scan start, if `.snitch/memory.md` exists at the project root, read it before scanning. Use it to:

- Use past false positives to locate the relevant controls, then recheck their current behavior.
- Start Rule 7 traces at the recorded sanitizers/middleware; memory is a pointer, not Pass evidence.
- Account for stack quirks that change how a finding should be judged.

## Format

One lesson per `###` block: a one-line summary on the heading, then the reason it matters.

```
### Request schemas live at src/middleware/validate.ts
Trace through validate() and inspect the parsed value actually consumed by each sink.
String/length validation does not clear SQL interpolation; verify binding at the query.

### lib/legacy/query.ts raw SQL is build-time only, not request-reachable
Flagged as SQLi in past scans; the input is a hardcoded migration constant. Pass, not a finding.
```

## Rules

- Update an existing block rather than adding a duplicate.
- Delete a block that turns out to be wrong.
- Record both corrections (false positives) and confirmed-good patterns, with the why.
- Never store secrets, tokens, or PII here. This file is plain context, not a vault.
- Don't record what the repo or `.snitch-ignore` already states.
