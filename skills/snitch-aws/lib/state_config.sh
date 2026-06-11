# lib/state_config.sh — AWS Config recorders, channels, conformance packs.
# Exports: run_state_config [slice]
#   slice ∈ digest (default) | full

run_state_config() {
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

  local recorders channels rec_status conf_packs
  recorders="$(aws_run_json configservice describe-configuration-recorders 2>/dev/null | jq '.ConfigurationRecorders // []' 2>/dev/null || printf '[]')"
  channels="$(aws_run_json configservice describe-delivery-channels 2>/dev/null | jq '.DeliveryChannels // []' 2>/dev/null || printf '[]')"
  rec_status="$(aws_run_json configservice describe-configuration-recorder-status 2>/dev/null | jq '.ConfigurationRecordersStatus // []' 2>/dev/null || printf '[]')"
  conf_packs="$(aws_run_json configservice describe-conformance-packs 2>/dev/null | jq '.ConformancePackDetails // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-config.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson recorders "$recorders" --argjson channels "$channels" \
    --argjson status "$rec_status" --argjson cpacks "$conf_packs" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-config", slice: $slice,
      account_id: $account, region: $region,
      recorders_summary: {
        total: ($recorders | length),
        recording: ($status | map(select(.recording == true)) | length),
        all_resources: ($recorders | map(select(.recordingGroup.allSupported == true)) | length)
      },
      delivery_channels_count: ($channels | length),
      conformance_packs_count: ($cpacks | length),
      recorders: (if $slice == "full" then $recorders else null end),
      delivery_channels: (if $slice == "full" then $channels else null end),
      recorder_status: (if $slice == "full" then $status else null end),
      conformance_packs: (if $slice == "full" then $cpacks else null end),
      hint: "for full data, run: state config full"
    }'
}
