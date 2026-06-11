# lib/state_defender.sh — Defender for Cloud digest.
# slice ∈ digest (default) | pricing | recommendations | full

run_state_defender() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3

  local pricing secure_score recommendations
  pricing="$(az_run_json security pricing list --subscription "$sub_id" 2>/dev/null \
    | jq '[.value[]? | {name, pricingTier, freeTrialRemainingTime: (.freeTrialRemainingTime // null)}]' 2>/dev/null || printf '[]')"
  secure_score="$(az_run_json security secure-score list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, displayName, current: .score.current, max: .score.max, percentage: .score.percentage}]' 2>/dev/null || printf '[]')"
  recommendations="$(az_run_json security task list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {name, state, securityTaskParameters: .securityTaskParameters.name}]' 2>/dev/null || printf '[]')"

  case "$slice" in
    pricing)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson p "$pricing" \
        '{schema:"azsec.state-defender.pricing", schema_version:1, generated_at:$ts,
          tool:"state-defender", slice:"pricing", subscription_id:$sub_id, pricing:$p}'
      return 0 ;;
    recommendations)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" --argjson r "$recommendations" \
        '{schema:"azsec.state-defender.recommendations", schema_version:1, generated_at:$ts,
          tool:"state-defender", slice:"recommendations", subscription_id:$sub_id, recommendations:$r}'
      return 0 ;;
    full)
      jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
        --argjson p "$pricing" --argjson s "$secure_score" --argjson r "$recommendations" \
        '{schema:"azsec.state-defender.full", schema_version:1, generated_at:$ts,
          tool:"state-defender", slice:"full", subscription_id:$sub_id,
          pricing:$p, secure_score:$s, recommendations:$r}'
      return 0 ;;
  esac

  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson p "$pricing" --argjson s "$secure_score" --argjson r "$recommendations" \
    '{
      schema: "azsec.state-defender.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-defender",
      slice: "digest",
      subscription_id: $sub_id,
      pricing_summary: {
        total: ($p | length),
        standard_count: ($p | map(select(.pricingTier=="Standard")) | length),
        free_count: ($p | map(select(.pricingTier=="Free")) | length),
        plans_standard: ($p | map(select(.pricingTier=="Standard") | .name)),
        plans_free: ($p | map(select(.pricingTier=="Free") | .name))
      },
      secure_score_summary: {
        total_subscopes: ($s | length),
        ascscore_percentage: ($s | map(select(.id|tostring|test("ascScore"; "i"))) | first | (.percentage // null))
      },
      recommendations_summary: {
        total: ($r | length),
        active: ($r | map(select(.state=="Active")) | length),
        resolved: ($r | map(select(.state=="Resolved")) | length)
      },
      hint: "for full data, run: state defender [pricing|recommendations|full]"
    }'
}
