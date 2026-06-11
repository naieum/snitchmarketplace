# lib/apply_nsg.sh — idempotent fixes for NSGs.
# Targets: deny-by-default + remove 0.0.0.0/0 on management ports — REFUSES
# to strip without explicit confirmation. Emits the proposed delta.

apply_nsg() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"   # nsg name, optional
  local confirm="${AZSEC_NSG_CONFIRM:-}"   # set to 'yes' to apply

  local nsgs
  if [[ -n "$target" ]]; then
    nsgs="$(az_run_json network nsg list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    nsgs="$(az_run_json network nsg list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$nsgs")"
  if [[ "$n" == "0" ]]; then
    log_warn "nsg" "scope" "no NSGs found"
    return 0
  fi

  local i nsg name rg risky_rules
  for ((i=0;i<n;i++)); do
    nsg="$(jq -c ".[$i]" <<<"$nsgs")"
    name="$(jq -r '.name' <<<"$nsg")"
    rg="$(jq -r '.resourceGroup' <<<"$nsg")"
    risky_rules="$(jq -c '
      [.securityRules[]? |
        select(.direction=="Inbound" and .access=="Allow") |
        select((.sourceAddressPrefix=="*" or .sourceAddressPrefix=="0.0.0.0/0" or .sourceAddressPrefix=="Internet") and
               ((.destinationPortRange | tostring | test("^(22|3389|5985|5986)$")) or
                ((.destinationPortRanges // []) | any(tostring | test("^(22|3389|5985|5986)$"))))) |
        .name
      ]' <<<"$nsg")"
    local nrules; nrules="$(jq -r 'length' <<<"$risky_rules")"
    if [[ "$nrules" == "0" ]]; then
      log_ok "nsg" "${name}/mgmt-ports" "no Allow-Any inbound rules on management ports."
      continue
    fi
    local rules_csv; rules_csv="$(jq -r 'join(",")' <<<"$risky_rules")"
    if [[ "$confirm" != "yes" ]]; then
      log_warn "nsg" "${name}/mgmt-ports" "${nrules} rule(s) allow Any → mgmt port: ${rules_csv}. Refuses to delete without AZSEC_NSG_CONFIRM=yes. Confirm with user first."
      continue
    fi
    # User explicitly confirmed via env var.
    local j rule_name
    for ((j=0;j<nrules;j++)); do
      rule_name="$(jq -r ".[$j]" <<<"$risky_rules")"
      if az_run network nsg rule delete --nsg-name "$name" --resource-group "$rg" --subscription "$sub_id" --name "$rule_name" >/dev/null 2>&1; then
        log_ok "nsg" "${name}/${rule_name}" "deleted."
      else
        log_fail "nsg" "${name}/${rule_name}" "could not delete. $(az_last_error)"
      fi
    done
  done
}
