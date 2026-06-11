# lib/state_registry.sh — Container Registry state.
# Exports: run_state_registry [slice]   slice ∈ digest|list|full

run_state_registry() {
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if ! _api_resolve_token; then
    printf '{"error":"missing DigitalOcean credentials","code":"E_AUTH"}\n' >&2
    return 2
  fi

  case "$slice" in
    digest) _state_reg_digest "$ts" ;;
    list)   _state_reg_list   "$ts" ;;
    full)   _state_reg_full   "$ts" ;;
    *)
      printf '{"error":"unknown state registry slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sr_registry_meta() {
  local body; body="$(do_get /registry)" || {
    if [[ "${DOSEC_LAST_STATUS:-0}" == "404" ]]; then
      printf '{"registry":null,"absent":true}'
      return
    fi
    printf '{"registry":null,"error":"%s"}' "${DOSEC_LAST_STATUS:-0}"
    return
  }
  printf '%s' "$body"
}

_sr_repositories() {
  local name="$1"
  [[ -z "$name" ]] && { printf '{"repositories":[]}'; return; }
  local body; body="$(do_get "/registry/${name}/repositoriesV2?per_page=200")" || { printf '{"repositories":[]}'; return; }
  printf '%s' "$body"
}

_sr_subscription() {
  local body; body="$(do_get /registry/subscription)" || { printf '{}'; return; }
  printf '%s' "$body"
}

_state_reg_digest() {
  local ts="$1"
  local meta; meta="$(_sr_registry_meta)"
  local absent; absent="$(jq -r '.absent // false' <<<"$meta" 2>/dev/null)"
  if [[ "$absent" == "true" ]]; then
    jq -n --arg ts "$ts" \
      '{ schema: "dosec.state-registry.digest", schema_version: 1, generated_at: $ts,
         tool: "state-registry", slice: "digest",
         present: false,
         hint: "no Container Registry created on this account" }'
    return 0
  fi

  local rname; rname="$(jq -r '.registry.name // empty' <<<"$meta")"
  local repos; repos="$(_sr_repositories "$rname")"
  local sub; sub="$(_sr_subscription)"

  jq -n --arg ts "$ts" --argjson meta "$meta" --argjson repos "$repos" --argjson sub "$sub" \
    '{ schema: "dosec.state-registry.digest", schema_version: 1, generated_at: $ts,
       tool: "state-registry", slice: "digest",
       present: true,
       name: ($meta.registry.name // null),
       region: ($meta.registry.region // null),
       subscription_tier: ($sub.subscription.tier // null),
       repositories_summary: {
         total: ($repos.repositories // [] | length),
         total_tags: ($repos.repositories // [] | map(.tag_count // 0) | add // 0),
         total_size_bytes: ($repos.repositories // [] | map(.tag_count // 0 | tonumber) | add // 0),
         sample: (($repos.repositories // [])[:5] | map({name, tag_count: (.tag_count // 0), latest_tag: (.latest_tag.tag // null), latest_pushed: (.latest_tag.updated_at // null)}))
       },
       hint: "for full data, run: state registry [list|full]" }'
}

_state_reg_list() {
  local ts="$1"
  local meta; meta="$(_sr_registry_meta)"
  local rname; rname="$(jq -r '.registry.name // empty' <<<"$meta")"
  local repos; repos="$(_sr_repositories "$rname")"
  jq -n --arg ts "$ts" --argjson meta "$meta" --argjson repos "$repos" \
    '{ schema: "dosec.state-registry.list", schema_version: 1, generated_at: $ts,
       tool: "state-registry", slice: "list",
       registry: ($meta.registry // null),
       repositories: ($repos.repositories // []) }'
}

_state_reg_full() {
  local ts="$1"
  local meta; meta="$(_sr_registry_meta)"
  local rname; rname="$(jq -r '.registry.name // empty' <<<"$meta")"
  local repos; repos="$(_sr_repositories "$rname")"
  local sub; sub="$(_sr_subscription)"
  jq -n --arg ts "$ts" --argjson meta "$meta" --argjson repos "$repos" --argjson sub "$sub" \
    '{ schema: "dosec.state-registry.full", schema_version: 1, generated_at: $ts,
       tool: "state-registry", slice: "full",
       registry: ($meta.registry // null), repositories: ($repos.repositories // []), subscription: ($sub.subscription // null) }'
}
