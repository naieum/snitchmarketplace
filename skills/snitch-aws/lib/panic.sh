# lib/panic.sh — incident response fast-path.
# Mutates AWS. Each subaction prints a banner before mutating; the dispatcher in
# snitch-aws.sh trusts that the user already agreed. Every change writes a state
# record to ${STATE_DIR}/panic-<ts>.json so `panic restore` can reverse it.
#
# Exports: run_panic

_panic_ts() { date -u +%Y%m%dT%H%M%SZ; }

# _panic_record <area> <prior_json> <set_json> [extra_json]
_panic_record() {
  local area="$1" prior="$2" set_to="$3" extra="${4:-{\}}"
  local ts; ts="$(_panic_ts)"
  local out="${STATE_DIR}/panic-${ts}.json"
  jq -n \
    --arg ts "$ts" \
    --arg area "$area" \
    --argjson prior "$prior" \
    --argjson set "$set_to" \
    --argjson extra "$extra" \
    '{ts:$ts, area:$area, prior:$prior, set:$set, extra:$extra}' > "$out"
  printf '%s' "$out"
}

_panic_banner() {
  printf '\n!! PANIC ACTION: %s !!\n\n' "$1"
}

# _panic_revoke_key <access-key-id>
# Marks the key Inactive. Identifies the user via list-users + list-access-keys.
_panic_revoke_key() {
  local kid="${1:-}"
  if [[ -z "$kid" ]]; then
    log_fail "panic" "revoke-key" "usage: panic revoke-key <access-key-id>"
    return 2
  fi
  _panic_banner "deactivating IAM access key ${kid}"
  # Find the user.
  local user=""
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    if aws_run iam list-access-keys --user-name "$u" --output text --query 'AccessKeyMetadata[].AccessKeyId' 2>/dev/null | grep -q -w "$kid"; then
      user="$u"; break
    fi
  done < <(aws_run_json iam list-users 2>/dev/null | jq -r '.Users[]?.UserName')
  if [[ -z "$user" ]]; then
    log_fail "panic" "revoke-key" "Could not find a user owning access key ${kid}."
    return 3
  fi
  if aws_run iam update-access-key --user-name "$user" --access-key-id "$kid" --status Inactive >/dev/null 2>&1; then
    local rec
    rec="$(_panic_record "iam-access-key" "{\"status\":\"Active\"}" "{\"status\":\"Inactive\"}" \
      "$(jq -n --arg u "$user" --arg k "$kid" '{user:$u, access_key_id:$k, kind:"access_key"}')")"
    log_ok "panic" "revoke-key" "Access key ${kid} (user ${user}) set to Inactive (state: ${rec})."
  else
    log_fail "panic" "revoke-key" "Could not deactivate ${kid}. ${AWSSEC_LAST_STDERR}"
    return 3
  fi
}

# _panic_quarantine_role <role-name>
# Attaches AWS-managed AWSDenyAll policy. Idempotent.
_panic_quarantine_role() {
  local role="${1:-}"
  if [[ -z "$role" ]]; then
    log_fail "panic" "quarantine-role" "usage: panic quarantine-role <role-name>"
    return 2
  fi
  _panic_banner "attaching AWSDenyAll to role ${role}"
  local arn="arn:aws:iam::aws:policy/AWSDenyAll"
  local already
  already="$(aws_run iam list-attached-role-policies --role-name "$role" --output text --query 'AttachedPolicies[].PolicyArn' 2>/dev/null | grep -c "AWSDenyAll" || true)"
  if [[ "${already:-0}" -gt 0 ]]; then
    log_ok "panic" "quarantine-role" "${role} already has AWSDenyAll attached."
    return 0
  fi
  if aws_run iam attach-role-policy --role-name "$role" --policy-arn "$arn" >/dev/null 2>&1; then
    local rec
    rec="$(_panic_record "iam-role" "{}" "{\"AttachedPolicy\":\"AWSDenyAll\"}" \
      "$(jq -n --arg r "$role" '{role:$r, policy_arn:"arn:aws:iam::aws:policy/AWSDenyAll", kind:"role_policy"}')")"
    log_ok "panic" "quarantine-role" "${role} quarantined with AWSDenyAll (state: ${rec})."
  else
    log_fail "panic" "quarantine-role" "Could not attach AWSDenyAll to ${role}. ${AWSSEC_LAST_STDERR}"
    return 3
  fi
}

# _panic_block_ip <ip-or-cidr>
# Adds the IP to a managed IPSet associated with a regional+CloudFront WAF ACL.
# We create the IPSet on first use; subsequent calls update the ACL.
_panic_block_ip() {
  local ip="${1:-}"
  if [[ -z "$ip" ]]; then
    log_fail "panic" "block-ip" "usage: panic block-ip <ip-or-cidr>"
    return 2
  fi
  [[ "$ip" != */* ]] && ip="${ip}/32"
  _panic_banner "adding ${ip} to snitch-aws panic IPSet (REGIONAL scope)"
  local set_name="snitch-aws-panic-block"
  local region; region="$(aws_pick_region)"
  local existing
  existing="$(aws_run_json wafv2 list-ip-sets --scope REGIONAL --region "$region" 2>/dev/null | jq -r --arg n "$set_name" '.IPSets[]? | select(.Name==$n) | .Id')"
  local set_id lock_token
  if [[ -z "$existing" ]]; then
    local create
    create="$(aws_run_json wafv2 create-ip-set --scope REGIONAL --region "$region" \
      --name "$set_name" --description "snitch-aws panic IPSet" \
      --ip-address-version IPV4 --addresses "$ip" 2>/dev/null)"
    set_id="$(jq -r '.Summary.Id // ""' <<<"$create")"
    if [[ -z "$set_id" ]]; then
      log_fail "panic" "block-ip" "Could not create IPSet. ${AWSSEC_LAST_STDERR}"
      return 3
    fi
    log_ok "panic" "block-ip" "Created IPSet ${set_name} (${set_id}) with ${ip}."
  else
    set_id="$existing"
    local meta
    meta="$(aws_run_json wafv2 get-ip-set --scope REGIONAL --region "$region" --name "$set_name" --id "$set_id" 2>/dev/null)"
    lock_token="$(jq -r '.LockToken' <<<"$meta")"
    local current
    current="$(jq -r '.IPSet.Addresses[]?' <<<"$meta")"
    if grep -qx "$ip" <<<"$current"; then
      log_ok "panic" "block-ip" "${ip} already present in IPSet ${set_name}."
      return 0
    fi
    local merged
    merged="$(printf '%s\n%s' "$current" "$ip" | sort -u | jq -R . | jq -s .)"
    if aws_run wafv2 update-ip-set --scope REGIONAL --region "$region" \
      --name "$set_name" --id "$set_id" --lock-token "$lock_token" \
      --addresses "$ip" $(printf '%s ' $current) >/dev/null 2>&1; then
      log_ok "panic" "block-ip" "Added ${ip} to IPSet ${set_name}."
    else
      log_fail "panic" "block-ip" "Could not update IPSet. ${AWSSEC_LAST_STDERR}"
      return 3
    fi
    : "$merged" # quiet -u
  fi
  local rec
  rec="$(_panic_record "wafv2-ipset" "{}" "{\"set_name\":\"$set_name\",\"ip\":\"$ip\"}" \
    "$(jq -n --arg s "$set_name" --arg id "$set_id" --arg i "$ip" --arg r "$region" '{set_name:$s, set_id:$id, ip:$i, region:$r, kind:"ipset"}')")"
  log_ok "panic" "block-ip" "panic state recorded: ${rec}"
  log_warn "panic" "block-ip" "Reminder: associate ${set_name} with a Web ACL on your ALB / CloudFront — IPSet alone does not block traffic."
}

# _panic_restore_one <state-file>
_panic_restore_one() {
  local f="$1"
  local kind area
  area="$(jq -r '.area // ""' "$f" 2>/dev/null)"
  kind="$(jq -r '.extra.kind // .area // ""' "$f" 2>/dev/null)"
  case "$kind" in
    access_key)
      local user kid
      user="$(jq -r '.extra.user' "$f")"
      kid="$(jq -r '.extra.access_key_id' "$f")"
      if aws_run iam update-access-key --user-name "$user" --access-key-id "$kid" --status Active >/dev/null 2>&1; then
        log_ok "panic" "restore/access-key" "Reactivated ${kid} on ${user}."
      else
        log_fail "panic" "restore/access-key" "Could not reactivate ${kid}. ${AWSSEC_LAST_STDERR}"
      fi
      ;;
    role_policy)
      local role
      role="$(jq -r '.extra.role' "$f")"
      if aws_run iam detach-role-policy --role-name "$role" --policy-arn "arn:aws:iam::aws:policy/AWSDenyAll" >/dev/null 2>&1; then
        log_ok "panic" "restore/quarantine-role" "Detached AWSDenyAll from ${role}."
      else
        log_fail "panic" "restore/quarantine-role" "Could not detach. ${AWSSEC_LAST_STDERR}"
      fi
      ;;
    ipset)
      local set_id set_name region ip
      set_id="$(jq -r '.extra.set_id' "$f")"
      set_name="$(jq -r '.extra.set_name' "$f")"
      region="$(jq -r '.extra.region' "$f")"
      ip="$(jq -r '.extra.ip' "$f")"
      local meta
      meta="$(aws_run_json wafv2 get-ip-set --scope REGIONAL --region "$region" --name "$set_name" --id "$set_id" 2>/dev/null)"
      local lock; lock="$(jq -r '.LockToken' <<<"$meta")"
      local addrs; addrs="$(jq -r '.IPSet.Addresses[]?' <<<"$meta" | grep -v -x "$ip" | tr '\n' ' ')"
      if aws_run wafv2 update-ip-set --scope REGIONAL --region "$region" \
        --name "$set_name" --id "$set_id" --lock-token "$lock" \
        --addresses $addrs >/dev/null 2>&1; then
        log_ok "panic" "restore/block-ip" "Removed ${ip} from IPSet ${set_name}."
      else
        log_fail "panic" "restore/block-ip" "Could not remove ${ip}. ${AWSSEC_LAST_STDERR}"
      fi
      ;;
    *)
      log_warn "panic" "restore" "Unknown panic record kind in ${f} (area=${area})"
      ;;
  esac
  mkdir -p "${STATE_DIR}/panic-restored"
  mv "$f" "${STATE_DIR}/panic-restored/" 2>/dev/null || true
}

_panic_restore() {
  _panic_banner "rolling back every recorded panic action"
  local files
  files="$(ls -1t "${STATE_DIR}"/panic-*.json 2>/dev/null || true)"
  if [[ -z "$files" ]]; then
    log_info "no panic state files to restore"
    return 0
  fi
  local f
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    [[ "$f" == *"/panic-restored/"* ]] && continue
    _panic_restore_one "$f" || true
  done <<<"$files"
  log_ok "panic" "restore" "all recorded panic actions rolled back"
}

# run_panic <action> [args]
run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    revoke-key)        _panic_revoke_key "$@" ;;
    quarantine-role)   _panic_quarantine_role "$@" ;;
    block-ip)          _panic_block_ip "$@" ;;
    restore)           _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic <revoke-key <id>|quarantine-role <name>|block-ip <ip>|restore>"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: ${action}"
      return 2 ;;
  esac
}
