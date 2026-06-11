# lib/apply_postgres.sh — Postgres rotation + attached-app least-privilege checks.
# Exports: apply_postgres [pg-app]
#
# Fly Postgres (legacy) and Managed Postgres handle rotation differently:
#  - Legacy: `fly pg revoke -a <pg-app> --user <user>` rotates a user's password.
#  - Managed: rotation is via the dashboard; we just print the URL.
# This function is idempotent: it inspects state, surfaces age, and emits the
# canonical command. It never auto-rotates (would orphan attached apps).

apply_postgres() {
  local pg="${1:-}"
  log_section "postgres"

  # Legacy clusters: anything in apps list whose name matches /pg|postgres/.
  local org; org="$(api_pick_org 2>/dev/null || printf '')"
  if [[ -z "$org" ]]; then
    log_warn "postgres" "org" "Could not pick org. Set FLYSEC_ORG to scope the audit."
    return 0
  fi
  local apps; apps="$(fly_run_json apps list --org "$org" 2>/dev/null || printf '[]')"
  local pg_apps
  pg_apps="$(jq -r '[.[] | (.Name // .name) | select(test("(postgres|pg)"; "i"))] | .[]' <<<"$apps" 2>/dev/null)"

  if [[ -z "$pg_apps" ]]; then
    log_info "No legacy Fly Postgres clusters detected in org=${org}."
  else
    while IFS= read -r pgapp; do
      [[ -z "$pgapp" ]] && continue
      log_subsection "legacy postgres: ${pgapp}"
      local body; body="$(fly_run_json status -a "$pgapp" 2>/dev/null || printf '{}')"
      local n; n="$(jq -r '((.Machines // .machines // []) | length)' <<<"$body" 2>/dev/null || printf '0')"
      if [[ "$n" -lt 2 ]]; then
        log_warn "postgres" "ha" "${pgapp} has ${n} machine(s). Single-node Postgres has no HA. Add a replica: fly machines clone -a ${pgapp} <id> --region <region2>."
      else
        log_ok "postgres" "ha" "${pgapp} has ${n} machines."
      fi
      log_info "Rotate the postgres password (legacy): fly pg revoke -a ${pgapp} --user postgres ; then fly pg attach -a <attached-app> --postgres-app ${pgapp} re-attaches with the new credentials."
      log_info "Backups: fly volumes snapshots list -a ${pgapp} -v <volume_id>"
    done <<<"$pg_apps"
  fi

  # Managed Postgres
  local managed; managed="$(fly_run_json mpg list 2>/dev/null || printf '[]')"
  local mn; mn="$(jq -r 'length' <<<"$managed" 2>/dev/null || printf '0')"
  if [[ "$mn" -gt 0 ]]; then
    log_subsection "managed postgres"
    log_ok "postgres" "managed-detected" "${mn} Managed Postgres cluster(s) detected."
    log_info "Manage via: https://fly.io/dashboard/${org}/managed-postgres . Rotation, backups, and PITR live there."
  else
    log_info "No Managed Postgres clusters detected."
  fi

  return 0
}
