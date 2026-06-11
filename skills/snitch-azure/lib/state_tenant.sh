# lib/state_tenant.sh — tenant signals (Entra tenant id, default domain, B2B settings).
# slice ∈ digest (default) | full

run_state_tenant() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local tid; tid="$(az_pick_tenant)" || {
    printf '{"error":"could not resolve tenant id","code":"E_TENANT","remediation":"set AZSEC_TENANT_ID or run az login"}\n' >&2
    return 3
  }
  local org domains
  org="$(az_run_json rest --method GET --url 'https://graph.microsoft.com/v1.0/organization' 2>/dev/null \
    | jq '.value[0] // {}' 2>/dev/null || printf '{}')"
  domains="$(az_run_json rest --method GET --url 'https://graph.microsoft.com/v1.0/domains' 2>/dev/null \
    | jq '[.value[]? | {id, isDefault, isVerified, supportedServices}]' 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg tid "$tid" \
    --argjson org "$org" --argjson domains "$domains" \
    '{
      schema: "azsec.state-tenant.\($slice|tostring)" | sub("\\.tostring";""),
      schema_version: 1,
      generated_at: $ts,
      tool: "state-tenant",
      slice: "digest",
      tenant_id: $tid,
      organization: { id: ($org.id // null), displayName: ($org.displayName // null), countryLetterCode: ($org.countryLetterCode // null), createdDateTime: ($org.createdDateTime // null), verifiedDomains_count: ((($org.verifiedDomains // []) | length)) },
      domains_summary: { total: ($domains | length), default: ($domains | map(select(.isDefault==true) | .id) | first), unverified: ($domains | map(select(.isVerified==false) | .id)) }
    }' 2>/dev/null \
    || printf '{"error":"failed to build tenant digest","code":"E_API"}\n' >&2
}
