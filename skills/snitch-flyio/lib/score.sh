# lib/score.sh — external validators (SSL Labs, Mozilla Observatory, securityheaders, hstspreload).
# Exports: run_score [host...]
#
# All third-party APIs; tolerate failure per-host.

run_score() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local results="{}"
  local host

  if [[ $# -eq 0 ]]; then
    # Default: derive from cwd fly.toml app.fly.dev
    if [[ -f "fly.toml" ]]; then
      local app
      app="$(grep -E '^app[[:space:]]*=' fly.toml 2>/dev/null | head -n1 \
        | sed -E 's/^app[[:space:]]*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')"
      [[ -n "$app" ]] && set -- "${app}.fly.dev"
    fi
  fi

  if [[ $# -eq 0 ]]; then
    printf '{"error":"no hosts provided","code":"E_USAGE","remediation":"score <host1> [host2] ..."}\n' >&2
    return 2
  fi

  for host in "$@"; do
    local one; one="$(_score_one "$host")"
    results="$(jq --arg h "$host" --argjson v "$one" '. + {($h): $v}' <<<"$results")"
  done

  jq -n --arg ts "$ts" --argjson r "$results" \
    '{ schema: "flysec.score", schema_version: 1, generated_at: $ts,
       tool: "score", results: $r }'
}

_score_one() {
  local host="$1"
  local out="{}"
  # SSL Labs (async; just kicks off and returns whatever's cached)
  local ssl
  ssl="$(curl -sS --max-time 8 "https://api.ssllabs.com/api/v3/analyze?host=${host}&publish=off&fromCache=on&maxAge=24" 2>/dev/null || printf '{}')"
  out="$(jq --argjson v "$(jq '{grade:(.endpoints[0].grade // null), status:.status}' <<<"$ssl" 2>/dev/null || printf '{}')" \
    '. + {ssllabs: $v}' <<<"$out")"
  # Mozilla Observatory
  local moz
  moz="$(curl -sS --max-time 8 -X POST "https://http-observatory.security.mozilla.org/api/v1/analyze?host=${host}&hidden=true&rescan=false" 2>/dev/null || printf '{}')"
  out="$(jq --argjson v "$(jq '{grade, score, status: .state}' <<<"$moz" 2>/dev/null || printf '{}')" \
    '. + {mozilla_observatory: $v}' <<<"$out")"
  # securityheaders.com — HTML; we just cite the URL
  out="$(jq --arg url "https://securityheaders.com/?q=${host}&followRedirects=on" \
    '. + {securityheaders: {url: $url, grade: null}}' <<<"$out")"
  # HSTS preload
  local hsts
  hsts="$(curl -sS --max-time 8 "https://hstspreload.org/api/v2/status?domain=${host}" 2>/dev/null || printf '{}')"
  out="$(jq --argjson v "$(jq '{status}' <<<"$hsts" 2>/dev/null || printf '{}')" \
    '. + {hsts_preload: $v}' <<<"$out")"
  printf '%s' "$out"
}
