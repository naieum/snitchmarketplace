# lib/panic.sh — incident response fast-path for Railway.
# Mutates Railway state. Each subaction prints a one-line consequence banner
# before mutating; the dispatcher in snitch-railway.sh trusts the user already agreed.
# Every change writes a state record to ${STATE_DIR}/panic-<ts>.json
# so `panic restore` can reverse where reversible.
#
# Exports: run_panic

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

_panic_banner() {
  printf '\n!! PANIC ACTION: %s !!\n\n' "$1"
}

# _panic_suspend_service <service-name>
# Sets numReplicas=0 via GraphQL upsertServiceInstance to halt traffic.
_panic_suspend_service() {
  local svc_name="$1"
  local pid; pid="$(api_pick_project)" || return 3
  local env_id
  env_id="$(_panic_resolve_env_id "$pid")"
  _panic_banner "suspending service ${svc_name} on project ${pid} (numReplicas=0)"

  # Look up service id and current numReplicas.
  local body
  body="$(rw_gql 'query($id:String!){
    project(id:$id){
      services { edges { node { id name serviceInstances { edges { node { id environmentId numReplicas } } } } } }
    }
  }' "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    log_fail "panic" "suspend-service" "could not list services. $(rw_last_error)"
    return 3
  }
  local svc_id prior_replicas
  svc_id="$(jq -r --arg n "$svc_name" '.data.project.services.edges[]?.node | select(.name==$n) | .id' <<<"$body" | head -n 1)"
  if [[ -z "$svc_id" ]]; then
    log_fail "panic" "suspend-service" "service '${svc_name}' not found in project ${pid}"
    return 2
  fi
  prior_replicas="$(jq -r --arg n "$svc_name" --arg eid "$env_id" \
    '.data.project.services.edges[]?.node | select(.name==$n) | .serviceInstances.edges[]?.node | select(.environmentId==$eid) | .numReplicas // 1' \
    <<<"$body" | head -n 1)"

  local mut
  mut='mutation($sid:String!,$eid:String!,$input:ServiceInstanceUpdateInput!){
    serviceInstanceUpdate(serviceId:$sid, environmentId:$eid, input:$input)
  }'
  local vars
  vars="$(jq -nc --arg sid "$svc_id" --arg eid "$env_id" --argjson n 0 \
    '{sid:$sid, eid:$eid, input:{numReplicas:$n}}')"

  local resp
  resp="$(rw_gql "$mut" "$vars" 2>/dev/null)" || {
    log_fail "panic" "suspend-service" "mutation failed. $(rw_last_error)"
    return 3
  }
  local rec
  rec="$(_panic_record "service_replicas" "$(jq -nc --arg n "$prior_replicas" '$n|tonumber? // 1')" '0' \
    "$(jq -nc --arg sid "$svc_id" --arg sname "$svc_name" --arg eid "$env_id" \
       '{service_id:$sid, service_name:$sname, environment_id:$eid, kind:"service_replicas"}')")"
  log_ok "panic" "suspend-service" "${svc_name} suspended (replicas 0). state: ${rec}"
}

# _panic_revoke_token <token-id>
_panic_revoke_token() {
  local tok_id="$1"
  _panic_banner "revoking project token ${tok_id}"
  local mut='mutation($id:String!){ projectTokenDelete(id:$id) }'
  local resp
  resp="$(rw_gql "$mut" "$(jq -nc --arg id "$tok_id" '{id:$id}')" 2>/dev/null)" || {
    log_fail "panic" "revoke-token" "could not delete token. $(rw_last_error)"
    return 3
  }
  local rec; rec="$(_panic_record "project_token" 'null' "$(jq -nc --arg id "$tok_id" '{token_id:$id, kind:"project_token"}')" \
    "$(jq -nc --arg id "$tok_id" '{token_id:$id, kind:"project_token"}')")"
  log_ok "panic" "revoke-token" "token ${tok_id} revoked. state: ${rec} (revocation is NOT reversible)."
}

# _panic_lockdown_db <service-name>
# Recommends + emits commands. Railway has no IP-allowlist mutation surface;
# the canonical lockdown is to remove TCP proxy + rotate the DATABASE_URL.
_panic_lockdown_db() {
  local svc_name="$1"
  _panic_banner "lockdown of database service ${svc_name}: removing public TCP proxy + rotating credential (manual steps)"
  log_warn "panic" "lockdown-db" "Railway databases have no IP-allowlist surface. Lockdown means: 1) delete the public TCP proxy on the DB service, 2) rotate the DB password, 3) re-set DATABASE_URL refs across services."
  log_info "Run these manually after agreeing:"
  log_info "  railway service ${svc_name}"
  log_info "  # In dashboard: Settings → Networking → Remove TCP proxy"
  log_info "  # Then connect via railway connect ${svc_name} and rotate password:"
  log_info "  railway connect ${svc_name}"
  log_info "  # ALTER USER postgres WITH PASSWORD 'NEW_STRONG_PASSWORD';"
  log_info "  # Update the password in DATABASE_URL via:"
  log_info "  railway variables --service ${svc_name} --set DATABASE_URL='postgres://postgres:NEW_STRONG_PASSWORD@<host>:<port>/<db>'"
}

# _panic_resolve_env_id <pid>
_panic_resolve_env_id() {
  local pid="$1"
  local env_name; env_name="$(api_pick_environment)"
  rw_gql 'query($id:String!){ project(id:$id){ environments { edges { node { id name } } } } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null \
    | jq -r --arg n "$env_name" '(.data.project.environments.edges // [])[].node | select(.name==$n) | .id' \
    | head -n 1
}

# _panic_restore_one <state-file>
_panic_restore_one() {
  local f="$1"
  local kind; kind="$(jq -r '.extra.kind // .area' "$f" 2>/dev/null)"
  case "$kind" in
    service_replicas)
      local sid eid prior
      sid="$(jq -r '.extra.service_id' "$f")"
      eid="$(jq -r '.extra.environment_id' "$f")"
      prior="$(jq -r '.prior' "$f")"
      [[ -z "$prior" || "$prior" == "null" ]] && prior=1
      local mut
      mut='mutation($sid:String!,$eid:String!,$input:ServiceInstanceUpdateInput!){
        serviceInstanceUpdate(serviceId:$sid, environmentId:$eid, input:$input)
      }'
      local vars
      vars="$(jq -nc --arg sid "$sid" --arg eid "$eid" --argjson n "$prior" \
        '{sid:$sid, eid:$eid, input:{numReplicas:$n}}')"
      rw_gql "$mut" "$vars" >/dev/null 2>&1 \
        && log_ok "panic" "restore/replicas" "service ${sid} replicas restored to ${prior}" \
        || log_fail "panic" "restore" "could not restore service ${sid}: $(rw_last_error)"
      ;;
    project_token)
      log_warn "panic" "restore/token" "token revocation is NOT reversible. Issue a new token in dashboard."
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
  log_ok "panic" "restore" "all reversible panic actions rolled back"
}

# run_panic <action> [args...]
run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    suspend-service)
      local svc="${1:-}"; shift || true
      [[ -z "$svc" ]] && { log_fail "panic" "usage" "panic suspend-service <service-name>"; return 2; }
      _panic_suspend_service "$svc" ;;
    revoke-token)
      local tid="${1:-}"; shift || true
      [[ -z "$tid" ]] && { log_fail "panic" "usage" "panic revoke-token <token-id>"; return 2; }
      _panic_revoke_token "$tid" ;;
    lockdown-db)
      local svc="${1:-}"; shift || true
      [[ -z "$svc" ]] && { log_fail "panic" "usage" "panic lockdown-db <service-name>"; return 2; }
      _panic_lockdown_db "$svc" ;;
    restore)
      _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic <suspend-service <svc>|revoke-token <id>|lockdown-db <svc>|restore>"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: ${action}"
      return 2 ;;
  esac
}
