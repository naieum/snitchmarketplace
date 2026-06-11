# lib/apply_policy.sh — Azure Policy assignment guidance.
# Suggest assigning the CIS / NIST built-in initiatives if not already assigned.

apply_policy() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local assignments
  assignments="$(az_run_json policy assignment list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  local cis nist
  cis="$(jq '[.[] | select((.policyDefinitionId|tostring) | test("CIS"; "i"))] | length' <<<"$assignments" 2>/dev/null || printf '0')"
  nist="$(jq '[.[] | select((.policyDefinitionId|tostring) | test("NIST"; "i"))] | length' <<<"$assignments" 2>/dev/null || printf '0')"
  if [[ "${cis:-0}" -gt 0 ]]; then
    log_ok "policy" "cis" "${cis} CIS-related assignment(s)."
  else
    log_warn "policy" "cis" "no CIS initiative assigned. See ${TPL_DIR}/azure-policy-builtin-pack.starter.json for the starter pack."
  fi
  if [[ "${nist:-0}" -gt 0 ]]; then
    log_ok "policy" "nist" "${nist} NIST-related assignment(s)."
  else
    log_warn "policy" "nist" "no NIST initiative assigned. Optional but recommended for federal/regulated."
  fi
}
