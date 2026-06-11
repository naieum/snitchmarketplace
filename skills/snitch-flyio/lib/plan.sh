# lib/plan.sh — Fly.io org-tier detection and feature gating.
# Tier ordering: personal < hobby < pay-as-you-go < launch < scale < enterprise.
# Cache: ${STATE_DIR}/tier-<org_slug>.txt holds the tier label.

# detect_tier <org_slug> -> echoes one of:
# personal | hobby | pay-as-you-go | launch | scale | enterprise | unknown
detect_tier() {
  local org="$1"
  local cache="${STATE_DIR}/tier-${org}.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body; body="$(fly_run_json orgs show "$org" 2>/dev/null)"
  local rc=$FLYSEC_LAST_RC
  if [[ $rc -ne 0 || -z "$body" ]]; then
    printf 'unknown'
    return 0
  fi
  # Fly's API returns billing tier under various names; try a few.
  local tier
  tier="$(jq -r '
    (.BillingStatus // .billing_status // .billing_tier // .tier // .plan //
     .Plan // empty) | ascii_downcase
  ' <<<"$body" 2>/dev/null | head -n1)"
  case "$tier" in
    personal|hobby|"pay-as-you-go"|payg|launch|scale|enterprise)
      ;;
    *)
      tier="unknown"
      ;;
  esac
  printf '%s' "$tier" > "$cache"
  printf '%s' "$tier"
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    personal)        echo 0 ;;
    hobby)           echo 1 ;;
    pay-as-you-go|payg) echo 2 ;;
    launch)          echo 3 ;;
    scale)           echo 4 ;;
    enterprise)      echo 5 ;;
    *)               echo -1 ;;
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
  local org; org="$(api_pick_org 2>/dev/null)" || { log_warn "$area" "$key" "$msg (org unknown)" "$url"; return 1; }
  local cur; cur="$(detect_tier "$org")"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}
