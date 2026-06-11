# lib/audit_logpush.sh — Logpush job coverage as JSON (read-only).
# Exports: run_audit_logpush [account-id]
#
# Logpush is Enterprise. GETs /accounts/{id}/logpush/jobs and, when a zone is
# resolvable, /zones/{id}/logpush/jobs (firewall_events / http_requests are
# zone datasets; audit_logs is an account dataset). A 403/404 → {locked:"enterprise"}
# (clean, rc 0). Destinations are redacted (creds stripped); coverage compares
# shipped datasets to the security-relevant set.

# Security-relevant Logpush datasets the agent expects shipped (see 33-logging-observability.md).
CFSEC_LOGPUSH_SECURITY_DATASETS='["http_requests","firewall_events","audit_logs","dns_logs","nel_reports","access_requests","gateway_dns","gateway_http","gateway_network","casb_findings","zero_trust_network_sessions","device_posture_results"]'

run_audit_logpush() {
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

  # --- account jobs (drives the entitlement gate) ---
  local st body
  body="$(cf_get "/accounts/${account_id}/logpush/jobs")"; st="$(cf_last_status)"
  case "$(api_surface_gate "$st" "$body")" in
    forbidden|notfound)
      emit_locked_doc "cfsec.audit-logpush" "audit-logpush" account_id "$account_id" \
        enterprise "Logpush requires an Enterprise plan" \
        '{"jobs":[],"coverage":null}'
      return 0 ;;
    error)
      printf '{"error":"logpush request failed","code":"E_API","status":%s,"account_id":"%s"}\n' "${st:-0}" "$account_id" >&2
      return 3 ;;
  esac
  local acct_jobs; acct_jobs="$(jq '[(.result // [])[] | . + {scope:"account"}]' <<<"$body" 2>/dev/null || printf '[]')"

  # --- zone jobs (best-effort; firewall_events/http_requests live here) ---
  local zone_jobs='[]' zone_id zst zbody
  zone_id="$(api_pick_zone 2>/dev/null)" || zone_id=""
  if [[ -n "$zone_id" ]]; then
    zbody="$(cf_get "/zones/${zone_id}/logpush/jobs")"; zst="$(cf_last_status)"
    if [[ "$zst" =~ ^2 ]]; then
      zone_jobs="$(jq '[(.result // [])[] | . + {scope:"zone"}]' <<<"$zbody" 2>/dev/null || printf '[]')"
    fi
  fi

  jq -n --arg ts "$ts" --arg account_id "$account_id" --arg zone_id "$zone_id" \
        --argjson acct "$acct_jobs" --argjson zone "$zone_jobs" \
        --argjson security "$CFSEC_LOGPUSH_SECURITY_DATASETS" '
    (($acct + $zone) | map({
        id: (.id // null),
        dataset: (.dataset // null),
        scope: (.scope // null),
        enabled: .enabled,
        frequency: (.frequency // null),
        last_complete: (.last_complete // null),
        last_error: (.last_error // null),
        filter_present: ((.filter // null) != null and (.filter // "") != ""),
        destination_redacted: ((.destination_conf // "")
            | sub("://[^@/]*@"; "://<redacted>@")
            | sub("\\?.*$"; "?<redacted>")),
        destination_has_secret: ((.destination_conf // "")
            | test("secret|access[-_]?key|sig=|token=|password|AKIA"; "i"))
      })) as $jobs
    | ($jobs | map(.dataset) | map(select(. != null)) | unique) as $shipped
    | {
        schema: "cfsec.audit-logpush", schema_version: 1, generated_at: $ts,
        tool: "audit-logpush", account_id: $account_id, zone_id: (if $zone_id=="" then null else $zone_id end),
        locked: null,
        jobs: $jobs,
        coverage: {
          datasets_shipped: $shipped,
          security_datasets: $security,
          missing_security_datasets: ($security - $shipped)
        }
      }'
}
