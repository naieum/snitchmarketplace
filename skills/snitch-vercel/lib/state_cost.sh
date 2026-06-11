# lib/state_cost.sh — usage signals (function invocations, bandwidth, image opt, KV).
# Exports: run_state_cost [team-id] [window]
#   window ∈ 24h | 7d (default) | 30d
# Vercel surfaces usage at /v1/usage and /v1/teams/<id>/usage; field names vary by plan.

run_state_cost() {
  local team_id="${1:-}" window="${2:-7d}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$team_id" ]]; then
    team_id="$(vercel_pick_team 2>/dev/null || true)"
  fi

  local seconds_back
  case "$window" in
    24h) seconds_back=86400 ;;
    7d)  seconds_back=604800 ;;
    30d) seconds_back=2592000 ;;
    *)
      printf '{"error":"unknown window","code":"E_USAGE","got":"%s","valid":["24h","7d","30d"]}\n' "$window" >&2
      return 2 ;;
  esac
  local now since
  now=$(date +%s)
  since=$(( (now - seconds_back) * 1000 ))
  local until=$((now * 1000))

  local path
  if [[ -n "$team_id" ]]; then
    path="/v1/teams/${team_id}/usage?from=${since}&to=${until}"
  else
    path="/v1/usage?from=${since}&to=${until}"
  fi
  local body; body="$(vrc_get "$path")" || body='{}'

  # Raw usage object varies; surface as-is plus a small derived summary.
  jq -n --arg ts "$ts" --arg team_id "$team_id" --arg window "$window" \
    --argjson usage "$body" \
    '{
      schema: "vrcsec.state-cost",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-cost",
      team_id: $team_id,
      window: $window,
      usage: $usage,
      hint: "Vercel usage shapes vary by plan tier. Use the raw object plus references/14-cost-and-budgets.md to interpret."
    }'
}
