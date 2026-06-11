# lib/state_shield.sh — AWS Shield Advanced subscription + protections.
# Exports: run_state_shield [slice]
#   slice ∈ digest (default) | full

run_state_shield() {
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

  local sub protections
  sub="$(aws_run_json shield describe-subscription 2>/dev/null | jq '.Subscription // null' 2>/dev/null || printf 'null')"
  protections="$(aws_run_json shield list-protections 2>/dev/null | jq '.Protections // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-shield.${slice}"

  jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
    --arg account "$account" --arg region "$region" \
    --argjson sub "$sub" --argjson protections "$protections" \
    '{
      schema: $schema, schema_version: 1, generated_at: $ts,
      tool: "state-shield", slice: $slice,
      account_id: $account, region: $region,
      subscription: $sub,
      shield_advanced_active: ($sub != null),
      protections_count: ($protections | length),
      protections: (if $slice == "full" then $protections else null end)
    }'
}
