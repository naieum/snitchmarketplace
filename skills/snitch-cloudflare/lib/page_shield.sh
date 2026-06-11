# lib/page_shield.sh — Page Shield audit + report-only CSP rollout.
# Exposes:
#   page_shield_run       — read-only; gated by Pro+. Surfaces unauthorized scripts.
#   page_shield_fix       — enables Page Shield, deploys a CSP-Report-Only Transform Rule.
# Notes:
#   - Page Shield is Pro+; gated via requires_tier.
#   - Enforcing CSP is NOT auto-flipped; only Report-Only is deployed. The skill flags the 24h soak.

# _page_shield_zone_run <zone_id>
_page_shield_zone_run() {
  local zid="$1"
  log_subsection "page-shield: zone ${zid}"

  local body
  body="$(cf_get "/zones/${zid}/page_shield")" || {
    log_warn "page-shield" "settings:${zid}" "Could not read Page Shield settings. $(cf_last_error)" "https://developers.cloudflare.com/page-shield/"
    return 0
  }
  local enabled
  enabled="$(jq -r '.result.enabled // false' <<<"$body")"
  if [[ "$enabled" == "true" ]]; then
    log_ok "page-shield" "enabled:${zid}" "Page Shield is enabled."
  else
    log_warn "page-shield" "enabled:${zid}" "Page Shield is disabled. Run page_shield_fix to enable." "https://developers.cloudflare.com/page-shield/"
  fi

  local scripts
  scripts="$(cf_get "/zones/${zid}/page_shield/scripts?per_page=100")" || {
    log_warn "page-shield" "scripts:${zid}" "Could not list Page Shield scripts (Page Shield may not be enabled yet)."
    return 0
  }
  local count
  count="$(jq -r '.result | length' <<<"$scripts")"
  if [[ -z "$count" || "$count" == "null" ]]; then count=0; fi
  log_ok "page-shield" "script-count:${zid}" "${count} third-party script(s) observed."

  if [[ "$count" -gt 0 ]]; then
    local urow
    while IFS= read -r urow; do
      [[ -z "$urow" ]] && continue
      local url status host
      url="$(jq -r '.url // ""' <<<"$urow")"
      status="$(jq -r '.status // "unknown"' <<<"$urow")"
      host="$(jq -r '.host // ""' <<<"$urow")"
      if [[ "$status" == "active" ]]; then
        log_warn "page-shield" "script:${host}" "Third-party script: ${url} (status=${status}). Verify it is authorized." "https://developers.cloudflare.com/page-shield/"
      else
        log_info "  script: ${url} status=${status}"
      fi
    done < <(jq -c '.result[]?' <<<"$scripts" 2>/dev/null)
  fi
}

page_shield_run() {
  log_section "page shield"
  local zid
  zid="$(api_pick_zone 2>/dev/null)"
  if [[ -z "$zid" ]]; then
    log_warn "page-shield" "zone" "Could not pick a zone. Set CFSEC_ZONE_ID."
    return 0
  fi
  requires_tier "page-shield" "enable" "Page Shield needs Pro+" "pro" "https://developers.cloudflare.com/page-shield/" || return 0
  _page_shield_zone_run "$zid"
}

# _page_shield_enable <zone_id> -> idempotent enable.
_page_shield_enable() {
  local zid="$1"
  local cur
  cur="$(cf_get "/zones/${zid}/page_shield")" || cur=""
  local was; was="$(jq -r '.result.enabled // false' <<<"$cur" 2>/dev/null)"
  local body
  body=$(jq -nc '{enabled:true, use_cloudflare_reporting_endpoint:true}')
  if [[ "$was" == "true" ]]; then
    # Still PUT to ensure use_cloudflare_reporting_endpoint=true, idempotent.
    cf_put "/zones/${zid}/page_shield" "$body" >/dev/null \
      && log_ok "page-shield" "enable:${zid}" "Page Shield was already enabled; ensured CF reporting endpoint." \
      || log_fail "page-shield" "enable:${zid}" "Failed to update Page Shield. $(cf_last_error)"
    return 0
  fi
  cf_put "/zones/${zid}/page_shield" "$body" >/dev/null \
    && log_ok "page-shield" "enable:${zid}" "Page Shield enabled (use_cloudflare_reporting_endpoint=true)." \
    || log_fail "page-shield" "enable:${zid}" "Failed to enable Page Shield. $(cf_last_error)"
}

# _page_shield_deploy_csp_report_only <zone_id> -> idempotent Transform Rule for CSP-Report-Only.
# Tag: cloudflare-secure:page-shield-csp-rep-only
_page_shield_deploy_csp_report_only() {
  local zid="$1"
  local desc='cloudflare-secure:page-shield-csp-rep-only'

  # Find the http_response_headers_transform ruleset for this zone.
  local rs_body
  rs_body="$(cf_get "/zones/${zid}/rulesets")" || {
    log_fail "page-shield" "csp-ro:${zid}" "Could not list rulesets. $(cf_last_error)"
    return 3
  }
  local rs_id
  rs_id="$(jq -r '.result[]? | select(.phase=="http_response_headers_transform" and .kind=="zone") | .id' <<<"$rs_body" | head -n1)"

  if [[ -z "$rs_id" ]]; then
    # Create the zone phase entrypoint.
    local create
    create=$(jq -nc '{name:"default", kind:"zone", phase:"http_response_headers_transform", rules:[]}')
    rs_body="$(cf_post "/zones/${zid}/rulesets" "$create")" || {
      log_fail "page-shield" "csp-ro:${zid}" "Failed to create response-headers ruleset. $(cf_last_error)"
      return 3
    }
    rs_id="$(jq -r '.result.id' <<<"$rs_body")"
  fi

  # Read existing rules; idempotency on description tag.
  local rs_full
  rs_full="$(cf_get "/zones/${zid}/rulesets/${rs_id}")" || {
    log_fail "page-shield" "csp-ro:${zid}" "Could not read ruleset ${rs_id}."
    return 3
  }
  if jq -e --arg d "$desc" '.result.rules[]? | select(.description == $d)' <<<"$rs_full" >/dev/null 2>&1; then
    log_ok "page-shield" "csp-ro:${zid}" "CSP-Report-Only Transform Rule already present (tag '${desc}'). No-op."
    return 0
  fi

  # Define a permissive starter CSP-Report-Only. Production CSP must be tuned by the user from observed reports.
  local csp="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; img-src 'self' data: https:; connect-src 'self' https:; frame-ancestors 'none'; report-uri /cdn-cgi/script_monitor/report"

  local rule
  rule=$(jq -nc \
    --arg desc "$desc" \
    --arg csp "$csp" \
    '{
      action: "rewrite",
      action_parameters: {
        headers: {
          "Content-Security-Policy-Report-Only": {
            operation: "set",
            value: $csp
          }
        }
      },
      expression: "true",
      description: $desc,
      enabled: true
    }')

  local rc
  cf_post "/zones/${zid}/rulesets/${rs_id}/rules" "$rule" >/dev/null
  rc=$?
  if [[ "$rc" -eq 0 ]]; then
    log_ok "page-shield" "csp-ro:${zid}" "Deployed CSP-Report-Only Transform Rule (description=${desc})."
  else
    log_fail "page-shield" "csp-ro:${zid}" "Failed to deploy CSP-RO rule. $(cf_last_error)"
    return 3
  fi
  log_warn "page-shield" "csp-soak:${zid}" "CSP is REPORT-ONLY. Soak for >=24h, review reports at /cdn-cgi/script_monitor/report, then flip to enforcing manually." "https://developers.cloudflare.com/page-shield/policies/"
}

page_shield_fix() {
  log_section "page-shield fix"
  local zid
  zid="$(api_pick_zone 2>/dev/null)"
  if [[ -z "$zid" ]]; then
    log_fail "page-shield" "zone" "Could not pick a zone. Set CFSEC_ZONE_ID."
    return 2
  fi
  requires_tier "page-shield" "fix" "Page Shield fix needs Pro+" "pro" "https://developers.cloudflare.com/page-shield/" || return 0
  _page_shield_enable "$zid"
  _page_shield_deploy_csp_report_only "$zid"
}
