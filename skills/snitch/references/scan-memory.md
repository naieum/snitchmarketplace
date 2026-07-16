# Scan memory (`.snitch/memory.md`)

An optional, server-free record of what Snitch learned about THIS repo across scans. Read it at scan start; offer to append to it after the report. It complements `.snitch-ignore` (hard suppressions) with durable, human-readable context.

## When to read it

At scan start, if `.snitch/memory.md` exists at the project root, read it before scanning. Use it to:

- Skip or down-rank patterns already confirmed as false positives here.
- Start Rule 7 traces from known-good sanitizers/middleware (the file says where they live).
- Account for stack quirks that change how a finding should be judged.

## Format

One lesson per `###` block: a one-line summary on the heading, then the reason it matters.

```
### Auth middleware sanitizes all req.body at src/middleware/validate.ts
Every route mounts validate() before handlers, so req.body.* reaching a sink is
already schema-checked. Trace to validate.ts before reporting body-derived input.

### lib/legacy/query.ts raw SQL is build-time only, not request-reachable
Flagged as SQLi in past scans; the input is a hardcoded migration constant. Pass, not a finding.
```

## Rules

- Update an existing block rather than adding a duplicate.
- Delete a block that turns out to be wrong.
- Record both corrections (false positives) and confirmed-good patterns, with the why.
- Never store secrets, tokens, or PII here. This file is plain context, not a vault.
- Don't record what the repo or `.snitch-ignore` already states.
