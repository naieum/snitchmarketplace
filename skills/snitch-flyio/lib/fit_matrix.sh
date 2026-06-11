# lib/fit_matrix.sh — emit migration fit matrix.
# Exports: run_fit_matrix [stack]

run_fit_matrix() {
  local stack="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local file="${TPL_DIR}/migration-fit-matrix.json"
  if [[ ! -f "$file" ]]; then
    printf '{"error":"missing migration-fit-matrix.json","code":"E_TEMPLATE","path":"%s"}\n' "$file" >&2
    return 2
  fi
  if [[ -z "$stack" ]]; then
    jq -n --arg ts "$ts" --slurpfile m "$file" \
      '{ schema: "flysec.fit-matrix", schema_version: 1, generated_at: $ts,
         tool: "fit-matrix", matrix: $m[0] }'
    return 0
  fi
  local entry
  entry="$(jq --arg s "$stack" '.[$s] // null' "$file")"
  if [[ "$entry" == "null" ]]; then
    printf '{"error":"unknown stack","code":"E_UNKNOWN_STACK","stack":"%s"}\n' "$stack" >&2
    return 2
  fi
  jq -n --arg ts "$ts" --arg s "$stack" --argjson e "$entry" \
    '{ schema: "flysec.fit-matrix-entry", schema_version: 1, generated_at: $ts,
       tool: "fit-matrix", stack: $s, entry: $e }'
}
