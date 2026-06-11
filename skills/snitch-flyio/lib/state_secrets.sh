# lib/state_secrets.sh — secrets metadata (no values), digest + slice.
# Exports: run_state_secrets [app] [slice]
#   slice ∈ digest (default) | full
#
# `fly secrets list --json` returns name + digest + created_at — never values.

run_state_secrets() {
  local app="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$app" ]]; then
    app="$(api_pick_app 2>/dev/null)" || {
      printf '{"error":"could not resolve app","code":"E_APP"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_secrets_digest "$app" "$ts" ;;
    full)   _state_secrets_full   "$app" "$ts" ;;
    *)
      printf '{"error":"unknown state secrets slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_secrets_list() {
  local app="$1"
  local body; body="$(fly_run_json secrets list -a "$app" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    name: (.Name // .name),
    digest: (.Digest // .digest),
    created_at: (.CreatedAt // .created_at)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

# Cross-reference fly.toml [env] keys against fly secrets — values that appear
# in BOTH should always be a secret only.
_local_env_keys() {
  if [[ -f "fly.toml" ]]; then
    grep -E -A 200 '^\[env\]' fly.toml 2>/dev/null \
      | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=' \
      | sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' \
      | sort -u | jq -R . | jq -s . 2>/dev/null || printf '[]'
  else
    printf '[]'
  fi
}

_state_secrets_digest() {
  local app="$1" ts="$2"
  local s env_keys
  s="$(_secrets_list "$app")"
  env_keys="$(_local_env_keys)"
  jq -n --arg ts "$ts" --arg app "$app" --argjson s "$s" --argjson e "$env_keys" \
    '{
      schema: "flysec.state-secrets.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-secrets",
      slice: "digest",
      app: $app,
      secrets_summary: {
        total: ($s | length),
        names: ($s | map(.name)),
        local_env_keys: $e,
        env_keys_overlapping_secrets: ($e | map(. as $k | select($s | map(.name) | index($k))))
      },
      secrets: $s,
      hint: "values are never returned. Set new with: fly secrets set NAME=value -a <app>. Avoid duplicating between fly.toml [env] and secrets."
    }'
}

_state_secrets_full() {
  local app="$1" ts="$2"
  local s
  s="$(_secrets_list "$app")"
  jq -n --arg ts "$ts" --arg app "$app" --argjson s "$s" \
    '{ schema: "flysec.state-secrets.full", schema_version: 1, generated_at: $ts,
       tool: "state-secrets", slice: "full", app: $app, secrets: $s }'
}
