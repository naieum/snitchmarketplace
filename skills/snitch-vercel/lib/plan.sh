# lib/plan.sh — Vercel plan-tier detection and feature gating.
# Tier ordering: hobby < pro < enterprise.
# Cache: ${STATE_DIR}/plan-<team_or_user_id>.txt holds the lowercase tier.

# detect_plan [team_id] -> echoes one of: hobby, pro, enterprise, unknown
detect_plan() {
  local team_id="${1:-}"
  if [[ -z "$team_id" ]]; then
    team_id="$(vercel_pick_team 2>/dev/null || true)"
  fi
  local cache key body tier
  if [[ -n "$team_id" ]]; then
    key="${team_id}"
    cache="${STATE_DIR}/plan-${key}.txt"
    if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
      cat "$cache"; return 0
    fi
    body="$(vrc_get "/v2/teams/${team_id}")" || { echo "unknown"; return 0; }
    tier="$(jq -r '.billing.plan // .plan // "unknown"' <<<"$body" 2>/dev/null)"
  else
    cache="${STATE_DIR}/plan-user.txt"
    if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
      cat "$cache"; return 0
    fi
    body="$(vrc_get "/v2/user")" || { echo "unknown"; return 0; }
    tier="$(jq -r '.user.billing.plan // .user.plan // "hobby"' <<<"$body" 2>/dev/null)"
  fi
  # Normalize known synonyms.
  case "$tier" in
    hobby|free|null|"") tier="hobby" ;;
    pro|premium)        tier="pro" ;;
    enterprise|ent)     tier="enterprise" ;;
    *)                  tier="$(printf '%s' "$tier" | tr '[:upper:]' '[:lower:]')" ;;
  esac
  printf '%s' "$tier" > "$cache" 2>/dev/null || true
  printf '%s' "$tier"
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    hobby|free)  echo 0 ;;
    pro|premium) echo 1 ;;
    enterprise)  echo 2 ;;
    *)           echo -1 ;;
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
# Returns 0 if current tier meets required (caller proceeds), 1 if locked.
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  local team_id; team_id="$(vercel_pick_team 2>/dev/null || true)"
  local cur; cur="$(detect_plan "$team_id")"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}
