# lib/audit_ai_gateway.sh — AI Gateway governance posture as JSON (read-only).
# Exports: run_audit_ai_gateway [account-id]
#
# GETs /accounts/{id}/ai-gateway/gateways and reads each gateway's CONFIG flags
# only (never log bodies — those may carry prompt/response PII). AI Gateway has a
# free tier, so the gate is on presence: no gateways (or 404) → {locked:"not-configured"}.
# A 403 means the token lacks AI Gateway Read (an error, not a lock).

run_audit_ai_gateway() {
  local account_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ -z "$account_id" ]]; then
    account_id="$(api_pick_account)" || {
      printf '{"error":"could not resolve account id","code":"E_ACCOUNT","remediation":"set CFSEC_ACCOUNT_ID or pass account-id as the first argument"}\n' >&2
      return 3
    }
  fi

  local st body
  body="$(cf_get "/accounts/${account_id}/ai-gateway/gateways?per_page=50")"; st="$(cf_last_status)"
  case "$(api_surface_gate "$st" "$body" '.result|length==0')" in
    forbidden)
      printf '{"error":"ai-gateway forbidden","code":"E_API","status":403,"remediation":"token needs Account AI Gateway Read for %s"}\n' "$account_id" >&2
      return 3 ;;
    notfound|empty)
      emit_locked_doc "cfsec.audit-ai-gateway" "audit-ai-gateway" account_id "$account_id" \
        not-configured "No AI Gateway configured on this account" \
        '{"gateways":[]}'
      return 0 ;;
    error)
      printf '{"error":"ai-gateway request failed","code":"E_API","status":%s,"account_id":"%s"}\n' "${st:-0}" "$account_id" >&2
      return 3 ;;
  esac

  jq -n --arg ts "$ts" --arg account_id "$account_id" --argjson raw "$body" '
    [($raw.result // [])[] | {
        id: (.id // .name // null),
        collect_logs: .collect_logs,
        log_management: (.log_management // .log_management_strategy // null),
        rate_limiting_enabled: (((.rate_limiting_limit // 0) | tonumber? // 0) > 0),
        rate_limiting_limit: (.rate_limiting_limit // null),
        rate_limiting_technique: (.rate_limiting_technique // null),
        authentication_enabled: (.authentication // false),
        caching_enabled: (((.cache_ttl // 0) | tonumber? // 0) > 0),
        cache_ttl: (.cache_ttl // null),
        logpush_enabled: (.logpush // false)
      }] as $gws
    | {
        schema: "cfsec.audit-ai-gateway", schema_version: 1, generated_at: $ts,
        tool: "audit-ai-gateway", account_id: $account_id, locked: null,
        gateways: $gws
      }'
}
