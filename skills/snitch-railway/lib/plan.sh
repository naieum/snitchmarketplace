# lib/plan.sh — plan-tier detection and feature gating.
# Tier ordering: trial < hobby < pro < enterprise.
# Detected via GraphQL `me` query. Cache: ${STATE_DIR}/plan.txt.

# detect_plan -> echoes one of: trial, hobby, pro, enterprise, unknown
detect_plan() {
  local cache="${STATE_DIR}/plan.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body; body="$(rw_gql 'query { me { plan } }' '{}' 2>/dev/null)" || { echo "unknown"; return 0; }
  local plan
  plan="$(jq -r '.data.me.plan // empty' <<<"$body" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  if [[ -z "$plan" ]]; then
    echo "unknown" > "$cache"
    printf 'unknown'
    return 0
  fi
  printf '%s' "$plan" > "$cache"
  printf '%s' "$plan"
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    trial)      echo 0 ;;
    hobby)      echo 1 ;;
    pro)        echo 2 ;;
    enterprise) echo 3 ;;
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
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  local cur; cur="$(detect_plan)"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}
