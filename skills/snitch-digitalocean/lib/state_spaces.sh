# lib/state_spaces.sh — Spaces (S3-compat) state.
# Exports: run_state_spaces [slice]   slice ∈ digest|list|full
#
# DigitalOcean does NOT expose buckets via the v2 API. The only programmatic
# inventory is via the S3-compatible endpoint per region with a Spaces access
# key + secret (DOSEC_SPACES_KEY / DOSEC_SPACES_SECRET). When those aren't
# set, we surface a helpful "not configured" payload instead of an error.

run_state_spaces() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${DOSEC_SPACES_KEY:-}" || -z "${DOSEC_SPACES_SECRET:-}" ]]; then
    jq -n --arg ts "$ts" --arg slice "$slice" \
      '{ schema: "dosec.state-spaces."+$slice, schema_version: 1, generated_at: $ts,
         tool: "state-spaces", slice: $slice,
         spaces_summary: { total: 0, by_region: {}, public_count: null, cors_configured_count: null, cdn_endpoint_count: null },
         buckets: [],
         note: "Set DOSEC_SPACES_KEY + DOSEC_SPACES_SECRET (Spaces access keys, NOT API token) to enumerate buckets. Generate at https://cloud.digitalocean.com/account/api/spaces. The skill uses these to call the S3-compat ListBuckets endpoint." }'
    return 0
  fi

  if ! command -v aws >/dev/null 2>&1 && ! command -v s3cmd >/dev/null 2>&1; then
    jq -n --arg ts "$ts" --arg slice "$slice" \
      '{ schema: "dosec.state-spaces."+$slice, schema_version: 1, generated_at: $ts,
         tool: "state-spaces", slice: $slice,
         note: "Install aws-cli or s3cmd to enumerate Spaces. Run: brew install awscli  /  apt install awscli." }'
    return 0
  fi

  # CDN endpoints come from the v2 API.
  local cdn_body cdn_count='0'
  cdn_body="$(do_get /cdn/endpoints?per_page=200)" || cdn_body='{"endpoints":[]}'
  cdn_count="$(jq '.endpoints // [] | length' <<<"$cdn_body" 2>/dev/null || echo 0)"

  # Use aws-cli per-region if available. Spaces regions: nyc3, sfo3, ams3, sgp1, fra1.
  local regions=("nyc3" "sfo3" "ams3" "sgp1" "fra1")
  local all='[]'
  if command -v aws >/dev/null 2>&1; then
    local r
    for r in "${regions[@]}"; do
      local out
      out="$(AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
        aws s3api list-buckets --endpoint-url "https://${r}.digitaloceanspaces.com" --output json 2>/dev/null)"
      if [[ -n "$out" ]]; then
        local addn
        addn="$(jq --arg r "$r" '.Buckets // [] | map({name:.Name, region:$r, created:.CreationDate})' <<<"$out" 2>/dev/null || echo '[]')"
        all="$(jq --argjson a "$all" --argjson b "$addn" -n '$a + $b')"
      fi
    done
  fi

  case "$slice" in
    digest)
      jq -n --arg ts "$ts" --argjson buckets "$all" --argjson cdnc "${cdn_count:-0}" \
        '{ schema: "dosec.state-spaces.digest", schema_version: 1, generated_at: $ts,
           tool: "state-spaces", slice: "digest",
           spaces_summary: {
             total: ($buckets | length),
             by_region: ($buckets | group_by(.region) | map({key: .[0].region, value: length}) | from_entries),
             cdn_endpoint_count: $cdnc
           },
           sample: ($buckets[:5]),
           hint: "for full data, run: state spaces [list|full]" }' ;;
    list|full)
      jq -n --arg ts "$ts" --arg slice "$slice" --argjson buckets "$all" --argjson cdn "$cdn_body" \
        '{ schema: "dosec.state-spaces."+$slice, schema_version: 1, generated_at: $ts,
           tool: "state-spaces", slice: $slice,
           buckets: $buckets, cdn_endpoints: ($cdn.endpoints // []) }' ;;
    *)
      printf '{"error":"unknown state spaces slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}
