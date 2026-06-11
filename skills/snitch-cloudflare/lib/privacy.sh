# lib/privacy.sh — privacy + first-party analytics recommendations.
# Exposes:
#   privacy_run — read-only detection of analytics + 3rd-party tags, recommends Cloudflare Web Analytics + Zaraz.
# No _fix; surfaces as WARN only.

# Greppable signal sets.
_PRIV_GA_PATTERNS=(
  'gtag\('
  'googletagmanager\.com'
  'google-analytics\.com'
  'window\.dataLayer'
)

_PRIV_ALT_ANALYTICS=(
  'plausible\.io'
  'usefathom\.com'
  'cdn\.usefathom\.com'
  'mixpanel\.com'
  'mixpanel\.init'
  'amplitude\.com'
  'amplitude\.init'
)

# 3rd-party tag signals -> "name|pattern"
_PRIV_THIRD_PARTY=(
  'Stripe|js\.stripe\.com'
  'Stripe|@stripe/stripe-js'
  'Hotjar|static\.hotjar\.com'
  'Hotjar|hj\('
  'Hubspot|js\.hs-scripts\.com'
  'Hubspot|js\.hs-analytics\.net'
  'GTM|googletagmanager\.com/gtm\.js'
  'FacebookPixel|connect\.facebook\.net.*fbevents'
  'FacebookPixel|fbq\('
  'Intercom|widget\.intercom\.io'
  'Intercom|intercomSettings'
  'Drift|js\.driftt\.com'
  'Drift|drift\.load'
)

_PRIV_GREP_INCLUDES=(
  --include='*.html'
  --include='*.htm'
  --include='*.js'
  --include='*.ts'
  --include='*.tsx'
  --include='*.jsx'
  --include='*.mjs'
  --include='*.cjs'
  --include='*.vue'
  --include='*.svelte'
  --include='*.astro'
  --include='*.liquid'
  --include='*.njk'
  --include='*.ejs'
  --include='*.hbs'
)

# _priv_grep <pattern> -> 0 if found, prints first match line.
_priv_grep() {
  local pat="$1"
  grep -REn "${_PRIV_GREP_INCLUDES[@]}" -e "$pat" . 2>/dev/null | head -1
}

# _priv_emit_cf_web_analytics_tag
_priv_emit_cf_web_analytics_tag() {
  cat <<'CFWA_EOF'

Cloudflare Web Analytics: drop this in your HTML <head> (or layout):

  <script defer src="https://static.cloudflareinsights.com/beacon.min.js"
          data-cf-beacon='{"token": "REPLACE_WITH_TOKEN"}'></script>

Get a token at https://dash.cloudflare.com/?to=/:account/web-analytics
No cookies, no consent banner required for basic page-view + RUM.

Honest scope: CF Web Analytics covers page views + Core Web Vitals.
It does NOT replace event/funnel analytics (Mixpanel, Amplitude territory).
CFWA_EOF
}

# _priv_emit_zaraz_starter <detected_csv>
_priv_emit_zaraz_starter() {
  local detected="$1"
  local f="${TPL_DIR}/zaraz-config.starter.json"
  local body=""
  if [[ -f "$f" ]]; then
    body="$(cat "$f")"
  else
    body='{
  "version": 1,
  "consent": {
    "enabled": true,
    "modal_intro": "We use a small set of tools to operate this site. You can opt out per category.",
    "purposes": [
      {"id": "functional",  "name": "Functional",  "description": "Required for the site to work."},
      {"id": "analytics",   "name": "Analytics",   "description": "Helps us understand usage."},
      {"id": "marketing",   "name": "Marketing",   "description": "Ads + remarketing pixels."}
    ]
  },
  "tools": []
}'
  fi

  # Augment tools array with detected items.
  local tools_jq='[]'
  if [[ -n "$detected" ]]; then
    tools_jq='['
    local first=1
    local item
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      [[ $first -eq 0 ]] && tools_jq+=','
      first=0
      tools_jq+="{\"name\":\"${item}\",\"enabled\":true,\"consent_purpose\":\"analytics\"}"
    done < <(printf '%s\n' "$detected" | tr ',' '\n')
    tools_jq+=']'
  fi

  local merged
  merged="$(jq --argjson tools "$tools_jq" '.tools = $tools' <<<"$body" 2>/dev/null || printf '%s' "$body")"

  printf '\n=== FILE: zaraz-config.starter.json ===\n'
  printf '=== DIFF ===\n'
  printf -- '--- /dev/null\n+++ zaraz-config.starter.json\n'
  printf '%s\n' "$merged" | sed 's/^/+/'
  printf '=== CONTENT ===\n'
  printf '%s\n' "$merged"
  printf '=== END ===\n'
}

# privacy_run — detect analytics + 3rd-party tags, surface recommendations.
privacy_run() {
  log_section "privacy + first-party analytics"

  log_subsection "analytics detection"
  local found_ga=0
  local found_alt=()
  local pat
  for pat in "${_PRIV_GA_PATTERNS[@]}"; do
    if [[ -n "$(_priv_grep "$pat")" ]]; then
      found_ga=1
      break
    fi
  done

  for entry in "${_PRIV_ALT_ANALYTICS[@]}"; do
    if [[ -n "$(_priv_grep "$entry")" ]]; then
      case "$entry" in
        *plausible*) found_alt+=("Plausible") ;;
        *fathom*)    found_alt+=("Fathom") ;;
        *mixpanel*)  found_alt+=("Mixpanel") ;;
        *amplitude*) found_alt+=("Amplitude") ;;
      esac
    fi
  done

  if [[ "$found_ga" -eq 1 ]]; then
    log_warn "privacy" "ga-detected" \
      "Google Analytics / GTM detected. Consider Cloudflare Web Analytics for basic page-view + RUM (no cookies, no consent banner required)." \
      "https://developers.cloudflare.com/web-analytics/"
    _priv_emit_cf_web_analytics_tag
  fi

  if [[ "${#found_alt[@]}" -gt 0 ]]; then
    local joined="${found_alt[*]}"
    log_warn "privacy" "alt-analytics" \
      "Third-party analytics detected: ${joined}. Cloudflare Web Analytics is a free, no-cookie alternative for page-view + RUM." \
      "https://developers.cloudflare.com/web-analytics/"
  fi

  if [[ "$found_ga" -eq 0 && "${#found_alt[@]}" -eq 0 ]]; then
    log_ok "privacy" "analytics" "No third-party analytics tags detected in source."
  fi

  log_subsection "third-party tags (Zaraz candidates)"
  local detected_tags=()
  local entry name pat_only
  for entry in "${_PRIV_THIRD_PARTY[@]}"; do
    name="${entry%%|*}"
    pat_only="${entry#*|}"
    if [[ -n "$(_priv_grep "$pat_only")" ]]; then
      # de-dup
      local dup=0
      for d in "${detected_tags[@]:-}"; do
        [[ "$d" == "$name" ]] && dup=1 && break
      done
      [[ "$dup" -eq 0 ]] && detected_tags+=("$name")
    fi
  done

  if [[ "${#detected_tags[@]}" -eq 0 ]]; then
    log_ok "privacy" "third-party" "No common third-party tags detected (Stripe, Hotjar, Hubspot, GTM, Facebook Pixel, Intercom, Drift)."
    return 0
  fi

  local joined_tags
  joined_tags="$(IFS=,; printf '%s' "${detected_tags[*]}")"
  log_warn "privacy" "zaraz" \
    "Third-party tags detected: ${joined_tags}. Consider Cloudflare Zaraz: server-side tag manager, consent gating, moves 3rd-party JS off the browser. Reduces supply-chain risk vs raw <script src=>." \
    "https://developers.cloudflare.com/zaraz/"

  _priv_emit_zaraz_starter "$joined_tags"
}
