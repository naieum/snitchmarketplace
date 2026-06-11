# snitch-aws — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-aws.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-aws.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.
- Every bash file must pass `bash -n` cleanly.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-aws.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-aws.sh`. Don't source siblings — add the function call to `snitch-aws.sh` instead.
- Each lib defines a small set of exported functions:
  - `run_state_<area>` — read-only digest/slice, called from `state <area>`.
  - `apply_<area>` — idempotent fix, called from `fix <area>`.
- Libs that are subcommands of their own (`fit_matrix.sh`, `score.sh`, `panic.sh`, `terraform.sh`, etc.) export `run_<command>`.

## Output: every finding goes through log.sh

Use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_tier> [docs_url]` — feature is gated by Support plan / Enterprise feature.
- `log_info  <message>` — chatter.
- `log_section <title>` — separator.
- `log_subsection <title>` — sub-separator.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, discover, account, iam, s3, ec2, vpc, rds, dynamodb, elasticache, lambda, apigw, alb, cloudfront, route53, acm, cognito, secrets, kms, cloudtrail, cloudwatch, wafv2, shield, config, inspector, macie, guardduty, securityhub, backup, organizations, eks, ecs, eventbridge, sqs-sns, cost, panic, migrate, score, fit-matrix, stack-docs, project, gha, terraform, drift, export, refresh-docs`.

## API helpers (`lib/api.sh`)

- `aws_run <args...>` — invokes the `aws` CLI with the user's resolved profile + region; returns the raw stdout, captures stderr in `AWSSEC_LAST_STDERR`, and sets `AWSSEC_LAST_STATUS` (`0` on success).
- `aws_run_json <args...>` — same as `aws_run` but always passes `--output json`. Returns the JSON on stdout. On non-2xx, the JSON body (or an empty `{}`) is still emitted so callers can `jq` defensively.
- `api_check_auth_env` — refuses long-lived `AKIA*` keys when SSO is available. Refuses if there are no creds at all.
- `aws_pick_account` — caches `aws sts get-caller-identity` Account.
- `aws_pick_region` — caches the resolved default region (env > profile > us-east-1).

## JSON output contract for `state_*`

Every state tool emits ONE JSON document on stdout with this header:

```json
{
  "schema": "awssec.state-<area>.<slice>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "state-<area>",
  "slice": "digest | <slice>",
  "account_id": "...",
  "region": "...",
  ...subscope-specific fields...
}
```

Errors (stderr): `{ "error": "<msg>", "code": "E_AUTH | E_API | E_USAGE | E_REGION | E_TEMPLATE | E_UNKNOWN_STACK", "remediation": "<fix>" }`.

## Plan-tier gating

Before every paid-only check or fix, call:

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

Tiers: `basic | developer | business | enterprise` (AWS Support); plus feature flags for `org` (Organizations) when a control needs it.

## Idempotency contract for `apply_*`

Every `apply_*` function:

1. **Reads current state first** via `aws_run_json`.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of API calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from a `*_fix` unless the API actually returned an error. Never **lower** posture (e.g., never disable a Public Access Block, never decrease retention, never remove MFA from a policy).

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (CDK files, Terraform `.tf` files, GitHub Actions workflows), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-aws/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when `AWS_ACCESS_KEY_ID` is `AKIA*` (long-lived) **and** an SSO profile exists in `~/.aws/config`. Redirect to `aws sso login`.
- Refuse to operate when no creds at all exist (no env vars, no profile, no instance role).
- Refuse to apply WAF rules that block the user's home IP without confirming.
- Refuse to lower posture in any `apply_*` (e.g., never decrease retention, never remove encryption).

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` and parse the JSON. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.

## Audit report rendering

Audit reports must use markdown tables sorted FAIL → WARN → N/A → OK with status emojis:

- 🔴 FAIL
- 🟡 WARN
- ⚪️ N/A (locked)
- 🟢 OK

The agent (not the skill) produces the report from `findings.tsv` + the in-memory state JSONs. The skill only emits primitives.
