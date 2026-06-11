# lib/apply_kms.sh — KMS hardening:
#  - Enable annual key rotation on every customer-managed symmetric key
#    that has rotation disabled (read-first; no-op when on).
# Exposes: apply_kms [args]

apply_kms() {
  log_section "KMS hardening"

  local ids
  ids="$(aws_run_json kms list-keys 2>/dev/null | jq -r '.Keys[]?.KeyId' 2>/dev/null)"
  while IFS= read -r k; do
    [[ -z "$k" ]] && continue
    local meta mgr spec state rot
    meta="$(aws_run_json kms describe-key --key-id "$k" 2>/dev/null | jq '.KeyMetadata // {}')"
    mgr="$(jq -r '.KeyManager // ""' <<<"$meta")"
    spec="$(jq -r '.KeySpec // ""' <<<"$meta")"
    state="$(jq -r '.KeyState // ""' <<<"$meta")"
    [[ "$mgr" != "CUSTOMER" ]] && continue
    [[ "$state" != "Enabled" ]] && { log_info "kms key ${k} state=${state} (skipping)"; continue; }
    [[ "$spec" != "SYMMETRIC_DEFAULT" ]] && { log_info "kms key ${k} spec=${spec} (rotation N/A)"; continue; }
    rot="$(aws_run_json kms get-key-rotation-status --key-id "$k" 2>/dev/null | jq -r '.KeyRotationEnabled // false')"
    if [[ "$rot" == "true" ]]; then
      log_ok "kms" "rotation/${k}" "Key ${k} already has annual rotation enabled."
    else
      if aws_run kms enable-key-rotation --key-id "$k" >/dev/null 2>&1; then
        log_ok "kms" "rotation/${k}" "Enabled annual key rotation on ${k}."
      else
        log_warn "kms" "rotation/${k}" "Could not enable rotation on ${k}. ${AWSSEC_LAST_STDERR}"
      fi
    fi
  done <<<"$ids"

  return 0
}
