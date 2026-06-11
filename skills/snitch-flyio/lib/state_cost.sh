# lib/state_cost.sh — spend digest. Fly's API doesn't expose detailed billing
# breakdown via flyctl; we surface a derived signal from machine sizes + volume
# sizes + GPU presence. The agent should still cite https://fly.io/dashboard
# for authoritative numbers.
# Exports: run_state_cost [org]

run_state_cost() {
  local org="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null)" || {
      printf '{"error":"could not resolve org","code":"E_ORG"}\n' >&2
      return 3
    }
  fi

  local apps; apps="$(fly_run_json apps list --org "$org" 2>/dev/null || printf '[]')"
  local app_names; app_names="$(jq -r '.[].Name // .[].name' <<<"$apps" 2>/dev/null)"

  local total_machines=0
  local total_gpu_machines=0
  local total_vol_gb=0
  local app_breakdown="[]"

  while IFS= read -r app; do
    [[ -z "$app" || "$app" == "null" ]] && continue
    local m v
    m="$(fly_run_json machines list -a "$app" 2>/dev/null || printf '[]')"
    v="$(fly_run_json volumes list -a "$app" 2>/dev/null || printf '[]')"
    local mc gc vc vsize
    mc="$(jq -r 'length' <<<"$m" 2>/dev/null || printf '0')"
    gc="$(jq -r '[.[] | select(((.config // .Config).guest.gpu_kind // null) != null)] | length' <<<"$m" 2>/dev/null || printf '0')"
    vc="$(jq -r 'length' <<<"$v" 2>/dev/null || printf '0')"
    vsize="$(jq -r '[.[] | (.size_gb // .SizeGb // 0)] | add // 0' <<<"$v" 2>/dev/null || printf '0')"
    total_machines=$(( total_machines + mc ))
    total_gpu_machines=$(( total_gpu_machines + gc ))
    total_vol_gb=$(( total_vol_gb + vsize ))
    app_breakdown="$(jq --arg name "$app" --argjson mc "$mc" --argjson gc "$gc" --argjson vc "$vc" --argjson vs "$vsize" \
      '. + [{app:$name, machines:$mc, gpu_machines:$gc, volumes:$vc, volume_gb:$vs}]' <<<"$app_breakdown")"
  done <<<"$app_names"

  jq -n --arg ts "$ts" --arg org "$org" \
    --argjson tm "$total_machines" \
    --argjson tg "$total_gpu_machines" \
    --argjson tv "$total_vol_gb" \
    --argjson breakdown "$app_breakdown" \
    '{
      schema: "flysec.state-cost",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-cost",
      org: $org,
      totals: {
        machines: $tm,
        gpu_machines: $tg,
        volume_gb: $tv
      },
      per_app: $breakdown,
      hint: "Authoritative billing at https://fly.io/dashboard. GPU machines and large volumes are the usual cost surprises."
    }'
}
