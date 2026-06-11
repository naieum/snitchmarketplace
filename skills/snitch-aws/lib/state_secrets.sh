# lib/state_secrets.sh — Secrets Manager + SSM Parameter Store posture.
# Exports: run_state_secrets [slice]
#   slice ∈ digest (default) | secrets | parameters | full

run_state_secrets() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|secrets|parameters|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","secrets","parameters","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local secrets params
  secrets="$(aws_run_json secretsmanager list-secrets --max-results 100 2>/dev/null | jq '.SecretList // []' 2>/dev/null || printf '[]')"
  params="$(aws_run_json ssm describe-parameters --max-results 50 2>/dev/null | jq '.Parameters // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-secrets.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson secrets "$secrets" --argjson params "$params" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-secrets", slice: $slice,
          account_id: $account, region: $region,
          secrets_manager_summary: {
            total: ($secrets | length),
            with_rotation: ($secrets | map(select(.RotationEnabled == true)) | length),
            without_rotation: ($secrets | map(select(.RotationEnabled != true)) | length),
            with_kms_key: ($secrets | map(select(.KmsKeyId != null and .KmsKeyId != "")) | length)
          },
          ssm_parameters_summary: {
            total: ($params | length),
            secure_string: ($params | map(select(.Type == "SecureString")) | length),
            string: ($params | map(select(.Type == "String")) | length)
          },
          hint: "for full data, run: state secrets [secrets|parameters|full]"
        }'
      ;;
    secrets)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson secrets "$secrets" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-secrets", slice: $slice,
           account_id: $account, region: $region, secrets: $secrets }'
      ;;
    parameters)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson params "$params" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-secrets", slice: $slice,
           account_id: $account, region: $region, ssm_parameters: $params }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson secrets "$secrets" --argjson params "$params" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-secrets", slice: $slice,
           account_id: $account, region: $region,
           secrets: $secrets, ssm_parameters: $params }'
      ;;
  esac
}
