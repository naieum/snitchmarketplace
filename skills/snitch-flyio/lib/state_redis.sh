# lib/state_redis.sh — Upstash-on-Fly Redis state, digest + slice.
# Exports: run_state_redis [slice]
#   slice ∈ digest (default) | full
#
# Fly's Redis offering is provided by Upstash. `fly redis list --json` is the
# canonical command. TLS is mandatory on managed Upstash-on-Fly Redis but we
# verify in the digest just in case.

run_state_redis() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$slice" in
    digest) _state_redis_digest "$ts" ;;
    full)   _state_redis_full   "$ts" ;;
    *)
      printf '{"error":"unknown state redis slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_redis_list() {
  local body; body="$(fly_run_json redis list 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    id: (.id // .ID),
    name: (.name // .Name),
    region: (.region // .Region // null),
    plan: (.plan // .Plan // null),
    eviction: (.eviction // .Eviction // null),
    public_url: (.public_url // .PublicURL // null),
    private_url: (.private_url // .PrivateURL // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_state_redis_digest() {
  local ts="$1"
  local r
  r="$(_redis_list)"
  jq -n --arg ts "$ts" --argjson r "$r" \
    '{
      schema: "flysec.state-redis.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-redis",
      slice: "digest",
      redis_summary: {
        total: ($r | length),
        by_region: ($r | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
        by_plan: ($r | group_by(.plan) | map({key: (.[0].plan // "?"), value: length}) | from_entries),
        with_public_url: ($r | map(select(.public_url != null and .public_url != "")) | length),
        without_eviction: ($r | map(select(.eviction == null or .eviction == false)) | length)
      },
      redis: $r,
      hint: "TLS is mandatory on Upstash-on-Fly. If a public_url is exposed, prefer private_url for app-to-redis calls."
    }'
}

_state_redis_full() {
  local ts="$1"
  local body; body="$(fly_run_json redis list 2>/dev/null)"
  [[ -z "$body" ]] && body="[]"
  jq -n --arg ts "$ts" --argjson r "$body" \
    '{ schema: "flysec.state-redis.full", schema_version: 1, generated_at: $ts,
       tool: "state-redis", slice: "full", redis: $r }'
}
