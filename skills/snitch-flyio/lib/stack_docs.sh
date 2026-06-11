# lib/stack_docs.sh — emit canonical doc URLs per stack so the agent can WebFetch.
# Exports: run_stack_docs [stack]

run_stack_docs() {
  local stack="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local file="${TPL_DIR}/stack-docs-registry.json"
  if [[ ! -f "$file" ]]; then
    printf '{"error":"missing stack-docs-registry.json","code":"E_TEMPLATE","path":"%s"}\n' "$file" >&2
    return 2
  fi
  if [[ -z "$stack" ]]; then
    jq -n --arg ts "$ts" --slurpfile r "$file" \
      '{ schema: "flysec.stack-docs", schema_version: 1, generated_at: $ts,
         tool: "stack-docs", registry: $r[0] }'
    return 0
  fi
  local entry
  entry="$(jq --arg s "$stack" '.[$s] // null' "$file")"
  if [[ "$entry" == "null" ]]; then
    printf '{"error":"unknown stack","code":"E_UNKNOWN_STACK","stack":"%s"}\n' "$stack" >&2
    return 2
  fi
  jq -n --arg ts "$ts" --arg s "$stack" --argjson e "$entry" \
    '{ schema: "flysec.stack-docs-entry", schema_version: 1, generated_at: $ts,
       tool: "stack-docs", stack: $s, entry: $e }'
}
