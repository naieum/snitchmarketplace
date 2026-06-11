# lib/health.sh — health checks, failover, load balancing.
# Exposes:
#   health_run — read-only audit: detect single-origin, list existing health checks.
#   health_fix — idempotent: create a Health Check on canonical health path.
#                LB pool creation gated behind CFSEC_HEALTH_LB_CONFIRMED=1.
# Side effects: cf_get/cf_post against /accounts/{id}/healthchecks.

# _health_canonical_paths -> common health-check URI candidates
_health_canonical_paths=( "/healthz" "/health" "/api/health" "/_health" "/status" )

# _health_zone_origins <zone_id> -> emits "<name>\t<type>\t<content>" for A/AAAA/CNAME records
_health_zone_origins() {
  local zone_id="$1"
  local body
  body="$(cf_get "/zones/${zone_id}/dns_records?per_page=1000")" || return 3
  jq -r '.result[]
    | select(.type=="A" or .type=="AAAA" or .type=="CNAME")
    | [.name, .type, .content] | @tsv' <<<"$body" 2>/dev/null
}

# _health_unique_origins <zone_id> -> integer count of unique non-Cloudflare targets
_health_unique_origins() {
  local zone_id="$1"
  local rows
  rows="$(_health_zone_origins "$zone_id")" || { printf '0'; return; }
  printf '%s\n' "$rows" \
    | awk -F'\t' '{print $3}' \
    | grep -v -E '\.cloudflare(access)?\.com$|\.workers\.dev$|\.pages\.dev$' \
    | sort -u | grep -v '^$' | wc -l | tr -d ' '
}

# _health_canonical_hostname <zone_id> -> echoes zone.name
_health_canonical_hostname() {
  local zone_id="$1"
  local body
  body="$(cf_get "/zones/${zone_id}")" || { printf ''; return 3; }
  jq -r '.result.name // empty' <<<"$body" 2>/dev/null
}

# _health_existing_for_zone <account_id> <zone_id> -> emits TSV "<id>\t<name>\t<address>\t<path>"
_health_existing_for_zone() {
  local account_id="$1" zone_id="$2"
  local body
  body="$(cf_get "/accounts/${account_id}/healthchecks")" || return 3
  local zone_host
  zone_host="$(_health_canonical_hostname "$zone_id")"
  [[ -z "$zone_host" ]] && { printf ''; return 0; }
  jq -r --arg host "$zone_host" '
    .result[]?
    | select((.address // "") | endswith($host))
    | [.id, .name, (.address // ""), (.http_config.path // "")] | @tsv' <<<"$body" 2>/dev/null
}

# _health_detect_health_path -> echoes the first existing health path under cwd, or empty
_health_detect_health_path() {
  local p
  for p in "${_health_canonical_paths[@]}"; do
    if grep -RE --include='*.js' --include='*.ts' --include='*.tsx' --include='*.jsx' \
                --include='*.mjs' --include='*.cjs' --include='*.py' --include='*.go' \
                --include='*.rb' --include='*.php' --include='*.java' --include='*.kt' \
                -e "[\"']${p}[\"']" -e "\"path\":[[:space:]]*\"${p}\"" \
                . >/dev/null 2>&1; then
      printf '%s' "$p"
      return 0
    fi
  done
  printf ''
}

# health_run — audit
health_run() {
  log_section "health checks + failover"
  local zone_id account_id
  zone_id="$(api_pick_zone 2>/dev/null)" || {
    log_warn "health" "zone" "Could not pick a zone."
    return 0
  }
  account_id="$(api_pick_account 2>/dev/null)" || {
    log_warn "health" "account" "Could not pick an account."
    return 0
  }

  local origins
  origins="$(_health_unique_origins "$zone_id")"
  if [[ "$origins" -le 1 ]]; then
    log_warn "health" "single-origin" \
      "Single origin detected (${origins} unique non-CF target). Add a standby for failover, even a static maintenance page." \
      "https://developers.cloudflare.com/load-balancing/"
  else
    log_ok "health" "origins" "${origins} unique origin targets detected."
  fi

  local existing
  existing="$(_health_existing_for_zone "$account_id" "$zone_id")"
  local zone_host
  zone_host="$(_health_canonical_hostname "$zone_id")"

  if [[ -z "$existing" ]]; then
    log_warn "health" "no-checks" \
      "No Health Checks cover ${zone_host}. Run: snitch-cloudflare.sh fix health." \
      "https://developers.cloudflare.com/health-checks/"
  else
    local found_canonical=0
    local id name addr path
    while IFS=$'\t' read -r id name addr path; do
      [[ -z "$id" ]] && continue
      log_ok "health" "check/${name}" "Health Check '${name}' covers ${addr}${path}."
      local cp
      for cp in "${_health_canonical_paths[@]}"; do
        if [[ "$path" == "$cp" ]]; then
          found_canonical=1
          break
        fi
      done
    done <<<"$existing"
    if [[ "$found_canonical" -eq 1 ]]; then
      log_ok "health" "canonical-path" "At least one Health Check uses a canonical path."
    else
      log_warn "health" "canonical-path" \
        "Existing Health Checks do not use a canonical path (/healthz, /health, /api/health). Consider standardizing." \
        "https://developers.cloudflare.com/health-checks/"
    fi
  fi
}

# _health_emit_lb_body <account_id> <zone_id> <health_check_id> <origin_address>
# Emits the LB pool creation body for the user to review.
_health_emit_lb_body() {
  local account_id="$1" zone_id="$2" hc_id="$3" origin="$4"
  local zone_host
  zone_host="$(_health_canonical_hostname "$zone_id")"
  cat <<LB_EOF

Load Balancer pricing has a per-DNS-query component. To proceed, set
CFSEC_HEALTH_LB_CONFIRMED=1 and re-run 'snitch-cloudflare.sh fix health'.

API call to create a pool:
  POST /accounts/${account_id}/load_balancers/pools
  {
    "name": "${zone_host}-primary",
    "origins": [
      {"name": "primary", "address": "${origin}", "enabled": true}
    ],
    "monitor": "${hc_id}",
    "enabled": true,
    "minimum_origins": 1
  }

Then a load balancer:
  POST /zones/${zone_id}/load_balancers
  {
    "name": "${zone_host}",
    "default_pools": ["<pool_id_from_above>"],
    "fallback_pool": "<pool_id_from_above>",
    "proxied": true
  }

Pricing: https://developers.cloudflare.com/load-balancing/reference/pricing/
LB_EOF
}

# health_fix — idempotent: ensure a Health Check exists on a canonical health path.
health_fix() {
  local zone_id account_id
  zone_id="$(api_pick_zone 2>/dev/null)" || { log_warn "health" "zone" "Could not pick a zone."; return 1; }
  account_id="$(api_pick_account 2>/dev/null)" || { log_warn "health" "account" "Could not pick an account."; return 1; }

  local zone_host
  zone_host="$(_health_canonical_hostname "$zone_id")"
  if [[ -z "$zone_host" ]]; then
    log_warn "health" "host" "Could not resolve canonical hostname; aborting."
    return 1
  fi

  # Idempotency: if any health check exists for this zone on a canonical path, no-op.
  local existing
  existing="$(_health_existing_for_zone "$account_id" "$zone_id")"
  if [[ -n "$existing" ]]; then
    local path cp
    while IFS=$'\t' read -r _id _name _addr path; do
      for cp in "${_health_canonical_paths[@]}"; do
        if [[ "$path" == "$cp" ]]; then
          log_ok "health" "exists" "Health Check on ${zone_host}${path} already present; no changes."
          return 0
        fi
      done
    done <<<"$existing"
  fi

  # Decide canonical path.
  local hp
  hp="$(_health_detect_health_path)"
  if [[ -z "$hp" ]]; then
    if [[ -n "${CFSEC_HEALTH_PATH:-}" ]]; then
      hp="${CFSEC_HEALTH_PATH}"
      log_info "using CFSEC_HEALTH_PATH=${hp}."
    else
      log_warn "health" "path" \
        "No health endpoint found in source. Set CFSEC_HEALTH_PATH=/healthz (or your path) and re-run 'snitch-cloudflare.sh fix health', or add a /healthz endpoint that returns 200."
      return 1
    fi
  fi

  log_info "creating Health Check for ${zone_host}${hp}..."
  local body
  body="$(jq -n \
    --arg name "${zone_host}-canonical" \
    --arg addr "${zone_host}" \
    --arg path "$hp" \
    '{
      name: $name,
      address: $addr,
      type: "HTTPS",
      check_regions: ["WNAM","ENAM","WEU","EEU"],
      http_config: {
        path: $path,
        port: 443,
        method: "GET",
        expected_codes: "200",
        follow_redirects: false,
        allow_insecure: false
      },
      timeout: 5,
      retries: 2,
      interval: 60,
      consecutive_fails: 2,
      consecutive_successes: 1,
      enabled: true,
      description: "Created by snitch-cloudflare skill."
    }')"

  local resp
  resp="$(cf_post "/accounts/${account_id}/healthchecks" "$body")"
  local rc=$?
  if [[ "$rc" -ne 0 ]]; then
    log_fail "health" "create" "Health Check creation failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 1
  fi
  local hc_id
  hc_id="$(jq -r '.result.id // empty' <<<"$resp")"
  log_ok "health" "create" "Health Check created (${hc_id}) on https://${zone_host}${hp}."

  # LB pool — gated.
  if [[ "${CFSEC_HEALTH_LB_CONFIRMED:-0}" == "1" ]]; then
    log_info "CFSEC_HEALTH_LB_CONFIRMED=1 — proceeding with LB pool + load balancer creation."
    local origin
    origin="$(_health_zone_origins "$zone_id" | awk -F'\t' '$2!="CNAME"{print $3; exit}')"
    [[ -z "$origin" ]] && origin="$zone_host"

    local pool_body
    pool_body="$(jq -n \
      --arg name "${zone_host}-primary" \
      --arg origin "$origin" \
      --arg monitor "$hc_id" \
      '{
        name: $name,
        origins: [{name: "primary", address: $origin, enabled: true}],
        monitor: $monitor,
        enabled: true,
        minimum_origins: 1
      }')"
    local pool_resp
    pool_resp="$(cf_post "/accounts/${account_id}/load_balancers/pools" "$pool_body")"
    if [[ $? -ne 0 ]]; then
      log_fail "health" "lb-pool" "LB pool creation failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
      return 1
    fi
    local pool_id
    pool_id="$(jq -r '.result.id // empty' <<<"$pool_resp")"
    log_ok "health" "lb-pool" "LB pool created (${pool_id})."

    local lb_body
    lb_body="$(jq -n \
      --arg name "$zone_host" \
      --arg pool "$pool_id" \
      '{
        name: $name,
        default_pools: [$pool],
        fallback_pool: $pool,
        proxied: true,
        enabled: true
      }')"
    local lb_resp
    lb_resp="$(cf_post "/zones/${zone_id}/load_balancers" "$lb_body")"
    if [[ $? -ne 0 ]]; then
      log_fail "health" "lb" "Load Balancer creation failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
      return 1
    fi
    log_ok "health" "lb" "Load Balancer created for ${zone_host}."
  else
    _health_emit_lb_body "$account_id" "$zone_id" "$hc_id" "$zone_host"
    log_info "Health Check created. LB pool not created (set CFSEC_HEALTH_LB_CONFIRMED=1 to proceed)."
  fi
}
