# lib/panic.sh — incident response fast-path.
# Mutates Azure. Each subaction prints a one-line consequence banner before
# mutating; the dispatcher in snitch-azure.sh trusts that the user already agreed.
# Every change writes a state record to ${STATE_DIR}/panic-<ts>.json so
# `panic restore` can reverse it.

_panic_ts() { date -u +%Y%m%dT%H%M%SZ; }

_panic_record() {
  local area="$1" prior="$2" set_to="$3"; shift 3
  local ts; ts="$(_panic_ts)"
  local out="${STATE_DIR}/panic-${ts}.json"
  jq -n \
    --arg ts "$ts" \
    --arg area "$area" \
    --argjson prior "$prior" \
    --argjson set "$set_to" \
    --argjson extra "${1:-{\}}" \
    '{ts:$ts, area:$area, prior:$prior, set:$set, extra:$extra}' \
    > "$out"
  printf '%s' "$out"
}

_panic_banner() { printf '\n!! PANIC ACTION: %s !!\n\n' "$1"; }

# _panic_lockdown <rg> — apply CanNotDelete lock + emergency Conditional Access guidance.
_panic_lockdown() {
  local rg="$1"
  if [[ -z "$rg" ]]; then
    log_fail "panic" "lockdown" "usage: panic lockdown <resource-group>"
    return 2
  fi
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  _panic_banner "applying CanNotDelete lock on resource group ${rg} in subscription ${sub_id}"
  if az_run lock create --name azsec-panic-lock --resource-group "$rg" --lock-type CanNotDelete --subscription "$sub_id" --notes "azure-secure:panic" >/dev/null 2>&1; then
    local rec; rec="$(_panic_record "lock" 'null' "\"applied\"" "$(jq -n --arg rg "$rg" --arg name "azsec-panic-lock" '{rg:$rg, name:$name, kind:"resource_group_lock"}')")"
    log_ok "panic" "lockdown" "CanNotDelete lock applied (state: ${rec})"
  else
    log_fail "panic" "lockdown" "could not apply lock. $(az_last_error)"
    return 3
  fi
}

# _panic_nsg_deny_all <nsg-name> — emit denial guidance + add a top-priority deny.
_panic_nsg_deny_all() {
  local target="$1"
  if [[ -z "$target" ]]; then
    log_fail "panic" "nsg-deny-all" "usage: panic nsg-deny-all <nsg-name>"
    return 2
  fi
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local rg
  rg="$(az_run_json network nsg list --subscription "$sub_id" --query "[?name=='${target}'].resourceGroup | [0]" 2>/dev/null \
    | jq -r '. // empty')"
  if [[ -z "$rg" ]]; then
    log_fail "panic" "nsg-deny-all" "NSG ${target} not found in subscription"
    return 3
  fi
  _panic_banner "adding top-priority Deny-All-Inbound rule on NSG ${target} (rg=${rg})"
  if az_run network nsg rule create --nsg-name "$target" --resource-group "$rg" --subscription "$sub_id" \
      --name azsec-panic-deny-all --priority 100 --direction Inbound --access Deny \
      --protocol '*' --source-address-prefixes '*' --source-port-ranges '*' \
      --destination-address-prefixes '*' --destination-port-ranges '*' >/dev/null 2>&1; then
    local rec; rec="$(_panic_record "nsg_rule" 'null' "\"applied\"" "$(jq -n --arg name "$target" --arg rg "$rg" --arg rule "azsec-panic-deny-all" '{nsg:$name, rg:$rg, rule:$rule, kind:"nsg_panic_rule"}')")"
    log_ok "panic" "nsg-deny-all" "deny-all rule added (state: ${rec})"
  else
    log_fail "panic" "nsg-deny-all" "could not add rule. $(az_last_error)"
    return 3
  fi
}

# _panic_keyvault_rotate <vault> — print rotation guidance for keys.
_panic_keyvault_rotate() {
  local vault="$1"
  if [[ -z "$vault" ]]; then
    log_fail "panic" "keyvault-rotate" "usage: panic keyvault-rotate <vault-name>"
    return 2
  fi
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  _panic_banner "listing rotateable keys + secrets in vault ${vault} for emergency rotation"
  local keys secrets
  keys="$(az_run_json keyvault key list --vault-name "$vault" --subscription "$sub_id" 2>/dev/null \
    | jq -r '.[].name' 2>/dev/null || true)"
  secrets="$(az_run_json keyvault secret list --vault-name "$vault" --subscription "$sub_id" 2>/dev/null \
    | jq -r '.[].name' 2>/dev/null || true)"
  log_warn "panic" "keyvault-rotate" "rotation must be done with downstream coordination — DO NOT silently rotate. Listing for the user:"
  printf 'KEYS:\n%s\nSECRETS:\n%s\n' "$keys" "$secrets"
  log_info "to rotate a key (creates a new version): az keyvault key rotate --vault-name ${vault} --name <key-name>"
}

# _panic_policy_emergency — assign a built-in restrictive initiative.
_panic_policy_emergency() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  _panic_banner "assigning emergency built-in 'Audit insecure configurations' initiative on subscription ${sub_id}"
  log_warn "panic" "policy-emergency" "Recommend assigning Microsoft cloud security benchmark initiative. Run: az policy assignment create --policy-set-definition 1f3afdf9-d0c9-4c3d-847f-89da613e70a8 --display-name azsec-panic-emergency --subscription ${sub_id}"
}

# _panic_restore_one <state-file>
_panic_restore_one() {
  local f="$1"
  local kind; kind="$(jq -r '.extra.kind // .area // empty' "$f" 2>/dev/null)"
  case "$kind" in
    resource_group_lock)
      local rg name
      rg="$(jq -r '.extra.rg' "$f")"
      name="$(jq -r '.extra.name' "$f")"
      if az_run lock delete --name "$name" --resource-group "$rg" >/dev/null 2>&1; then
        log_ok "panic" "restore/lock" "deleted lock ${name} on ${rg}"
      else
        log_fail "panic" "restore/lock" "could not delete lock ${name}"
      fi
      ;;
    nsg_panic_rule)
      local nsg rg rule
      nsg="$(jq -r '.extra.nsg' "$f")"
      rg="$(jq -r '.extra.rg' "$f")"
      rule="$(jq -r '.extra.rule' "$f")"
      if az_run network nsg rule delete --nsg-name "$nsg" --resource-group "$rg" --name "$rule" >/dev/null 2>&1; then
        log_ok "panic" "restore/nsg-rule" "deleted ${rule} on ${nsg}"
      else
        log_fail "panic" "restore/nsg-rule" "could not delete rule ${rule}"
      fi
      ;;
    *)
      log_warn "panic" "restore" "unknown record kind in ${f}"
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

run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    lockdown)         _panic_lockdown "${1:-}" ;;
    nsg-deny-all)     _panic_nsg_deny_all "${1:-}" ;;
    keyvault-rotate)  _panic_keyvault_rotate "${1:-}" ;;
    policy-emergency) _panic_policy_emergency ;;
    restore)          _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic <lockdown <rg>|nsg-deny-all <nsg>|keyvault-rotate <vault>|policy-emergency|restore>"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: ${action}"
      return 2 ;;
  esac
}
