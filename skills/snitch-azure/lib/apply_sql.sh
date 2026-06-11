# lib/apply_sql.sh — idempotent fixes for Azure SQL.
# Targets: TDE on, AAD admin set, Defender enabled, auditing to LA workspace.

apply_sql() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local target="${1:-}"
  local servers
  if [[ -n "$target" ]]; then
    servers="$(az_run_json sql server list --subscription "$sub_id" --query "[?name=='${target}']" 2>/dev/null || printf '[]')"
  else
    servers="$(az_run_json sql server list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  fi
  local n; n="$(jq -r 'length' <<<"$servers")"
  if [[ "$n" == "0" ]]; then
    log_warn "sql" "scope" "no SQL servers found"
    return 0
  fi

  local i s name rg minTls aadAdmin
  for ((i=0;i<n;i++)); do
    s="$(jq -c ".[$i]" <<<"$servers")"
    name="$(jq -r '.name' <<<"$s")"
    rg="$(jq -r '.resourceGroup' <<<"$s")"
    minTls="$(jq -r '.minimalTlsVersion // ""' <<<"$s")"
    aadAdmin="$(jq -r '.administrators.administratorType // ""' <<<"$s")"

    # min TLS
    if [[ "$minTls" == "1.2" || "$minTls" == "1.3" ]]; then
      log_ok "sql" "${name}/tls" "min TLS already ${minTls}."
    else
      if az_run sql server update -n "$name" -g "$rg" --subscription "$sub_id" --minimal-tls-version 1.2 >/dev/null 2>&1; then
        log_ok "sql" "${name}/tls" "min TLS set to 1.2."
      else
        log_fail "sql" "${name}/tls" "could not set min TLS. $(az_last_error)"
      fi
    fi

    # AAD admin
    if [[ -n "$aadAdmin" && "$aadAdmin" != "null" ]]; then
      log_ok "sql" "${name}/aad-admin" "AAD admin set (${aadAdmin})."
    else
      log_warn "sql" "${name}/aad-admin" "no AAD admin set. Run: az sql server ad-admin create -s ${name} -g ${rg} -u <name> -i <object-id>"
    fi

    # TDE per-database — operates on default DB plus user DBs.
    local dbs
    dbs="$(az_run_json sql db list --server "$name" --resource-group "$rg" --subscription "$sub_id" 2>/dev/null \
      | jq '[.[] | select(.name != "master") | {name, id}]' 2>/dev/null || printf '[]')"
    local dbn; dbn="$(jq -r 'length' <<<"$dbs")"
    local j db dbname tde_state
    for ((j=0;j<dbn;j++)); do
      db="$(jq -c ".[$j]" <<<"$dbs")"
      dbname="$(jq -r '.name' <<<"$db")"
      tde_state="$(az_run_json sql db tde show --server "$name" --database "$dbname" --resource-group "$rg" --subscription "$sub_id" 2>/dev/null \
        | jq -r '.state // "Unknown"' 2>/dev/null || printf 'Unknown')"
      if [[ "$tde_state" == "Enabled" ]]; then
        log_ok "sql" "${name}/${dbname}/tde" "TDE already Enabled."
      else
        if az_run sql db tde set --server "$name" --database "$dbname" --resource-group "$rg" --subscription "$sub_id" --status Enabled >/dev/null 2>&1; then
          log_ok "sql" "${name}/${dbname}/tde" "TDE enabled."
        else
          log_fail "sql" "${name}/${dbname}/tde" "could not enable TDE. $(az_last_error)"
        fi
      fi
    done

    # Defender for SQL — gated by Defender plan.
    log_warn "sql" "${name}/defender" "Defender for SQL is paid (Defender Standard for SqlServers). Run: az security pricing create -n SqlServers --tier Standard"
  done
}
