# lib/export.sh — read-only JSON snapshot of Railway project + workspace.
# Captures workspace + project + services + env (names only) + volumes +
# databases + tokens + domains + tcp-proxies. Stable, versioned schema.
# Output goes to ./railway-export-<project>-<ts>.json in cwd.
#
# Exports: run_export

run_export() {
  log_section "export"
  api_check_auth_env || return $?
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local pid env_name
  pid="$(api_pick_project 2>/dev/null || printf 'unknown')"
  env_name="$(api_pick_environment 2>/dev/null || printf 'production')"
  log_info "snapshotting project=${pid} env=${env_name}"

  local out_file="./railway-export-${pid}-${ts}.json"

  . "$LIB_DIR/state_workspace.sh"
  . "$LIB_DIR/state_project.sh"
  . "$LIB_DIR/state_services.sh"
  . "$LIB_DIR/state_env.sh"
  . "$LIB_DIR/state_volumes.sh"
  . "$LIB_DIR/state_databases.sh"
  . "$LIB_DIR/state_tokens.sh"
  . "$LIB_DIR/state_domains.sh"
  . "$LIB_DIR/state_tcp_proxies.sh"
  . "$LIB_DIR/state_logs.sh"
  . "$LIB_DIR/state_cost.sh"

  local ws proj svcs envv vols dbs toks doms tcp logs cost
  ws="$(run_state_workspace digest 2>/dev/null || printf '{}')"
  proj="$(run_state_project "$pid" digest 2>/dev/null || printf '{}')"
  svcs="$(run_state_services "$pid" digest 2>/dev/null || printf '{}')"
  # env only as the value-stripped vars slice (do NOT export raw values)
  envv="$(run_state_env "$pid" "$env_name" vars 2>/dev/null || printf '{}')"
  vols="$(run_state_volumes "$pid" digest 2>/dev/null || printf '{}')"
  dbs="$(run_state_databases "$pid" digest 2>/dev/null || printf '{}')"
  toks="$(run_state_tokens digest 2>/dev/null || printf '{}')"
  doms="$(run_state_domains "$pid" digest 2>/dev/null || printf '{}')"
  tcp="$(run_state_tcp_proxies "$pid" digest 2>/dev/null || printf '{}')"
  logs="$(run_state_logs "$pid" digest 2>/dev/null || printf '{}')"
  cost="$(run_state_cost "$pid" digest 2>/dev/null || printf '{}')"

  jq -n \
    --arg sv "1" \
    --arg ts "$ts" \
    --arg project_id "$pid" \
    --arg environment "$env_name" \
    --argjson workspace "$ws" \
    --argjson project "$proj" \
    --argjson services "$svcs" \
    --argjson env "$envv" \
    --argjson volumes "$vols" \
    --argjson databases "$dbs" \
    --argjson tokens "$toks" \
    --argjson domains "$doms" \
    --argjson tcp_proxies "$tcp" \
    --argjson logs "$logs" \
    --argjson cost "$cost" \
    '{
      schema: "rwsec.export",
      schema_version: ($sv|tonumber),
      generated_at: $ts,
      project_id: $project_id,
      environment: $environment,
      workspace: $workspace,
      project: $project,
      services: $services,
      env: $env,
      volumes: $volumes,
      databases: $databases,
      tokens: $tokens,
      domains: $domains,
      tcp_proxies: $tcp_proxies,
      logs: $logs,
      cost: $cost
    }' > "$out_file"

  log_ok "export" "snapshot" "wrote ${out_file}"
}
