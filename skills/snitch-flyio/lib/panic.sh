# lib/panic.sh — incident response actions.
# Exports: run_panic <action> [args...]
#
# Actions:
#   suspend <app>           — fly apps suspend (stop all machines, preserve state)
#   revoke-token <token-id> — fly tokens revoke
#   scale-to-zero <app>     — fly scale count 0 (stops everything; volumes preserved)
#   restore                 — replay reverse actions from .state/panic-<ts>.json
#
# Every mutating action records its before-state to .state/panic-<ts>.json so
# `restore` can roll back.

run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    suspend)       _panic_suspend "$@" ;;
    revoke-token)  _panic_revoke_token "$@" ;;
    scale-to-zero) _panic_scale_to_zero "$@" ;;
    restore)       _panic_restore "$@" ;;
    "")
      log_fail "panic" "usage" "panic requires an action. Valid: suspend | revoke-token | scale-to-zero | restore."
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: $action. Valid: suspend | revoke-token | scale-to-zero | restore."
      return 2 ;;
  esac
}

_panic_record() {
  local action="$1" payload="$2"
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local f="${STATE_DIR}/panic-${ts}.json"
  printf '%s\n' "$payload" > "$f"
  printf '%s\n' "$f" >> "${STATE_DIR}/panic-stack.txt"
  log_info "panic action recorded → ${f}"
}

_panic_suspend() {
  local app="${1:-}"
  if [[ -z "$app" ]]; then
    log_fail "panic" "suspend-usage" "panic suspend requires an app name."
    return 2
  fi
  local before; before="$(fly_run_json status -a "$app" 2>/dev/null || printf '{}')"
  _panic_record "suspend" "$(jq -n --arg app "$app" --arg action "suspend" --argjson before "$before" \
    '{action:$action, app:$app, before:$before, restore_cmd:("fly machines start --all -a " + $app)}')"
  fly_run apps suspend "$app" >/dev/null
  if [[ $FLYSEC_LAST_RC -eq 0 ]]; then
    log_ok "panic" "suspend" "Suspended app ${app}. Restore with: fly machines start --all -a ${app}"
  else
    log_fail "panic" "suspend" "Failed to suspend ${app}. stderr: ${FLYSEC_LAST_STDERR}"
    return 3
  fi
}

_panic_revoke_token() {
  local id="${1:-}"
  if [[ -z "$id" ]]; then
    log_fail "panic" "revoke-usage" "panic revoke-token requires a token id."
    return 2
  fi
  _panic_record "revoke-token" "$(jq -n --arg id "$id" --arg action "revoke-token" \
    '{action:$action, token_id:$id, before:null, restore_cmd:"<cannot restore — recreate the token from scratch>"}')"
  fly_run tokens revoke "$id" >/dev/null
  if [[ $FLYSEC_LAST_RC -eq 0 ]]; then
    log_ok "panic" "revoke" "Revoked token ${id}. Token revocation is irreversible."
  else
    log_fail "panic" "revoke" "Failed to revoke ${id}. stderr: ${FLYSEC_LAST_STDERR}"
    return 3
  fi
}

_panic_scale_to_zero() {
  local app="${1:-}"
  if [[ -z "$app" ]]; then
    log_fail "panic" "scale-usage" "panic scale-to-zero requires an app name."
    return 2
  fi
  # Volume safety: if the app has volumes, refuse without explicit env override.
  local v; v="$(fly_run_json volumes list -a "$app" 2>/dev/null || printf '[]')"
  local vc; vc="$(jq -r 'length' <<<"$v" 2>/dev/null || printf '0')"
  if [[ "$vc" -gt 0 && -z "${FLYSEC_PANIC_FORCE:-}" ]]; then
    log_fail "panic" "scale-zero-volume" "App ${app} has ${vc} volume(s). Scaling to zero stops machines but volumes persist; you may still want this for rapid cost cut. Re-run with FLYSEC_PANIC_FORCE=1 to confirm."
    return 2
  fi
  local before; before="$(fly_run_json machines list -a "$app" 2>/dev/null || printf '[]')"
  _panic_record "scale-to-zero" "$(jq -n --arg app "$app" --arg action "scale-to-zero" --argjson before "$before" \
    '{action:$action, app:$app, before:$before, restore_cmd:("fly scale count " + ((($before | length) | tostring)) + " -a " + $app)}')"
  fly_run scale count 0 -a "$app" >/dev/null
  if [[ $FLYSEC_LAST_RC -eq 0 ]]; then
    log_ok "panic" "scale-zero" "Scaled ${app} to 0 machines."
    log_info "Restore: fly scale count $(jq -r 'length' <<<"$before") -a ${app}"
  else
    log_fail "panic" "scale-zero" "Failed: ${FLYSEC_LAST_STDERR}"
    return 3
  fi
}

_panic_restore() {
  local stack="${STATE_DIR}/panic-stack.txt"
  if [[ ! -f "$stack" ]]; then
    log_warn "panic" "restore" "No panic-stack.txt; nothing to restore."
    return 0
  fi
  log_section "panic restore"
  local f
  while IFS= read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    local action app cmd
    action="$(jq -r '.action' "$f")"
    app="$(jq -r '.app // ""' "$f")"
    cmd="$(jq -r '.restore_cmd // ""' "$f")"
    log_info "Reverse action: ${action} ${app}  →  ${cmd}"
    if [[ -n "$cmd" && "$cmd" != "<cannot"* ]]; then
      log_info "  Run manually: ${cmd}"
    fi
  done < <(tac "$stack" 2>/dev/null || tail -r "$stack" 2>/dev/null)
  log_info "panic restore is human-driven — execute the commands above in order. Then: rm ${stack}"
}
