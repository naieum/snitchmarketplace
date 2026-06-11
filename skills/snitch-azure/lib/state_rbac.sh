# lib/state_rbac.sh — role assignments + custom-vs-builtin split, deny assignments.
# slice ∈ digest (default) | assignments | custom-roles | full

run_state_rbac() {
  local scope="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local args=()
  if [[ -n "$scope" ]]; then
    args+=(--scope "$scope")
  fi
  local assignments custom_roles deny
  assignments="$(az_run_json role assignment list --subscription "$sub_id" "${args[@]}" 2>/dev/null \
    | jq '[.[] | {id, principalName, principalType, roleDefinitionName, scope}]' 2>/dev/null || printf '[]')"
  custom_roles="$(az_run_json role definition list --custom-role-only true --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {name: .roleName, id, assignableScopes, permissions: [.permissions[]? | {actions: (.actions // []), notActions: (.notActions // []), dataActions: (.dataActions // []), notDataActions: (.notDataActions // [])}]}]' 2>/dev/null || printf '[]')"
  deny="$(az_run_json rest --method GET --url "https://management.azure.com/subscriptions/${sub_id}/providers/Microsoft.Authorization/denyAssignments?api-version=2022-04-01" 2>/dev/null \
    | jq '.value // []' 2>/dev/null || printf '[]')"

  case "$slice" in
    assignments)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson a "$assignments" \
        '{schema:"azsec.state-rbac.assignments", schema_version:1, generated_at:$ts,
          tool:"state-rbac", slice:"assignments", subscription_id:$sub_id, assignments:$a}'
      return 0 ;;
    custom-roles)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson c "$custom_roles" \
        '{schema:"azsec.state-rbac.custom-roles", schema_version:1, generated_at:$ts,
          tool:"state-rbac", slice:"custom-roles", subscription_id:$sub_id, custom_roles:$c}'
      return 0 ;;
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
        --argjson a "$assignments" --argjson c "$custom_roles" --argjson d "$deny" \
        '{schema:"azsec.state-rbac.full", schema_version:1, generated_at:$ts,
          tool:"state-rbac", slice:"full", subscription_id:$sub_id,
          assignments:$a, custom_roles:$c, deny_assignments:$d}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson a "$assignments" --argjson c "$custom_roles" --argjson d "$deny" \
    '{
      schema: "azsec.state-rbac.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-rbac",
      slice: "digest",
      subscription_id: $sub_id,
      assignments_summary: {
        total: ($a | length),
        by_role: ($a | group_by(.roleDefinitionName) | map({key: .[0].roleDefinitionName, value: length}) | from_entries),
        by_principal_type: ($a | group_by(.principalType) | map({key: .[0].principalType, value: length}) | from_entries),
        owners: ($a | map(select(.roleDefinitionName=="Owner")) | length),
        contributors: ($a | map(select(.roleDefinitionName=="Contributor")) | length)
      },
      custom_roles_summary: { total: ($c | length), names: ($c | map(.name)) },
      deny_assignments_summary: { total: ($d | length) },
      hint: "for full data, run: state rbac [<scope>] [assignments|custom-roles|full]"
    }'
}
