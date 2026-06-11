# lib/export.sh — assemble a JSON snapshot of org+apps state to cwd.
# Exports: run_export

run_export() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local out="flysec-export-$(date -u +%Y%m%dT%H%M%SZ).json"
  if ! command -v flyctl >/dev/null 2>&1 && ! command -v fly >/dev/null 2>&1; then
    printf '{"error":"flyctl not installed","code":"E_TOOL"}\n' >&2
    return 2
  fi

  local org; org="$(api_pick_org 2>/dev/null || printf '')"
  local apps machines_per_app="{}" volumes_per_app="{}" secrets_per_app="{}"
  apps="$(fly_run_json apps list --org "$org" 2>/dev/null || printf '[]')"

  local app
  while IFS= read -r app; do
    [[ -z "$app" || "$app" == "null" ]] && continue
    local m v s
    m="$(fly_run_json machines list -a "$app" 2>/dev/null || printf '[]')"
    v="$(fly_run_json volumes list -a "$app" 2>/dev/null || printf '[]')"
    s="$(fly_run_json secrets list -a "$app" 2>/dev/null || printf '[]')"
    machines_per_app="$(jq --arg k "$app" --argjson v "$m" '. + {($k): $v}' <<<"$machines_per_app")"
    volumes_per_app="$(jq --arg k "$app" --argjson v "$v" '. + {($k): $v}' <<<"$volumes_per_app")"
    secrets_per_app="$(jq --arg k "$app" --argjson v "$s" '. + {($k): $v}' <<<"$secrets_per_app")"
  done < <(jq -r '.[].Name // .[].name' <<<"$apps" 2>/dev/null)

  local org_meta tokens redis pg_legacy pg_managed wg
  org_meta="$(fly_run_json orgs show "$org" 2>/dev/null || printf '{}')"
  tokens="$(fly_run_json tokens list --org "$org" 2>/dev/null || printf '[]')"
  redis="$(fly_run_json redis list 2>/dev/null || printf '[]')"
  pg_legacy="$(jq '[.[] | (.Name // .name) | select(test("(postgres|pg)"; "i"))]' <<<"$apps" 2>/dev/null || printf '[]')"
  pg_managed="$(fly_run_json mpg list 2>/dev/null || printf '[]')"
  wg="$(fly_run_json wireguard list "$org" 2>/dev/null || printf '[]')"

  jq -n --arg ts "$ts" --arg org "$org" \
    --argjson org_meta "$org_meta" \
    --argjson apps "$apps" \
    --argjson machines "$machines_per_app" \
    --argjson volumes "$volumes_per_app" \
    --argjson secrets "$secrets_per_app" \
    --argjson tokens "$tokens" \
    --argjson redis "$redis" \
    --argjson pg_legacy "$pg_legacy" \
    --argjson pg_managed "$pg_managed" \
    --argjson wireguard "$wg" \
    '{ schema: "flysec.export", schema_version: 1, generated_at: $ts,
       tool: "export", org: $org, org_meta: $org_meta, apps: $apps,
       machines: $machines, volumes: $volumes, secrets: $secrets,
       tokens: $tokens, redis: $redis,
       postgres: { legacy_names: $pg_legacy, managed: $pg_managed },
       wireguard_peers: $wireguard }' > "$out"

  log_info "export written → ${out}"
}
