# lib/apply_zone.sh — idempotent zone-level fixes.
# Exposes:
#   apply_zone <area> [args]   — dispatcher for zone-area fixes.
# Areas:
#   ssl | hsts | dnssec | dns-email | aop | headers | rate-limit | all
# Side effects:
#   - Reads current state via cf_get; mutates only when target state differs.
#   - Tags Transform / Custom rules with description prefix `cloudflare-secure:`
#     so re-runs find and update existing rules instead of duplicating.

# _apply_zone_setting <zone_id> <setting> <target_value>
# Idempotent PATCH /zones/{id}/settings/{setting} {"value": <target>}.
_apply_zone_setting() {
  local zone_id="$1" setting="$2" target="$3"
  local body cur
  body="$(cf_get "/zones/${zone_id}/settings/${setting}")" || {
    log_fail "${setting}" "read" "Could not read setting ${setting}. $(cf_last_error)"
    return 3
  }
  cur="$(jq -r '.result.value // empty' <<<"$body" 2>/dev/null)"
  if [[ "$cur" == "$target" ]]; then
    log_ok "${setting}" "apply" "${setting} already '${target}'."
    return 0
  fi
  local payload
  payload="$(jq -n --arg v "$target" '{value:$v}')"
  cf_patch "/zones/${zone_id}/settings/${setting}" "$payload" >/dev/null || {
    log_fail "${setting}" "apply" "PATCH ${setting} failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 3
  }
  log_ok "${setting}" "apply" "${setting} set to '${target}'."
}

# apply_zone_ssl <zone_id>
apply_zone_ssl() {
  local zone_id="$1"
  _apply_zone_setting "$zone_id" "ssl" "strict"
}

# apply_zone_hsts <zone_id>
# Read first; no-op if already strict.
apply_zone_hsts() {
  local zone_id="$1"
  local body cur target
  body="$(cf_get "/zones/${zone_id}/settings/security_header")" || {
    log_fail "hsts" "read" "Could not read security_header."
    return 3
  }
  cur="$(jq -c '.result.value.strict_transport_security // {}' <<<"$body" 2>/dev/null)"
  target='{"enabled":true,"max_age":31536000,"include_subdomains":true,"preload":true,"nosniff":true}'
  # Compare normalized
  local cur_norm tgt_norm
  cur_norm="$(jq -cS '.' <<<"$cur" 2>/dev/null)"
  tgt_norm="$(jq -cS '.' <<<"$target" 2>/dev/null)"
  if [[ "$cur_norm" == "$tgt_norm" ]]; then
    log_ok "hsts" "apply" "HSTS already at target (1y, includeSubDomains, preload, nosniff)."
    return 0
  fi
  local payload
  payload="$(jq -n --argjson hsts "$target" '{value:{strict_transport_security:$hsts}}')"
  cf_patch "/zones/${zone_id}/settings/security_header" "$payload" >/dev/null || {
    log_fail "hsts" "apply" "PATCH security_header failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 3
  }
  log_ok "hsts" "apply" "HSTS set: max_age=31536000, includeSubDomains, preload, nosniff."
}

# apply_zone_dnssec <zone_id>
apply_zone_dnssec() {
  local zone_id="$1"
  local body status
  body="$(cf_get "/zones/${zone_id}/dnssec")" || {
    log_fail "dnssec" "read" "Could not read DNSSEC status."
    return 3
  }
  status="$(jq -r '.result.status // "unknown"' <<<"$body" 2>/dev/null)"
  if [[ "$status" == "active" ]]; then
    log_ok "dnssec" "apply" "DNSSEC already active."
    return 0
  fi
  cf_patch "/zones/${zone_id}/dnssec" '{"status":"active"}' >/dev/null || {
    log_fail "dnssec" "apply" "PATCH dnssec failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 3
  }
  log_ok "dnssec" "apply" "DNSSEC activated. Now add the DS record at the registrar (read /zones/${zone_id}/dnssec for the values)."
}

# apply_zone_dns_email <zone_id>
# Ensures CAA records for letsencrypt.org and pki.goog. Recommends SPF/DMARC.
apply_zone_dns_email() {
  local zone_id="$1"
  local body zone_name
  body="$(cf_get "/zones/${zone_id}")" || {
    log_fail "dns-email" "zone-read" "Could not read zone."
    return 3
  }
  zone_name="$(jq -r '.result.name // empty' <<<"$body" 2>/dev/null)"
  if [[ -z "$zone_name" ]]; then
    log_fail "dns-email" "zone-read" "Could not determine zone name."
    return 3
  fi
  local recs
  recs="$(cf_get "/zones/${zone_id}/dns_records?type=CAA&per_page=100")" || {
    log_fail "dns-email" "caa-read" "Could not list CAA records."
    return 3
  }
  local issuer
  for issuer in "letsencrypt.org" "pki.goog"; do
    local has
    has="$(jq -r --arg n "$zone_name" --arg v "$issuer" \
      '[.result[] | select(.name==$n) | select(.data.value==$v) | select(.data.tag=="issue")] | length' \
      <<<"$recs" 2>/dev/null)"
    if [[ "${has:-0}" -gt 0 ]]; then
      log_ok "dns-email" "caa-${issuer}" "CAA issue ${issuer} already present for ${zone_name}."
      continue
    fi
    local payload
    payload="$(jq -n --arg n "$zone_name" --arg v "$issuer" \
      '{type:"CAA",name:$n,data:{flags:0,tag:"issue",value:$v},ttl:1,comment:"cloudflare-secure:caa"}')"
    cf_post "/zones/${zone_id}/dns_records" "$payload" >/dev/null || {
      log_fail "dns-email" "caa-${issuer}" "POST CAA ${issuer} failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
      continue
    }
    log_ok "dns-email" "caa-${issuer}" "CAA issue ${issuer} added for ${zone_name}."
  done
  log_warn "dns-email" "spf-dmarc" "SPF / DKIM / DMARC are email-domain-specific; run fix email for selector-aware records."
}

# apply_zone_aop <zone_id>
apply_zone_aop() {
  local zone_id="$1"
  _apply_zone_setting "$zone_id" "tls_client_auth" "on"
}

# _ruleset_entrypoint <zone_id> <phase>
# Reads the current ruleset for the phase. Echoes JSON; rc=3 if not found.
_ruleset_entrypoint() {
  local zone_id="$1" phase="$2"
  local body
  body="$(cf_get "/zones/${zone_id}/rulesets/phases/${phase}/entrypoint")" || return 3
  printf '%s\n' "$body"
}

# _put_ruleset_entrypoint <zone_id> <phase> <rules_array_json>
# Replaces the entrypoint ruleset's rules. Idempotent only if caller compared first.
_put_ruleset_entrypoint() {
  local zone_id="$1" phase="$2" rules="$3"
  local payload
  payload="$(jq -n --argjson rules "$rules" '{rules:$rules}')"
  cf_put "/zones/${zone_id}/rulesets/phases/${phase}/entrypoint" "$payload" >/dev/null
}

# apply_zone_headers <zone_id>
# Emits a Transform Rule (http_response_headers_transform phase) with the security header set.
# Description tag: cloudflare-secure:security-headers
apply_zone_headers() {
  local zone_id="$1"
  local phase="http_response_headers_transform"
  local desc_tag="cloudflare-secure:security-headers"
  local target_rule
  target_rule="$(jq -n --arg desc "$desc_tag" '{
    description: $desc,
    expression: "true",
    action: "rewrite",
    enabled: true,
    action_parameters: {
      headers: {
        "Strict-Transport-Security":           {operation:"set", value:"max-age=31536000; includeSubDomains; preload"},
        "X-Content-Type-Options":              {operation:"set", value:"nosniff"},
        "X-Frame-Options":                     {operation:"set", value:"DENY"},
        "Referrer-Policy":                     {operation:"set", value:"strict-origin-when-cross-origin"},
        "Permissions-Policy":                  {operation:"set", value:"geolocation=(), microphone=(), camera=()"},
        "Cross-Origin-Opener-Policy":          {operation:"set", value:"same-origin"},
        "Cross-Origin-Resource-Policy":        {operation:"set", value:"same-site"}
      }
    }
  }')"

  local existing
  existing="$(_ruleset_entrypoint "$zone_id" "$phase" 2>/dev/null || true)"
  if [[ -z "$existing" ]]; then
    # No entrypoint yet — create one with just our rule.
    local rules
    rules="$(jq -n --argjson r "$target_rule" '[$r]')"
    if _put_ruleset_entrypoint "$zone_id" "$phase" "$rules"; then
      log_ok "headers" "apply" "Created ${phase} entrypoint with security headers rule."
      return 0
    fi
    log_fail "headers" "apply" "Could not create ${phase} entrypoint. $(cf_last_error)"
    return 3
  fi

  local cur_rules new_rules existing_rule
  cur_rules="$(jq -c '.result.rules // []' <<<"$existing")"
  existing_rule="$(jq -c --arg d "$desc_tag" '.[] | select(.description==$d)' <<<"$cur_rules" 2>/dev/null | head -n1)"

  if [[ -n "$existing_rule" ]]; then
    # Compare existing rule's action_parameters to target.
    local cur_norm tgt_norm
    cur_norm="$(jq -cS '.action_parameters // {}' <<<"$existing_rule")"
    tgt_norm="$(jq -cS '.action_parameters // {}' <<<"$target_rule")"
    if [[ "$cur_norm" == "$tgt_norm" ]]; then
      log_ok "headers" "apply" "Security headers rule already at target."
      return 0
    fi
    new_rules="$(jq -c --arg d "$desc_tag" --argjson r "$target_rule" \
      '[ .[] | if .description==$d then $r else . end ]' <<<"$cur_rules")"
  else
    new_rules="$(jq -c --argjson r "$target_rule" '. + [$r]' <<<"$cur_rules")"
  fi

  if _put_ruleset_entrypoint "$zone_id" "$phase" "$new_rules"; then
    log_ok "headers" "apply" "Security headers Transform Rule applied (tag: ${desc_tag})."
  else
    log_fail "headers" "apply" "PUT entrypoint failed. $(cf_last_error)"
    return 3
  fi
}

# apply_zone_rate_limit <zone_id>
# Adds a rate limit rule on auth endpoints. Description tag cloudflare-secure:rate-limit-auth.
apply_zone_rate_limit() {
  local zone_id="$1"
  local phase="http_ratelimit"
  local desc_tag="cloudflare-secure:rate-limit-auth"
  local expr='(http.request.method eq "POST") and (http.request.uri.path in {"/login" "/signup"} or starts_with(http.request.uri.path, "/api/auth/"))'
  local target_rule
  target_rule="$(jq -n --arg desc "$desc_tag" --arg e "$expr" '{
    description: $desc,
    expression: $e,
    action: "managed_challenge",
    enabled: true,
    ratelimit: {
      characteristics: ["ip.src", "cf.colo.id"],
      period: 60,
      requests_per_period: 5,
      mitigation_timeout: 60
    }
  }')"

  local existing cur_rules existing_rule new_rules
  existing="$(_ruleset_entrypoint "$zone_id" "$phase" 2>/dev/null || true)"
  if [[ -z "$existing" ]]; then
    local rules
    rules="$(jq -n --argjson r "$target_rule" '[$r]')"
    if _put_ruleset_entrypoint "$zone_id" "$phase" "$rules"; then
      log_ok "rate-limit" "apply" "Created ${phase} entrypoint with auth rate-limit rule."
      return 0
    fi
    log_fail "rate-limit" "apply" "Could not create ${phase} entrypoint. $(cf_last_error)"
    return 3
  fi
  cur_rules="$(jq -c '.result.rules // []' <<<"$existing")"
  existing_rule="$(jq -c --arg d "$desc_tag" '.[] | select(.description==$d)' <<<"$cur_rules" 2>/dev/null | head -n1)"
  if [[ -n "$existing_rule" ]]; then
    local cur_norm tgt_norm
    cur_norm="$(jq -cS '{expression,action,ratelimit}' <<<"$existing_rule")"
    tgt_norm="$(jq -cS '{expression,action,ratelimit}' <<<"$target_rule")"
    if [[ "$cur_norm" == "$tgt_norm" ]]; then
      log_ok "rate-limit" "apply" "Auth rate-limit rule already at target."
      return 0
    fi
    new_rules="$(jq -c --arg d "$desc_tag" --argjson r "$target_rule" \
      '[ .[] | if .description==$d then $r else . end ]' <<<"$cur_rules")"
  else
    new_rules="$(jq -c --argjson r "$target_rule" '. + [$r]' <<<"$cur_rules")"
  fi
  if _put_ruleset_entrypoint "$zone_id" "$phase" "$new_rules"; then
    log_ok "rate-limit" "apply" "Auth rate-limit rule applied (tag: ${desc_tag})."
  else
    log_fail "rate-limit" "apply" "PUT entrypoint failed. $(cf_last_error)"
    return 3
  fi
}

# apply_zone <area> [args] — dispatcher.
apply_zone() {
  local area="${1:-}"
  shift || true
  local zone_id
  zone_id="$(api_pick_zone)" || {
    log_fail "${area:-zone}" "pick" "No zone selected."
    return 3
  }
  case "$area" in
    ssl)        apply_zone_ssl "$zone_id" ;;
    hsts)       apply_zone_hsts "$zone_id" ;;
    dnssec)     apply_zone_dnssec "$zone_id" ;;
    dns-email)  apply_zone_dns_email "$zone_id" ;;
    aop)        apply_zone_aop "$zone_id" ;;
    headers)    apply_zone_headers "$zone_id" ;;
    rate-limit) apply_zone_rate_limit "$zone_id" ;;
    all)
      apply_zone_ssl "$zone_id"
      apply_zone_hsts "$zone_id"
      apply_zone_dnssec "$zone_id"
      apply_zone_dns_email "$zone_id"
      apply_zone_aop "$zone_id"
      apply_zone_headers "$zone_id"
      apply_zone_rate_limit "$zone_id"
      ;;
    *)
      log_fail "apply" "area" "Unknown apply_zone area: '${area}'. Valid: ssl|hsts|dnssec|dns-email|aop|headers|rate-limit|all."
      return 2
      ;;
  esac
}
