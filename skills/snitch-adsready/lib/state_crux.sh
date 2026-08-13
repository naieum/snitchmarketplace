# lib/state_crux.sh — Chrome UX Report (CrUX) field data via the PageSpeed
# Insights API. Anonymous calls work but are rate-limited; PSI_API_KEY raises
# the quota.
#
# Exports: run_state_crux <url> [mobile|desktop]

run_state_crux() {
  local url="${1:-}"
  local strategy="${2:-mobile}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$url" ]]; then
    printf '{"error":"state crux requires a URL","code":"E_USAGE","remediation":"usage: state crux <url> [mobile|desktop]"}\n' >&2
    return 2
  fi
  case "$url" in
    http://*|https://*) ;;
    *)
      printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s"}\n' "$url" >&2
      return 2 ;;
  esac
  case "$strategy" in
    mobile|desktop) ;;
    *)
      printf '{"error":"strategy must be mobile or desktop","code":"E_USAGE","got":"%s"}\n' "$strategy" >&2
      return 2 ;;
  esac

  local api="https://www.googleapis.com/pagespeedonline/v5/runPagespeed"
  # Encode URL minimally; assume the agent passes a sane URL.
  local q="url=${url}&strategy=${strategy}&category=performance&category=accessibility&category=best-practices&category=seo"
  if has_psi_api_key; then
    q+="&key=${PSI_API_KEY}"
  fi
  local full="${api}?${q}"

  local body
  body="$(http_get "$full" 2>/dev/null || true)"
  local code="${ADSEC_LAST_STATUS:-000}"
  if [[ ! "$code" =~ ^2 ]]; then
    printf '{"error":"PSI API call failed","code":"E_PSI","status":"%s","url":"%s","remediation":"set PSI_API_KEY to raise the quota; or retry later"}\n' "$code" "$url" >&2
    return 3
  fi

  # Extract field data + lab category scores into a compact JSON shape.
  local digest
  digest="$(jq '{
    requested_url: .id,
    final_url: .lighthouseResult.finalUrl,
    fetch_time: .analysisUTCTimestamp,
    strategy: .lighthouseResult.configSettings.formFactor,
    categories: (.lighthouseResult.categories | to_entries | map({key: .key, score: .value.score}) | from_entries),
    field_data: (
      .loadingExperience as $le |
      {
        overall_category: ($le.overall_category // null),
        metrics: ($le.metrics // {} | to_entries | map({
          key: .key,
          percentile: .value.percentile,
          category: .value.category
        }) | from_entries)
      }
    ),
    origin_field_data: (
      .originLoadingExperience as $oe |
      ($oe // null)
    ),
    audits_summary: (
      .lighthouseResult.audits | to_entries | map(select(.value.score != null)) | map({
        id: .key,
        score: .value.score,
        title: .value.title
      })
    )
  }' <<<"$body" 2>/dev/null)"

  jq -n --arg ts "$ts" --arg url "$url" --arg strategy "$strategy" \
    --argjson digest "${digest:-{}}" \
    --argjson has_key "$(has_psi_api_key && printf 'true' || printf 'false')" \
    '{
      schema: "adssec.state-crux",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-crux",
      url: $url,
      strategy: $strategy,
      psi_api_key_used: $has_key,
      data: $digest
    }'
}
