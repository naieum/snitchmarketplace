# snitch-vercel — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently. Mirrors the cloudflare-secure shape with Vercel-specific helpers.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-vercel.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-vercel.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-vercel.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-vercel.sh`. Don't source siblings — add the function call to `snitch-vercel.sh` instead.
- Each lib defines a small set of exported functions:
  - `run_state_<area>` — the read-only audit pass for that area.
  - `apply_<area>` — the idempotent apply pass, called from `fix <area>`.
- Libs that are subcommands of their own (e.g., `score.sh`, `fit_matrix.sh`) export `run_<command>`.

## Output: every finding goes through log.sh

Use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_tier> [docs_url]` — feature is gated by plan.
- `log_info  <message>` — chatter.
- `log_section <title>` — separator.
- `log_subsection <title>` — sub-separator.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, detect, account, team, project, env, domains, deployments, protection, functions, middleware, kv-postgres-blob, edge-config, log-drains, analytics, cost, headers, panic, score, fit-matrix, stack-docs, drift, terraform, export`.

## API helpers (`lib/api.sh`)

- `vrc_get <path>`, `vrc_post <path> <json>`, `vrc_patch <path> <json>`, `vrc_delete <path>` — direct REST against `https://api.vercel.com`. All read `VERCEL_TOKEN` from env. Return JSON body on stdout. Non-2xx returns rc=3.
- `vercel_run <args...>` — invoke the `vercel` CLI; capture stdout. rc passes through.
- `vercel_run_json <args...>` — invoke the CLI with explicit `--scope` + JSON-friendly flags where supported, parse to JSON or fall back to `{}` if the CLI emits a table.
- `VRCSEC_LAST_STATUS`, `VRCSEC_LAST_BODY` are set after every REST call.
- `vrc_last_error` pretty-prints the API errors array.
- `vercel_pick_team` and `vercel_pick_project` cache and return ids; they read `VRCSEC_TEAM_ID` / `VRCSEC_PROJECT_ID` from env first, and fall back to the cached `~/.local/share/com.vercel.cli/auth.json` defaults plus `.vercel/project.json` (when running inside a linked project).

Environment prefix `VRCSEC_*` is reserved for this skill's own variables (so users don't collide with `VERCEL_*` Vercel-defined names).

## Plan-tier gating

Vercel tiers: `hobby` (0) < `pro` (1) < `enterprise` (2). Some features (SSO, log drains, deployment protection beyond password, audit log access, trusted-IP allowlist, advanced firewall) gate on Pro/Enterprise.

Before every paid-only check or fix, call:

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

It logs `[N/A locked: tier+]` automatically and returns 1, letting the caller skip to the next check cleanly.

## Idempotency contract for `apply_*`

Every `apply_<area>` function:

1. **Reads current state first** via `vrc_get` / `vercel_run_json` or local file inspection.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of API calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from an `apply_*` unless the API actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (`vercel.json` headers block, `middleware.ts` starter, `.github/workflows/*`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-vercel/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate without `vercel login` succeeded AND `VERCEL_TOKEN` set if the API path is required.
- Refuse to ship Vercel env values to stdout — emit `vercel env add NAME` invocations instead.
- Refuse to lower posture in any `apply_*` (e.g., never disable HSTS, never widen deployment protection).
- Flag any plaintext env value with secret-shaped patterns (length > 20 + alphanumeric + entropy heuristic) for migration to Sensitive type or `@secret`.

## Stack detection

Stack detection lives in `lib/detect.sh`. It includes Vercel-specific markers: `vercel.json`, `.vercel/`, `next.config.*`, `vercel-env.d.ts`, presence of `@vercel/edge`, `@vercel/kv`, `@vercel/postgres`, `@vercel/blob`, `@vercel/edge-config` deps, `middleware.ts` / `middleware.js` at the app root.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
