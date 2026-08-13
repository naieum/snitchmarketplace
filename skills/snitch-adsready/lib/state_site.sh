# lib/state_site.sh — universal site-side audit.
# Fetches a URL once, parses it for ALL 10 platforms' pixel signals + consent +
# structured data + companion files (robots.txt, sitemap.xml, ads.txt,
# app-ads.txt, security.txt, llms.txt). Slices: digest|html|headers|pixels|
# consent|structured-data|robots|sitemap|ads-txt|full
#
# Exports: run_state_site <url> [slice]

# --- low-level fetchers (cached per-call in $STATE_DIR) ---

# Cache key for a url.
_ss_cache_key() {
  local url="$1"
  # Filesystem-safe slug, includes a short hash for uniqueness.
  local hash
  if command -v shasum >/dev/null 2>&1; then
    hash="$(printf '%s' "$url" | shasum -a 256 | awk '{print substr($1,1,12)}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    hash="$(printf '%s' "$url" | sha256sum | awk '{print substr($1,1,12)}')"
  else
    hash="nohash"
  fi
  printf '%s' "$hash"
}

# _ss_fetch_html <url>  -> echoes HTML body; writes status code to a tempfile.
# Note: ADSEC_LAST_STATUS set inside $(…) doesn't propagate back to the parent shell.
# Callers read the status via _ss_last_status() which reads /tmp/adsec_fetch_status_$$.
_ss_fetch_html() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -L --max-redirs 5 \
    --max-time "${ADSEC_HTTP_TIMEOUT:-15}" \
    -A "${ADSEC_USER_AGENT:-ads-ready-skill/1}" \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  printf '%s' "$code" > "/tmp/adsec_fetch_status_$$"
  if [[ "$code" != "000" ]]; then
    cat "$tmp"
  fi
  rm -f "$tmp"
}

# _ss_fetch_headers <url> -> echoes raw header text; writes status to tempfile.
_ss_fetch_headers() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -L --max-redirs 5 \
    --max-time "${ADSEC_HTTP_TIMEOUT:-15}" \
    -A "${ADSEC_USER_AGENT:-ads-ready-skill/1}" \
    -I \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  printf '%s' "$code" > "/tmp/adsec_fetch_status_$$"
  cat "$tmp"
  rm -f "$tmp"
}

# Read the status code captured by the most recent _ss_fetch_* call.
_ss_last_status() {
  cat "/tmp/adsec_fetch_status_$$" 2>/dev/null || printf '000'
}

# Build "<scheme>://<host>" from a full URL.
_ss_origin() {
  local url="$1"
  printf '%s' "$url" | sed -E 's,(https?://[^/]+).*,\1,'
}

# --- pixel extractors ---

# Each extractor reads HTML on stdin and emits a JSON snippet of the form:
#   {"detected": <bool>, "ids": [<string>, ...], "evidence": "<short str>"}

_ss_extract_google() {
  local html="$1"
  local ga_ids gtm_ids aw_ids ua_ids
  ga_ids="$(printf '%s' "$html" | grep -E -o 'G-[A-Z0-9]{4,}' 2>/dev/null | sort -u)"
  gtm_ids="$(printf '%s' "$html" | grep -E -o 'GTM-[A-Z0-9]+' 2>/dev/null | sort -u)"
  aw_ids="$(printf '%s' "$html" | grep -E -o 'AW-[0-9]+' 2>/dev/null | sort -u)"
  ua_ids="$(printf '%s' "$html" | grep -E -o 'UA-[0-9]+-[0-9]+' 2>/dev/null | sort -u)"
  local all=""
  [[ -n "$ga_ids" ]]  && all+="${ga_ids}"$'\n'
  [[ -n "$gtm_ids" ]] && all+="${gtm_ids}"$'\n'
  [[ -n "$aw_ids" ]]  && all+="${aw_ids}"$'\n'
  [[ -n "$ua_ids" ]]  && all+="${ua_ids}"$'\n'
  local ids_json="[]"
  if [[ -n "$all" ]]; then
    ids_json="$(printf '%s' "$all" | grep -v '^$' | jq -R . | jq -s .)"
  fi
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"google", detected:$detected, ids:$ids}'
}

_ss_extract_meta() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "fbq\\('init',[[:space:]]*['\"][0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([0-9]+)['\"].*/\1/" | sort -u)"
  local fb_helper
  fb_helper="$(printf '%s' "$html" | grep -E -c 'connect\.facebook\.net/[a-z_A-Z]+/fbevents\.js' 2>/dev/null || true)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  if [[ "$ids_json" != "[]" || "$fb_helper" -gt 0 ]]; then detected="true"; fi
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"meta", detected:$detected, ids:$ids}'
}

_ss_extract_microsoft() {
  local html="$1"
  local ids
  # UET tag id: window.uetq plus the tag id passed as ti:'...'
  ids="$(printf '%s' "$html" \
    | grep -E -o "ti:[[:space:]]*['\"][0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([0-9]+)['\"].*/\1/" | sort -u)"
  local has_uet
  has_uet="$(printf '%s' "$html" | grep -E -c 'bat\.bing\.com/bat\.js|window\.uetq' 2>/dev/null || true)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  if [[ "$ids_json" != "[]" || "$has_uet" -gt 0 ]]; then detected="true"; fi
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"microsoft", detected:$detected, ids:$ids}'
}

_ss_extract_linkedin() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "_linkedin_partner_id[[:space:]]*=[[:space:]]*['\"][0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([0-9]+)['\"].*/\1/" | sort -u)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"linkedin", detected:$detected, ids:$ids}'
}

_ss_extract_tiktok() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "ttq\.load\([[:space:]]*['\"][A-Z0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([A-Z0-9]+)['\"].*/\1/" | sort -u)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"tiktok", detected:$detected, ids:$ids}'
}

_ss_extract_x() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "twq\([[:space:]]*['\"]config['\"][[:space:]]*,[[:space:]]*['\"][a-z0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([a-z0-9]+)['\"][[:space:]]*\$/\1/" | sort -u)"
  local has_twq
  has_twq="$(printf '%s' "$html" | grep -E -c 'static\.ads-twitter\.com/uwt\.js|twq\(' 2>/dev/null || true)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  if [[ "$ids_json" != "[]" || "$has_twq" -gt 0 ]]; then detected="true"; fi
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"x", detected:$detected, ids:$ids}'
}

_ss_extract_pinterest() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "pintrk\([[:space:]]*['\"]load['\"][[:space:]]*,[[:space:]]*['\"][0-9]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([0-9]+)['\"].*/\1/" | sort -u)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"pinterest", detected:$detected, ids:$ids}'
}

_ss_extract_reddit() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "rdt\([[:space:]]*['\"]init['\"][[:space:]]*,[[:space:]]*['\"][a-z0-9_]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([a-z0-9_]+)['\"].*/\1/" | sort -u)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"reddit", detected:$detected, ids:$ids}'
}

_ss_extract_snapchat() {
  local html="$1"
  local ids
  ids="$(printf '%s' "$html" \
    | grep -E -o "snaptr\([[:space:]]*['\"]init['\"][[:space:]]*,[[:space:]]*['\"][0-9a-f-]+['\"]" 2>/dev/null \
    | sed -E "s/.*['\"]([0-9a-f-]+)['\"].*/\1/" | sort -u)"
  local ids_json="[]"
  [[ -n "$ids" ]] && ids_json="$(printf '%s' "$ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"snapchat", detected:$detected, ids:$ids}'
}

_ss_extract_apple() {
  local html="$1"
  # Apple Search Ads itself doesn't have a web pixel — surface the iOS hint via
  # the apple-itunes-app meta tag (which links to an App Store id).
  local app_ids
  app_ids="$(printf '%s' "$html" \
    | grep -E -i -o '<meta[[:space:]]+name=["'\'']apple-itunes-app["'\''][^>]*app-id=[0-9]+' 2>/dev/null \
    | grep -E -o 'app-id=[0-9]+' | sed -E 's/app-id=//' | sort -u)"
  local ids_json="[]"
  [[ -n "$app_ids" ]] && ids_json="$(printf '%s' "$app_ids" | jq -R . | jq -s .)"
  local detected="false"
  [[ "$ids_json" != "[]" ]] && detected="true"
  jq -n --argjson detected "$detected" --argjson ids "$ids_json" \
    '{platform:"apple", detected:$detected, ids:$ids, note:"Apple Search Ads is iOS-only; web tag is the apple-itunes-app meta link to an App Store id."}'
}

# --- lead-capture extractor (call tracking + offline-conversion readiness) ---

# Reads HTML, emits JSON:
#   { tel_links: {count, numbers}, call_tracking: {...}, forms: {...}, flags: {...} }
# Static-HTML heuristics only: a GTM container can carry call tracking or gclid
# capture this parser can't see — gtm_present is included so the agent can
# soften the flags accordingly.
_ss_extract_lead_capture() {
  local html="$1"

  # tel: links — unique normalized numbers (capped at 10 for payload size).
  local tel_numbers tel_count
  tel_numbers="$(printf '%s' "$html" \
    | grep -E -i -o 'href=["'\'']tel:[^"'\'']+' 2>/dev/null \
    | sed -E 's/^[^:]*://; s/[^0-9+]//g' | grep -v '^$' | sort -u | head -10)"
  tel_count=0
  [[ -n "$tel_numbers" ]] && tel_count="$(printf '%s\n' "$tel_numbers" | grep -c . || true)"
  local tel_json="[]"
  [[ -n "$tel_numbers" ]] && tel_json="$(printf '%s\n' "$tel_numbers" | jq -R . | jq -s .)"

  # Google website call conversions: gtag config carrying phone_conversion_number.
  local phone_conv="false"
  printf '%s' "$html" | grep -E -q 'phone_conversion_number' 2>/dev/null && phone_conv="true"

  # Dynamic number insertion (DNI) providers — first recognized script host wins.
  local dni="none"
  if   printf '%s' "$html" | grep -E -q -i 'callrail\.com' 2>/dev/null; then dni="callrail"
  elif printf '%s' "$html" | grep -E -q -i 'calltrackingmetrics\.com|tctm\.co' 2>/dev/null; then dni="calltrackingmetrics"
  elif printf '%s' "$html" | grep -E -q -i 'invoca(cdn)?\.(net|com)' 2>/dev/null; then dni="invoca"
  elif printf '%s' "$html" | grep -E -q -i 'whatconverts\.com' 2>/dev/null; then dni="whatconverts"
  elif printf '%s' "$html" | grep -E -q -i 'marchex\.(com|io)' 2>/dev/null; then dni="marchex"
  fi

  # Forms + offline-conversion readiness signals.
  local form_count
  form_count="$(printf '%s' "$html" | grep -E -i -c '<form[[:space:]>]' 2>/dev/null || true)"
  local gclid_field="false"
  printf '%s' "$html" | grep -E -i -q '(name|id)=["'\'']gclid' 2>/dev/null && gclid_field="true"
  local gclid_js="false"
  printf '%s' "$html" | grep -E -q 'gclid' 2>/dev/null && gclid_js="true"
  local ec_signal="false"
  printf '%s' "$html" | grep -E -q 'enhanced_conversion|user_data' 2>/dev/null && ec_signal="true"
  local gtm_present="false"
  printf '%s' "$html" | grep -E -q 'GTM-[A-Z0-9]+' 2>/dev/null && gtm_present="true"

  # Derived flags (heuristic — see gtm_present caveat above).
  local untracked_phone="false"
  if [[ "$tel_count" -gt 0 && "$phone_conv" == "false" && "$dni" == "none" ]]; then
    untracked_phone="true"
  fi
  local offline_not_ready="false"
  if [[ "$form_count" -gt 0 && "$gclid_field" == "false" && "$gclid_js" == "false" && "$ec_signal" == "false" ]]; then
    offline_not_ready="true"
  fi

  jq -n \
    --argjson tel_count "$tel_count" \
    --argjson tel_numbers "$tel_json" \
    --argjson phone_conv "$phone_conv" \
    --arg dni "$dni" \
    --argjson form_count "$form_count" \
    --argjson gclid_field "$gclid_field" \
    --argjson gclid_js "$gclid_js" \
    --argjson ec_signal "$ec_signal" \
    --argjson gtm_present "$gtm_present" \
    --argjson untracked_phone "$untracked_phone" \
    --argjson offline_not_ready "$offline_not_ready" \
    '{
      tel_links: {count: $tel_count, numbers: $tel_numbers},
      call_tracking: {phone_conversion_config: $phone_conv, dni_provider: $dni},
      forms: {count: $form_count, gclid_field: $gclid_field, gclid_js_capture: $gclid_js, enhanced_conversions_signal: $ec_signal},
      gtm_present: $gtm_present,
      flags: {untracked_phone_path: $untracked_phone, offline_import_not_ready: $offline_not_ready},
      note: "static-HTML heuristics; a GTM container may carry call tracking or gclid capture not visible here — check the container when gtm_present is true"
    }'
}

# --- consent extractor ---

_ss_extract_consent() {
  local html="$1"
  local platform="none"
  local mode_v2="false"
  local has_dataLayer="false"

  if   printf '%s' "$html" | grep -E -q -i 'cookiebot\.com|Cookiebot|cbid' 2>/dev/null; then platform="cookiebot"
  elif printf '%s' "$html" | grep -E -q -i 'OneTrust|optanon|cdn\.cookielaw\.org' 2>/dev/null; then platform="onetrust"
  elif printf '%s' "$html" | grep -E -q -i 'iubenda\.com|_iub' 2>/dev/null; then platform="iubenda"
  elif printf '%s' "$html" | grep -E -q -i 'cookieyes\.com' 2>/dev/null; then platform="cookieyes"
  elif printf '%s' "$html" | grep -E -q -i 'termly\.io' 2>/dev/null; then platform="termly"
  elif printf '%s' "$html" | grep -E -q -i 'osano\.com' 2>/dev/null; then platform="osano"
  elif printf '%s' "$html" | grep -E -q 'klaroConfig|klaro\.js' 2>/dev/null; then platform="klaro"
  elif printf '%s' "$html" | grep -E -q 'tarteaucitron' 2>/dev/null; then platform="tarteaucitron"
  elif printf '%s' "$html" | grep -E -q -i 'quantcast' 2>/dev/null; then platform="quantcast"
  fi

  if printf '%s' "$html" | grep -E -q "gtag\\('consent'" 2>/dev/null; then mode_v2="true"; fi
  if printf '%s' "$html" | grep -E -q 'dataLayer\.push' 2>/dev/null; then has_dataLayer="true"; fi

  jq -n \
    --arg platform "$platform" \
    --argjson mode_v2 "$mode_v2" \
    --argjson has_data_layer "$has_dataLayer" \
    '{platform:$platform, consent_mode_v2:$mode_v2, has_data_layer:$has_data_layer}'
}

# --- structured data extractor ---

_ss_extract_structured_data() {
  local html="$1"
  # Pull every <script type="application/ld+json">...</script> block (greedy
  # close, single-pass via sed). Use awk for a multi-line capture.
  local blocks
  blocks="$(printf '%s' "$html" | awk '
    BEGIN { capture=0 }
    /<script[^>]*type=["'\'']application\/ld\+json["'\''][^>]*>/ {
      capture=1
      sub(/^.*<script[^>]*>/, "")
    }
    capture==1 {
      if ($0 ~ /<\/script>/) {
        sub(/<\/script>.*$/, "")
        print $0
        print "<<<JSONLD-BLOCK-END>>>"
        capture=0
      } else {
        print $0
      }
    }
  ' 2>/dev/null)"

  if [[ -z "$blocks" ]]; then
    printf '{"jsonld_count":0,"types":[],"valid":[],"invalid":[]}'
    return
  fi

  local valid_count=0
  local invalid_count=0
  local types_seen=""
  local valid_payload="[]"
  local invalid_payload="[]"
  local current=""
  local in_block=1
  while IFS= read -r line; do
    if [[ "$line" == "<<<JSONLD-BLOCK-END>>>" ]]; then
      if [[ -n "$current" ]]; then
        if printf '%s' "$current" | jq empty 2>/dev/null; then
          valid_count=$((valid_count+1))
          local types
          types="$(printf '%s' "$current" | jq -r '.. | objects | ."@type"? // empty' 2>/dev/null | sort -u)"
          while IFS= read -r t; do
            [[ -z "$t" ]] && continue
            case " $types_seen " in *" $t "*) continue ;; esac
            types_seen+=" $t"
          done <<<"$types"
        else
          invalid_count=$((invalid_count+1))
        fi
      fi
      current=""
      continue
    fi
    if [[ -n "$current" ]]; then
      current+=$'\n'"$line"
    else
      current="$line"
    fi
    in_block=0
  done <<<"$blocks"

  # Build types JSON array from accumulated $types_seen.
  local types_json="[]"
  if [[ -n "$types_seen" ]]; then
    types_json="$(printf '%s\n' $types_seen | jq -R . | jq -s 'unique' 2>/dev/null)"
  fi

  jq -n \
    --argjson n "$valid_count" \
    --argjson m "$invalid_count" \
    --argjson types "$types_json" \
    '{jsonld_count:$n, invalid_count:$m, types:$types}'
}

# --- companion files ---

# _ss_fetch_text <url> — like _ss_fetch_html but for companion text files.
# Writes the REAL status of THIS fetch to the status tempfile (http_get can't:
# its ADSEC_LAST_STATUS is set inside $(…) and lost, which made companion
# present/status reflect the previous page fetch).
_ss_fetch_text() {
  local url="$1"
  local tmp; tmp="$(mktemp)"
  local code
  code=$(curl -sS -L --max-redirs 5 \
    --max-time "${ADSEC_HTTP_TIMEOUT:-15}" \
    -A "${ADSEC_USER_AGENT:-ads-ready-skill/1}" \
    -o "$tmp" -w '%{http_code}' \
    "$url" 2>/dev/null || echo "000")
  printf '%s' "$code" > "/tmp/adsec_fetch_status_$$"
  if [[ "$code" != "000" ]]; then
    cat "$tmp"
  fi
  rm -f "$tmp"
}

# _ss_robots_agent_status <robots-body> <agent> — heuristic per-agent verdict:
# blocked | allowed (agent has its own UA group) or
# blocked-by-default | allowed-by-default (falls under the * group).
# Whole-site "Disallow: /" only; path-level rules are not evaluated.
_ss_robots_agent_status() {
  local body="$1" agent="$2"
  printf '%s\n' "$body" | awk -v agent="$(printf '%s' "$agent" | tr '[:upper:]' '[:lower:]')" '
    {
      line=$0; sub(/\r$/,"",line); sub(/#.*/,"",line)
      l=tolower(line); gsub(/^[ \t]+/,"",l); gsub(/[ \t]+$/,"",l)
      if (l ~ /^user-agent:/) {
        ua=l; sub(/^user-agent:[ \t]*/,"",ua)
        if (prev_was_rule) { in_specific=0; in_star=0; prev_was_rule=0 }
        if (ua == agent) { in_specific=1; spec_seen=1 }
        if (ua == "*") { in_star=1 }
        next
      }
      if (l ~ /^disallow:/ || l ~ /^allow:/) {
        prev_was_rule=1
        if (l ~ /^disallow:[ \t]*\/[ \t]*$/) {
          if (in_specific) spec_block=1
          if (in_star) star_block=1
        }
        if (l ~ /^allow:[ \t]*\/[ \t]*$/) {
          if (in_specific) spec_allow=1
        }
      }
    }
    END {
      if (spec_seen) {
        if (spec_block && !spec_allow) { print "blocked" } else { print "allowed" }
      } else {
        if (star_block) { print "blocked-by-default" } else { print "allowed-by-default" }
      }
    }'
}

_ss_companion_robots() {
  local origin="$1"
  local body
  body="$(_ss_fetch_text "${origin}/robots.txt")"
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  # Per-agent verdicts: ad-platform crawlers (blocking these breaks ad review /
  # dynamic ads) and AI crawlers (blocking OAI-SearchBot removes the site from
  # ChatGPT answers and its contextual ad surface; GPTBot is training-only).
  local crawler_access="{}"
  if [[ "$present" == "true" && -n "$body" ]]; then
    local a s
    crawler_access="$(for a in AdsBot-Google AdIdxBot bingbot facebookexternalhit Applebot \
                               GPTBot OAI-SearchBot ChatGPT-User PerplexityBot ClaudeBot Google-Extended Applebot-Extended; do
      s="$(_ss_robots_agent_status "$body" "$a")"
      jq -n --arg a "$a" --arg s "$s" '{($a): $s}'
    done | jq -s 'add')"
  fi
  jq -n --argjson present "$present" --arg status "$code" --arg body "$body" \
    --argjson crawler_access "$crawler_access" \
    '{present:$present, status:($status|tonumber? // 0),
      crawler_access:$crawler_access,
      crawler_access_note:"whole-site Disallow heuristic; path-level rules not evaluated. First 5 agents are ad/presence crawlers (Applebot governs Siri, Spotlight, and Apple Maps web enrichment); the rest are AI crawlers (OAI-SearchBot governs ChatGPT search visibility; GPTBot and Applebot-Extended are training-only opt-outs).",
      body:$body}'
}

_ss_companion_sitemap() {
  local origin="$1"
  local body
  body="$(_ss_fetch_text "${origin}/sitemap.xml")"
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  local urls=0
  if [[ "$present" == "true" ]]; then
    urls="$(printf '%s' "$body" | grep -E -c '<loc>' 2>/dev/null || true)"
  fi
  jq -n --argjson present "$present" --argjson urls "$urls" --arg status "$code" \
    '{present:$present, status:($status|tonumber? // 0), url_count:$urls}'
}

_ss_companion_ads_txt() {
  local origin="$1"
  local body
  body="$(_ss_fetch_text "${origin}/ads.txt")"
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  local lines=0
  if [[ "$present" == "true" ]]; then
    lines="$(printf '%s' "$body" | grep -E -c -v '^[[:space:]]*(#|$)' 2>/dev/null || true)"
  fi
  jq -n --argjson present "$present" --argjson lines "$lines" --arg status "$code" --arg body "$body" \
    '{present:$present, status:($status|tonumber? // 0), line_count:$lines, body:$body}'
}

_ss_companion_app_ads_txt() {
  local origin="$1"
  local body
  body="$(_ss_fetch_text "${origin}/app-ads.txt")"
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  local lines=0
  if [[ "$present" == "true" ]]; then
    lines="$(printf '%s' "$body" | grep -E -c -v '^[[:space:]]*(#|$)' 2>/dev/null || true)"
  fi
  jq -n --argjson present "$present" --argjson lines "$lines" --arg status "$code" \
    '{present:$present, status:($status|tonumber? // 0), line_count:$lines}'
}

_ss_companion_security_txt() {
  local origin="$1"
  http_get "${origin}/.well-known/security.txt" >/dev/null 2>&1
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  jq -n --argjson present "$present" --arg status "$code" \
    '{present:$present, status:($status|tonumber? // 0)}'
}

_ss_companion_llms_txt() {
  local origin="$1"
  http_get "${origin}/llms.txt" >/dev/null 2>&1
  local code="$(_ss_last_status)"
  local present="false"
  [[ "$code" =~ ^2 ]] && present="true"
  jq -n --argjson present "$present" --arg status "$code" \
    '{present:$present, status:($status|tonumber? // 0)}'
}

# --- header parsers ---

_ss_parse_security_headers() {
  local headers_text="$1"
  local hsts csp xframe xcto rp pp coop corp
  hsts="$(printf '%s' "$headers_text"   | grep -E -i '^strict-transport-security:'  | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  csp="$(printf '%s' "$headers_text"    | grep -E -i '^content-security-policy:'    | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  xframe="$(printf '%s' "$headers_text" | grep -E -i '^x-frame-options:'            | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  xcto="$(printf '%s' "$headers_text"   | grep -E -i '^x-content-type-options:'     | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  rp="$(printf '%s' "$headers_text"     | grep -E -i '^referrer-policy:'            | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  pp="$(printf '%s' "$headers_text"     | grep -E -i '^permissions-policy:'         | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  coop="$(printf '%s' "$headers_text"   | grep -E -i '^cross-origin-opener-policy:' | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  corp="$(printf '%s' "$headers_text"   | grep -E -i '^cross-origin-resource-policy:' | head -n1 | sed -E 's/^[^:]+:[[:space:]]*//I' | tr -d '\r')"
  jq -n \
    --arg hsts "$hsts" --arg csp "$csp" --arg xframe "$xframe" --arg xcto "$xcto" \
    --arg rp "$rp" --arg pp "$pp" --arg coop "$coop" --arg corp "$corp" \
    '{
      strict_transport_security: ($hsts|select(length>0) // null),
      content_security_policy:   ($csp|select(length>0)  // null),
      x_frame_options:           ($xframe|select(length>0) // null),
      x_content_type_options:    ($xcto|select(length>0)  // null),
      referrer_policy:           ($rp|select(length>0)    // null),
      permissions_policy:        ($pp|select(length>0)    // null),
      cross_origin_opener_policy:    ($coop|select(length>0) // null),
      cross_origin_resource_policy:  ($corp|select(length>0) // null)
    }'
}

# --- builder: pixel matrix (all 10 platforms) ---

_ss_build_pixel_matrix() {
  local html="$1"
  jq -n \
    --argjson google    "$(_ss_extract_google    "$html")" \
    --argjson meta      "$(_ss_extract_meta      "$html")" \
    --argjson microsoft "$(_ss_extract_microsoft "$html")" \
    --argjson linkedin  "$(_ss_extract_linkedin  "$html")" \
    --argjson tiktok    "$(_ss_extract_tiktok    "$html")" \
    --argjson x         "$(_ss_extract_x         "$html")" \
    --argjson pinterest "$(_ss_extract_pinterest "$html")" \
    --argjson reddit    "$(_ss_extract_reddit    "$html")" \
    --argjson snapchat  "$(_ss_extract_snapchat  "$html")" \
    --argjson apple     "$(_ss_extract_apple     "$html")" \
    '{
      google: $google, meta: $meta, microsoft: $microsoft, linkedin: $linkedin,
      tiktok: $tiktok, x: $x, pinterest: $pinterest, reddit: $reddit,
      snapchat: $snapchat, apple: $apple
    }'
}

# --- entrypoint ---

run_state_site() {
  local url="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$url" ]]; then
    printf '{"error":"state site requires a URL","code":"E_USAGE","remediation":"usage: state site <url> [slice]"}\n' >&2
    return 2
  fi
  case "$url" in
    http://*|https://*) ;;
    *)
      printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s"}\n' "$url" >&2
      return 2 ;;
  esac
  case "$slice" in
    digest|html|headers|pixels|consent|structured-data|robots|sitemap|ads-txt|lead-capture|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","html","headers","pixels","consent","structured-data","robots","sitemap","ads-txt","lead-capture","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local origin; origin="$(_ss_origin "$url")"

  # Always need HTML for most slices; fetch once.
  local html=""
  local html_status="000"
  if [[ "$slice" == "headers" ]]; then
    : # headers slice can skip the body fetch
  else
    html="$(_ss_fetch_html "$url" 2>/dev/null || true)"
    html_status="$(_ss_last_status)"
    if [[ ! "$html_status" =~ ^2 ]]; then
      printf '{"error":"could not fetch URL","code":"E_FETCH","status":"%s","url":"%s","remediation":"verify the URL is reachable from this machine"}\n' "$html_status" "$url" >&2
      return 3
    fi
  fi

  case "$slice" in
    html)
      jq -n --arg ts "$ts" --arg url "$url" --arg html "$html" --arg status "$html_status" \
        '{
          schema: "adssec.state-site.html",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "html",
          url: $url,
          status: ($status|tonumber? // 0),
          html: $html
        }'
      ;;
    headers)
      local hdrs; hdrs="$(_ss_fetch_headers "$url" 2>/dev/null || true)"
      local code="$(_ss_last_status)"
      local sec; sec="$(_ss_parse_security_headers "$hdrs")"
      jq -n --arg ts "$ts" --arg url "$url" --arg status "$code" --arg raw "$hdrs" \
        --argjson security_headers "$sec" \
        '{
          schema: "adssec.state-site.headers",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "headers",
          url: $url,
          status: ($status|tonumber? // 0),
          security_headers: $security_headers,
          raw: $raw
        }'
      ;;
    pixels)
      local pixels; pixels="$(_ss_build_pixel_matrix "$html")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson pixels "$pixels" \
        '{
          schema: "adssec.state-site.pixels",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "pixels",
          url: $url,
          pixels: $pixels
        }'
      ;;
    consent)
      local consent; consent="$(_ss_extract_consent "$html")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson consent "$consent" \
        '{
          schema: "adssec.state-site.consent",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "consent",
          url: $url,
          consent: $consent
        }'
      ;;
    lead-capture)
      local lc; lc="$(_ss_extract_lead_capture "$html")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson lead_capture "$lc" \
        '{
          schema: "adssec.state-site.lead-capture",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "lead-capture",
          url: $url,
          lead_capture: $lead_capture
        }'
      ;;
    structured-data)
      local sd; sd="$(_ss_extract_structured_data "$html")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson sd "$sd" \
        '{
          schema: "adssec.state-site.structured-data",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "structured-data",
          url: $url,
          structured_data: $sd
        }'
      ;;
    robots)
      local r; r="$(_ss_companion_robots "$origin")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson robots "$r" \
        '{
          schema: "adssec.state-site.robots",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "robots",
          url: $url,
          robots: $robots
        }'
      ;;
    sitemap)
      local s; s="$(_ss_companion_sitemap "$origin")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson sitemap "$s" \
        '{
          schema: "adssec.state-site.sitemap",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "sitemap",
          url: $url,
          sitemap: $sitemap
        }'
      ;;
    ads-txt)
      local a; a="$(_ss_companion_ads_txt "$origin")"
      local aa; aa="$(_ss_companion_app_ads_txt "$origin")"
      jq -n --arg ts "$ts" --arg url "$url" --argjson ads_txt "$a" --argjson app_ads_txt "$aa" \
        '{
          schema: "adssec.state-site.ads-txt",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "ads-txt",
          url: $url,
          ads_txt: $ads_txt,
          app_ads_txt: $app_ads_txt
        }'
      ;;
    digest)
      local pixels consent sd hdrs sec robots sitemap ads_txt app_ads sec_txt llms_txt lc
      pixels="$(_ss_build_pixel_matrix "$html")"
      consent="$(_ss_extract_consent "$html")"
      lc="$(_ss_extract_lead_capture "$html")"
      sd="$(_ss_extract_structured_data "$html")"
      hdrs="$(_ss_fetch_headers "$url" 2>/dev/null || true)"
      sec="$(_ss_parse_security_headers "$hdrs")"
      robots="$(_ss_companion_robots "$origin")"
      sitemap="$(_ss_companion_sitemap "$origin")"
      ads_txt="$(_ss_companion_ads_txt "$origin")"
      app_ads="$(_ss_companion_app_ads_txt "$origin")"
      sec_txt="$(_ss_companion_security_txt "$origin")"
      llms_txt="$(_ss_companion_llms_txt "$origin")"
      # Strip the heavy ads_txt body in digest mode (kept in ads-txt slice).
      ads_txt="$(jq 'del(.body)' <<<"$ads_txt")"
      jq -n \
        --arg ts "$ts" --arg url "$url" --arg origin "$origin" --arg status "$html_status" \
        --argjson pixels "$pixels" \
        --argjson consent "$consent" \
        --argjson structured_data "$sd" \
        --argjson security_headers "$sec" \
        --argjson robots "$robots" \
        --argjson sitemap "$sitemap" \
        --argjson ads_txt "$ads_txt" \
        --argjson app_ads_txt "$app_ads" \
        --argjson security_txt "$sec_txt" \
        --argjson llms_txt "$llms_txt" \
        --argjson lead_capture "$lc" \
        '{
          schema: "adssec.state-site.digest",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "digest",
          url: $url,
          origin: $origin,
          status: ($status|tonumber? // 0),
          pixels: $pixels,
          consent: $consent,
          lead_capture: $lead_capture,
          structured_data: $structured_data,
          security_headers: $security_headers,
          robots: $robots,
          sitemap: $sitemap,
          ads_txt: $ads_txt,
          app_ads_txt: $app_ads_txt,
          security_txt: $security_txt,
          llms_txt: $llms_txt,
          hint: "for the HTML body, run: state site <url> html  |  for ads.txt body: state site <url> ads-txt"
        }'
      ;;
    full)
      local pixels consent sd hdrs sec robots sitemap ads_txt app_ads sec_txt llms_txt lc
      pixels="$(_ss_build_pixel_matrix "$html")"
      consent="$(_ss_extract_consent "$html")"
      lc="$(_ss_extract_lead_capture "$html")"
      sd="$(_ss_extract_structured_data "$html")"
      hdrs="$(_ss_fetch_headers "$url" 2>/dev/null || true)"
      sec="$(_ss_parse_security_headers "$hdrs")"
      robots="$(_ss_companion_robots "$origin")"
      sitemap="$(_ss_companion_sitemap "$origin")"
      ads_txt="$(_ss_companion_ads_txt "$origin")"
      app_ads="$(_ss_companion_app_ads_txt "$origin")"
      sec_txt="$(_ss_companion_security_txt "$origin")"
      llms_txt="$(_ss_companion_llms_txt "$origin")"
      jq -n \
        --arg ts "$ts" --arg url "$url" --arg origin "$origin" --arg status "$html_status" \
        --arg html "$html" --arg headers_raw "$hdrs" \
        --argjson pixels "$pixels" \
        --argjson consent "$consent" \
        --argjson structured_data "$sd" \
        --argjson security_headers "$sec" \
        --argjson robots "$robots" \
        --argjson sitemap "$sitemap" \
        --argjson ads_txt "$ads_txt" \
        --argjson app_ads_txt "$app_ads" \
        --argjson security_txt "$sec_txt" \
        --argjson llms_txt "$llms_txt" \
        --argjson lead_capture "$lc" \
        '{
          schema: "adssec.state-site.full",
          schema_version: 1,
          generated_at: $ts,
          tool: "state-site",
          slice: "full",
          url: $url,
          origin: $origin,
          status: ($status|tonumber? // 0),
          html: $html,
          headers_raw: $headers_raw,
          pixels: $pixels,
          consent: $consent,
          lead_capture: $lead_capture,
          structured_data: $structured_data,
          security_headers: $security_headers,
          robots: $robots,
          sitemap: $sitemap,
          ads_txt: $ads_txt,
          app_ads_txt: $app_ads_txt,
          security_txt: $security_txt,
          llms_txt: $llms_txt
        }'
      ;;
  esac
}
