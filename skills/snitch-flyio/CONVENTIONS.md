# snitch-flyio — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-flyio.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-flyio.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-flyio.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-flyio.sh`. Don't source siblings — add the function call to `snitch-flyio.sh` instead.
- Each lib defines a small set of exported functions:
  - `<area>_run` — the read-only audit pass.
  - `<area>_fix <subaction?>` — the idempotent apply pass, called from `fix <area>`.
- Libs that are subcommands of their own (e.g., `score.sh`) export `run_<command>`.

## Output: every finding goes through log.sh

Use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_tier> [docs_url]` — feature is gated by org tier.
- `log_info  <message>` — chatter.
- `log_section <title>` — separator.
- `log_subsection <title>` — sub-separator.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, discover, account, apps, machines, volumes, postgres, redis, secrets, services, network, tokens, cost, regions, project, gha, panic, fit-matrix, score, terraform, export, drift, refresh-docs, snapshot`.

## API helpers (`lib/api.sh`)

- `fly_run <args...>` — calls `flyctl <args>` with `--access-token "$FLY_API_TOKEN"` if set; otherwise relies on `~/.fly/config.yml`. Returns the captured stdout. Non-zero exit returns rc=3 and stderr is captured to `FLYSEC_LAST_STDERR`.
- `fly_run_json <args...>` — same as `fly_run` but appends `--json` and validates the result parses with `jq`.
- `FLYSEC_LAST_STDERR`, `FLYSEC_LAST_STDOUT` are set after every call.
- `auth_verify` calls `fly auth whoami` and surfaces the result. Refuses the no-auth case.
- `api_pick_org` and `api_pick_app` cache and return ids; they read `FLYSEC_ORG` / `FLYSEC_APP` from env when set.

## Plan-tier gating

Fly.io org tiers ordered: `personal < hobby < pay-as-you-go < launch < scale < enterprise`. Before every paid-only check or fix:

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

It logs `[N/A locked: tier+]` automatically and returns 1, letting the caller skip cleanly.

## Idempotency contract for `*_fix`

Every `<area>_fix` function:

1. **Reads current state first** via `fly_run` or local file inspection.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of CLI calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from a `*_fix` unless the CLI actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (`fly.toml` edits, `.github/workflows/*`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-flyio/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when `fly auth whoami` fails (no logged-in user).
- Refuse to "fix" anything that would replace a non-empty `fly.toml [env]` value with a literal — always emit the `fly secrets set NAME=...` invocation instead.
- Refuse to lower posture in any `*_fix` (e.g., never disable `force_https`).
- Refuse to scale a stateful service (with mounted volume) to zero without explicit user confirmation.

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` and parse the JSON document. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
