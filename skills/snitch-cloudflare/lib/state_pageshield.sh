# lib/state_pageshield.sh — Page Shield zone state as JSON.
# Exports: run_state_pageshield [zone-id]
#
# Reads CLOUDFLARE_API_TOKEN. GETs /zones/{id}/page_shield (settings) and
# /zones/{id}/page_shield/scripts?per_page=500 (detected scripts). Page Shield
# is a Pro+ entitlement; a 403 from either endpoint emits a "locked" payload
# on stdout (not an error).

run_state_pageshield() {
  local zone_id="${1:-}"
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

  local settings_body scripts_body
  local settings_status="" scripts_status=""

  # cf_last_status (file-backed) — $CFSEC_LAST_STATUS set inside body="$(cf_get ...)"
  # does not survive the command-substitution subshell, so the 403 gate below
  # never fired with the old global read.
  settings_body="$(cf_get "/zones/${zone_id}/page_shield")"; settings_status="$(cf_last_status)"
  scripts_body="$(cf_get "/zones/${zone_id}/page_shield/scripts?per_page=500")"; scripts_status="$(cf_last_status)"

  # If either endpoint says 403 (not entitled), surface as locked.
  if [[ "$settings_status" == "403" || "$scripts_status" == "403" ]]; then
    jq -n \
      --arg ts "$ts" \
      --arg zone_id "$zone_id" \
      '{
        schema: "cfsec.state-pageshield",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-pageshield",
        zone_id: $zone_id,
        locked: "pro",
        reason: "Page Shield requires Pro plan or higher",
        enabled: null,
        scripts: []
      }'
    return 0
  fi

  local enabled='null'
  local settings_obj='{}'
  if [[ "$settings_status" =~ ^2 ]]; then
    enabled="$(jq '.result.enabled // null' <<<"$settings_body" 2>/dev/null)" || enabled='null'
    settings_obj="$(jq '.result // {}' <<<"$settings_body" 2>/dev/null)" || settings_obj='{}'
  else
    printf '{"error":"failed to fetch page_shield settings","code":"E_API","status":%s,"remediation":"verify token has Zone Page Shield:Read for %s"}\n' "${settings_status:-0}" "$zone_id" >&2
  fi

  local scripts='[]'
  if [[ "$scripts_status" =~ ^2 ]]; then
    scripts="$(jq '.result // []' <<<"$scripts_body" 2>/dev/null)" || scripts='[]'
  else
    printf '{"error":"failed to fetch page_shield scripts","code":"E_API","status":%s,"remediation":"verify token has Zone Page Shield:Read for %s"}\n' "${scripts_status:-0}" "$zone_id" >&2
  fi

  jq -n \
    --arg ts "$ts" \
    --arg zone_id "$zone_id" \
    --argjson enabled "$enabled" \
    --argjson settings "$settings_obj" \
    --argjson scripts "$scripts" \
    '{
      schema: "cfsec.state-pageshield",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-pageshield",
      zone_id: $zone_id,
      locked: null,
      enabled: $enabled,
      settings: $settings,
      scripts: $scripts
    }'
}
