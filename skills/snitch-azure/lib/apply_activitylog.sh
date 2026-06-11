# lib/apply_activitylog.sh — diagnostic-settings on the subscription should
# stream to Log Analytics + Storage + Event Hub for SIEM.

apply_activitylog() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local settings
  settings="$(az_run_json monitor diagnostic-settings subscription list --subscription "$sub_id" 2>/dev/null \
    | jq '.value // []' 2>/dev/null || printf '[]')"
  local n; n="$(jq -r 'length' <<<"$settings")"
  if [[ "$n" == "0" ]]; then
    log_warn "activitylog" "settings" "no subscription diagnostic settings. Stream activity log to Log Analytics + Storage. Run: az monitor diagnostic-settings subscription create -n primary --workspace <ws-id>"
    return 0
  fi
  local has_la has_storage has_eh
  has_la="$(jq '[.[] | select(.properties.workspaceId != null and .properties.workspaceId != "")] | length' <<<"$settings" 2>/dev/null || printf '0')"
  has_storage="$(jq '[.[] | select(.properties.storageAccountId != null and .properties.storageAccountId != "")] | length' <<<"$settings" 2>/dev/null || printf '0')"
  has_eh="$(jq '[.[] | select(.properties.eventHubAuthorizationRuleId != null and .properties.eventHubAuthorizationRuleId != "")] | length' <<<"$settings" 2>/dev/null || printf '0')"
  if [[ "${has_la:-0}" -gt 0 ]]; then
    log_ok "activitylog" "la" "activity log streaming to Log Analytics."
  else
    log_warn "activitylog" "la" "no Log Analytics target. Sentinel needs this."
  fi
  if [[ "${has_storage:-0}" -gt 0 ]]; then
    log_ok "activitylog" "storage" "activity log archived to Storage."
  else
    log_warn "activitylog" "storage" "no Storage target. Long-term retention needs this."
  fi
  if [[ "${has_eh:-0}" -gt 0 ]]; then
    log_ok "activitylog" "eventhub" "activity log streaming to Event Hub."
  else
    log_warn "activitylog" "eventhub" "no Event Hub target. External SIEM needs this."
  fi
}
