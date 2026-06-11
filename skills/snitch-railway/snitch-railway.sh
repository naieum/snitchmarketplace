#!/usr/bin/env bash
# snitch-railway: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (RWSEC_PROJECT_ID, RWSEC_ENVIRONMENT).

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
snitch-railway: thin Railway tool surface. Agent orchestrates synthesis.

Read-only (JSON on stdout):
  doctor                              env health: railway CLI, jq, token, MCP
  detect                              cwd signals: stacks, databases, hostnames
  state workspace [slice]             digest|members|billing|full
  state project [pid] [slice]         digest|environments|full
  state services [pid] [slice]        digest|full
  state env [pid] [env] [slice]       digest|vars|full (heuristic secret-shape flags)
  state volumes [pid] [slice]         volume inventory + mount summary
  state databases [pid] [slice]       DB add-on inventory + version + EOL
  state tokens [slice]                token inventory (project + account)
  state domains [pid] [slice]         custom domains + TLS state
  state tcp-proxies [pid] [slice]     per-service public TCP exposures
  state logs [pid] [slice]            log retention + drain config
  state cost [pid] [slice]            usage estimate + free-tier exhaustion
  fit-matrix [stack]                  migration fit matrix
  stack-docs [stack]                  canonical doc URLs per stack
  score [host...]                     external validators

Mutating (idempotent / explicit):
  fix <area> [args]                   apply hardening; safe to re-run
  panic <action> [args...]            suspend-service <svc> | revoke-token <id> |
                                      lockdown-db <svc> | restore

Utility:
  export                              JSON snapshot of project to cwd
  terraform                           Terraform stub (Railway has limited TF coverage)
  verify                              diff current state vs last snapshot
  refresh-docs                        re-pull canonical Railway docs to references/_cache/
  help                                this message

Areas for `fix`: env services databases domains workspace tokens logs all

Env:
  RAILWAY_TOKEN                       project-scoped token
  RAILWAY_API_TOKEN                   account-scoped (preferred for state queries)
  RWSEC_PROJECT_ID                    optional project id override
  RWSEC_ENVIRONMENT                   optional environment (production|staging|...)
  RWSEC_MCP_PRESENT                   set to 1 if a Railway MCP is loaded
EOF
}

dispatch_state() {
  api_check_auth_env_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    workspace)   . "$LIB_DIR/state_workspace.sh";   run_state_workspace "$@" ;;
    project)     . "$LIB_DIR/state_project.sh";     run_state_project "$@" ;;
    services)    . "$LIB_DIR/state_services.sh";    run_state_services "$@" ;;
    env)         . "$LIB_DIR/state_env.sh";         run_state_env "$@" ;;
    volumes)     . "$LIB_DIR/state_volumes.sh";     run_state_volumes "$@" ;;
    databases)   . "$LIB_DIR/state_databases.sh";   run_state_databases "$@" ;;
    tokens)      . "$LIB_DIR/state_tokens.sh";      run_state_tokens "$@" ;;
    domains)     . "$LIB_DIR/state_domains.sh";     run_state_domains "$@" ;;
    tcp-proxies) . "$LIB_DIR/state_tcp_proxies.sh"; run_state_tcp_proxies "$@" ;;
    logs)        . "$LIB_DIR/state_logs.sh";        run_state_logs "$@" ;;
    cost)        . "$LIB_DIR/state_cost.sh";        run_state_cost "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["workspace","project","services","env","volumes","databases","tokens","domains","tcp-proxies","logs","cost"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-railway.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    env)        . "$LIB_DIR/apply_env.sh";       apply_env "$@" ;;
    services)   . "$LIB_DIR/apply_services.sh";  apply_services "$@" ;;
    databases)  . "$LIB_DIR/apply_databases.sh"; apply_databases "$@" ;;
    domains)    . "$LIB_DIR/apply_domains.sh";   apply_domains "$@" ;;
    workspace)  . "$LIB_DIR/apply_workspace.sh"; apply_workspace "$@" ;;
    tokens)     . "$LIB_DIR/apply_tokens.sh";    apply_tokens "$@" ;;
    logs)       . "$LIB_DIR/apply_logs.sh";      apply_logs "$@" ;;
    all)
      . "$LIB_DIR/apply_env.sh";       apply_env "$@"
      . "$LIB_DIR/apply_services.sh";  apply_services "$@"
      . "$LIB_DIR/apply_databases.sh"; apply_databases "$@"
      . "$LIB_DIR/apply_domains.sh";   apply_domains "$@"
      . "$LIB_DIR/apply_workspace.sh"; apply_workspace "$@"
      . "$LIB_DIR/apply_tokens.sh";    apply_tokens "$@"
      . "$LIB_DIR/apply_logs.sh";      apply_logs "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area"
      return 2 ;;
  esac
}

# Deprecation notice for synthesis subcommands.
deprecation_notice() {
  local cmd="$1"
  printf '%s\n' "[DEPRECATED] '$cmd' is deprecated. The agent should compose the answer using primitive tools instead. See SKILL.md → 'Recipes' for the new flow." >&2
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
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      api_check_auth_env || return $?
      . "$LIB_DIR/state_project.sh"
      . "$LIB_DIR/drift.sh"
      run_state_project "$@" >/dev/null
      drift_run ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      api_check_auth_env || return $?
      . "$LIB_DIR/panic.sh"; run_panic "$@" ;;
    # ---------- DEPRECATED synthesis subcommands ----------
    check|migrate|roadmap|report|diagnose)
      deprecation_notice "$cmd"
      printf '%s\n' "[INFO] The agent should run the appropriate primitive tool combination instead. See $REF_DIR/30-recipes.md." >&2
      return 64 ;;
    help|-h|--help|"")
      usage ;;
    *)
      log_fail "skill" "usage" "unknown subcommand: $cmd"
      usage
      return 2 ;;
  esac
}

main "$@"
