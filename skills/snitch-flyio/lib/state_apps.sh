# lib/state_apps.sh — apps inventory, digest by default + slice on request.
# Exports: run_state_apps [org] [slice]
#   slice ∈ digest (default) | full

run_state_apps() {
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
    digest) _state_apps_digest "$org" "$ts" ;;
    full)   _state_apps_full   "$org" "$ts" ;;
    *)
      printf '{"error":"unknown state apps slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_apps_list_full() {
  local org="$1"
  local body; body="$(fly_run_json apps list --org "$org" 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  # Normalize: each row contains Name, Status, Org, Hostname, ...
  jq '[ .[] | {
    name: (.Name // .name),
    status: (.Status // .status),
    org: (.Organization.Slug // .org // null),
    hostname: (.Hostname // .hostname // null),
    deployed: (.Deployed // .deployed // null),
    platform_version: (.PlatformVersion // .platform_version // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

# For the digest, we don't shell out to fly_run on every app — too slow.
# Instead we list apps once, then for the local cwd's fly.toml(s) we inspect
# force_https + plaintext-secret hint locally. That's the high-signal subset.
_apps_local_signals() {
  local out="[]"
  local toml
  while IFS= read -r toml; do
    [[ -n "$toml" && -f "$toml" ]] || continue
    local app force_https plaintext_secret_hint env_keys
    app="$(grep -E '^app[[:space:]]*=' "$toml" 2>/dev/null | head -n1 | sed -E 's/^app[[:space:]]*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')"
    if grep -E -q '^[[:space:]]*force_https[[:space:]]*=[[:space:]]*true' "$toml" 2>/dev/null; then
      force_https="true"
    elif grep -E -q '^[[:space:]]*force_https[[:space:]]*=[[:space:]]*false' "$toml" 2>/dev/null; then
      force_https="false"
    else
      force_https="unset"
    fi
    if grep -E -A 200 '^\[env\]' "$toml" 2>/dev/null \
      | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=[[:space:]]*"[^"]{24,}"' \
      | grep -E -i '(KEY|SECRET|TOKEN|PASS(WORD)?|DSN)' >/dev/null 2>&1; then
      plaintext_secret_hint="true"
    else
      plaintext_secret_hint="false"
    fi
    env_keys="$(grep -E -A 200 '^\[env\]' "$toml" 2>/dev/null \
      | grep -E '^[[:space:]]*[A-Z_][A-Z0-9_]*[[:space:]]*=' \
      | sed -E 's/^[[:space:]]*([A-Z_][A-Z0-9_]*).*/\1/' \
      | sort -u | jq -R . | jq -s . 2>/dev/null || printf '[]')"
    out="$(jq --arg toml "$toml" --arg app "$app" --arg fh "$force_https" \
            --arg ph "$plaintext_secret_hint" --argjson keys "$env_keys" \
            '. + [{toml:$toml, app:$app, force_https:$fh, plaintext_secret_hint:$ph, env_keys:$keys}]' \
            <<<"$out")"
  done < <(find . -maxdepth 4 \
    \( -name node_modules -o -name .git -o -name dist -o -name build -o -name .next \
       -o -name target -o -name vendor -o -name _build -o -name deps \) -prune \
    -o -type f -name 'fly.toml' -print 2>/dev/null \
    | sed -E 's|^\./||' | sort -u)
  printf '%s' "$out"
}

_state_apps_digest() {
  local org="$1" ts="$2"
  local apps local_signals total deployed
  apps="$(_apps_list_full "$org")"
  local_signals="$(_apps_local_signals)"
  total="$(jq -r 'length' <<<"$apps" 2>/dev/null || printf '0')"
  deployed="$(jq -r 'map(select(.deployed == true)) | length' <<<"$apps" 2>/dev/null || printf '0')"

  jq -n \
    --arg ts "$ts" --arg org "$org" \
    --argjson apps "$apps" \
    --argjson local_signals "$local_signals" \
    --argjson total "$total" \
    --argjson deployed "$deployed" \
    '{
      schema: "flysec.state-apps.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-apps",
      slice: "digest",
      org: $org,
      apps_summary: {
        total: $total,
        deployed: $deployed,
        names: ($apps | map(.name)),
        by_status: ($apps | group_by(.status) | map({key: .[0].status, value: length}) | from_entries)
      },
      apps: $apps,
      local_signals: $local_signals,
      hint: "for full data including config dump per app, run: state apps <org> full"
    }'
}

_state_apps_full() {
  local org="$1" ts="$2"
  local apps configs="[]"
  apps="$(_apps_list_full "$org")"
  # For each app, fetch config (heavy — only on full slice).
  while IFS= read -r app; do
    [[ -z "$app" || "$app" == "null" ]] && continue
    local cfg; cfg="$(fly_run_json config show -a "$app" 2>/dev/null || printf '{}')"
    configs="$(jq --arg name "$app" --argjson cfg "$cfg" '. + [{name:$name, config:$cfg}]' <<<"$configs")"
  done < <(jq -r '.[].name' <<<"$apps" 2>/dev/null)
  jq -n \
    --arg ts "$ts" --arg org "$org" \
    --argjson apps "$apps" \
    --argjson configs "$configs" \
    '{ schema: "flysec.state-apps.full", schema_version: 1, generated_at: $ts,
       tool: "state-apps", slice: "full", org: $org,
       apps: $apps, configs: $configs }'
}
