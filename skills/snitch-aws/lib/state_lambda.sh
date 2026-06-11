# lib/state_lambda.sh — Lambda functions, Function URLs, env vars heuristics.
# Exports: run_state_lambda [slice]
#   slice ∈ digest (default) | functions | urls | full

run_state_lambda() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|functions|urls|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","functions","urls","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local funcs
  funcs="$(aws_run_json lambda list-functions 2>/dev/null | jq '.Functions // []' 2>/dev/null || printf '[]')"

  # Function URLs.
  local urls='[]'
  if [[ "$slice" != "digest" ]]; then
    local fnames
    fnames="$(jq -r '.[].FunctionName' <<<"$funcs" 2>/dev/null)"
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      local u
      u="$(aws_run_json lambda get-function-url-config --function-name "$f" 2>/dev/null)"
      [[ "$(jq -r 'has("FunctionUrl")' <<<"$u" 2>/dev/null)" == "true" ]] && \
        urls="$(jq --arg f "$f" --argjson u "$u" '. + [{function:$f, config:$u}]' <<<"$urls")"
    done <<<"$fnames"
  fi

  local schema="awssec.state-lambda.${slice}"

  # Heuristic: env vars whose keys/values look like secrets.
  local env_secret_funcs
  env_secret_funcs="$(jq '[.[] | select(((.Environment.Variables // {}) | to_entries | map(select((.key | test("(?i)(SECRET|PASSWORD|TOKEN|KEY|API_KEY)")) or (.value | type=="string" and (test("^[A-Za-z0-9+/=]{20,}$"))))) | length) > 0) | .FunctionName]' <<<"$funcs" 2>/dev/null || printf '[]')"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson funcs "$funcs" --argjson env_secret_funcs "$env_secret_funcs" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-lambda", slice: $slice,
          account_id: $account, region: $region,
          functions_summary: {
            total: ($funcs | length),
            runtimes: ($funcs | group_by(.Runtime // "unknown") | map({key: (.[0].Runtime // "unknown"), value: length}) | from_entries),
            with_vpc: ($funcs | map(select(.VpcConfig.VpcId != null and .VpcConfig.VpcId != "")) | length),
            with_dlq: ($funcs | map(select(.DeadLetterConfig.TargetArn != null)) | length),
            with_envvars: ($funcs | map(select((.Environment.Variables // {}) | length > 0)) | length)
          },
          env_secret_heuristic: {
            count: ($env_secret_funcs | length),
            functions: $env_secret_funcs
          },
          hint: "for full data, run: state lambda [functions|urls|full]"
        }'
      ;;
    functions)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson funcs "$funcs" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-lambda", slice: $slice,
           account_id: $account, region: $region, functions: $funcs }'
      ;;
    urls)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson urls "$urls" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-lambda", slice: $slice,
           account_id: $account, region: $region, function_urls: $urls }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson funcs "$funcs" --argjson urls "$urls" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-lambda", slice: $slice,
           account_id: $account, region: $region,
           functions: $funcs, function_urls: $urls }'
      ;;
  esac
}
