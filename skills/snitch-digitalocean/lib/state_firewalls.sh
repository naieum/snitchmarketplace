# lib/state_firewalls.sh — Cloud Firewall state.
# Exports: run_state_firewalls [slice]   slice ∈ digest|list|full

run_state_firewalls() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_fw_digest "$ts" ;;
    list)   _state_fw_list   "$ts" ;;
    full)   _state_fw_full   "$ts" ;;
    *)
      printf '{"error":"unknown state firewalls slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sf_raw() {
  local body; body="$(do_get /firewalls?per_page=200)" || {
    printf '{"error":"failed to fetch firewalls","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"firewalls":[]}'
    return
  }
  printf '%s' "$body"
}

# Detect inbound rules with 0.0.0.0/0 / ::/0 sources, especially on mgmt ports (22/3389/etc).
_sf_summary() {
  local raw="$1"
  jq '{
    total: ((.firewalls // []) | length),
    droplet_attached_count: ((.firewalls // []) | map(.droplet_ids // [] | length) | add // 0),
    tag_scoped_count: ((.firewalls // []) | map(select(.tags // [] | length > 0)) | length),
    inbound_open_world_count: ((.firewalls // []) | map(.inbound_rules // [] | map(select((.sources.addresses // []) | map(. == "0.0.0.0/0" or . == "::/0") | any)) | length) | add // 0),
    mgmt_port_open_world_count: ((.firewalls // []) | map(.inbound_rules // [] | map(select(((.ports // "") | tostring) as $p | (($p == "22" or $p == "3389" or $p == "5432" or $p == "3306" or $p == "27017" or $p == "6379")) and ((.sources.addresses // []) | map(. == "0.0.0.0/0" or . == "::/0") | any))) | length) | add // 0),
    sample: ((.firewalls // [])[:5] | map({id, name, status, created_at, droplet_ids, tags, inbound_rules: (.inbound_rules // []), outbound_rules: (.outbound_rules // [])}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_fw_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sf_raw)"
  summary="$(_sf_summary "$raw")"
  jq -n --arg ts "$ts" --argjson summary "$summary" \
    '{ schema: "dosec.state-firewalls.digest", schema_version: 1, generated_at: $ts,
       tool: "state-firewalls", slice: "digest",
       firewalls_summary: $summary,
       hint: "for full data, run: state firewalls [list|full]" }'
}

_state_fw_list() {
  local ts="$1"
  local raw; raw="$(_sf_raw)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-firewalls.list", schema_version: 1, generated_at: $ts,
       tool: "state-firewalls", slice: "list",
       firewalls: [(.firewalls // [])[] | {id, name, status, created_at, droplet_ids, tags, pending_changes, inbound_rules, outbound_rules}] }' \
    <<<"$raw"
}

_state_fw_full() {
  local ts="$1"
  local raw; raw="$(_sf_raw)"
  jq --arg ts "$ts" \
    '. + { schema: "dosec.state-firewalls.full", schema_version: 1, generated_at: $ts,
           tool: "state-firewalls", slice: "full" }' \
    <<<"$raw"
}
