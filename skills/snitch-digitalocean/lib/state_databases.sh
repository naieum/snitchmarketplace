# lib/state_databases.sh — Managed Database state.
# Exports: run_state_databases [slice]   slice ∈ digest|list|full

run_state_databases() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_databases_digest "$ts" ;;
    list)   _state_databases_list   "$ts" ;;
    full)   _state_databases_full   "$ts" ;;
    *)
      printf '{"error":"unknown state databases slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sdb_raw() {
  local body; body="$(do_get /databases?per_page=200)" || {
    printf '{"error":"failed to fetch databases","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"databases":[]}'
    return
  }
  printf '%s' "$body"
}

_sdb_firewall_rules() {
  local cluster_id="$1"
  local body; body="$(do_get "/databases/${cluster_id}/firewall")" || { printf '{"rules":[]}'; return; }
  printf '%s' "$body"
}

_sdb_summary() {
  local raw="$1"
  jq '{
    total: ((.databases // []) | length),
    by_engine: ((.databases // []) | group_by(.engine // "unknown") | map({key:(.[0].engine // "unknown"), value:length}) | from_entries),
    by_region: ((.databases // []) | group_by(.region // "unknown") | map({key:(.[0].region // "unknown"), value:length}) | from_entries),
    online_count: ((.databases // []) | map(select(.status == "online")) | length),
    private_network_count: ((.databases // []) | map(select(.private_network_uuid // "" != "")) | length),
    sample: ((.databases // [])[:5] | map({id, name, engine, version, status, region, num_nodes, size, created_at, vpc_uuid: (.private_network_uuid // null), connection: { ssl: (.connection.ssl // null), host: (.connection.host // null), port: (.connection.port // null) } }))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_databases_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sdb_raw)"
  summary="$(_sdb_summary "$raw")"

  # Firewall coverage: count clusters with at least one trusted source rule.
  local cluster_ids covered=0 total
  cluster_ids="$(jq -r '.databases[]? | .id' <<<"$raw" 2>/dev/null)"
  total="$(jq '.databases | length' <<<"$raw" 2>/dev/null)"
  if [[ "${total:-0}" -gt 0 && -n "$cluster_ids" ]]; then
    while IFS= read -r cid; do
      [[ -z "$cid" ]] && continue
      local fw n
      fw="$(_sdb_firewall_rules "$cid")"
      n="$(jq -r '.rules // [] | length' <<<"$fw" 2>/dev/null)"
      [[ "${n:-0}" -gt 0 ]] && covered=$((covered+1))
    done <<<"$cluster_ids"
  fi

  jq -n --arg ts "$ts" --argjson summary "$summary" --argjson tcov "${covered:-0}" --argjson tot "${total:-0}" \
    '{ schema: "dosec.state-databases.digest", schema_version: 1, generated_at: $ts,
       tool: "state-databases", slice: "digest",
       databases_summary: ($summary + { trusted_source_coverage: { total: $tot, with_firewall_rules: $tcov } }),
       hint: "for full data, run: state databases [list|full]" }'
}

_state_databases_list() {
  local ts="$1"
  local raw; raw="$(_sdb_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-databases.list", schema_version: 1, generated_at: $ts,
       tool: "state-databases", slice: "list",
       databases: [(.databases // [])[] | {id, name, engine, version, status, region, num_nodes, size, created_at, vpc_uuid: (.private_network_uuid // null), tags, connection: {host: (.connection.host // null), port: (.connection.port // null), ssl: (.connection.ssl // null)} }] }' \
    <<<"$raw"
}

_state_databases_full() {
  local ts="$1"
  local raw; raw="$(_sdb_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-databases.full", schema_version: 1, generated_at: $ts,
           tool: "state-databases", slice: "full" }' \
    <<<"$raw"
}
