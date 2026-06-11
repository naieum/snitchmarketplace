# lib/apply_dns.sh — DNS-zone hygiene. DNSSEC on Azure DNS is in preview /
# limited GA — surface as WARN with the doc pointer. We do CAA-records advice.

apply_dns() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local zones
  zones="$(az_run_json network dns zone list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  local n; n="$(jq -r 'length' <<<"$zones")"
  if [[ "$n" == "0" ]]; then
    log_warn "dns" "scope" "no public DNS zones found"
    return 0
  fi
  local i z name rg caa_count
  for ((i=0;i<n;i++)); do
    z="$(jq -c ".[$i]" <<<"$zones")"
    name="$(jq -r '.name' <<<"$z")"
    rg="$(jq -r '.resourceGroup' <<<"$z")"
    caa_count="$(az_run_json network dns record-set caa list -g "$rg" --zone-name "$name" --subscription "$sub_id" 2>/dev/null \
      | jq 'length' 2>/dev/null || printf '0')"
    if [[ "${caa_count:-0}" -gt 0 ]]; then
      log_ok "dns" "${name}/caa" "CAA records present (${caa_count})."
    else
      log_warn "dns" "${name}/caa" "no CAA records. Recommend adding 'issue letsencrypt.org' and 'issue digicert.com' (or your CA)."
    fi
    log_warn "dns" "${name}/dnssec" "DNSSEC on Azure DNS is in preview / limited GA. Verify current support before enabling. https://learn.microsoft.com/en-us/azure/dns/dnssec"
  done
}
