# lib/state_zone.sh — zone state, digest by default + slice on request.
# Exports: run_state_zone [zone-id] [slice]
#   slice ∈ digest (default) | dns | rulesets | firewall | full
#
# Digest mode emits the small high-signal summary the agent needs 90% of the
# time. Slices emit one section in full. Full emits everything (heaviest).
#
# Reads CLOUDFLARE_API_TOKEN. Per-call API errors → stderr JSON; partial
# data still emits on stdout.

run_state_zone() {
  local zone_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  if [[ -z "$zone_id" ]]; then
    zone_id="$(api_pick_zone)" || {
      printf '{"error":"could not resolve zone id","code":"E_ZONE","remediation":"set CFSEC_ZONE_ID or pass zone-id as the first argument"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_zone_digest "$zone_id" "$ts" ;;
    dns)    _state_zone_dns      "$zone_id" "$ts" ;;
    rulesets) _state_zone_rulesets "$zone_id" "$ts" ;;
    firewall) _state_zone_firewall "$zone_id" "$ts" ;;
    full)   _state_zone_full     "$zone_id" "$ts" ;;
    *)
      printf '{"error":"unknown state zone slice","code":"E_USAGE","got":"%s","valid":["digest","dns","rulesets","firewall","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

# --- helpers ---

_szz_zone_meta() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}")" || {
    printf '{"error":"failed to fetch zone meta","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '{}'
    return
  }
  jq '{
    id: (.result.id // null),
    name: (.result.name // null),
    status: (.result.status // null),
    paused: (.result.paused // null),
    plan_tier: (.result.plan.legacy_id // .result.plan.name // null),
    account_id: (.result.account.id // null),
    account_name: (.result.account.name // null),
    name_servers: (.result.name_servers // []),
    original_name_servers: (.result.original_name_servers // [])
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_szz_settings_flat() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/settings")" || {
    printf '{"error":"failed to fetch zone settings","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '{}'
    return
  }
  jq 'reduce (.result // [])[] as $s ({}; .[$s.id] = $s.value)' <<<"$body" 2>/dev/null || printf '{}'
}

_szz_dnssec() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/dnssec")" || {
    printf '{"error":"failed to fetch dnssec","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '{}'
    return
  }
  jq '.result // {}' <<<"$body" 2>/dev/null || printf '{}'
}

_szz_ssl_verification() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/ssl/verification")" || {
    printf '{"error":"failed to fetch ssl verification","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '[]'
    return
  }
  jq '.result // []' <<<"$body" 2>/dev/null || printf '[]'
}

# Fetches DNS records summary (count + types breakdown + proxy counts + 10-record sample).
_szz_dns_summary() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/dns_records?per_page=500")" || {
    printf '{"error":"failed to fetch dns records","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '{}'
    return
  }
  jq '{
    total: ((.result // []) | length),
    proxied: ((.result // []) | map(select(.proxied==true)) | length),
    dns_only: ((.result // []) | map(select(.proxied==false)) | length),
    types: ((.result // []) | group_by(.type) | map({key: .[0].type, value: length}) | from_entries),
    sample: ((.result // [])[:10] | map({type, name, content, proxied}))
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_szz_dns_full() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/dns_records?per_page=500")" || {
    printf '{"error":"failed to fetch dns records","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | {type, name, content, proxied, ttl, comment}]' <<<"$body" 2>/dev/null || printf '[]'
}

_szz_rulesets_summary() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/rulesets")" || {
    printf '{"error":"failed to fetch rulesets","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '[]'
    return
  }
  jq '[(.result // [])[] | {name, kind, phase, version, description}]' <<<"$body" 2>/dev/null || printf '[]'
}

_szz_rulesets_full() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/rulesets")" || {
    printf '{"error":"failed to fetch rulesets","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '[]'
    return
  }
  jq '.result // []' <<<"$body" 2>/dev/null || printf '[]'
}

_szz_firewall_summary() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/firewall/access_rules/rules?per_page=200")" || {
    printf '{"error":"failed to fetch firewall access rules","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '{}'
    return
  }
  jq '{
    total: ((.result // []) | length),
    by_mode: ((.result // []) | group_by(.mode) | map({key: .[0].mode, value: length}) | from_entries),
    by_target: ((.result // []) | group_by(.configuration.target) | map({key: .[0].configuration.target, value: length}) | from_entries)
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_szz_firewall_full() {
  local zone_id="$1"
  local body; body="$(cf_get "/zones/${zone_id}/firewall/access_rules/rules?per_page=200")" || {
    printf '{"error":"failed to fetch firewall access rules","code":"E_API","status":%s,"zone_id":"%s"}\n' "${CFSEC_LAST_STATUS:-0}" "$zone_id" >&2
    printf '[]'
    return
  }
  jq '.result // []' <<<"$body" 2>/dev/null || printf '[]'
}

# --- emit functions ---

_state_zone_digest() {
  local zone_id="$1" ts="$2"
  local zone settings dnssec ssl_v dns_sum rs_sum fw_sum
  zone="$(_szz_zone_meta "$zone_id")"
  settings="$(_szz_settings_flat "$zone_id")"
  dnssec="$(_szz_dnssec "$zone_id")"
  ssl_v="$(_szz_ssl_verification "$zone_id")"
  dns_sum="$(_szz_dns_summary "$zone_id")"
  rs_sum="$(_szz_rulesets_summary "$zone_id")"
  fw_sum="$(_szz_firewall_summary "$zone_id")"

  jq -n \
    --arg ts "$ts" --arg zone_id "$zone_id" \
    --argjson zone "$zone" \
    --argjson settings "$settings" \
    --argjson dnssec "$dnssec" \
    --argjson ssl_verification "$ssl_v" \
    --argjson dns_summary "$dns_sum" \
    --argjson rulesets_summary "$rs_sum" \
    --argjson firewall_summary "$fw_sum" \
    '{
      schema: "cfsec.state-zone.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-zone",
      slice: "digest",
      zone_id: $zone_id,
      zone: $zone,
      settings: $settings,
      dnssec: $dnssec,
      ssl_verification: $ssl_verification,
      dns_summary: $dns_summary,
      rulesets_summary: $rulesets_summary,
      firewall_summary: $firewall_summary,
      hint: "for full data, run: state zone <zone-id> [dns|rulesets|firewall|full]"
    }'
}

_state_zone_dns() {
  local zone_id="$1" ts="$2"
  local zone dns
  zone="$(_szz_zone_meta "$zone_id")"
  dns="$(_szz_dns_full "$zone_id")"
  jq -n \
    --arg ts "$ts" --arg zone_id "$zone_id" \
    --argjson zone "$zone" \
    --argjson dns_records "$dns" \
    '{ schema: "cfsec.state-zone.dns", schema_version: 1, generated_at: $ts,
       tool: "state-zone", slice: "dns", zone_id: $zone_id,
       zone: $zone, dns_records: $dns_records }'
}

_state_zone_rulesets() {
  local zone_id="$1" ts="$2"
  local zone rs
  zone="$(_szz_zone_meta "$zone_id")"
  rs="$(_szz_rulesets_full "$zone_id")"
  jq -n \
    --arg ts "$ts" --arg zone_id "$zone_id" \
    --argjson zone "$zone" \
    --argjson rulesets "$rs" \
    '{ schema: "cfsec.state-zone.rulesets", schema_version: 1, generated_at: $ts,
       tool: "state-zone", slice: "rulesets", zone_id: $zone_id,
       zone: $zone, rulesets: $rulesets }'
}

_state_zone_firewall() {
  local zone_id="$1" ts="$2"
  local zone fw
  zone="$(_szz_zone_meta "$zone_id")"
  fw="$(_szz_firewall_full "$zone_id")"
  jq -n \
    --arg ts "$ts" --arg zone_id "$zone_id" \
    --argjson zone "$zone" \
    --argjson firewall_access_rules "$fw" \
    '{ schema: "cfsec.state-zone.firewall", schema_version: 1, generated_at: $ts,
       tool: "state-zone", slice: "firewall", zone_id: $zone_id,
       zone: $zone, firewall_access_rules: $firewall_access_rules }'
}

_state_zone_full() {
  local zone_id="$1" ts="$2"
  local zone settings dnssec dns rs fw ssl_v
  zone="$(_szz_zone_meta "$zone_id")"
  settings="$(_szz_settings_flat "$zone_id")"
  dnssec="$(_szz_dnssec "$zone_id")"
  dns="$(_szz_dns_full "$zone_id")"
  rs="$(_szz_rulesets_full "$zone_id")"
  fw="$(_szz_firewall_full "$zone_id")"
  ssl_v="$(_szz_ssl_verification "$zone_id")"

  jq -n \
    --arg ts "$ts" --arg zone_id "$zone_id" \
    --argjson zone "$zone" \
    --argjson settings "$settings" \
    --argjson dnssec "$dnssec" \
    --argjson dns_records "$dns" \
    --argjson rulesets "$rs" \
    --argjson firewall_access_rules "$fw" \
    --argjson ssl_verification "$ssl_v" \
    '{ schema: "cfsec.state-zone.full", schema_version: 1, generated_at: $ts,
       tool: "state-zone", slice: "full", zone_id: $zone_id,
       zone: $zone, settings: $settings, dnssec: $dnssec,
       dns_records: $dns_records, rulesets: $rulesets,
       firewall_access_rules: $firewall_access_rules,
       ssl_verification: $ssl_verification }'
}
