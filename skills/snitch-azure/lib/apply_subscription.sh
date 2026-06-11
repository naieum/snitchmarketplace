# lib/apply_subscription.sh — root MFA via Entra Conditional Access guidance.
# Conditional Access policy creation requires graph permissions and is
# tenant-scoped; we emit the recommended starter policy via templates.

apply_subscription() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local tid; tid="$(az_pick_tenant)" || return 3

  log_section "subscription / tenant root hardening"
  log_info "subscription=${sub_id}"
  log_info "tenant=${tid}"

  # Owners count
  local owners; owners="$(az_run_json role assignment list --subscription "$sub_id" --role Owner 2>/dev/null \
    | jq 'length' 2>/dev/null || printf '0')"
  if [[ "${owners:-0}" -ge 2 && "${owners:-0}" -le 4 ]]; then
    log_ok "subscription" "owners" "owner count is ${owners} (recommended 2-4)."
  elif [[ "${owners:-0}" -lt 2 ]]; then
    log_warn "subscription" "owners" "only ${owners} Owner(s). Add a backup owner (break-glass account)."
  else
    log_warn "subscription" "owners" "${owners} Owners is high. Consolidate via Contributor + per-resource owners."
  fi

  # Guidance for Conditional Access
  log_warn "subscription" "ca-policy" "Recommend deploying Entra Conditional Access starter policies (require MFA for admins, block legacy auth). See ${TPL_DIR}/entra-conditional-access.starter.json."

  # Subscription-level resource lock (CanNotDelete) — guidance only.
  local locks; locks="$(az_run_json lock list --subscription "$sub_id" 2>/dev/null \
    | jq 'length' 2>/dev/null || printf '0')"
  if [[ "${locks:-0}" -gt 0 ]]; then
    log_ok "subscription" "locks" "${locks} subscription-scoped lock(s) present."
  else
    log_warn "subscription" "locks" "no subscription-scoped locks. Consider 'CanNotDelete' on production. Run: az lock create -n cannotdelete-prod --lock-type CanNotDelete"
  fi
}
