# lib/state_iam.sh — IAM state (users, roles, policies, access analyzer).
# Exports: run_state_iam [slice]
#   slice ∈ digest (default) | users | roles | policies | analyzer | full

run_state_iam() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|users|roles|policies|analyzer|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","users","roles","policies","analyzer","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local users='[]' roles='[]' policies='[]' analyzers='[]' findings='[]'
  users="$(aws_run_json iam list-users 2>/dev/null | jq '.Users // []' 2>/dev/null || printf '[]')"
  roles="$(aws_run_json iam list-roles 2>/dev/null | jq '.Roles // []' 2>/dev/null || printf '[]')"
  policies="$(aws_run_json iam list-policies --scope Local 2>/dev/null | jq '.Policies // []' 2>/dev/null || printf '[]')"
  analyzers="$(aws_run_json accessanalyzer list-analyzers 2>/dev/null | jq '.analyzers // []' 2>/dev/null || printf '[]')"

  if [[ "$slice" == "full" || "$slice" == "analyzer" ]]; then
    local first_arn
    first_arn="$(jq -r '.[0].arn // empty' <<<"$analyzers")"
    if [[ -n "$first_arn" ]]; then
      findings="$(aws_run_json accessanalyzer list-findings --analyzer-arn "$first_arn" 2>/dev/null | jq '.findings // []' 2>/dev/null || printf '[]')"
    fi
  fi

  local schema="awssec.state-iam.${slice}"

  case "$slice" in
    digest)
      # Compute access key age signals.
      local users_age='[]'
      local user_names
      user_names="$(jq -r '.[].UserName' <<<"$users" 2>/dev/null)"
      while IFS= read -r u; do
        [[ -z "$u" ]] && continue
        local keys
        keys="$(aws_run_json iam list-access-keys --user-name "$u" 2>/dev/null | jq '.AccessKeyMetadata // []' 2>/dev/null || printf '[]')"
        users_age="$(jq --arg u "$u" --argjson k "$keys" '. + [{user:$u, access_keys:$k}]' <<<"$users_age")"
      done <<<"$user_names"

      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson users "$users" --argjson roles "$roles" \
        --argjson policies "$policies" --argjson analyzers "$analyzers" \
        --argjson users_age "$users_age" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-iam", slice: $slice,
          account_id: $account, region: $region,
          users_summary: {
            total: ($users | length),
            with_console_password: ($users | map(select(.PasswordLastUsed != null)) | length),
            never_logged_in: ($users | map(select(.PasswordLastUsed == null)) | length),
            stale_passwords_90d: ($users | map(select(.PasswordLastUsed != null and (.PasswordLastUsed[0:10] < ($ts[0:8]+"01")))) | length)
          },
          access_keys_summary: {
            total_keys: ($users_age | map(.access_keys | length) | add // 0),
            old_keys_90d: ($users_age | [.[] | .access_keys[]] | map(select(.CreateDate != null)) | length)
          },
          roles_summary: {
            total: ($roles | length),
            service_roles: ($roles | map(select(.Path | startswith("/aws-service-role/"))) | length)
          },
          policies_summary: {
            customer_managed_total: ($policies | length),
            attachment_count_zero: ($policies | map(select(.AttachmentCount == 0)) | length)
          },
          access_analyzer_summary: {
            analyzers: ($analyzers | length),
            type_organization: ($analyzers | map(select(.type == "ORGANIZATION")) | length),
            type_account: ($analyzers | map(select(.type == "ACCOUNT")) | length)
          },
          hint: "for full data, run: state iam [users|roles|policies|analyzer|full]"
        }'
      ;;
    users)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson users "$users" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-iam", slice: $slice,
           account_id: $account, region: $region,
           users: $users }'
      ;;
    roles)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson roles "$roles" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-iam", slice: $slice,
           account_id: $account, region: $region,
           roles: $roles }'
      ;;
    policies)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson policies "$policies" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-iam", slice: $slice,
           account_id: $account, region: $region,
           policies: $policies }'
      ;;
    analyzer)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson analyzers "$analyzers" --argjson findings "$findings" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-iam", slice: $slice,
           account_id: $account, region: $region,
           analyzers: $analyzers, findings: $findings }'
      ;;
    full)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson users "$users" --argjson roles "$roles" \
        --argjson policies "$policies" --argjson analyzers "$analyzers" \
        --argjson findings "$findings" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-iam", slice: $slice,
           account_id: $account, region: $region,
           users: $users, roles: $roles, policies: $policies,
           analyzers: $analyzers, access_analyzer_findings: $findings }'
      ;;
  esac
}
