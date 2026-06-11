# lib/plan.sh — plan-tier detection and feature gating.
# Tier ordering: free < pro < business < enterprise.
# Cache: ${STATE_DIR}/plan-<zone_id>.txt holds the legacy_id.

# detect_plan <zone_id> -> echoes one of: free, pro, business, enterprise, partners_*, unknown
detect_plan() {
  local zone_id="$1"
  local cache="${STATE_DIR}/plan-${zone_id}.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body; body="$(cf_get "/zones/${zone_id}")" || { echo "unknown"; return 0; }
  local pid; pid="$(jq -r '.result.plan.legacy_id // "unknown"' <<<"$body" 2>/dev/null)"
  echo "$pid" > "$cache"
  printf '%s' "$pid"
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    free)             echo 0 ;;
    pro)              echo 1 ;;
    business)         echo 2 ;;
    enterprise)       echo 3 ;;
    partners_free)    echo 0 ;;
    partners_pro)     echo 1 ;;
    partners_business) echo 2 ;;
    partners_enterprise) echo 3 ;;
    *) echo -1 ;;
  esac
}

# tier_at_least <current> <required> -> 0 if current >= required, else 1
tier_at_least() {
  local cur req cr rr
  cur="$1"; req="$2"
  cr=$(tier_rank "$cur"); rr=$(tier_rank "$req")
  [[ "$cr" -ge "$rr" ]]
}

# requires_tier <area> <key> <message> <required_tier> <docs_url>
# If current zone tier meets required, returns 0 (caller proceeds).
# Else logs a [N/A locked] entry and returns 1.
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  local zone_id; zone_id="$(api_pick_zone 2>/dev/null)" || { log_warn "$area" "$key" "$msg (zone unknown)" "$url"; return 1; }
  local cur; cur="$(detect_plan "$zone_id")"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}
