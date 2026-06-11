# lib/state_vpc.sh — VPC, security groups, NACLs, flow logs, peerings.
# Exports: run_state_vpc [slice]
#   slice ∈ digest (default) | sgs | flow-logs | full

run_state_vpc() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|sgs|flow-logs|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","sgs","flow-logs","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local vpcs sgs nacls flogs peers tgws endpoints
  vpcs="$(aws_run_json ec2 describe-vpcs 2>/dev/null | jq '.Vpcs // []' 2>/dev/null || printf '[]')"
  sgs="$(aws_run_json ec2 describe-security-groups 2>/dev/null | jq '.SecurityGroups // []' 2>/dev/null || printf '[]')"
  nacls="$(aws_run_json ec2 describe-network-acls 2>/dev/null | jq '.NetworkAcls // []' 2>/dev/null || printf '[]')"
  flogs="$(aws_run_json ec2 describe-flow-logs 2>/dev/null | jq '.FlowLogs // []' 2>/dev/null || printf '[]')"
  peers="$(aws_run_json ec2 describe-vpc-peering-connections 2>/dev/null | jq '.VpcPeeringConnections // []' 2>/dev/null || printf '[]')"
  tgws="$(aws_run_json ec2 describe-transit-gateways 2>/dev/null | jq '.TransitGateways // []' 2>/dev/null || printf '[]')"
  endpoints="$(aws_run_json ec2 describe-vpc-endpoints 2>/dev/null | jq '.VpcEndpoints // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-vpc.${slice}"

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson vpcs "$vpcs" --argjson sgs "$sgs" --argjson nacls "$nacls" \
        --argjson flogs "$flogs" --argjson peers "$peers" \
        --argjson tgws "$tgws" --argjson endpoints "$endpoints" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-vpc", slice: $slice,
          account_id: $account, region: $region,
          vpcs_summary: {
            total: ($vpcs | length),
            with_flow_logs: (($flogs | map(.ResourceId) | unique) | length)
          },
          security_groups_summary: {
            total: ($sgs | length),
            ingress_world_22:    ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any(.FromPort == 22 or (.FromPort // 0) <= 22 and (.ToPort // 65535) >= 22))) | length),
            ingress_world_3389:  ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 3389 and (.ToPort // 0) >= 3389))) | length),
            ingress_world_3306:  ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 3306 and (.ToPort // 0) >= 3306))) | length),
            ingress_world_5432:  ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 5432 and (.ToPort // 0) >= 5432))) | length),
            ingress_world_27017: ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 27017 and (.ToPort // 0) >= 27017))) | length),
            ingress_world_6379:  ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 6379 and (.ToPort // 0) >= 6379))) | length),
            ingress_world_9200:  ($sgs | map(select((.IpPermissions // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and any((.FromPort // 0) <= 9200 and (.ToPort // 0) >= 9200))) | length),
            unrestricted_egress: ($sgs | map(select((.IpPermissionsEgress // []) | any(.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")))) | length)
          },
          nacls_count: ($nacls | length),
          flow_logs_count: ($flogs | length),
          peering_count: ($peers | length),
          transit_gateways_count: ($tgws | length),
          vpc_endpoints_count: ($endpoints | length),
          hint: "for full data, run: state vpc [sgs|flow-logs|full]"
        }'
      ;;
    sgs)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" --argjson sgs "$sgs" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-vpc", slice: $slice,
           account_id: $account, region: $region, security_groups: $sgs }'
      ;;
    flow-logs)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson vpcs "$vpcs" --argjson flogs "$flogs" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-vpc", slice: $slice,
           account_id: $account, region: $region,
           vpcs: $vpcs, flow_logs: $flogs }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson vpcs "$vpcs" --argjson sgs "$sgs" --argjson nacls "$nacls" \
        --argjson flogs "$flogs" --argjson peers "$peers" \
        --argjson tgws "$tgws" --argjson endpoints "$endpoints" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-vpc", slice: $slice,
           account_id: $account, region: $region,
           vpcs: $vpcs, security_groups: $sgs, network_acls: $nacls,
           flow_logs: $flogs, peering_connections: $peers,
           transit_gateways: $tgws, vpc_endpoints: $endpoints }'
      ;;
  esac
}
