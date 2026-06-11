# lib/apply_log_drains.sh — recommend log-drain destinations (Pro+).
# Read-first; if no drain exists, surface the dashboard URL + an example payload to POST.
# Does not create drains automatically (destination credentials must come from the user).

apply_log_drains() {
  local team_id="${1:-}"
  if [[ -z "$team_id" ]]; then
    team_id="$(vercel_pick_team 2>/dev/null || true)"
  fi
  if [[ -z "$team_id" ]]; then
    log_warn "log-drains" "pick" "No team selected. Set VRCSEC_TEAM_ID to enable log-drain audit."
    return 0
  fi

  log_section "log-drains apply (team: ${team_id})"

  if ! requires_tier "log-drains" "tier" "Log drains require Pro or higher." "pro" "https://vercel.com/docs/observability/log-drains"; then
    return 0
  fi

  local body; body="$(vrc_get "/v1/integrations/log-drains")" || body='{"drains":[]}'
  local count; count="$(jq -r '(.drains // []) | length' <<<"$body" 2>/dev/null)"
  if [[ "${count:-0}" -gt 0 ]]; then
    log_ok "log-drains" "exists" "${count} log-drain destination(s) configured."
    jq -r '(.drains // [])[] | "  - \(.name // .id)  url=\(.url)  env=\(.environment // "all")"' <<<"$body" || true
    return 0
  fi

  log_warn "log-drains" "missing" "No log-drain destinations configured. Send Vercel logs to a SIEM (Datadog, Better Stack, Axiom, Datadog, S3, etc.) for retention + alerting."
  printf '\n=== EXAMPLE: create a log drain ===\n'
  printf 'curl -X POST "%s/v1/integrations/log-drains" \\\n' "${VRCSEC_API_BASE}"
  printf '  -H "Authorization: Bearer $VERCEL_TOKEN" \\\n'
  printf '  -H "Content-Type: application/json" \\\n'
  printf '  --data %s\n' "'{
    \"name\": \"siem-prod\",
    \"url\": \"https://siem.example.com/vercel\",
    \"deliveryFormat\": \"json\",
    \"sources\": [\"build\", \"static\", \"lambda\", \"edge\", \"external\"],
    \"environment\": \"production\"
  }'"
  printf '=== END ===\n'

  return 0
}
