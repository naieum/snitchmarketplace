# lib/state_policy.sh — Azure Policy assignments, compliance state, remediation tasks.
# slice ∈ digest (default) | assignments | compliance | full

run_state_policy() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local assignments initiatives compliance remediations
  assignments="$(az_run_json policy assignment list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, displayName, scope, policyDefinitionId, enforcementMode}]' 2>/dev/null || printf '[]')"
  initiatives="$(az_run_json policy set-definition list --subscription "$sub_id" --query "[?policyType=='BuiltIn']" 2>/dev/null \
    | jq '[.[] | {id, displayName, category: .metadata.category}]' 2>/dev/null || printf '[]')"
  compliance="$(az_run_json policy state list --subscription "$sub_id" --top 200 2>/dev/null \
    | jq '[.[] | {complianceState, policyDefinitionAction, resourceId}]' 2>/dev/null || printf '[]')"
  remediations="$(az_run_json policy remediation list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, provisioningState, policyAssignmentId}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    assignments)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$assignments" \
        '{schema:"azsec.state-policy.assignments", schema_version:1, generated_at:$ts,
          tool:"state-policy", slice:"assignments", subscription_id:$sub_id, assignments:$a}'
      return 0 ;;
    compliance)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson c "$compliance" \
        '{schema:"azsec.state-policy.compliance", schema_version:1, generated_at:$ts,
          tool:"state-policy", slice:"compliance", subscription_id:$sub_id, compliance:$c}'
      return 0 ;;
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
        --argjson a "$assignments" --argjson i "$initiatives" \
        --argjson c "$compliance" --argjson r "$remediations" \
        '{schema:"azsec.state-policy.full", schema_version:1, generated_at:$ts,
          tool:"state-policy", slice:"full", subscription_id:$sub_id,
          assignments:$a, builtin_initiatives:$i, compliance:$c, remediations:$r}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson a "$assignments" --argjson c "$compliance" --argjson r "$remediations" \
    '{
      schema: "azsec.state-policy.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-policy",
      slice: "digest",
      subscription_id: $sub_id,
      assignments_summary: {
        total: ($a | length),
        cis_assigned: ($a | map(select(.policyDefinitionId | tostring | test("CIS"; "i"))) | length),
        nist_assigned: ($a | map(select(.policyDefinitionId | tostring | test("NIST"; "i"))) | length),
        do_not_enforce: ($a | map(select(.enforcementMode=="DoNotEnforce")) | length)
      },
      compliance_summary: {
        sampled: ($c | length),
        non_compliant: ($c | map(select(.complianceState=="NonCompliant")) | length),
        compliant: ($c | map(select(.complianceState=="Compliant")) | length)
      },
      remediations_summary: { total: ($r | length), failed: ($r | map(select(.provisioningState=="Failed")) | length) },
      hint: "for full data, run: state policy [assignments|compliance|full]"
    }'
}
