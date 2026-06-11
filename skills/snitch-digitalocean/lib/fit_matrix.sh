# lib/fit_matrix.sh — read templates/migration-fit-matrix.json.
# Exports: run_fit_matrix [stack]

run_fit_matrix() {
  local stack="${1:-}"
  local file="${TPL_DIR}/migration-fit-matrix.json"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ ! -f "$file" ]]; then
    printf '{"error":"fit-matrix template missing","code":"E_TEMPLATE","remediation":"reinstall the skill","path":"%s"}\n' "$file" >&2
    return 4
  fi

  if [[ -z "$stack" ]]; then
    jq -n --arg ts "$ts" --slurpfile m "$file" \
      '{ schema: "dosec.fit-matrix", schema_version: 1, generated_at: $ts,
         tool: "fit-matrix", matrix: $m[0] }'
    return 0
  fi

  local entry; entry="$(jq --arg s "$stack" '.[$s] // empty' "$file" 2>/dev/null)"
  if [[ -z "$entry" ]]; then
    printf '{"error":"unknown stack","code":"E_UNKNOWN_STACK","stack":"%s","remediation":"run snitch-digitalocean.sh fit-matrix without args to see all stack keys"}\n' "$stack" >&2
    return 5
  fi

  jq -n --arg ts "$ts" --arg stack "$stack" --argjson entry "$entry" \
    '{ schema: "dosec.fit-matrix-entry", schema_version: 1, generated_at: $ts,
       tool: "fit-matrix", stack: $stack, entry: $entry }'
}
