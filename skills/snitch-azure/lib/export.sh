# lib/export.sh — JSON snapshot of subscription + selected RGs.

run_export() {
  log_section "export"
  auth_verify || return $?
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local sub_name; sub_name="$(az_run_json account show --subscription "$sub_id" 2>/dev/null | jq -r '.name // ""' 2>/dev/null)"

  local out_file="./azure-export-${sub_id}-${ts}.json"

  log_info "snapshotting subscription=${sub_id} (${sub_name})"

  local resources storage keyvaults sql cosmos webapps nsgs vms
  resources="$(az_run_json resource list --subscription "$sub_id" 2>/dev/null \
    | jq '[.[] | {id,name,type,location,resourceGroup,tags}]' 2>/dev/null || printf '[]')"
  storage="$(az_run_json storage account list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  keyvaults="$(az_run_json keyvault list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  sql="$(az_run_json sql server list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  cosmos="$(az_run_json cosmosdb list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  webapps="$(az_run_json webapp list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  nsgs="$(az_run_json network nsg list --subscription "$sub_id" 2>/dev/null || printf '[]')"
  vms="$(az_run_json vm list --subscription "$sub_id" 2>/dev/null || printf '[]')"

  jq -n \
    --arg sv "1" --arg ts "$ts" --arg sub "$sub_id" --arg sub_name "$sub_name" \
    --argjson resources "$resources" --argjson storage "$storage" --argjson keyvaults "$keyvaults" \
    --argjson sql "$sql" --argjson cosmos "$cosmos" --argjson webapps "$webapps" \
    --argjson nsgs "$nsgs" --argjson vms "$vms" \
    '{
      schema_version: ($sv|tonumber),
      generated_at: $ts,
      subscription_id: $sub,
      subscription_name: $sub_name,
      resources: $resources,
      storage_accounts: $storage,
      keyvaults: $keyvaults,
      sql_servers: $sql,
      cosmosdb_accounts: $cosmos,
      web_apps: $webapps,
      nsgs: $nsgs,
      vms: $vms
    }' > "$out_file"

  log_ok "export" "snapshot" "wrote ${out_file}"
}
