# lib/state_kms.sh — KMS keys (rotation, customer-managed vs AWS-managed).
# Exports: run_state_kms [slice]
#   slice ∈ digest (default) | keys | full

run_state_kms() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|keys|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","keys","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local keys details='[]'
  keys="$(aws_run_json kms list-keys 2>/dev/null | jq '.Keys // []' 2>/dev/null || printf '[]')"
  local ids
  ids="$(jq -r '.[].KeyId' <<<"$keys" 2>/dev/null)"
  while IFS= read -r k; do
    [[ -z "$k" ]] && continue
    local meta rot
    meta="$(aws_run_json kms describe-key --key-id "$k" 2>/dev/null | jq '.KeyMetadata // {}' 2>/dev/null || printf '{}')"
    rot="$(aws_run_json kms get-key-rotation-status --key-id "$k" 2>/dev/null | jq '.KeyRotationEnabled // null' 2>/dev/null || printf 'null')"
    details="$(jq --arg id "$k" --argjson m "$meta" --argjson r "$rot" \
      '. + [{key_id:$id, metadata:$m, rotation_enabled:$r}]' <<<"$details")"
  done <<<"$ids"

  local schema="awssec.state-kms.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson details "$details" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-kms", slice: $slice,
          account_id: $account, region: $region,
          keys_summary: {
            total: ($details | length),
            customer_managed: ($details | map(select(.metadata.KeyManager == "CUSTOMER")) | length),
            aws_managed: ($details | map(select(.metadata.KeyManager == "AWS")) | length),
            with_rotation_enabled: ($details | map(select(.rotation_enabled == true)) | length),
            customer_keys_without_rotation: ($details | map(select(.metadata.KeyManager == "CUSTOMER" and .rotation_enabled != true)) | length),
            pending_deletion: ($details | map(select(.metadata.KeyState == "PendingDeletion")) | length)
          },
          hint: "for full data, run: state kms [keys|full]"
        }'
      ;;
    keys|full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson details "$details" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-kms", slice: $slice,
           account_id: $account, region: $region, keys: $details }'
      ;;
  esac
}
