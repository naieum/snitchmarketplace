#!/usr/bin/env bash
# snitch-vercel: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (VRCSEC_TEAM_ID, VRCSEC_PROJECT_ID, VERCEL_TOKEN).

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
snitch-vercel: thin Vercel tool surface. The agent orchestrates synthesis.

Read-only (JSON on stdout):
  doctor                          env health: curl, jq, vercel CLI, token, MCP
  detect                          cwd signals: stacks, databases, hostnames, vercel markers
  state account [slice]           user + team summary. Slices: members | tokens | audit | full
  state team [team-id] [slice]    team meta + plan. Slices: members | full
  state project [project-id] [slice]   project meta + framework + region. Slices: full
  state env [project-id] [slice]  env vars per env. Slices: production | preview | development | full
  state domains [project-id]      domains + TLS + redirects
  state deployments [project-id] [window]   window: 24h | 7d | 30d
  state protection [project-id]   deployment protection policy
  state functions [project-id]    serverless + edge function inventory
  state middleware [project-id]   introspect middleware.ts
  state kv-postgres-blob [project-id]  storage bindings
  state edge-config [project-id]  edge-config items + tokens
  state log-drains [team-id]      log-drain destinations (Pro+)
  state analytics [project-id]    web analytics + speed insights status
  state cost [team-id] [window]   function invocations, bandwidth, image-opt, KV
  fit-matrix [stack]              migration fit matrix
  stack-docs [stack]              canonical doc URLs per stack
  score [host...]                 SSL Labs / Mozilla Observatory / etc.

Mutating (idempotent):
  fix <area> [project-id]         apply hardening; safe to re-run
  panic <action> [args...]        pause-deploys | revoke-token <id> | lock-production | restore

Utility:
  export                          JSON snapshot of project+team to cwd
  terraform                       vercel/vercel HCL stub to stdout
  verify                          diff current state vs last snapshot
  refresh-docs                    re-pull canonical Vercel docs into references/_cache/
  help                            this message

Areas for `fix`:
  account project env domains headers log-drains all

Environment:
  VERCEL_TOKEN                    scoped API token (https://vercel.com/account/tokens)
  VRCSEC_TEAM_ID                  optional team id override
  VRCSEC_PROJECT_ID               optional project id override
  VRCSEC_MCP_PRESENT              set to 1 if a Vercel MCP server is loaded
EOF
}

_refuse_when_unauthed() {
  # The skill needs either a working `vercel whoami` OR VERCEL_TOKEN. doctor reports details.
  if [[ -z "${VERCEL_TOKEN:-}" ]]; then
    if ! command -v vercel >/dev/null 2>&1; then
      printf '{"error":"vercel CLI not installed and VERCEL_TOKEN not set","code":"E_AUTH","remediation":"npm i -g vercel && vercel login, OR export VERCEL_TOKEN from https://vercel.com/account/tokens"}\n' >&2
      return 2
    fi
    if ! vercel whoami >/dev/null 2>&1; then
      printf '{"error":"vercel whoami failed and VERCEL_TOKEN not set","code":"E_AUTH","remediation":"run vercel login OR export VERCEL_TOKEN"}\n' >&2
      return 2
    fi
  fi
  return 0
}

dispatch_state() {
  _refuse_when_unauthed || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    account)         . "$LIB_DIR/state_account.sh";    run_state_account "$@" ;;
    team)            . "$LIB_DIR/state_team.sh";       run_state_team "$@" ;;
    project)         . "$LIB_DIR/state_project.sh";    run_state_project "$@" ;;
    env)             . "$LIB_DIR/state_env.sh";        run_state_env "$@" ;;
    domains)         . "$LIB_DIR/state_domains.sh";    run_state_domains "$@" ;;
    deployments)     . "$LIB_DIR/state_deployments.sh"; run_state_deployments "$@" ;;
    protection)      . "$LIB_DIR/state_protection.sh"; run_state_protection "$@" ;;
    functions)       . "$LIB_DIR/state_functions.sh";  run_state_functions "$@" ;;
    middleware)      . "$LIB_DIR/state_middleware.sh"; run_state_middleware "$@" ;;
    kv-postgres-blob|storage)
                     . "$LIB_DIR/state_storage.sh";    run_state_storage "$@" ;;
    edge-config)     . "$LIB_DIR/state_edge_config.sh"; run_state_edge_config "$@" ;;
    log-drains)      . "$LIB_DIR/state_log_drains.sh"; run_state_log_drains "$@" ;;
    analytics)       . "$LIB_DIR/state_analytics.sh";  run_state_analytics "$@" ;;
    cost)            . "$LIB_DIR/state_cost.sh";       run_state_cost "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["account","team","project","env","domains","deployments","protection","functions","middleware","kv-postgres-blob","edge-config","log-drains","analytics","cost"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-vercel.sh help' for the list."
    return 2
  fi
  _refuse_when_unauthed || return $?
  case "$area" in
    account)
      . "$LIB_DIR/apply_account.sh"; apply_account "$@" ;;
    project)
      . "$LIB_DIR/apply_project.sh"; apply_project "$@" ;;
    env)
      . "$LIB_DIR/apply_env.sh"; apply_env "$@" ;;
    domains)
      . "$LIB_DIR/apply_domains.sh"; apply_domains "$@" ;;
    headers)
      . "$LIB_DIR/apply_headers.sh"; apply_headers "$@" ;;
    log-drains)
      . "$LIB_DIR/apply_log_drains.sh"; apply_log_drains "$@" ;;
    all)
      . "$LIB_DIR/apply_account.sh"
      . "$LIB_DIR/apply_project.sh"
      . "$LIB_DIR/apply_env.sh"
      . "$LIB_DIR/apply_domains.sh"
      . "$LIB_DIR/apply_headers.sh"
      . "$LIB_DIR/apply_log_drains.sh"
      apply_account "$@"
      apply_project "$@"
      apply_env "$@"
      apply_domains "$@"
      apply_headers "$@"
      apply_log_drains "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area. Valid: account|project|env|domains|headers|log-drains|all."
      return 2 ;;
  esac
}

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
      _refuse_when_unauthed || return $?
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      _refuse_when_unauthed || return $?
      . "$LIB_DIR/verify.sh"; run_verify "$@" ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      _refuse_when_unauthed || return $?
      . "$LIB_DIR/panic.sh"; run_panic "$@" ;;
    # ---------- DEPRECATED synthesis subcommands ----------
    check|migrate|roadmap|report|diagnose|stacks)
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
