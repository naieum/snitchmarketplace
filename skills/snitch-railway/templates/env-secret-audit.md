# Railway env-var secret audit

Use this template after `bash snitch-railway.sh state env <project> <env> digest` and
`bash snitch-railway.sh fix env`. The skill emits a populated version of this file to
stdout — copy it into your project's `docs/` and check off as you remediate.

## Context

- Project: `REPLACE_WITH_PROJECT_ID`
- Environment: `REPLACE_WITH_ENVIRONMENT`
- Audit run: `REPLACE_WITH_TIMESTAMP`

## What Railway treats as a "secret"

Railway makes no distinction between an env var and a secret — both live in
the same Variables surface. That means anything you can set as a value is
visible to anyone with project access. The only safety controls are:

1. **Project-level (shared) variables** — set once, referenced from each
   service via `${{ shared.NAME }}`. Avoids duplication.
2. **Cross-service references** — `${{ Postgres.DATABASE_URL }}` resolves at
   build/deploy time without exposing the value to the consumer service's
   variable list.
3. **Project tokens** scoped to a single environment.

## Findings to remediate

### 1. Plaintext-shaped secrets

Values that look like secrets (length ≥32, base64ish/hex, or name suffix
like `_KEY`, `_TOKEN`, `_SECRET`) but are stored as plaintext rather than
references:

- [ ] service `REPLACE` var `REPLACE` — promote to shared and reference

### 2. Reserved RAILWAY_* overrides

Railway reserves `RAILWAY_*` and `PORT`. Setting these manually is usually a
bug:

- [ ] service `REPLACE` var `REPLACE` — drop or rename

### 3. Duplicates across services

Same value name in N services almost always means "promote to shared":

- [ ] var `REPLACE` (in services: `REPLACE_LIST`) — make shared, reference

## Remediation order

1. Move each plaintext-shaped secret to a **shared** project variable, then
   reference as `${{ shared.NAME }}` in each service.
2. Drop user-set `RAILWAY_*` and `PORT` vars unless you have a specific
   override reason.
3. Audit duplicates: same value across services almost always means
   "promote to shared".
4. Rotate any value that has been stored plaintext for more than 90 days.

## Verifying the fix

```bash
bash ~/.claude/skills/snitch-railway/snitch-railway.sh state env <project> <env> digest \
  | jq '.summary.plaintext_secret_warnings | length'
# expect: 0
```
