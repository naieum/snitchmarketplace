# snitch-azure — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `snitch-azure.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `snitch-azure.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.
- `bash -n` clean.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `snitch-azure.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `snitch-azure.sh`. Don't source siblings — add the function call to `snitch-azure.sh` instead.
- Each lib defines a small set of exported functions:
  - `<area>_run` / `run_state_<area>` — the read-only audit pass.
  - `apply_<area>` / `<area>_fix` — the idempotent apply pass, called from `fix <area>`.
- Libs that are subcommands of their own (e.g., `score.sh`, `terraform.sh`) export `run_<command>`.

## Output: every finding goes through log.sh

Use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_tier> [docs_url]` — feature is gated by plan/sku.
- `log_info  <message>` — chatter.
- `log_section <title>` — separator.
- `log_subsection <title>` — sub-separator.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, discover, tenant, subscription, entra, rbac, policy, defender, sentinel, storage, keyvault, vm, appservice, functions, aks, acr, sql, cosmos, postgres, mysql, appgw, frontdoor, dns, nsg, firewall, bastion, backup, cost, tags, activitylog, project, security-txt, cookies, takeovers, exposure-probe, health, gha, iac, drift, score, panic, migrate, terraform, export`.

## API helpers (`lib/api.sh`)

- `az_run <args...>` — run `az <args>` and emit stdout. Captures stderr in `AZSEC_LAST_STDERR`. Non-zero rc passes through.
- `az_run_json <args...>` — same plus `-o json` injected; validates that stdout parses as JSON.
- `AZSEC_LAST_STATUS`, `AZSEC_LAST_STDERR` are set after every call.
- `az_pick_subscription`, `az_pick_tenant`, `az_pick_rg` cache and return ids; they read `AZSEC_SUBSCRIPTION_ID` / `AZSEC_TENANT_ID` / `AZSEC_RESOURCE_GROUP` from env.
- `api_check_auth_env` refuses dangerous env (embedded `AZURE_CLIENT_SECRET` when WI/MI is detected) and verifies `az account show`.

## Plan-tier gating

Azure features are gated by Defender for Cloud plan (Standard/Free) per workload, by SKU (App Service Basic vs Premium, Front Door Standard vs Premium, etc.), and sometimes by license (Entra ID P1/P2, Sentinel commitment tier).

Before every paid-only check or fix, call:

```sh
requires_tier <area> <key> <message> <required_tier> <docs_url> || return 0
```

It logs `[N/A locked: tier+]` automatically and returns 1, letting the caller skip to the next check cleanly.

`required_tier` values used here:
- `defender-standard` (Defender for Cloud Standard plan, per workload)
- `entra-p1`, `entra-p2`
- `sentinel`
- `appservice-premium`
- `frontdoor-premium`
- `appgw-waf-v2`
- `keyvault-premium`

## Idempotency contract for `*_fix` / `apply_*`

Every fix function:

1. **Reads current state first** via `az ... show -o json` or local file inspection.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise mutates via the smallest set of `az` calls or stdout-emitted file diffs.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from a `*_fix` unless `az` actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (Bicep templates, ARM, Terraform, `.github/workflows/*`, `staticwebapp.config.json`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

```
=== FILE: <relative path> ===
=== DIFF ===
<unified diff>
=== CONTENT ===
<full proposed file>
=== END ===
```

- The skill freely writes inside `~/.claude/skills/snitch-azure/.state/` (snapshots, caches, panic state).

## Refusing dangerous defaults

- Refuse to operate when `AZURE_CLIENT_SECRET` is set if Managed Identity / Workload Identity Federation is available.
- Refuse `fix nsg` deletion of 0.0.0.0/0 rules on management ports without explicit confirmation.
- Refuse to lower posture in any `*_fix` (e.g., never decrease `min_tls_version`, never disable HTTPS-only).
- Refuse to operate in subscriptions that the active principal doesn't have at least Reader on; emit `[FAIL] auth missing-reader` and exit.

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` and read `${STATE_DIR}/detect.json`. Don't re-implement detection. Azure-specific markers added: `bicep` files, `*.parameters.json`, `azuredeploy.json`, ARM templates with `schema.management.azure.com`, `terraform` AzureRM provider, `pulumi.azure.yaml`, `Azure.yml` DevOps pipeline, `staticwebapp.config.json`.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
