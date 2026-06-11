# lib/state_env.sh — env-var posture per environment.
# Exports: run_state_env [project-id] [slice]
#   slice ∈ digest (default) | production | preview | development | full
#
# Heuristics:
#   - Flags any NEXT_PUBLIC_* var whose value (when readable) looks secret-shaped.
#   - Flags any plaintext (non-Sensitive, non-encrypted) var with a secret-shaped name/value.

run_state_env() {
  local project_id="${1:-}" slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT","remediation":"set VRCSEC_PROJECT_ID or pass project-id"}\n' >&2
    return 3
  fi
  case "$slice" in
    digest)        _se_digest "$project_id" "$ts" ;;
    production)    _se_one_env "$project_id" "$ts" "production" ;;
    preview)       _se_one_env "$project_id" "$ts" "preview" ;;
    development)   _se_one_env "$project_id" "$ts" "development" ;;
    full)          _se_full "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state env slice","code":"E_USAGE","got":"%s","valid":["digest","production","preview","development","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

# Fetch env list (decrypted=false to avoid pulling secret values).
_se_list() {
  local project_id="$1"
  local body; body="$(vrc_get "/v9/projects/${project_id}/env?decrypt=false")" || {
    printf '{"error":"failed to list env","code":"E_API","status":%s,"project_id":"%s"}\n' "${VRCSEC_LAST_STATUS:-0}" "$project_id" >&2
    printf '[]'
    return
  }
  jq '[(.envs // [])[] | {
    id, key, type, target,
    gitBranch: (.gitBranch // null),
    comment: (.comment // null),
    sensitive: (.type == "secret" or .type == "sensitive"),
    createdAt, updatedAt
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

# Detect secret-shaped names that should be Sensitive.
_se_secret_name_jq() {
  cat <<'JQ'
def secret_name:
  test("(?i)(secret|token|api[_-]?key|password|passwd|private_key|dsn|connection|database_url)");
JQ
}

_se_digest() {
  local project_id="$1" ts="$2"
  local envs; envs="$(_se_list "$project_id")"

  # Pull NEXT_PUBLIC_* leak suspects from .env files in cwd (if any).
  local public_suspects='[]'
  if compgen -G ".env*" >/dev/null 2>&1; then
    public_suspects="$(. "${LIB_DIR}/detect.sh"; _det_next_public_envs)"
  fi

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --argjson envs "$envs" --argjson public_suspects "$public_suspects" \
    "$(_se_secret_name_jq) "'
    {
      schema: "vrcsec.state-env.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-env",
      slice: "digest",
      project_id: $project_id,
      counts: {
        production:  ($envs | map(select(.target | index("production"))) | length),
        preview:     ($envs | map(select(.target | index("preview")))    | length),
        development: ($envs | map(select(.target | index("development"))) | length),
        total: ($envs | length)
      },
      sensitive_summary: {
        sensitive_total: ($envs | map(select(.sensitive == true)) | length),
        plaintext_total: ($envs | map(select(.sensitive == false)) | length),
        plaintext_with_secret_name: [ $envs[] | select(.sensitive == false and (.key | secret_name)) | .key ],
        next_public_secret_shape: [ $envs[] | select(.key | startswith("NEXT_PUBLIC_")) | select(.key | secret_name) | .key ]
      },
      next_public_envs_in_cwd: $public_suspects,
      envs_meta: $envs,
      hint: "for full per-environment data, run: state env <project-id> [production|preview|development|full]"
    }
    '
}

_se_one_env() {
  local project_id="$1" ts="$2" target="$3"
  local envs; envs="$(_se_list "$project_id")"
  local filtered
  filtered="$(jq --arg t "$target" '[ .[] | select(.target | index($t)) ]' <<<"$envs")"
  jq -n --arg ts "$ts" --arg project_id "$project_id" --arg target "$target" \
    --argjson envs "$filtered" \
    '{ schema: "vrcsec.state-env.target", schema_version: 1, generated_at: $ts,
       tool: "state-env", slice: $target, project_id: $project_id, target: $target,
       envs: $envs }'
}

_se_full() {
  local project_id="$1" ts="$2"
  local envs; envs="$(_se_list "$project_id")"
  jq -n --arg ts "$ts" --arg project_id "$project_id" --argjson envs "$envs" \
    '{ schema: "vrcsec.state-env.full", schema_version: 1, generated_at: $ts,
       tool: "state-env", slice: "full", project_id: $project_id, envs: $envs }'
}
