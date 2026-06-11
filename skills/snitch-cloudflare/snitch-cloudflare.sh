#!/usr/bin/env bash
# snitch-cloudflare: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (CFSEC_ZONE_ID, CFSEC_ACCOUNT_ID).

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
snitch-cloudflare: thin Cloudflare tool surface. Agent orchestrates synthesis.

Read tools (JSON on stdout):
  doctor                          env health
  detect                          cwd signals (stacks, dbs, storage, AI, hostnames)
  state zone [zone-id] [slice]    digest by default; slices: dns|rulesets|firewall|full
  state account [acct-id] [slice] digest by default; slices: members|tokens|audit|full
  state tunnels                   tunnel inventory
  state access                    access apps + service tokens
  state pageshield [zone]         page shield state (Pro+; {locked:"pro"} if not entitled)
  analytics zone [zone] [window]  cache, threats, top ASNs/countries/paths (1h|24h|7d)
  events zone [zone] [window]     recent firewall events
  fit-matrix [stack]              migration fit matrix
  stack-docs [stack]              canonical doc URLs (for WebFetch)
  score [host...]                 SSL Labs / MDN Observatory / local header grade / hstspreload

Audit lenses (cross-cutting; JSON on stdout; gated lenses emit {locked:...} cleanly):
  audit auditlog [acct] [window]  account audit-log analysis (24h|7d|30d)
  audit logpush [acct]            Logpush job coverage (Enterprise; {locked:"enterprise"} else)
  audit dns [zone] [window]       DNS settings + DNS analytics (1h|24h|7d)
  audit ai-gateway [acct]         AI Gateway governance ({locked:"not-configured"} if none)
  audit secevents [zone] [window] aggregated WAF/security-event analytics
  audit casb|dex|builds           MCP-only lens → delegation pointer (Zero Trust / CI-CD)
  audit browser [host...]         external rendered header/CSP (browser MCP; curl fallback)
  audit observability             Workers errors/exceptions (observability MCP; GraphQL fallback)
  audit all                       master toes-to-top report envelope (sequences every lens)

Mutating (idempotent):
  fix <area> [zone-id]            apply hardening for one area
  panic <action> [args...]        under-attack | block ip|asn|country <v> | challenge-all | restore

Utility:
  export | terraform | verify | refresh-docs | help

`fix` areas:
  ssl hsts dnssec dns-email waf rules bots rate-limit headers aop tunnel access
  account tokens project security-txt cookies takeovers health gha wrangler-lint
  email page-shield all

Env:
  CLOUDFLARE_API_TOKEN  scoped token (NEVER the global API key)
  CFSEC_ZONE_ID         optional zone id override
  CFSEC_ACCOUNT_ID      optional account id override
  CFSEC_MCP_PRESENT     set to 1 if the Cloudflare Developer Platform MCP is loaded
  CFSEC_MCP_CASB        set to 1 if the Cloudflare CASB MCP is loaded (audit casb)
  CFSEC_MCP_DEX         set to 1 if the Cloudflare DEX MCP is loaded (audit dex)
  CFSEC_MCP_BUILDS      set to 1 if the Workers Builds MCP is loaded (audit builds)
  CFSEC_MCP_BROWSER     set to 1 if the Browser Rendering MCP is loaded (audit browser)
  CFSEC_MCP_OBSERVABILITY set to 1 if the Observability MCP is loaded (audit observability)
EOF
}

_refuse_global_key_json() {
  if [[ -n "${CLOUDFLARE_API_KEY:-}" && -n "${CLOUDFLARE_EMAIL:-}" ]]; then
    printf '{"error":"global API key detected","code":"E_AUTH","remediation":"unset CLOUDFLARE_API_KEY and CLOUDFLARE_EMAIL; create a scoped token at https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi
  return 0
}

dispatch_state() {
  # State tools handle their own missing-token case (JSON on stderr).
  # We only pre-empt the legacy global-API-key case here.
  _refuse_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    zone)       . "$LIB_DIR/state_zone.sh";       run_state_zone "$@" ;;
    account)    . "$LIB_DIR/state_account.sh";    run_state_account "$@" ;;
    tunnels)    . "$LIB_DIR/state_tunnels.sh";    run_state_tunnels "$@" ;;
    access)     . "$LIB_DIR/state_access.sh";     run_state_access "$@" ;;
    pageshield) . "$LIB_DIR/state_pageshield.sh"; run_state_pageshield "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["zone","account","tunnels","access","pageshield"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s","valid":["zone","account","tunnels","access","pageshield"]}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_analytics() {
  _refuse_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    zone) . "$LIB_DIR/analytics.sh"; run_analytics zone "$@" ;;
    "")
      printf '{"error":"analytics requires a subscope","code":"E_USAGE","valid":["zone"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown analytics subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_events() {
  _refuse_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    zone) . "$LIB_DIR/events.sh"; run_events zone "$@" ;;
    "")
      printf '{"error":"events requires a subscope","code":"E_USAGE","valid":["zone"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown events subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_audit() {
  # Cross-cutting security lenses + the master report. Curl lenses self-gate
  # (emit {locked:...} cleanly); MCP-backed lenses emit a delegation pointer.
  _refuse_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    auditlog)   . "$LIB_DIR/audit_auditlog.sh";   run_audit_auditlog "$@" ;;
    logpush)    . "$LIB_DIR/audit_logpush.sh";    run_audit_logpush "$@" ;;
    dns)        . "$LIB_DIR/audit_dns.sh";        run_audit_dns "$@" ;;
    ai-gateway) . "$LIB_DIR/audit_ai_gateway.sh"; run_audit_ai_gateway "$@" ;;
    secevents)  . "$LIB_DIR/audit_secevents.sh";  run_audit_secevents "$@" ;;
    casb|dex|builds|browser|observability)
                . "$LIB_DIR/audit_delegated.sh";  run_audit_delegated "$sub" "$@" ;;
    all)
      . "$LIB_DIR/audit_auditlog.sh"; . "$LIB_DIR/audit_logpush.sh"
      . "$LIB_DIR/audit_dns.sh";      . "$LIB_DIR/audit_ai_gateway.sh"
      . "$LIB_DIR/audit_secevents.sh"; . "$LIB_DIR/audit_delegated.sh"
      . "$LIB_DIR/audit_all.sh";      run_audit_all "$@" ;;
    "")
      printf '{"error":"audit requires a lens","code":"E_USAGE","valid":["auditlog","logpush","dns","ai-gateway","secevents","casb","dex","builds","browser","observability","all"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown audit lens","code":"E_USAGE","got":"%s","valid":["auditlog","logpush","dns","ai-gateway","secevents","casb","dex","builds","browser","observability","all"]}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-cloudflare.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    ssl|hsts|dnssec|dns-email|aop|headers|rate-limit)
      . "$LIB_DIR/apply_zone.sh"; apply_zone "$area" "$@" ;;
    waf|rules|bots)
      . "$LIB_DIR/rules.sh"; apply_rules "$area" "$@" ;;
    tunnel|access)
      . "$LIB_DIR/tunnel_access.sh"; apply_tunnel_access "$area" "$@" ;;
    account)
      . "$LIB_DIR/apply_account.sh"; apply_account "$@" ;;
    tokens)
      . "$LIB_DIR/tokens.sh"; tokens_fix "$@" ;;
    project)
      . "$LIB_DIR/apply_project.sh"; apply_project "$@" ;;
    security-txt|cookies|takeovers)
      . "$LIB_DIR/security_extras.sh"; security_extras_fix "$area" "$@" ;;
    health)
      . "$LIB_DIR/health.sh"; health_fix "$@" ;;
    gha)
      . "$LIB_DIR/gha.sh"; gha_fix "$@" ;;
    wrangler-lint)
      . "$LIB_DIR/wrangler_lint.sh"; wrangler_lint_fix "$@" ;;
    email)
      . "$LIB_DIR/email.sh"; email_fix "$@" ;;
    page-shield)
      . "$LIB_DIR/page_shield.sh"; page_shield_fix "$@" ;;
    all)
      . "$LIB_DIR/apply_zone.sh"; . "$LIB_DIR/apply_account.sh"
      . "$LIB_DIR/apply_project.sh"; . "$LIB_DIR/rules.sh"
      . "$LIB_DIR/security_extras.sh"; . "$LIB_DIR/email.sh"
      apply_zone all "$@"
      apply_account "$@"
      apply_project "$@"
      apply_rules all "$@"
      security_extras_fix all "$@"
      email_fix "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area"
      return 2 ;;
  esac
}

# Deprecation notice for synthesis subcommands. Phase 1: prints a warning to
# stderr; Phase 2: removed entirely.
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
    analytics)
      dispatch_analytics "$@" ;;
    events)
      dispatch_events "$@" ;;
    audit)
      dispatch_audit "$@" ;;
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
      auth_verify || return $?
      . "$LIB_DIR/state_zone.sh"
      . "$LIB_DIR/drift.sh"
      run_state_zone "$@" >/dev/null
      drift_run ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      api_check_auth_env || return $?
      . "$LIB_DIR/panic.sh"; run_panic "$@" ;;
    # ---------- DEPRECATED synthesis subcommands (Phase 1) ----------
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
