# snitch-digitalocean — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-digitalocean.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-digitalocean.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-digitalocean.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-digitalocean.sh`. Don't source siblings — add the function call to `snitch-digitalocean.sh` instead.
- Each lib defines a small set of exported functions:
  - `run_<area>` — the read-only state pass.
  - `apply_<area>` — the idempotent apply pass.

## Output: every finding goes through log.sh

Use these and only these:

- `log_ok    <area> <key> <message> [docs_url]`
- `log_warn  <area> <key> <message> [docs_url]`
- `log_fail  <area> <key> <message> [docs_url]`
- `log_locked <area> <key> <message> <required_tier> [docs_url]`
- `log_info  <message>`
- `log_section <title>`
- `log_subsection <title>`

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, discover, account, droplets, databases, spaces, apps, loadbalancers, firewalls, registry, kubernetes, functions, vpcs, dns, monitoring, cost, panic, score, drift, terraform, export, fit-matrix, stack-docs, refresh-docs, project`.

## API helpers (`lib/api.sh`)

- `do_run <doctl-args...>` — runs `doctl --output json <args>`. Returns JSON on stdout, rc!=0 on error.
- `do_run_json <doctl-args...>` — alias for `do_run` with stricter parsing.
- `do_get <path>`, `do_post <path> <json>`, `do_put <path> <json>`, `do_patch <path> <json>`, `do_delete <path>` — direct REST helpers, base `https://api.digitalocean.com/v2/`. Reads `DIGITALOCEAN_ACCESS_TOKEN` (or pulls from doctl context).
- `DOSEC_LAST_STATUS`, `DOSEC_LAST_BODY` are set after every call.
- `do_last_error` pretty-prints the API errors.
- `api_check_auth_env` refuses to operate without a token and (heuristically) refuses tokens older than ~365 days when token-creation metadata is reachable.

## Idempotency contract for `apply_*`

Every `apply_<area>` function:

1. **Reads current state first** via `do_get` / `do_run`.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of API calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (e.g., `app.yaml`, `.do/app.yaml`, k8s NetworkPolicy yamls), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-digitalocean/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when no auth is set (no `DIGITALOCEAN_ACCESS_TOKEN` AND no active `doctl` context).
- Refuse legacy un-scoped tokens (heuristic — surface a WARN if we cannot determine).
- Refuse to apply firewall rules that would block the user's own IP without confirming.
- Refuse to lower posture in any `apply_*` (e.g., never disable backups, never make a private DB cluster public).

## Stack detection

Stack detection lives in `lib/detect.sh`. It includes DO-specific markers (`app.yaml`, `.do/app.yaml`, terraform/pulumi DigitalOcean providers).

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
