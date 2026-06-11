# lib/state_middleware.sh — introspect detected middleware.ts/js.
# Exports: run_state_middleware [project-id]
# Pure cwd inspection; no API calls required.

run_state_middleware() {
  local project_id="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local file=""
  for cand in middleware.ts middleware.js src/middleware.ts src/middleware.js app/middleware.ts; do
    if [[ -f "$cand" ]]; then file="$cand"; break; fi
  done
  if [[ -z "$file" ]]; then
    jq -n --arg ts "$ts" --arg project_id "$project_id" \
      '{
        schema: "vrcsec.state-middleware",
        schema_version: 1,
        generated_at: $ts,
        tool: "state-middleware",
        project_id: $project_id,
        present: false,
        path: null,
        signals: {}
      }'
    return 0
  fi

  # Heuristic flag detection.
  local rate_limit=false bot_block=false geo=false auth=false matcher=""
  if grep -E -q '(@upstash/ratelimit|rateLimit\(|ratelimit\.|express-rate-limit)' "$file" 2>/dev/null; then rate_limit=true; fi
  if grep -E -q '(user-agent|userAgent|bot|crawler|isbot|@vercel/edge.*ipAddress)' "$file" 2>/dev/null; then bot_block=true; fi
  if grep -E -q '(geo\.|request\.geo|x-vercel-ip-country|GeoIP)' "$file" 2>/dev/null; then geo=true; fi
  if grep -E -q '(jwt|session|cookie|authorization|nextauth|auth0|clerk|next-auth)' "$file" 2>/dev/null; then auth=true; fi
  matcher="$(grep -E -o 'matcher[[:space:]]*:[[:space:]]*\[[^]]*\]' "$file" 2>/dev/null | head -n1 | sed 's/"/\\"/g')"

  jq -n --arg ts "$ts" --arg project_id "$project_id" \
    --arg path "$file" \
    --argjson rate_limit "$rate_limit" \
    --argjson bot_block "$bot_block" \
    --argjson geo "$geo" \
    --argjson auth "$auth" \
    --arg matcher "$matcher" \
    '{
      schema: "vrcsec.state-middleware",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-middleware",
      project_id: $project_id,
      present: true,
      path: $path,
      signals: {
        rate_limit_detected: $rate_limit,
        bot_block_detected: $bot_block,
        geo_routing_detected: $geo,
        auth_at_edge_detected: $auth
      },
      matcher_excerpt: $matcher,
      hint: "matcher narrows scope; an unbounded matcher means the function runs on every request and bills accordingly."
    }'
}
