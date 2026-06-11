# snitch-cloudflare — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-cloudflare.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-cloudflare.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-cloudflare.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-cloudflare.sh`. Don't source siblings — add the function call to `snitch-cloudflare.sh` instead.
- Each lib defines a small set of exported functions:
  - `<area>_run` — the read-only audit pass, called from `check`.
  - `<area>_fix <subaction?>` — the idempotent apply pass, called from `fix <area>`.
- Libs that are subcommands of their own (e.g., `migrate.sh`, `score.sh`) export `run_<command>`.

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
`auth, doctor, discover, ssl, hsts, dnssec, dns, dns-email, waf, rules, bots, rate-limit, headers, aop, tunnel, access, account, tokens, project, workers, pages, r2, kv, d1, hyperdrive, durable-objects, security-txt, cookies, takeovers, exposure-probe, health, gha, wrangler, email, page-shield, ai-security, ai-offerings, drift, cost, score, panic, migrate, roadmap, stacks, terraform, export, diagnose, report`.

Audit-lens areas (read-only `audit <lens>` group): `auditlog, logpush, dns-analytics, ai-gateway, secevents, casb, dex, builds, browser, observability`.

## API helpers (`lib/api.sh`)

- `cf_get <path>`, `cf_post <path> <json>`, `cf_patch <path> <json>`, `cf_put <path> <json>`, `cf_delete <path>` — all read `CLOUDFLARE_API_TOKEN` from env. Return the JSON body on stdout. Non-2xx returns rc=3.
- `CFSEC_LAST_STATUS`, `CFSEC_LAST_BODY` are set after every call **but do NOT survive `body="$(cf_get ...)"`** (command substitution runs in a subshell; globals set there are lost to the caller). For status checks after a captured call, use **`cf_last_status`** (file-backed; echoes e.g. `200`/`403`/`000`).
- `cf_last_error` pretty-prints the API errors array.
- `api_pick_account` and `api_pick_zone` cache and return ids; they read `CFSEC_ACCOUNT_ID` / `CFSEC_ZONE_ID` from env.

### Auto-gating for read lenses (JSON track)

For data lenses that must skip a surface cleanly (paid-only, not-configured, or MCP-absent):

- `api_surface_gate <last_status> <body_json> [empty_jq_filter]` → echoes `forbidden` (403) | `notfound` (404) | `empty` (2xx + filter truthy, e.g. `'.result|length==0'`) | `ok` | `error`. Pair with `cf_last_status`:
  ```sh
  body="$(cf_get "/accounts/${id}/logpush/jobs")"; st="$(cf_last_status)"
  case "$(api_surface_gate "$st" "$body")" in
    forbidden|notfound) emit_locked_doc cfsec.audit-logpush audit-logpush account_id "$id" enterprise "Logpush requires Enterprise" '{"jobs":[]}'; return 0 ;;
  esac
  ```
- `emit_locked_doc <schema> <tool> <id_field> <id_value> <locked_value> <reason> [extra_json]` → prints the standard locked doc (`locked` ∈ tier | `not-configured` | `mcp-absent`). The JSON-track equivalent of `log_locked` (which is for the badge/`*_fix` track). See `lib/state_pageshield.sh` for the canonical 403→locked precedent and `references/31-tool-contracts.md` for the locked convention.

Use a bare `.field` (not `.field // null`) when surfacing a boolean whose `false` is meaningful — jq's `//` treats both `null` AND `false` as empty and would collapse `false` to the default.

## Plan-tier gating

Before every paid-only check or fix, call:

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

It logs `[N/A locked: tier+]` automatically and returns 1, letting the caller skip to the next check cleanly.

## Idempotency contract for `*_fix`

Every `<area>_fix` function:

1. **Reads current state first** via `cf_get` or local file inspection.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of API calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from a `*_fix` unless the API actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (Pages `_headers`, `wrangler.toml` edits, `.github/workflows/*`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-cloudflare/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when `CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL` are set — that's the global API key path.
- Refuse to apply WAF rules that block the user's home IP without confirming.
- Refuse to lower posture in any `*_fix` (e.g., never decrease `min_tls_version`).

## Stack detection

Stack detection lives in `lib/stacks.sh`. Other libs that need stack info call `stacks_detect_run` and read `${STATE_DIR}/stacks.json`. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
