# lib/state_postgres.sh — Fly Managed Postgres state, digest + slice.
# Exports: run_state_postgres [app] [slice]
#   slice ∈ digest (default) | full
#
# Note: Fly's Postgres offering has TWO products: legacy "Fly Postgres" (an app
# in your org) and the newer "Managed Postgres" (separate dashboard product).
# We surface both: legacy via `fly postgres list -a <app>` and managed via
# `fly mpg list` if available.

run_state_postgres() {
  local app="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$slice" in
    digest) _state_postgres_digest "$app" "$ts" ;;
    full)   _state_postgres_full   "$app" "$ts" ;;
    *)
      printf '{"error":"unknown state postgres slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_pg_legacy_list() {
  # Legacy Fly Postgres: each is an app of role "postgres_cluster". Filter
  # `apps list` for those.
  local org; org="$(api_pick_org 2>/dev/null)" || { printf '[]'; return; }
  local body; body="$(fly_run_json apps list --org "$org" 2>/dev/null)"
  [[ -z "$body" ]] && { printf '[]'; return; }
  # Fly's apps list doesn't always tag role; we fall back to name heuristics
  # and let `fly status -a` enrich the digest.
  jq '[ .[] | select(((.Name // .name // "") | test("(postgres|pg)"; "i"))) | {
    name: (.Name // .name),
    status: (.Status // .status),
    hostname: (.Hostname // .hostname),
    deployed: (.Deployed // .deployed)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_pg_managed_list() {
  # `fly mpg list --json` (Managed Postgres). May not be installed/available
  # for all flyctl versions; tolerate failure.
  local body; body="$(fly_run_json mpg list 2>/dev/null)"
  if [[ -z "$body" ]]; then
    printf '[]'
    return
  fi
  jq '[ .[] | {
    id: (.id // .ID // null),
    name: (.name // .Name // null),
    region: (.region // .Region // null),
    state: (.state // .State // null),
    plan: (.plan // .Plan // null)
  } ]' <<<"$body" 2>/dev/null || printf '[]'
}

_pg_status_for() {
  local pg_app="$1"
  local body; body="$(fly_run_json status -a "$pg_app" 2>/dev/null)"
  [[ -z "$body" ]] && { printf '{}'; return; }
  jq '{
    name: (.Name // .name),
    status: (.Status // .status),
    hostname: (.Hostname // .hostname),
    image: (.ImageDetails.Repository // null),
    machines: ((.Machines // .machines // []) | map({id, region, state}))
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_state_postgres_digest() {
  local _app="$1" ts="$2"
  local legacy managed legacy_status="[]"
  legacy="$(_pg_legacy_list)"
  managed="$(_pg_managed_list)"
  while IFS= read -r pg; do
    [[ -z "$pg" || "$pg" == "null" ]] && continue
    local s; s="$(_pg_status_for "$pg")"
    legacy_status="$(jq --argjson s "$s" '. + [$s]' <<<"$legacy_status")"
  done < <(jq -r '.[].name' <<<"$legacy" 2>/dev/null)

  jq -n --arg ts "$ts" \
    --argjson legacy "$legacy" \
    --argjson legacy_status "$legacy_status" \
    --argjson managed "$managed" \
    '{
      schema: "flysec.state-postgres.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-postgres",
      slice: "digest",
      legacy_summary: {
        total: ($legacy | length),
        names: ($legacy | map(.name)),
        per_cluster_machines: ($legacy_status | map({(.name // "?"): ((.machines // []) | length)}) | add // {})
      },
      managed_summary: {
        total: ($managed | length),
        by_region: ($managed | group_by(.region) | map({key: (.[0].region // "?"), value: length}) | from_entries),
        by_plan: ($managed | group_by(.plan) | map({key: (.[0].plan // "?"), value: length}) | from_entries)
      },
      legacy: $legacy,
      legacy_status: $legacy_status,
      managed: $managed,
      hint: "rotate legacy passwords with: fly pg revoke -a <pg-app> --user <user>; for managed, use the dashboard."
    }'
}

_state_postgres_full() {
  local _app="$1" ts="$2"
  local legacy managed
  legacy="$(_pg_legacy_list)"
  managed="$(_pg_managed_list)"
  jq -n --arg ts "$ts" --argjson legacy "$legacy" --argjson managed "$managed" \
    '{ schema: "flysec.state-postgres.full", schema_version: 1, generated_at: $ts,
       tool: "state-postgres", slice: "full",
       legacy: $legacy, managed: $managed }'
}
