# lib/state_network.sh — WireGuard / private network / IP allocations, digest + slice.
# Exports: run_state_network [org] [slice]
#   slice ∈ digest (default) | full

run_state_network() {
  local org="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null)" || {
      printf '{"error":"could not resolve org","code":"E_ORG"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_network_digest "$org" "$ts" ;;
    full)   _state_network_full   "$org" "$ts" ;;
    *)
      printf '{"error":"unknown state network slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_wg_peers() {
  local org="$1"
  local body; body="$(fly_run_json wireguard list "$org" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    name: (.Name // .name // null),
    region: (.Region // .region // null),
    network: (.Network // .network // null),
    peerip: (.Peerip // .peer_ip // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

# Per-app IP allocations summary. We don't enumerate every app; the agent can
# call this with an app via the `slice` extension if needed. For org digest we
# count v4 vs v6 allocations across the org by sampling apps list.
_ip_allocations_per_app() {
  local app="$1"
  local body; body="$(fly_run_json ips list -a "$app" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    address: (.Address // .address // null),
    type: (.Type // .type // null),
    region: (.Region // .region // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_network_digest() {
  local org="$1" ts="$2"
  local peers
  peers="$(_wg_peers "$org")"

  jq -n --arg ts "$ts" --arg org "$org" --argjson peers "$peers" \
    '{
      schema: "flysec.state-network.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-network",
      slice: "digest",
      org: $org,
      wireguard_summary: {
        total_peers: ($peers | length),
        by_region: ($peers | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
        peer_names: ($peers | map(.name))
      },
      wireguard_peers: $peers,
      hint: "private nets are scoped to the org. To list IPs allocated to a specific app, run: fly ips list -a <app>."
    }'
}

_state_network_full() {
  local org="$1" ts="$2"
  local peers; peers="$(_wg_peers "$org")"
  jq -n --arg ts "$ts" --arg org "$org" --argjson peers "$peers" \
    '{ schema: "flysec.state-network.full", schema_version: 1, generated_at: $ts,
       tool: "state-network", slice: "full", org: $org, wireguard_peers: $peers }'
}
