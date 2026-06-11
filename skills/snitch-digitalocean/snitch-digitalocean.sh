#!/usr/bin/env bash
# snitch-digitalocean: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (DOSEC_*, DIGITALOCEAN_ACCESS_TOKEN).

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
snitch-digitalocean: thin DO tool surface. Agent orchestrates synthesis.

Reads (JSON on stdout):
  doctor                              env health: curl, jq, doctl, token, MCP
  detect                              cwd signals: stacks, dbs, storage, hostnames, do_markers
  state account [slice]               digest|team|tokens|audit|full
  state droplets [slice]              digest|list|full
  state databases [slice]             digest|list|full
  state spaces [slice]                digest|list|full
  state apps [slice]                  digest|list|full
  state loadbalancers [slice]         digest|list|full
  state firewalls [slice]             digest|list|full
  state registry [slice]              digest|list|full
  state kubernetes [slice]            digest|list|full
  state functions [slice]             digest|list|full
  state vpcs [slice]                  digest|list|full
  state dns [slice]                   digest|list|full
  state monitoring [slice]            digest|list|full
  state cost [slice]                  digest|list|full
  fit-matrix [stack]                  migration verdict (full or per-stack)
  stack-docs [stack]                  canonical doc URLs
  score [host...]                     external validators

Mutations (idempotent):
  fix <area> [args]                   areas: droplets databases spaces firewalls apps
                                             kubernetes account dns all
  panic <action> [args...]            rotate-token | firewall-block <ip> |
                                      spaces-lockdown <bucket> | restore

Utility:
  export                              JSON snapshot to cwd
  terraform                           HCL of current state to stdout
  verify                              diff current state vs last snapshot
  refresh-docs                        re-pull DO docs to references/_cache/
  help [subcommand]                   this message

Env:
  DIGITALOCEAN_ACCESS_TOKEN           scoped token (preferred); OR active doctl context
  DOSEC_ACCOUNT_CONTEXT               doctl context override
  DOSEC_MCP_PRESENT                   1 if DO MCP is loaded
EOF
}

dispatch_state() {
  local sub="${1:-}"; shift || true
  case "$sub" in
    account)       . "$LIB_DIR/state_account.sh";       run_state_account "$@" ;;
    droplets)      . "$LIB_DIR/state_droplets.sh";      run_state_droplets "$@" ;;
    databases)     . "$LIB_DIR/state_databases.sh";     run_state_databases "$@" ;;
    spaces)        . "$LIB_DIR/state_spaces.sh";        run_state_spaces "$@" ;;
    apps)          . "$LIB_DIR/state_apps.sh";          run_state_apps "$@" ;;
    loadbalancers) . "$LIB_DIR/state_loadbalancers.sh"; run_state_loadbalancers "$@" ;;
    firewalls)     . "$LIB_DIR/state_firewalls.sh";     run_state_firewalls "$@" ;;
    registry)      . "$LIB_DIR/state_registry.sh";      run_state_registry "$@" ;;
    kubernetes)    . "$LIB_DIR/state_kubernetes.sh";    run_state_kubernetes "$@" ;;
    functions)     . "$LIB_DIR/state_functions.sh";     run_state_functions "$@" ;;
    vpcs)          . "$LIB_DIR/state_vpcs.sh";          run_state_vpcs "$@" ;;
    dns)           . "$LIB_DIR/state_dns.sh";           run_state_dns "$@" ;;
    monitoring)    . "$LIB_DIR/state_monitoring.sh";    run_state_monitoring "$@" ;;
    cost)          . "$LIB_DIR/state_cost.sh";          run_state_cost "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["account","droplets","databases","spaces","apps","loadbalancers","firewalls","registry","kubernetes","functions","vpcs","dns","monitoring","cost"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-digitalocean.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    droplets)    . "$LIB_DIR/apply_droplets.sh";    apply_droplets "$@" ;;
    databases)   . "$LIB_DIR/apply_databases.sh";   apply_databases "$@" ;;
    spaces)      . "$LIB_DIR/apply_spaces.sh";      apply_spaces "$@" ;;
    firewalls)   . "$LIB_DIR/apply_firewalls.sh";   apply_firewalls "$@" ;;
    apps)        . "$LIB_DIR/apply_apps.sh";        apply_apps "$@" ;;
    kubernetes)  . "$LIB_DIR/apply_kubernetes.sh";  apply_kubernetes "$@" ;;
    account)     . "$LIB_DIR/apply_account.sh";     apply_account "$@" ;;
    dns)         . "$LIB_DIR/apply_dns.sh";         apply_dns "$@" ;;
    all)
      . "$LIB_DIR/apply_droplets.sh";    apply_droplets "$@"
      . "$LIB_DIR/apply_databases.sh";   apply_databases "$@"
      . "$LIB_DIR/apply_spaces.sh";      apply_spaces "$@"
      . "$LIB_DIR/apply_firewalls.sh";   apply_firewalls "$@"
      . "$LIB_DIR/apply_apps.sh";        apply_apps "$@"
      . "$LIB_DIR/apply_kubernetes.sh";  apply_kubernetes "$@"
      . "$LIB_DIR/apply_account.sh";     apply_account "$@"
      . "$LIB_DIR/apply_dns.sh";         apply_dns "$@"
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
      api_check_auth_env || return $?
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      api_check_auth_env || return $?
      . "$LIB_DIR/verify.sh"; run_verify "$@" ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      api_check_auth_env || return $?
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
