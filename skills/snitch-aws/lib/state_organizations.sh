# lib/state_organizations.sh — AWS Organizations: structure, SCPs, accounts.
# Exports: run_state_organizations [slice]
#   slice ∈ digest (default) | accounts | scps | full

run_state_organizations() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|accounts|scps|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","accounts","scps","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local org accounts scps roots
  org="$(aws_run_json organizations describe-organization 2>/dev/null | jq '.Organization // null' 2>/dev/null || printf 'null')"
  accounts="$(aws_run_json organizations list-accounts 2>/dev/null | jq '.Accounts // []' 2>/dev/null || printf '[]')"
  scps="$(aws_run_json organizations list-policies --filter SERVICE_CONTROL_POLICY 2>/dev/null | jq '.Policies // []' 2>/dev/null || printf '[]')"
  roots="$(aws_run_json organizations list-roots 2>/dev/null | jq '.Roots // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-organizations.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson org "$org" --argjson accounts "$accounts" \
        --argjson scps "$scps" --argjson roots "$roots" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-organizations", slice: $slice,
          account_id: $account, region: $region,
          is_organization: ($org != null),
          is_management_account: ($org != null and (($org.MasterAccountId // "") == $account)),
          organization: $org,
          accounts_summary: {
            total: ($accounts | length),
            active: ($accounts | map(select(.Status == "ACTIVE")) | length),
            suspended: ($accounts | map(select(.Status == "SUSPENDED")) | length)
          },
          scps_summary: {
            total: ($scps | length),
            non_default: ($scps | map(select(.AwsManaged != true)) | length)
          },
          roots_count: ($roots | length),
          hint: "for full data, run: state organizations [accounts|scps|full]"
        }'
      ;;
    accounts)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson accounts "$accounts" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-organizations", slice: $slice,
           account_id: $account, region: $region, accounts: $accounts }'
      ;;
    scps)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson scps "$scps" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-organizations", slice: $slice,
           account_id: $account, region: $region, scps: $scps }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson org "$org" --argjson accounts "$accounts" \
        --argjson scps "$scps" --argjson roots "$roots" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-organizations", slice: $slice,
           account_id: $account, region: $region,
           organization: $org, accounts: $accounts, scps: $scps, roots: $roots }'
      ;;
  esac
}
