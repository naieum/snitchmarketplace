# lib/drift.sh — diff current findings against the latest snapshot.
# Findings TSV format (from log.sh):
#   STATUS \t area \t key \t message \t docs_url

_drift_status_for_key() {
  local file="$1" area="$2" key="$3"
  awk -F'\t' -v a="$area" -v k="$key" '$2==a && $3==k {print $1; exit}' "$file"
}

_drift_message_for_key() {
  local file="$1" area="$2" key="$3"
  awk -F'\t' -v a="$area" -v k="$key" '$2==a && $3==k {print $4; exit}' "$file"
}

drift_run() {
  local prior="${STATE_DIR}/snapshot-latest.tsv"
  local current="${AZSEC_FINDINGS_FILE}"

  if [[ -L "$prior" && ! -e "$prior" ]]; then return 0; fi
  if [[ ! -f "$prior" ]]; then return 0; fi
  if [[ ! -f "$current" ]]; then return 0; fi

  local prior_keys current_keys all_keys
  prior_keys="$(awk -F'\t' '{print $2"\t"$3}' "$prior" | sort -u)"
  current_keys="$(awk -F'\t' '{print $2"\t"$3}' "$current" | sort -u)"
  all_keys="$(printf '%s\n%s\n' "$prior_keys" "$current_keys" | sort -u)"

  local area key prev_status cur_status cur_msg
  while IFS=$'\t' read -r area key; do
    [[ -z "$area" && -z "$key" ]] && continue
    prev_status="$(_drift_status_for_key "$prior"   "$area" "$key")"
    cur_status="$( _drift_status_for_key "$current" "$area" "$key")"
    cur_msg="$(   _drift_message_for_key "$current" "$area" "$key")"
    if [[ -z "$prev_status" && -n "$cur_status" ]]; then
      log_info "new finding: [${area}/${key}] ${cur_msg}"
      continue
    fi
    if [[ -n "$prev_status" && -z "$cur_status" ]]; then
      log_info "finding cleared: [${area}/${key}]"
      continue
    fi
    if [[ "$prev_status" == "$cur_status" ]]; then continue; fi
    if [[ "$prev_status" == "OK" && ( "$cur_status" == "WARN" || "$cur_status" == "FAIL" ) ]]; then
      log_warn "drift" "${area}/${key}" "regressed: was OK, now ${cur_status}"
    elif [[ "$prev_status" == "FAIL" && "$cur_status" == "OK" ]]; then
      log_ok "drift" "${area}/${key}" "improved: was FAIL, now OK"
    elif [[ "$prev_status" == "WARN" && "$cur_status" == "OK" ]]; then
      log_ok "drift" "${area}/${key}" "improved: was WARN, now OK"
    elif [[ "$prev_status" == "WARN" && "$cur_status" == "FAIL" ]]; then
      log_warn "drift" "${area}/${key}" "regressed: was WARN, now FAIL"
    else
      log_info "[${area}/${key}] status changed: ${prev_status} → ${cur_status}"
    fi
  done <<<"$all_keys"
}
