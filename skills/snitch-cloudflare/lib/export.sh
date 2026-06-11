# lib/export.sh — read-only JSON snapshot of Cloudflare config.
# Captures zone settings (loop common keys), all rulesets, DNS records, Access
# apps, Tunnels, account members, token metadata only (no secrets, no DNSSEC
# private material). Stable, versioned schema (schema_version: 1). Output goes
# to ./cloudflare-export-<account>-<zone>-<ts>.json in cwd.
#
# Exports: run_export

# _export_zone_settings <zone_id>
# Loops the common settings keys and merges into one JSON object.
_export_zone_settings() {
  local zone_id="$1"
  local keys=(
    ssl always_use_https min_tls_version tls_1_3 automatic_https_rewrites
    opportunistic_encryption security_header browser_check security_level
    challenge_ttl brotli http3 0rtt websockets ipv6 pseudo_ipv4
    development_mode email_obfuscation server_side_exclude hotlink_protection
    cache_level always_online polish webp mirage rocket_loader
  )
  local out='{}'
  local k body val
  for k in "${keys[@]}"; do
    body="$(cf_get "/zones/${zone_id}/settings/${k}" 2>/dev/null)" || continue
    val="$(jq -c '.result // null' <<<"$body" 2>/dev/null)"
    [[ -z "$val" || "$val" == "null" ]] && continue
    out="$(jq --arg k "$k" --argjson v "$val" '. + {($k): $v}' <<<"$out")"
  done
  printf '%s' "$out"
}

# _export_token_metadata
# Lists user tokens but strips any value/secret fields.
_export_token_metadata() {
  local body
  body="$(cf_get /user/tokens 2>/dev/null)" || { printf '[]'; return; }
  jq '[.result[]? | {id, name, status, issued_on, last_used_on, expires_on, not_before, policies}]' \
    <<<"$body" 2>/dev/null || printf '[]'
}

# run_export
run_export() {
  log_section "export"
  api_check_auth_env || return $?
  auth_verify || return $?
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local account_id zone_id zone_name
  account_id="$(api_pick_account 2>/dev/null || printf 'unknown')"
  zone_id="$(api_pick_zone 2>/dev/null || printf 'unknown')"
  if [[ "$zone_id" != "unknown" ]]; then
    zone_name="$(cf_get "/zones/${zone_id}" 2>/dev/null | jq -r '.result.name // ""' 2>/dev/null)"
  fi

  log_info "snapshotting account=${account_id} zone=${zone_id}"

  local out_file="./cloudflare-export-${account_id}-${zone_id}-${ts}.json"

  local zone_settings rulesets dns_records access_apps tunnels members tokens
  zone_settings="$(_export_zone_settings "$zone_id")"
  rulesets="$(cf_get "/zones/${zone_id}/rulesets" 2>/dev/null | jq '.result // []' 2>/dev/null || printf '[]')"
  # Strip any private DNSSEC material defensively, even though the records API
  # shouldn't return it.
  dns_records="$(cf_get "/zones/${zone_id}/dns_records?per_page=500" 2>/dev/null \
    | jq '[.result[]? | del(.meta.private_key, .data.private_key)]' 2>/dev/null || printf '[]')"
  access_apps="$(cf_get "/accounts/${account_id}/access/apps" 2>/dev/null | jq '.result // []' 2>/dev/null || printf '[]')"
  tunnels="$(cf_get "/accounts/${account_id}/cfd_tunnel" 2>/dev/null | jq '.result // []' 2>/dev/null || printf '[]')"
  members="$(cf_get "/accounts/${account_id}/members" 2>/dev/null | jq '.result // []' 2>/dev/null || printf '[]')"
  tokens="$(_export_token_metadata)"

  jq -n \
    --arg sv "1" \
    --arg ts "$ts" \
    --arg account "$account_id" \
    --arg zone_id "$zone_id" \
    --arg zone_name "${zone_name:-}" \
    --argjson zone_settings "$zone_settings" \
    --argjson rulesets "$rulesets" \
    --argjson dns_records "$dns_records" \
    --argjson access_apps "$access_apps" \
    --argjson tunnels "$tunnels" \
    --argjson members "$members" \
    --argjson tokens "$tokens" \
    '{
      schema_version: ($sv|tonumber),
      generated_at: $ts,
      account_id: $account,
      zone_id: $zone_id,
      zone_name: $zone_name,
      zone_settings: $zone_settings,
      rulesets: $rulesets,
      dns_records: $dns_records,
      access_apps: $access_apps,
      tunnels: $tunnels,
      members: $members,
      tokens_metadata: $tokens
    }' > "$out_file"

  log_ok "export" "snapshot" "wrote ${out_file}"
}
