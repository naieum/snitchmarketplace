# lib/state_cost.sh — Cost / billing state.
# Exports: run_state_cost [slice]   slice ∈ digest|list|full

run_state_cost() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_cost_digest "$ts" ;;
    list)   _state_cost_list   "$ts" ;;
    full)   _state_cost_full   "$ts" ;;
    *)
      printf '{"error":"unknown state cost slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sc_balance() {
  local body; body="$(do_get /customers/my/balance)" || { printf '{}'; return; }
  printf '%s' "$body"
}

_sc_billing_history() {
  local body; body="$(do_get /customers/my/billing_history?per_page=50)" || { printf '{"billing_history":[]}'; return; }
  printf '%s' "$body"
}

_sc_invoices() {
  local body; body="$(do_get /customers/my/invoices?per_page=12)" || { printf '{"invoices":[]}'; return; }
  printf '%s' "$body"
}

_state_cost_digest() {
  local ts="$1"
  local bal hist inv
  bal="$(_sc_balance)"
  hist="$(_sc_billing_history)"
  inv="$(_sc_invoices)"

  jq -n --arg ts "$ts" --argjson bal "$bal" --argjson hist "$hist" --argjson inv "$inv" \
    '{ schema: "dosec.state-cost.digest", schema_version: 1, generated_at: $ts,
       tool: "state-cost", slice: "digest",
       cost_summary: {
         month_to_date_balance: ($bal.month_to_date_balance // null),
         account_balance: ($bal.account_balance // null),
         month_to_date_usage: ($bal.month_to_date_usage // null),
         recent_invoices: (($inv.invoices // [])[:6] | map({invoice_id, amount, invoice_period, updated_at})),
         recent_charges: (($hist.billing_history // [])[:6] | map({type, description, amount, date}))
       },
       hint: "for full data, run: state cost [list|full]. Resource-level cost requires per-resource enumeration; use the dashboard for the breakdown." }'
}

_state_cost_list() {
  local ts="$1"
  local bal hist inv
  bal="$(_sc_balance)"
  hist="$(_sc_billing_history)"
  inv="$(_sc_invoices)"
  jq -n --arg ts "$ts" --argjson bal "$bal" --argjson hist "$hist" --argjson inv "$inv" \
    '{ schema: "dosec.state-cost.list", schema_version: 1, generated_at: $ts,
       tool: "state-cost", slice: "list",
       balance: $bal, billing_history: ($hist.billing_history // []), invoices: ($inv.invoices // []) }'
}

_state_cost_full() {
  _state_cost_list "$@"
}
