# snitch-railway — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-railway.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-railway.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-railway.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-railway.sh`. Don't source siblings — add the function call to `snitch-railway.sh` instead.
- Each lib defines a small set of exported functions:
  - `run_state_<area>` — the read-only state pass.
  - `apply_<area>` — the idempotent apply pass.
- Libs that are subcommands of their own (e.g., `score.sh`) export `run_<command>`.

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
`auth, doctor, discover, workspace, project, services, env, volumes, databases, tokens, domains, tcp-proxies, logs, cost, panic, migrate, drift, score, terraform, export`.

## API helpers (`lib/api.sh`)

- `rw_cli <args...>` — invoke the `railway` CLI; stdout on success.
- `rw_gql <query> [variables_json]` — POST to `https://backboard.railway.com/graphql/v2` with `RAILWAY_API_TOKEN` (preferred) or `RAILWAY_TOKEN` Bearer auth. Returns JSON body. Non-2xx returns rc=3.
- `RWSEC_LAST_STATUS`, `RWSEC_LAST_BODY` are set after every GraphQL call.
- `api_check_auth_env` refuses to operate without `railway whoami` succeeding (or a usable RAILWAY_API_TOKEN).
- `api_pick_project` reads `RWSEC_PROJECT_ID` from env or `railway status -j`; caches.
- `api_pick_environment` reads `RWSEC_ENVIRONMENT` (`production`, `staging`, etc.) from env or defaults to the active env.

## Plan-tier gating

Railway plan tiers: `trial < hobby < pro < enterprise`.

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

It logs `[N/A locked: tier+]` automatically and returns 1, letting the caller skip to the next check cleanly.

## Idempotency contract for `apply_*`

Every `apply_*` function:

1. **Reads current state first** via the CLI / GraphQL or local file inspection.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of CLI calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from an `apply_*` unless the API actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (`railway.json`, `nixpacks.toml`, `.github/workflows/*`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-railway/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when `railway whoami` fails AND `RAILWAY_API_TOKEN` is not set.
- Refuse to delete data (volumes, databases). Mutations on stateful resources only happen via emitted CLI commands the user runs themselves.
- Refuse to lower posture in any `apply_*` (e.g., never disable HTTPS-only, never expose a previously-private TCP service).

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` directly or read `${STATE_DIR}/detect.json`. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.

## Secret heuristics

`lib/state_env.sh` flags env-var values matching any of:

- length ≥ 32 chars + base64ish/hex regex
- name suffix `_KEY|_TOKEN|_SECRET|_PASSWORD|_PASS|_DSN`
- prefix matches: `sk_`, `pk_`, `ghp_`, `xoxb-`, `AKIA`, `eyJ` (JWT)

Any flagged value that is NOT a `${{ shared.* }}` / `${{ secret.* }}` reference becomes a `WARN` finding under area `env` with key `plaintext-secret-<NAME>`. False positives are expected — surface as WARN never FAIL.
