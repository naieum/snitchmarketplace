# lib/state_dns.sh — DNS state.
# Exports: run_state_dns [slice]   slice ∈ digest|list|full
#
# Note: DigitalOcean's managed DNS does NOT support DNSSEC. The digest
# always includes a dnssec_supported:false signal; agent should surface
# a WARN recommending Cloudflare DNS (or a registrar that supports DNSSEC) in front.

run_state_dns() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_dns_digest "$ts" ;;
    list)   _state_dns_list   "$ts" ;;
    full)   _state_dns_full   "$ts" ;;
    *)
      printf '{"error":"unknown state dns slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sdns_raw_domains() {
  local body; body="$(do_get /domains?per_page=200)" || {
    printf '{"error":"failed to fetch domains","code":"E_API","status":%s}\n' "${DOSEC_LAST_STATUS:-0}" >&2
    printf '{"domains":[]}'
    return
  }
  printf '%s' "$body"
}

_sdns_records() {
  local domain="$1"
  local body; body="$(do_get "/domains/${domain}/records?per_page=500")" || { printf '{"domain_records":[]}'; return; }
  printf '%s' "$body"
}

_sdns_summary() {
  local raw="$1"
  jq '{
    total_domains: ((.domains // []) | length),
    domains: ((.domains // []) | map(.name)),
    sample: ((.domains // [])[:5] | map({name, ttl, zone_file: (.zone_file // null)}))
  }' <<<"$raw" 2>/dev/null || printf '{}'
}

_state_dns_digest() {
  local ts="$1"
  local raw summary
  raw="$(_sdns_raw_domains)"
  summary="$(_sdns_summary "$raw")"

  # Aggregate record counts across the first up-to-5 domains.
  local rec_total=0 rec_a=0 rec_caa=0 rec_mx=0 rec_txt=0
  local domains
  domains="$(jq -r '.domains // [] | .[].name' <<<"$raw" 2>/dev/null | head -5)"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    local rec; rec="$(_sdns_records "$d")"
    local n a caa mx txt
    n="$(jq '.domain_records // [] | length' <<<"$rec")"
    a="$(jq '.domain_records // [] | map(select(.type == "A" or .type == "AAAA")) | length' <<<"$rec")"
    caa="$(jq '.domain_records // [] | map(select(.type == "CAA")) | length' <<<"$rec")"
    mx="$(jq '.domain_records // [] | map(select(.type == "MX")) | length' <<<"$rec")"
    txt="$(jq '.domain_records // [] | map(select(.type == "TXT")) | length' <<<"$rec")"
    rec_total=$((rec_total + ${n:-0}))
    rec_a=$((rec_a + ${a:-0}))
    rec_caa=$((rec_caa + ${caa:-0}))
    rec_mx=$((rec_mx + ${mx:-0}))
    rec_txt=$((rec_txt + ${txt:-0}))
  done <<<"$domains"

  jq -n --arg ts "$ts" --argjson summary "$summary" \
    --argjson rt "$rec_total" --argjson ra "$rec_a" --argjson rcaa "$rec_caa" --argjson rmx "$rec_mx" --argjson rtxt "$rec_txt" \
    '{ schema: "dosec.state-dns.digest", schema_version: 1, generated_at: $ts,
       tool: "state-dns", slice: "digest",
       dns_summary: ($summary + {
         records_sampled: $rt, a_records: $ra, caa_records: $rcaa, mx_records: $rmx, txt_records: $rtxt
       }),
       dnssec_supported: false,
       dnssec_note: "DigitalOcean managed DNS does NOT support DNSSEC. To enable DNSSEC, either use Cloudflare DNS in front (orange-cloud) or a registrar that signs your zone.",
       hint: "for full data, run: state dns [list|full]" }'
}

_state_dns_list() {
  local ts="$1"
  local raw; raw="$(_sdns_raw_domains)"
  jq --arg ts "$ts" \
    '{ schema: "dosec.state-dns.list", schema_version: 1, generated_at: $ts,
       tool: "state-dns", slice: "list",
       domains: (.domains // []),
       dnssec_supported: false }' \
    <<<"$raw"
}

_state_dns_full() {
  local ts="$1"
  local raw; raw="$(_sdns_raw_domains)"
  local enriched='[]'
  local domains
  domains="$(jq -r '.domains // [] | .[].name' <<<"$raw" 2>/dev/null)"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    local rec; rec="$(_sdns_records "$d")"
    enriched="$(jq --argjson e "$enriched" --arg d "$d" --argjson r "$rec" \
      -n '$e + [{ name: $d, records: ($r.domain_records // []) }]')"
  done <<<"$domains"
  jq -n --arg ts "$ts" --argjson raw "$raw" --argjson enriched "$enriched" \
    '{ schema: "dosec.state-dns.full", schema_version: 1, generated_at: $ts,
       tool: "state-dns", slice: "full",
       domains: ($raw.domains // []),
       domain_records: $enriched,
       dnssec_supported: false }'
}
