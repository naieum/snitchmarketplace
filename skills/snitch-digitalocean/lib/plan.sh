# lib/plan.sh — DigitalOcean has no plan-tier system per se, but this lib
# distinguishes personal accounts vs team accounts so locked-feature output is
# honest. (E.g., audit logs and team-level access are team-only.)
#
# Tier ordering: personal < team.

# detect_account_type — echoes "personal" or "team" or "unknown".
detect_account_type() {
  local cache="${STATE_DIR}/account-type.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body type
  body="$(do_get /account 2>/dev/null)" || { echo "unknown"; return 0; }
  type="$(jq -r '.account.team.name // empty' <<<"$body" 2>/dev/null)"
  if [[ -n "$type" ]]; then
    echo "team" > "$cache"
    printf 'team'
  else
    echo "personal" > "$cache"
    printf 'personal'
  fi
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    personal) echo 0 ;;
    team)     echo 1 ;;
    *)        echo -1 ;;
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
# Returns 0 if current account meets required, else logs locked + returns 1.
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  local cur; cur="$(detect_account_type)"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}
