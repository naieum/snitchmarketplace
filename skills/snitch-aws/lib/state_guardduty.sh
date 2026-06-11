# lib/state_guardduty.sh — GuardDuty detectors + protections.
# Exports: run_state_guardduty [slice]
#   slice ∈ digest (default) | full

run_state_guardduty() {
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

  local detectors detail='[]'
  detectors="$(aws_run_json guardduty list-detectors 2>/dev/null | jq '.DetectorIds // []' 2>/dev/null || printf '[]')"
  local ids
  ids="$(jq -r '.[]' <<<"$detectors" 2>/dev/null)"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    local g
    g="$(aws_run_json guardduty get-detector --detector-id "$d" 2>/dev/null)"
    detail="$(jq --arg id "$d" --argjson g "$g" '. + [{detector_id:$id, config:$g}]' <<<"$detail")"
  done <<<"$ids"

  local schema="awssec.state-guardduty.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson detail "$detail" --argjson detectors "$detectors" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-guardduty", slice: $slice,
      account_id: $account, region: $region,
      enabled: (($detail | length) > 0 and ($detail | any(.config.Status == "ENABLED"))),
      detectors_count: ($detectors | length),
      detectors_detail: $detail,
      hint: "for full data, run: state guardduty full"
    }'
}
