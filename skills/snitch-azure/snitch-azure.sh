#!/usr/bin/env bash
# snitch-azure: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (AZSEC_SUBSCRIPTION_ID,
# AZSEC_TENANT_ID, AZSEC_RESOURCE_GROUP).

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
snitch-azure: thin Azure tool surface. Agent orchestrates synthesis.

Read tools (JSON on stdout):
  doctor                       env health: az, jq, login, MCP, secret-leak guard
  detect                       cwd signals: stacks, DBs, storage, AI, hostnames, IaC
  state tenant [slice]         tenant + B2B + default domain
  state subscription [id] [s]  subscription digest
  state entra [slice]          users/groups/roles, MFA, CA, app regs
  state rbac [scope] [slice]   role assignments, custom-vs-builtin, deny
  state policy [slice]         initiative assignments, compliance
  state defender [slice]       Defender plans, secure score
  state sentinel [slice]       workspaces, connectors, rules, incidents
  state storage [slice]        HTTPS, public access, soft-delete, encryption
  state keyvault [slice]       soft-delete, purge, RBAC, network ACL
  state vm [slice]             NSG mgmt-ports, encryption, JIT, agents
  state appservice [slice]     HTTPS, TLS, FTPS, SCM basic, identity
  state functions [slice]      HTTPS, identity, runtime
  state aks [slice]            version, net policy, AAD, RBAC, defender
  state acr [slice]            scan, retention, network rules, content trust
  state sql [slice]            TDE, AAD, Defender, audit, public access
  state cosmos [slice]         TLS, AAD, firewall, PE, CMK
  state postgres [slice]       TLS, AAD, firewall, PE
  state mysql [slice]          TLS, AAD, firewall, PE
  state appgw [slice]          WAF mode, TLS policy
  state frontdoor [slice]      WAF mode, custom rules, HTTPS
  state dns [slice]            zones (DNSSEC note)
  state nsg [slice]            0.0.0.0/0 mgmt ports, flow logs
  state firewall [slice]       tier, threat-intel mode
  state bastion [slice]        Bastion vs public RDP/SSH
  state backup [slice]         RSV: soft-del, MUA, immutability
  state cost [slice]           budgets, spend, untagged
  state tags [slice]           tag policy + coverage
  state activitylog [slice]    diagnostic-settings targets
  analytics subscription [w]   activity-log totals (window: 1h | 24h | 7d)
  events subscription [w]      recent activity-log entries
  fit-matrix [stack]           migration fit matrix
  stack-docs [stack]           canonical doc URLs (agent WebFetches)
  score [host...]              SSL Labs, Mozilla Observatory, securityheaders, hstspreload

Mutating (idempotent):
  fix <area> [args]            apply hardening for one area
  panic <action> [args]        lockdown <rg> | nsg-deny-all <nsg> |
                               keyvault-rotate <vault> | policy-emergency | restore

Utility:
  export                       JSON snapshot of subscription + selected RGs
  terraform                    AzureRM HCL to stdout
  verify                       diff current state vs last snapshot
  refresh-docs                 re-pull canonical Azure docs into references/_cache/
  help                         this message

Areas for `fix`:
  storage keyvault appservice sql cosmos postgres mysql nsg defender sentinel
  backup dns subscription tags policy activitylog all

Environment:
  AZSEC_SUBSCRIPTION_ID        subscription id override
  AZSEC_TENANT_ID              tenant id override
  AZSEC_RESOURCE_GROUP         resource group scope
  AZSEC_MCP_PRESENT            set to 1 if Azure MCP is loaded
EOF
}

_refuse_embedded_secret_json() {
  # Refuse running with AZURE_CLIENT_SECRET when WI/MI is available.
  if [[ -n "${AZURE_CLIENT_SECRET:-}" ]]; then
    # Heuristic: WI/MI markers in env.
    if [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-}" || -n "${MSI_ENDPOINT:-}" \
          || -n "${IDENTITY_ENDPOINT:-}" || -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
      printf '{"error":"AZURE_CLIENT_SECRET set while Workload Identity / Managed Identity is available","code":"E_AUTH","remediation":"Drop AZURE_CLIENT_SECRET and use OIDC federation (azure/login@v2 with client-id + tenant-id + subscription-id) or Managed Identity."}\n' >&2
      return 2
    fi
  fi
  return 0
}

dispatch_state() {
  _refuse_embedded_secret_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    tenant)        . "$LIB_DIR/state_tenant.sh";       run_state_tenant "$@" ;;
    subscription)  . "$LIB_DIR/state_subscription.sh"; run_state_subscription "$@" ;;
    entra)         . "$LIB_DIR/state_entra.sh";        run_state_entra "$@" ;;
    rbac)          . "$LIB_DIR/state_rbac.sh";         run_state_rbac "$@" ;;
    policy)        . "$LIB_DIR/state_policy.sh";       run_state_policy "$@" ;;
    defender)      . "$LIB_DIR/state_defender.sh";     run_state_defender "$@" ;;
    sentinel)      . "$LIB_DIR/state_sentinel.sh";     run_state_sentinel "$@" ;;
    storage)       . "$LIB_DIR/state_storage.sh";      run_state_storage "$@" ;;
    keyvault)      . "$LIB_DIR/state_keyvault.sh";     run_state_keyvault "$@" ;;
    vm)            . "$LIB_DIR/state_vm.sh";           run_state_vm "$@" ;;
    appservice)    . "$LIB_DIR/state_appservice.sh";   run_state_appservice "$@" ;;
    functions)     . "$LIB_DIR/state_functions.sh";    run_state_functions "$@" ;;
    aks)           . "$LIB_DIR/state_aks.sh";          run_state_aks "$@" ;;
    acr)           . "$LIB_DIR/state_acr.sh";          run_state_acr "$@" ;;
    sql)           . "$LIB_DIR/state_sql.sh";          run_state_sql "$@" ;;
    cosmos)        . "$LIB_DIR/state_cosmos.sh";       run_state_cosmos "$@" ;;
    postgres)      . "$LIB_DIR/state_postgres.sh";     run_state_postgres "$@" ;;
    mysql)         . "$LIB_DIR/state_mysql.sh";        run_state_mysql "$@" ;;
    appgw)         . "$LIB_DIR/state_appgw.sh";        run_state_appgw "$@" ;;
    frontdoor)     . "$LIB_DIR/state_frontdoor.sh";    run_state_frontdoor "$@" ;;
    dns)           . "$LIB_DIR/state_dns.sh";          run_state_dns "$@" ;;
    nsg)           . "$LIB_DIR/state_nsg.sh";          run_state_nsg "$@" ;;
    firewall)      . "$LIB_DIR/state_firewall.sh";     run_state_firewall "$@" ;;
    bastion)       . "$LIB_DIR/state_bastion.sh";      run_state_bastion "$@" ;;
    backup)        . "$LIB_DIR/state_backup.sh";       run_state_backup "$@" ;;
    cost)          . "$LIB_DIR/state_cost.sh";         run_state_cost "$@" ;;
    tags)          . "$LIB_DIR/state_tags.sh";         run_state_tags "$@" ;;
    activitylog)   . "$LIB_DIR/state_activitylog.sh";  run_state_activitylog "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["tenant","subscription","entra","rbac","policy","defender","sentinel","storage","keyvault","vm","appservice","functions","aks","acr","sql","cosmos","postgres","mysql","appgw","frontdoor","dns","nsg","firewall","bastion","backup","cost","tags","activitylog"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_analytics() {
  _refuse_embedded_secret_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    subscription) . "$LIB_DIR/analytics.sh"; run_analytics subscription "$@" ;;
    "")
      printf '{"error":"analytics requires a subscope","code":"E_USAGE","valid":["subscription"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown analytics subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_events() {
  _refuse_embedded_secret_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    subscription) . "$LIB_DIR/events.sh"; run_events subscription "$@" ;;
    "")
      printf '{"error":"events requires a subscope","code":"E_USAGE","valid":["subscription"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown events subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-azure.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    storage)      . "$LIB_DIR/apply_storage.sh";      apply_storage "$@" ;;
    keyvault)     . "$LIB_DIR/apply_keyvault.sh";     apply_keyvault "$@" ;;
    appservice)   . "$LIB_DIR/apply_appservice.sh";   apply_appservice "$@" ;;
    sql)          . "$LIB_DIR/apply_sql.sh";          apply_sql "$@" ;;
    cosmos)       . "$LIB_DIR/apply_cosmos.sh";       apply_cosmos "$@" ;;
    postgres)     . "$LIB_DIR/apply_postgres.sh";     apply_postgres "$@" ;;
    mysql)        . "$LIB_DIR/apply_mysql.sh";        apply_mysql "$@" ;;
    nsg)          . "$LIB_DIR/apply_nsg.sh";          apply_nsg "$@" ;;
    defender)     . "$LIB_DIR/apply_defender.sh";     apply_defender "$@" ;;
    sentinel)     . "$LIB_DIR/apply_sentinel.sh";     apply_sentinel "$@" ;;
    backup)       . "$LIB_DIR/apply_backup.sh";       apply_backup "$@" ;;
    dns)          . "$LIB_DIR/apply_dns.sh";          apply_dns "$@" ;;
    subscription) . "$LIB_DIR/apply_subscription.sh"; apply_subscription "$@" ;;
    tags)         . "$LIB_DIR/apply_tags.sh";         apply_tags "$@" ;;
    policy)       . "$LIB_DIR/apply_policy.sh";       apply_policy "$@" ;;
    activitylog)  . "$LIB_DIR/apply_activitylog.sh";  apply_activitylog "$@" ;;
    all)
      . "$LIB_DIR/apply_storage.sh"
      . "$LIB_DIR/apply_keyvault.sh"
      . "$LIB_DIR/apply_appservice.sh"
      . "$LIB_DIR/apply_sql.sh"
      . "$LIB_DIR/apply_nsg.sh"
      . "$LIB_DIR/apply_defender.sh"
      . "$LIB_DIR/apply_backup.sh"
      . "$LIB_DIR/apply_subscription.sh"
      . "$LIB_DIR/apply_tags.sh"
      . "$LIB_DIR/apply_policy.sh"
      . "$LIB_DIR/apply_activitylog.sh"
      apply_storage "$@"
      apply_keyvault "$@"
      apply_appservice "$@"
      apply_sql "$@"
      apply_nsg "$@"
      apply_defender "$@"
      apply_backup "$@"
      apply_subscription "$@"
      apply_tags "$@"
      apply_policy "$@"
      apply_activitylog "$@"
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
    analytics)
      dispatch_analytics "$@" ;;
    events)
      dispatch_events "$@" ;;
    fit-matrix)
      . "$LIB_DIR/fit_matrix.sh"; run_fit_matrix "$@" ;;
    stack-docs)
      . "$LIB_DIR/stack_docs.sh"; run_stack_docs "$@" ;;
    score)
      . "$LIB_DIR/score.sh"; run_score "$@" ;;
    export)
      api_check_auth_env || return $?
      . "$LIB_DIR/export.sh"; run_export "$@" ;;
    terraform)
      api_check_auth_env || return $?
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      api_check_auth_env || return $?
      . "$LIB_DIR/state_subscription.sh"
      . "$LIB_DIR/drift.sh"
      run_state_subscription "$@" >/dev/null
      drift_run ;;
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
