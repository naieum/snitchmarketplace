# lib/stack_docs.sh — read templates/stack-docs-registry.json.
# Exports: run_stack_docs [stack]

run_stack_docs() {
  local stack="${1:-}"
  local file="${TPL_DIR}/stack-docs-registry.json"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ ! -f "$file" ]]; then
    printf '{"error":"stack-docs registry missing","code":"E_TEMPLATE","remediation":"reinstall the skill","path":"%s"}\n' "$file" >&2
    return 4
  fi

  if [[ -z "$stack" ]]; then
    jq -n --arg ts "$ts" --slurpfile r "$file" \
      '{
        schema: "vrcsec.stack-docs",
        schema_version: 1,
        generated_at: $ts,
        tool: "stack-docs",
        registry: $r[0]
      }'
    return 0
  fi

  local entry; entry="$(jq --arg s "$stack" '.[$s] // empty' "$file" 2>/dev/null)"
  if [[ -z "$entry" ]]; then
    printf '{"error":"unknown stack","code":"E_UNKNOWN_STACK","stack":"%s","remediation":"run snitch-vercel.sh stack-docs without args to see all keys"}\n' "$stack" >&2
    return 5
  fi

  jq -n --arg ts "$ts" --arg stack "$stack" --argjson entry "$entry" \
    '{
      schema: "vrcsec.stack-docs-entry",
      schema_version: 1,
      generated_at: $ts,
      tool: "stack-docs",
      stack: $stack,
      entry: $entry
    }'
}
