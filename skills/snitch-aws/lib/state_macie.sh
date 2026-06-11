# lib/state_macie.sh — Macie 2 status + classification jobs.
# Exports: run_state_macie [slice]
#   slice ∈ digest (default) | full

run_state_macie() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local session jobs
  session="$(aws_run_json macie2 get-macie-session 2>/dev/null)"
  jobs="$(aws_run_json macie2 list-classification-jobs --max-results 50 2>/dev/null | jq '.items // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-macie.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson session "$session" --argjson jobs "$jobs" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-macie", slice: $slice,
      account_id: $account, region: $region,
      enabled: ($session.status // "DISABLED") == "ENABLED",
      session: $session,
      classification_jobs_count: ($jobs | length),
      classification_jobs: (if $slice == "full" then $jobs else null end),
      hint: "for full data, run: state macie full"
    }'
}
