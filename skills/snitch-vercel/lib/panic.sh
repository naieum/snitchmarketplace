# lib/panic.sh — incident response fast-path.
# Actions:
#   pause-deploys         — disable production auto-deploys (set git production deploys to "manual")
#   revoke-token <id>     — DELETE /v5/user/tokens/<id>
#   lock-production       — set ssoProtection={deploymentType:"all"} until restore
#   restore               — undo every recorded action under .state/panic-*.json
# Records every mutation to .state/panic-<ts>.json for restore.

run_panic() {
  local action="${1:-}"; shift || true
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  case "$action" in
    pause-deploys)   _panic_pause_deploys "$ts" "$@" ;;
    revoke-token)    _panic_revoke_token "$ts" "$@" ;;
    lock-production) _panic_lock_production "$ts" "$@" ;;
    restore)         _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic requires an action. Valid: pause-deploys | revoke-token <id> | lock-production | restore"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: $action"
      return 2 ;;
  esac
}

_panic_record() {
  local ts="$1" action="$2" before="$3" after="$4"
  local file="${STATE_DIR}/panic-${ts}-${action}.json"
  jq -n --arg ts "$ts" --arg action "$action" --argjson before "$before" --argjson after "$after" \
    '{ ts: $ts, action: $action, before: $before, after: $after }' > "$file" 2>/dev/null
  log_info "panic recorded → ${file}"
}

_panic_pause_deploys() {
  local ts="$1"
  local project_id; project_id="$(vercel_pick_project 2>/dev/null || true)"
  if [[ -z "$project_id" ]]; then
    log_fail "panic" "pick" "No project selected. Set VRCSEC_PROJECT_ID."
    return 3
  fi
  local before; before="$(vrc_get "/v9/projects/${project_id}")" || before='{}'
  local pre; pre="$(jq '{ ssoProtection, passwordProtection, autoAssignCustomDomains, gitForkProtection }' <<<"$before")"
  local payload='{"ssoProtection":{"deploymentType":"all"},"gitForkProtection":true}'
  vrc_patch "/v9/projects/${project_id}" "$payload" >/dev/null && \
    log_ok "panic" "pause-deploys" "Project ${project_id}: SSO protection on all + git fork protection on." || \
    { log_fail "panic" "pause-deploys" "PATCH failed (status ${VRCSEC_LAST_STATUS}). $(vrc_last_error)"; return 3; }
  local after; after="$(vrc_get "/v9/projects/${project_id}")" || after='{}'
  local post; post="$(jq '{ ssoProtection, passwordProtection, autoAssignCustomDomains, gitForkProtection }' <<<"$after")"
  _panic_record "$ts" "pause-deploys" "$pre" "$post"
}

_panic_revoke_token() {
  local ts="$1" token_id="${2:-}"
  if [[ -z "$token_id" ]]; then
    log_fail "panic" "revoke-token" "Pass a token id. Find with: snitch-vercel.sh state account tokens"
    return 2
  fi
  vrc_delete "/v3/user/tokens/${token_id}" >/dev/null && \
    log_ok "panic" "revoke-token" "Token ${token_id} revoked." || \
    { log_fail "panic" "revoke-token" "DELETE failed (status ${VRCSEC_LAST_STATUS}). $(vrc_last_error)"; return 3; }
  _panic_record "$ts" "revoke-token" "{\"id\":\"${token_id}\"}" "{\"deleted\":true}"
}

_panic_lock_production() {
  local ts="$1"
  local project_id; project_id="$(vercel_pick_project 2>/dev/null || true)"
  if [[ -z "$project_id" ]]; then
    log_fail "panic" "pick" "No project selected. Set VRCSEC_PROJECT_ID."
    return 3
  fi
  local before; before="$(vrc_get "/v9/projects/${project_id}")" || before='{}'
  local pre; pre="$(jq '{ ssoProtection, passwordProtection }' <<<"$before")"
  local payload='{"ssoProtection":{"deploymentType":"all"}}'
  vrc_patch "/v9/projects/${project_id}" "$payload" >/dev/null && \
    log_ok "panic" "lock-production" "Project ${project_id}: ssoProtection set to 'all'." || \
    { log_fail "panic" "lock-production" "PATCH failed (status ${VRCSEC_LAST_STATUS}). $(vrc_last_error)"; return 3; }
  local after; after="$(vrc_get "/v9/projects/${project_id}")" || after='{}'
  local post; post="$(jq '{ ssoProtection, passwordProtection }' <<<"$after")"
  _panic_record "$ts" "lock-production" "$pre" "$post"
}

_panic_restore() {
  local f
  if ! compgen -G "${STATE_DIR}/panic-*.json" >/dev/null 2>&1; then
    log_warn "panic" "restore" "No panic actions recorded; nothing to restore."
    return 0
  fi
  # Reverse-chronological replay of "before" payloads.
  for f in $(ls -1 "${STATE_DIR}"/panic-*.json 2>/dev/null | sort -r); do
    local action before
    action="$(jq -r '.action' "$f")"
    before="$(jq -r '.before' "$f")"
    case "$action" in
      pause-deploys|lock-production)
        local project_id; project_id="$(vercel_pick_project 2>/dev/null || true)"
        if [[ -z "$project_id" ]]; then
          log_warn "panic" "restore-${action}" "No project context for ${f}; skipping."
          continue
        fi
        # Reconstruct a minimal patch that restores SSO + fork protection states.
        local payload
        payload="$(jq -n --argjson b "$before" '{
          ssoProtection: ($b.ssoProtection // null),
          passwordProtection: ($b.passwordProtection // null),
          gitForkProtection: ($b.gitForkProtection // null)
        }')"
        vrc_patch "/v9/projects/${project_id}" "$payload" >/dev/null && \
          log_ok "panic" "restore-${action}" "Restored from ${f}." || \
          log_fail "panic" "restore-${action}" "PATCH failed (status ${VRCSEC_LAST_STATUS}). $(vrc_last_error)"
        ;;
      revoke-token)
        log_warn "panic" "restore-revoke-token" "Cannot recreate a revoked token automatically — generate a new one at https://vercel.com/account/tokens."
        ;;
      *)
        log_warn "panic" "restore" "Unknown action in ${f}; skipping."
        ;;
    esac
    mv "$f" "${f%.json}.applied.json" 2>/dev/null || true
  done
}
