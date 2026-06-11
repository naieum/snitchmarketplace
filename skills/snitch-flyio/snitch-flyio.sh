#!/usr/bin/env bash
# snitch-flyio: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (FLYSEC_ORG, FLYSEC_APP).

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SKILL_DIR/lib"
REF_DIR="$SKILL_DIR/references"
TPL_DIR="$SKILL_DIR/templates"
STATE_DIR="$SKILL_DIR/.state"
mkdir -p "$STATE_DIR"
export SKILL_DIR LIB_DIR REF_DIR TPL_DIR STATE_DIR

# shellcheck source=lib/log.sh
. "$LIB_DIR/log.sh"
# shellcheck source=lib/api.sh
. "$LIB_DIR/api.sh"
# shellcheck source=lib/plan.sh
. "$LIB_DIR/plan.sh"

usage() {
  cat <<'EOF'
snitch-flyio: thin Fly.io tool surface. Agent orchestrates synthesis.

Read-only (JSON on stdout):
  doctor                   env health: flyctl, jq, auth, MCP
  detect                   cwd signals: stacks, fly.toml, dockerfile, db, AI, hostnames
  state account [org]      tier + members + 2FA coverage
  state apps [org]         inventory + force_https + plaintext-secret counts
  state machines [app]     status, restart policy, health checks, regions
  state volumes [app]      count, region affinity, snapshot retention
  state postgres [app]     nodes, region spread, backups
  state redis              Upstash-on-Fly Redis + TLS posture
  state secrets [app]      count, names (no values), digest hashes
  state services [app]     HTTP/TCP, force_https, internal vs public, checks
  state network [org]      WireGuard peers, IPs (v4/v6), private-net
  state tokens [org]       count, scopes, expiry distribution
  state cost [org]         spend digest (machine-hours, GB-months, GPU minutes)
  state regions [app]      per-region presence
  fit-matrix [stack]       migration verdict
  stack-docs [stack]       canonical doc URLs
  score [host...]          SSL Labs / Mozilla Observatory / securityheaders / hstspreload

Mutating (idempotent):
  fix <area> [app]         areas: apps secrets postgres machines volumes account tokens project gha all
  panic <action> [args...] suspend <app> | revoke-token <id> | scale-to-zero <app> | restore

Utility:
  export                   JSON snapshot of org+apps to cwd
  terraform                fly-terraform HCL to stdout
  verify                   diff current vs last snapshot
  refresh-docs             re-pull canonical Fly docs into references/_cache/
  help                     this message

Environment:
  FLY_API_TOKEN            optional (else flyctl reads ~/.fly/config.yml)
  FLYSEC_ORG               Fly org slug override
  FLYSEC_APP               Fly app name override
  FLYSEC_MCP_PRESENT       set to 1 if a Fly MCP server is loaded
EOF
}

_refuse_no_flyctl_json() {
  if ! command -v flyctl >/dev/null 2>&1 && ! command -v fly >/dev/null 2>&1; then
    printf '{"error":"flyctl not found","code":"E_TOOL","remediation":"install flyctl: curl -L https://fly.io/install.sh | sh  (or brew install flyctl). Then run: fly auth login."}\n' >&2
    return 2
  fi
  return 0
}

dispatch_state() {
  _refuse_no_flyctl_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    account)  . "$LIB_DIR/state_account.sh";  run_state_account "$@" ;;
    apps)     . "$LIB_DIR/state_apps.sh";     run_state_apps "$@" ;;
    machines) . "$LIB_DIR/state_machines.sh"; run_state_machines "$@" ;;
    volumes)  . "$LIB_DIR/state_volumes.sh";  run_state_volumes "$@" ;;
    postgres) . "$LIB_DIR/state_postgres.sh"; run_state_postgres "$@" ;;
    redis)    . "$LIB_DIR/state_redis.sh";    run_state_redis "$@" ;;
    secrets)  . "$LIB_DIR/state_secrets.sh";  run_state_secrets "$@" ;;
    services) . "$LIB_DIR/state_services.sh"; run_state_services "$@" ;;
    network)  . "$LIB_DIR/state_network.sh";  run_state_network "$@" ;;
    tokens)   . "$LIB_DIR/state_tokens.sh";   run_state_tokens "$@" ;;
    cost)     . "$LIB_DIR/state_cost.sh";     run_state_cost "$@" ;;
    regions)  . "$LIB_DIR/state_machines.sh"; run_state_regions "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["account","apps","machines","volumes","postgres","redis","secrets","services","network","tokens","cost","regions"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-flyio.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    apps)
      . "$LIB_DIR/apply_apps.sh"; apply_apps "$@" ;;
    secrets)
      . "$LIB_DIR/apply_secrets.sh"; apply_secrets "$@" ;;
    postgres)
      . "$LIB_DIR/apply_postgres.sh"; apply_postgres "$@" ;;
    machines)
      . "$LIB_DIR/apply_machines.sh"; apply_machines "$@" ;;
    volumes)
      . "$LIB_DIR/apply_volumes.sh"; apply_volumes "$@" ;;
    account)
      . "$LIB_DIR/apply_account.sh"; apply_account "$@" ;;
    tokens)
      . "$LIB_DIR/apply_tokens.sh"; apply_tokens "$@" ;;
    project)
      . "$LIB_DIR/apply_apps.sh"; apply_apps "$@" ;;
    gha)
      . "$LIB_DIR/gha.sh"; gha_fix "$@" ;;
    all)
      . "$LIB_DIR/apply_apps.sh"; . "$LIB_DIR/apply_secrets.sh"
      . "$LIB_DIR/apply_postgres.sh"; . "$LIB_DIR/apply_machines.sh"
      . "$LIB_DIR/apply_volumes.sh"; . "$LIB_DIR/apply_account.sh"
      . "$LIB_DIR/apply_tokens.sh"
      apply_account "$@"
      apply_apps "$@"
      apply_secrets "$@"
      apply_machines "$@"
      apply_volumes "$@"
      apply_postgres "$@"
      apply_tokens "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area"
      return 2 ;;
  esac
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    doctor)
      doctor_run ;;
    detect)
      . "$LIB_DIR/detect.sh"; run_detect "$@" ;;
    state)
      dispatch_state "$@" ;;
    fit-matrix)
      . "$LIB_DIR/fit_matrix.sh"; run_fit_matrix "$@" ;;
    stack-docs)
      . "$LIB_DIR/stack_docs.sh"; run_stack_docs "$@" ;;
    score)
      . "$LIB_DIR/score.sh"; run_score "$@" ;;
    export)
      . "$LIB_DIR/export.sh"; run_export "$@" ;;
    terraform)
      _refuse_no_flyctl_json || return $?
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      _refuse_no_flyctl_json || return $?
      auth_verify || return $?
      . "$LIB_DIR/verify.sh"; run_verify "$@" ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      _refuse_no_flyctl_json || return $?
      . "$LIB_DIR/panic.sh"; run_panic "$@" ;;
    help|-h|--help|"")
      usage ;;
    *)
      log_fail "skill" "usage" "unknown subcommand: $cmd"
      usage
      return 2 ;;
  esac
}

main "$@"
