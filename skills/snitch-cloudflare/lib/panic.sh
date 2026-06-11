# lib/panic.sh — incident response fast-path.
# Mutates Cloudflare. Each subaction prints a one-line consequence banner
# before mutating; the dispatcher in snitch-cloudflare.sh trusts that the user already
# agreed. Every change writes a state record to ${STATE_DIR}/panic-<ts>.json
# so `panic restore` can reverse it.
#
# Exports: run_panic

# _panic_ts — UTC timestamp suitable for filenames.
_panic_ts() {
  date -u +%Y%m%dT%H%M%SZ
}

# _panic_record <area> <prior_json> <set_json> [extra_kv...]
# Writes a JSON record under ${STATE_DIR}/panic-<ts>.json.
_panic_record() {
  local area="$1" prior="$2" set_to="$3"; shift 3
  local ts; ts="$(_panic_ts)"
  local out="${STATE_DIR}/panic-${ts}.json"
  jq -n \
    --arg ts "$ts" \
    --arg area "$area" \
    --argjson prior "$prior" \
    --argjson set "$set_to" \
    --argjson extra "${1:-{\}}" \
    '{ts:$ts, area:$area, prior:$prior, set:$set, extra:$extra}' \
    > "$out"
  printf '%s' "$out"
}

# _panic_banner <line>
_panic_banner() {
  printf '\n!! PANIC ACTION: %s !!\n\n' "$1"
}

# _panic_under_attack — set zone security_level=under_attack.
_panic_under_attack() {
  local zone_id; zone_id="$(api_pick_zone)" || return 3
  _panic_banner "setting security_level=under_attack on zone ${zone_id} — every visitor sees a JS challenge"
  local cur; cur="$(cf_get "/zones/${zone_id}/settings/security_level")" || return 3
  local prior; prior="$(jq -c '.result.value // "medium"' <<<"$cur" 2>/dev/null)"
  cf_patch "/zones/${zone_id}/settings/security_level" '{"value":"under_attack"}' >/dev/null || {
    log_fail "panic" "under-attack" "PATCH security_level failed: $(cf_last_error)"
    return 3
  }
  local rec; rec="$(_panic_record "security_level" "$prior" '"under_attack"')"
  log_ok "panic" "under-attack" "security_level=under_attack (state: ${rec})"
}

# _panic_block_target <target> <value>
# target: ip | ip_range | asn | country
_panic_block_target() {
  local target="$1" value="$2"
  local zone_id; zone_id="$(api_pick_zone)" || return 3
  _panic_banner "blocking ${target}=${value} on zone ${zone_id}"
  local body
  body="$(jq -n --arg t "$target" --arg v "$value" \
    '{mode:"block", configuration:{target:$t, value:$v}, notes:"cloudflare-secure:panic"}')"
  local resp
  resp="$(cf_post "/zones/${zone_id}/firewall/access_rules/rules" "$body")" || {
    log_fail "panic" "block/${target}" "POST access_rules failed: $(cf_last_error)"
    return 3
  }
  local rule_id; rule_id="$(jq -r '.result.id // ""' <<<"$resp")"
  local extra
  extra="$(jq -n --arg id "$rule_id" --arg t "$target" --arg v "$value" \
    '{rule_id:$id, target:$t, value:$v, kind:"access_rule"}')"
  local rec; rec="$(_panic_record "access_rule" "null" "$extra" "$extra")"
  log_ok "panic" "block/${target}" "rule ${rule_id} created for ${value} (state: ${rec})"
}

# _panic_challenge_all — top-priority Custom Rule with managed_challenge.
_panic_challenge_all() {
  local zone_id; zone_id="$(api_pick_zone)" || return 3
  _panic_banner "creating top-priority managed_challenge Custom Rule on zone ${zone_id} — all traffic challenged"
  # Find the http_request_firewall_custom phase ruleset for this zone.
  local rs_resp; rs_resp="$(cf_get "/zones/${zone_id}/rulesets")" || return 3
  local rs_id
  rs_id="$(jq -r '.result[] | select(.phase=="http_request_firewall_custom") | .id' <<<"$rs_resp" | head -n 1)"
  if [[ -z "$rs_id" ]]; then
    # Create the entrypoint ruleset.
    local create
    create="$(cf_post "/zones/${zone_id}/rulesets" \
      '{"name":"default","kind":"zone","phase":"http_request_firewall_custom","rules":[]}')" || {
      log_fail "panic" "challenge-all" "could not create custom firewall ruleset: $(cf_last_error)"
      return 3
    }
    rs_id="$(jq -r '.result.id' <<<"$create")"
  fi
  local rule_body
  rule_body="$(jq -n \
    '{action:"managed_challenge", expression:"(true)", description:"cloudflare-secure:panic-challenge-all", enabled:true}')"
  local resp
  resp="$(cf_post "/zones/${zone_id}/rulesets/${rs_id}/rules" "$rule_body")" || {
    log_fail "panic" "challenge-all" "could not append rule: $(cf_last_error)"
    return 3
  }
  local rule_id
  rule_id="$(jq -r '.result.rules[]? | select(.description=="cloudflare-secure:panic-challenge-all") | .id' <<<"$resp" | tail -n 1)"
  local extra
  extra="$(jq -n --arg rs "$rs_id" --arg id "$rule_id" \
    '{ruleset_id:$rs, rule_id:$id, kind:"custom_rule"}')"
  local rec; rec="$(_panic_record "custom_rule" "null" "$extra" "$extra")"
  log_ok "panic" "challenge-all" "rule ${rule_id} on ruleset ${rs_id} (state: ${rec})"
}

# _panic_restore_one <state-file>
_panic_restore_one() {
  local f="$1"
  local zone_id; zone_id="$(api_pick_zone)" || return 3
  local area kind
  area="$(jq -r '.area' "$f" 2>/dev/null)"
  kind="$(jq -r '.extra.kind // .area' "$f" 2>/dev/null)"
  case "$kind" in
    security_level|area=security_level)
      local prior; prior="$(jq -c '.prior' "$f" 2>/dev/null)"
      cf_patch "/zones/${zone_id}/settings/security_level" \
        "$(jq -n --argjson v "$prior" '{value:$v}')" >/dev/null \
        || { log_fail "panic" "restore" "could not revert security_level"; return 3; }
      log_ok "panic" "restore/security_level" "reverted to ${prior}"
      ;;
    access_rule)
      local id; id="$(jq -r '.extra.rule_id' "$f" 2>/dev/null)"
      cf_delete "/zones/${zone_id}/firewall/access_rules/rules/${id}" >/dev/null \
        || { log_fail "panic" "restore" "could not delete access rule ${id}"; return 3; }
      log_ok "panic" "restore/access_rule" "deleted rule ${id}"
      ;;
    custom_rule)
      local rs rid
      rs="$(jq -r '.extra.ruleset_id' "$f" 2>/dev/null)"
      rid="$(jq -r '.extra.rule_id'    "$f" 2>/dev/null)"
      cf_delete "/zones/${zone_id}/rulesets/${rs}/rules/${rid}" >/dev/null \
        || { log_fail "panic" "restore" "could not delete custom rule ${rid}"; return 3; }
      log_ok "panic" "restore/custom_rule" "deleted rule ${rid} on ruleset ${rs}"
      ;;
    *)
      # Fall back to the area field if extra.kind isn't set.
      case "$area" in
        security_level)
          local prior2; prior2="$(jq -c '.prior' "$f" 2>/dev/null)"
          cf_patch "/zones/${zone_id}/settings/security_level" \
            "$(jq -n --argjson v "$prior2" '{value:$v}')" >/dev/null \
            && log_ok "panic" "restore/security_level" "reverted to ${prior2}"
          ;;
        *)
          log_warn "panic" "restore" "unknown record kind in ${f}"
          ;;
      esac
      ;;
  esac

  # Move processed record out of the way so it isn't replayed.
  mkdir -p "${STATE_DIR}/panic-restored"
  mv "$f" "${STATE_DIR}/panic-restored/" 2>/dev/null || true
}

# _panic_restore — newest-first replay-and-reverse.
_panic_restore() {
  _panic_banner "rolling back every recorded panic action"
  local files
  files="$(ls -1t "${STATE_DIR}"/panic-*.json 2>/dev/null || true)"
  if [[ -z "$files" ]]; then
    log_info "no panic state files to restore"
    return 0
  fi
  local f
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    [[ "$f" == *"/panic-restored/"* ]] && continue
    _panic_restore_one "$f" || true
  done <<<"$files"
  log_ok "panic" "restore" "all recorded panic actions rolled back"
}

# run_panic <action> [args...]
run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    under-attack)
      _panic_under_attack ;;
    block)
      local kind="${1:-}"; shift || true
      local value="${1:-}"; shift || true
      if [[ -z "$kind" || -z "$value" ]]; then
        log_fail "panic" "block" "usage: panic block <ip|asn|country> <value>"
        return 2
      fi
      case "$kind" in
        ip)
          local target="ip"
          [[ "$value" == */* ]] && target="ip_range"
          _panic_block_target "$target" "$value" ;;
        asn)
          [[ "$value" =~ ^AS ]] || value="AS${value}"
          _panic_block_target "asn" "$value" ;;
        country)
          # Honest warning for very-large legitimate-traffic countries.
          case "$value" in
            US|GB|DE|FR|BR|IN|JP|CN)
              log_warn "panic" "block/country" "${value} is a major source of legitimate traffic. Consider managed_challenge instead of block."
              ;;
          esac
          _panic_block_target "country" "$value" ;;
        *)
          log_fail "panic" "block" "unknown block kind: ${kind}"
          return 2 ;;
      esac
      ;;
    challenge-all)
      _panic_challenge_all ;;
    restore)
      _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic <under-attack|block ip|asn|country <v>|challenge-all|restore>"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: ${action}"
      return 2 ;;
  esac
}
