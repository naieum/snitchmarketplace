# lib/state_subscription.sh — subscription digest + slices.
# slice ∈ digest (default) | locks | budgets | full

run_state_subscription() {
  local sub_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$sub_id" ]]; then
    sub_id="$(az_pick_subscription)" || {
      printf '{"error":"could not resolve subscription id","code":"E_SUBSCRIPTION","remediation":"set AZSEC_SUBSCRIPTION_ID or run az account set --subscription <id>"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest)  _state_subscription_digest  "$sub_id" "$ts" ;;
    locks)   _state_subscription_locks   "$sub_id" "$ts" ;;
    budgets) _state_subscription_budgets "$sub_id" "$ts" ;;
    full)    _state_subscription_full    "$sub_id" "$ts" ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","locks","budgets","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_ssub_meta() {
  local sub_id="$1"
  az_run_json account show --subscription "$sub_id" 2>/dev/null \
    | jq '{id, name, state, tenantId, isDefault, user: .user, quotaId: (.subscriptionPolicies.quotaId // null), spendingLimit: (.subscriptionPolicies.spendingLimit // null)}' 2>/dev/null \
    || printf '{}'
}

_ssub_locks() {
  local sub_id="$1"
  az_run_json lock list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id, name, level, notes}]' 2>/dev/null \
    || printf '[]'
}

_ssub_budgets() {
  local sub_id="$1"
  az_run_json consumption budget list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {name, amount, timeGrain, currentSpend: .currentSpend.amount, limit: .amount}]' 2>/dev/null \
    || printf '[]'
}

_ssub_owners() {
  local sub_id="$1"
  az_run_json role assignment list --subscription "$sub_id" --role Owner 2>/dev/null \
    | jq '[.[] | {principalName, principalType, scope}]' 2>/dev/null \
    || printf '[]'
}

_state_subscription_digest() {
  local sub_id="$1" ts="$2"
  local meta locks budgets owners
  meta="$(_ssub_meta "$sub_id")"
  locks="$(_ssub_locks "$sub_id")"
  budgets="$(_ssub_budgets "$sub_id")"
  owners="$(_ssub_owners "$sub_id")"

  jq -n \
    --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson meta "$meta" \
    --argjson locks "$locks" \
    --argjson budgets "$budgets" \
    --argjson owners "$owners" \
    '{
      schema: "azsec.state-subscription.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-subscription",
      slice: "digest",
      subscription_id: $sub_id,
      subscription: $meta,
      locks_summary: { total: ($locks|length), by_level: ($locks | group_by(.level) | map({key: .[0].level, value: length}) | from_entries) },
      budgets_summary: { total: ($budgets|length), names: ($budgets | map(.name)) },
      owners_summary: { total: ($owners|length), principal_types: ($owners | group_by(.principalType) | map({key: .[0].principalType, value: length}) | from_entries) },
      hint: "for full data, run: state subscription <id> [locks|budgets|full]"
    }'
}

_state_subscription_locks() {
  local sub_id="$1" ts="$2"
  local meta locks
  meta="$(_ssub_meta "$sub_id")"
  locks="$(_ssub_locks "$sub_id")"
  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson meta "$meta" --argjson locks "$locks" \
    '{schema:"azsec.state-subscription.locks", schema_version:1, generated_at:$ts,
      tool:"state-subscription", slice:"locks", subscription_id:$sub_id,
      subscription:$meta, locks:$locks}'
}

_state_subscription_budgets() {
  local sub_id="$1" ts="$2"
  local meta budgets
  meta="$(_ssub_meta "$sub_id")"
  budgets="$(_ssub_budgets "$sub_id")"
  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson meta "$meta" --argjson budgets "$budgets" \
    '{schema:"azsec.state-subscription.budgets", schema_version:1, generated_at:$ts,
      tool:"state-subscription", slice:"budgets", subscription_id:$sub_id,
      subscription:$meta, budgets:$budgets}'
}

_state_subscription_full() {
  local sub_id="$1" ts="$2"
  local meta locks budgets owners
  meta="$(_ssub_meta "$sub_id")"
  locks="$(_ssub_locks "$sub_id")"
  budgets="$(_ssub_budgets "$sub_id")"
  owners="$(_ssub_owners "$sub_id")"
  jq -n --arg ts "$ts" --arg sub_id "$sub_id" \
    --argjson meta "$meta" --argjson locks "$locks" \
    --argjson budgets "$budgets" --argjson owners "$owners" \
    '{schema:"azsec.state-subscription.full", schema_version:1, generated_at:$ts,
      tool:"state-subscription", slice:"full", subscription_id:$sub_id,
      subscription:$meta, locks:$locks, budgets:$budgets, owners:$owners}'
}
