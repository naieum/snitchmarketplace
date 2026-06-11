# lib/apply_vpc.sh — VPC hardening:
#  - Surface obviously-bad SG rules (0.0.0.0/0 on management ports) as FAIL.
#  - Do NOT auto-revoke SG rules — too easy to break the user's app.
# Exposes: apply_vpc [args]

apply_vpc() {
  log_section "VPC hardening"

  local sgs
  sgs="$(aws_run_json ec2 describe-security-groups 2>/dev/null | jq -c '.SecurityGroups // []' 2>/dev/null)"

  # Walk each SG, find rules opening 0.0.0.0/0 on management ports.
  local danger_ports="22 3389 3306 5432 27017 6379 9200 11211"
  local p sg_count_with_issue=0
  for p in $danger_ports; do
    local hits
    hits="$(jq -r --argjson p "$p" \
      '[ .[] | select(any(.IpPermissions[]?; (.IpRanges // [] | any(.CidrIp == "0.0.0.0/0")) and ((.FromPort // 0) <= $p and (.ToPort // 65535) >= $p))) | .GroupId ] | unique[]' \
      <<<"$sgs" 2>/dev/null)"
    while IFS= read -r gid; do
      [[ -z "$gid" ]] && continue
      log_fail "vpc" "sg-world-${p}/${gid}" "Security group ${gid} has 0.0.0.0/0 ingress on port ${p}. Revoke or restrict by hand: 'aws ec2 revoke-security-group-ingress --group-id ${gid} --protocol tcp --port ${p} --cidr 0.0.0.0/0'."
      sg_count_with_issue=$((sg_count_with_issue+1))
    done <<<"$hits"
  done

  if [[ $sg_count_with_issue -eq 0 ]]; then
    log_ok "vpc" "sg-world-mgmt" "No security groups expose management ports to 0.0.0.0/0."
  fi

  # Flow logs: warn if any VPC has none.
  local vpcs flogs
  vpcs="$(aws_run_json ec2 describe-vpcs 2>/dev/null | jq -r '.Vpcs[]?.VpcId' 2>/dev/null)"
  flogs="$(aws_run_json ec2 describe-flow-logs 2>/dev/null | jq -r '.FlowLogs[]?.ResourceId' 2>/dev/null | sort -u)"
  while IFS= read -r v; do
    [[ -z "$v" ]] && continue
    if ! grep -qx "$v" <<<"$flogs"; then
      log_warn "vpc" "flow-logs/${v}" "VPC ${v} has no flow logs. Recommended: enable to S3 or CloudWatch Logs." "https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html"
    else
      log_ok "vpc" "flow-logs/${v}" "VPC ${v} has flow logs."
    fi
  done <<<"$vpcs"

  return 0
}
