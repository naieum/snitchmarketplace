# lib/audit_auditlog.sh — account audit-log analysis as JSON (read-only).
# Exports: run_audit_auditlog [account-id] [window]
#   window ∈ 24h | 7d (default) | 30d
#
# Reads CLOUDFLARE_API_TOKEN. GETs /accounts/{id}/audit_logs?since=<iso>&per_page=200
# (paginated, capped at 5 pages). Emits counts + a sensitive-event subset; the
# agent grades. Audit logs are available on all plans, so a 403 here means the
# token lacks Account Audit Logs Read (an error, not a plan lock).

run_audit_auditlog() {
  local account_id="${1:-}"
  local window="${2:-7d}"
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

  local since_iso
  case "$window" in
    24h)
      since_iso="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    30d)
      since_iso="$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
    7d|*)
      window="7d"
      since_iso="$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ;;
  esac

  _aal_stub() {
    local err="$1"
    jq -n --arg ts "$ts" --arg account_id "$account_id" --arg window "$window" \
          --arg since "$since_iso" --arg err "$err" \
      '{ schema: "cfsec.audit-auditlog", schema_version: 1, generated_at: $ts,
         tool: "audit-auditlog", account_id: $account_id, window: $window, since: $since,
         error: $err, total: 0, by_action_type: {}, by_actor: [], top_actor_ips: [],
         sensitive_events: [] }'
  }

  # Paginate (cap 5 pages × 200).
  local all='[]' page=1 st body chunk n
  while (( page <= 5 )); do
    body="$(cf_get "/accounts/${account_id}/audit_logs?since=${since_iso}&per_page=200&page=${page}")"; st="$(cf_last_status)"
    if [[ "$page" == "1" ]]; then
      case "$(api_surface_gate "$st" "$body" '.result|length==0')" in
        forbidden)
          printf '{"error":"audit_logs forbidden","code":"E_API","status":403,"remediation":"token needs Account Audit Logs Read for %s"}\n' "$account_id" >&2
          _aal_stub "forbidden"; return 3 ;;
        error)
          printf '{"error":"audit_logs request failed","code":"E_API","status":%s,"account_id":"%s"}\n' "${st:-0}" "$account_id" >&2
          _aal_stub "api-error"; return 3 ;;
        empty)
          : ;;  # no events in window — emit a clean zero digest below
      esac
    fi
    [[ "$st" =~ ^2 ]] || break
    chunk="$(jq '.result // []' <<<"$body" 2>/dev/null || printf '[]')"
    n="$(jq 'length' <<<"$chunk" 2>/dev/null || printf 0)"
    all="$(jq -n --argjson a "$all" --argjson b "$chunk" '$a + $b' 2>/dev/null || printf '%s' "$all")"
    (( n < 200 )) && break
    page=$((page+1))
  done

  # Normalize each entry to a stable shape, then derive counts + sensitive subset.
  jq -n --arg ts "$ts" --arg account_id "$account_id" --arg window "$window" \
        --arg since "$since_iso" --argjson raw "$all" '
    ($raw | map({
        when: (.when // null),
        action_type: (.action.type // "unknown"),
        result: (.action.result // null),
        actor_email: (.actor.email // null),
        actor_type: (.actor.type // null),
        actor_ip: (.actor.ip // null),
        interface: (.interface // null),
        resource_type: (.resource.type // null)
      })) as $e
    | {
        schema: "cfsec.audit-auditlog", schema_version: 1, generated_at: $ts,
        tool: "audit-auditlog", account_id: $account_id, window: $window, since: $since,
        total: ($e | length),
        by_action_type: ($e | group_by(.action_type)
                            | map({key: .[0].action_type, value: length}) | from_entries),
        by_actor: ($e | map(select(.actor_email != null)) | group_by(.actor_email)
                      | map({email: .[0].actor_email, type: .[0].actor_type, count: length})
                      | sort_by(-.count) | .[0:15]),
        top_actor_ips: ($e | map(.actor_ip) | map(select(. != null)) | group_by(.)
                          | map({ip: .[0], count: length}) | sort_by(-.count) | .[0:10]),
        sensitive_events: ($e | map(select(
              (.action_type | test("token|member|delete|two.?factor|2fa|sso|login|owner|role|account.update"; "i"))
              or (.resource_type | tostring | test("token|member|account"; "i"))
            )) | .[0:50])
      }'
}
