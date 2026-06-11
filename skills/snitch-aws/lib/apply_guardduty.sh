# lib/apply_guardduty.sh — GuardDuty hardening:
#  - Enable a detector if none exists in the active region.
# Exposes: apply_guardduty [args]

apply_guardduty() {
  log_section "GuardDuty hardening"

  local detectors
  detectors="$(aws_run_json guardduty list-detectors 2>/dev/null | jq -r '.DetectorIds[]?')"
  if [[ -n "$detectors" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      local g
      g="$(aws_run_json guardduty get-detector --detector-id "$d" 2>/dev/null)"
      local status; status="$(jq -r '.Status // "DISABLED"' <<<"$g")"
      if [[ "$status" == "ENABLED" ]]; then
        log_ok "guardduty" "detector/${d}" "Detector ${d} ENABLED."
      else
        if aws_run guardduty update-detector --detector-id "$d" --enable >/dev/null 2>&1; then
          log_ok "guardduty" "detector/${d}" "Re-enabled detector ${d}."
        else
          log_fail "guardduty" "detector/${d}" "Could not re-enable ${d}. ${AWSSEC_LAST_STDERR}"
        fi
      fi
    done <<<"$detectors"
  else
    if aws_run guardduty create-detector --enable >/dev/null 2>&1; then
      log_ok "guardduty" "detector" "Created and enabled GuardDuty detector in this region."
    else
      log_fail "guardduty" "detector" "Could not create detector. ${AWSSEC_LAST_STDERR}"
    fi
  fi
  return 0
}
