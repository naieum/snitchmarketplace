# lib/score.sh — composite ads-readiness score.
# Calls state_site + state_crux internally; combines into a single score JSON.
#
# Output schema: adssec.score
# Components (each 0-100):
#   pixel_coverage  — fraction of expected platforms found * 100, gated by what's reasonable.
#   cwv             — all three URL field categories, or null when unavailable.
#   consent         — present + mode_v2 + integrated_with_pixels.
#   structured_data — jsonld_count + types richness.
#   security_headers — % of canonical headers present.
#   ads_txt         — present + non-empty.
# overall_grade derived from weighted average.
#
# Exports: run_score <url>

_score_pixel_coverage() {
  local pixels_json="$1"
  # Count detected platforms (true bool). Apple is iOS-specific, so don't penalize hard.
  local total found
  total=10
  found="$(jq '[.google,.meta,.microsoft,.linkedin,.tiktok,.x,.pinterest,.reddit,.snapchat,.apple] | map(select(.detected==true)) | length' <<<"$pixels_json" 2>/dev/null)"
  found="${found:-0}"
  # Score is found/total * 100, but: detecting at least 1 platform is fine (most sites
  # don't run all 10). So we cap the "expected" at 3 — finding 3+ pixel platforms = 100.
  local expected=3
  if (( found >= expected )); then
    printf '100'
  else
    printf '%d' $(( found * 100 / expected ))
  fi
}

_score_cwv() {
  # All three URL field categories are required. Lab/origin data are separate evidence.
  # Missing, malformed, or unknown categories yield null, never a manufactured zero.
  jq -r '
    def points:
      if . == "FAST" then 100
      elif . == "AVERAGE" or . == "NEEDS_IMPROVEMENT" then 65
      elif . == "SLOW" then 30 else null end;
    .data.field_data.metrics as $m |
    [$m.LARGEST_CONTENTFUL_PAINT_MS.category,
     $m.INTERACTION_TO_NEXT_PAINT.category,
     $m.CUMULATIVE_LAYOUT_SHIFT_SCORE.category] |
    map(points) |
    if any(. == null) then null else (add / 3 | floor) end
  ' <<<"$1" 2>/dev/null || printf 'null'
}

_score_consent() {
  local consent_json="$1"
  local platform mode_v2 dl
  platform="$(jq -r '.platform // "none"' <<<"$consent_json" 2>/dev/null)"
  mode_v2="$(jq -r '.consent_mode_v2 // false' <<<"$consent_json" 2>/dev/null)"
  dl="$(jq -r '.has_data_layer // false' <<<"$consent_json" 2>/dev/null)"
  local s=0
  if [[ "$platform" != "none" && -n "$platform" ]]; then s=$((s+50)); fi
  if [[ "$mode_v2" == "true" ]]; then s=$((s+35)); fi
  if [[ "$dl" == "true" ]]; then s=$((s+15)); fi
  if (( s > 100 )); then s=100; fi
  printf '%d' "$s"
}

_score_structured_data() {
  local sd_json="$1"
  local n; n="$(jq -r '.jsonld_count // 0' <<<"$sd_json" 2>/dev/null)"
  local types_count; types_count="$(jq -r '.types | length' <<<"$sd_json" 2>/dev/null)"
  n="${n:-0}"; types_count="${types_count:-0}"
  local s=0
  if (( n >= 1 )); then s=$((s+40)); fi
  if (( n >= 3 )); then s=$((s+20)); fi
  s=$(( s + (types_count * 10) ))
  if (( s > 100 )); then s=100; fi
  printf '%d' "$s"
}

_score_security_headers() {
  local sec_json="$1"
  # Canonical headers we expect for ads pages.
  local h
  local present=0 total=6
  for h in strict_transport_security content_security_policy x_content_type_options referrer_policy permissions_policy x_frame_options; do
    local v; v="$(jq -r ".${h} // empty" <<<"$sec_json" 2>/dev/null)"
    [[ -n "$v" ]] && present=$((present+1))
  done
  printf '%d' $(( present * 100 / total ))
}

_score_ads_txt() {
  local ads_json="$1"
  local present lines
  present="$(jq -r '.present // false' <<<"$ads_json" 2>/dev/null)"
  lines="$(jq -r '.line_count // 0' <<<"$ads_json" 2>/dev/null)"
  if [[ "$present" != "true" ]]; then printf '0'; return; fi
  if [[ "${lines:-0}" -ge 5 ]]; then printf '100'; return; fi
  if [[ "${lines:-0}" -ge 1 ]]; then printf '60'; return; fi
  printf '30'
}

# Weighted overall grade. Weights:
#   pixels 25, cwv 20, consent 20, structured-data 15, headers 15, ads_txt 5
_score_overall() {
  local pixels="$1" cwv="$2" consent="$3" sd="$4" sec="$5" ads="$6"
  if [[ "$cwv" == "null" ]]; then printf 'null'; return; fi
  local sum
  sum=$(( pixels*25 + cwv*20 + consent*20 + sd*15 + sec*15 + ads*5 ))
  sum=$(( sum / 100 ))
  printf '%d' "$sum"
}

_score_grade_letter() {
  local n="$1"
  if [[ "$n" == "null" ]]; then printf 'UNRATED'; return; fi
  if   (( n >= 90 )); then printf 'A'
  elif (( n >= 75 )); then printf 'B'
  elif (( n >= 60 )); then printf 'C'
  elif (( n >= 40 )); then printf 'D'
  else printf 'F'
  fi
}

run_score() {
  local url="${1:-}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$url" ]]; then
    printf '{"error":"score requires a URL","code":"E_USAGE","remediation":"usage: score <url>"}\n' >&2
    return 2
  fi
  case "$url" in
    http://*|https://*) ;;
    *)
      printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s"}\n' "$url" >&2
      return 2 ;;
  esac

  # Fetch site digest + crux (or fall back gracefully if either fails).
  if ! declare -f run_state_site >/dev/null 2>&1; then
    . "$LIB_DIR/state_site.sh"
  fi
  if ! declare -f run_state_crux >/dev/null 2>&1; then
    . "$LIB_DIR/state_crux.sh"
  fi

  local digest crux
  digest="$(run_state_site "$url" digest 2>/dev/null)" || digest=""
  if ! jq -e '.schema == "adssec.state-site.digest" and (.status >= 200 and .status < 300) and (.pixels | type == "object")' <<<"$digest" >/dev/null 2>&1; then
    printf '{"error":"score could not run state-site digest","code":"E_DEPENDENCY","url":"%s"}\n' "$url" >&2
    return 3
  fi
  crux="$(run_state_crux "$url" mobile 2>/dev/null)" || crux="{}"
  jq -e 'type == "object"' <<<"$crux" >/dev/null 2>&1 || crux="{}"

  # Pull subobjects.
  local pixels consent sd sec ads
  pixels="$(jq '.pixels // {}' <<<"$digest" 2>/dev/null)"
  consent="$(jq '.consent // {}' <<<"$digest" 2>/dev/null)"
  sd="$(jq '.structured_data // {}' <<<"$digest" 2>/dev/null)"
  sec="$(jq '.security_headers // {}' <<<"$digest" 2>/dev/null)"
  ads="$(jq '.ads_txt // {}' <<<"$digest" 2>/dev/null)"

  local s_pixels s_cwv s_consent s_sd s_sec s_ads s_overall grade
  s_pixels="$(_score_pixel_coverage  "$pixels")"
  s_cwv="$(_score_cwv               "$crux")"
  s_consent="$(_score_consent       "$consent")"
  s_sd="$(_score_structured_data    "$sd")"
  s_sec="$(_score_security_headers  "$sec")"
  s_ads="$(_score_ads_txt           "$ads")"
  s_overall="$(_score_overall "$s_pixels" "$s_cwv" "$s_consent" "$s_sd" "$s_sec" "$s_ads")"
  grade="$(_score_grade_letter "$s_overall")"

  jq -n \
    --arg ts "$ts" --arg url "$url" \
    --argjson pixels "$pixels" \
    --argjson consent "$consent" \
    --argjson structured_data "$sd" \
    --argjson security_headers "$sec" \
    --argjson ads_txt "$ads" \
    --argjson s_pixels "$s_pixels" \
    --argjson s_cwv "$s_cwv" \
    --argjson s_consent "$s_consent" \
    --argjson s_sd "$s_sd" \
    --argjson s_sec "$s_sec" \
    --argjson s_ads "$s_ads" \
    --argjson s_overall "$s_overall" \
    --arg grade "$grade" \
    --argjson crux "$crux" \
    '{
      schema: "adssec.score",
      schema_version: 2,
      score_basis: "static-signature heuristic; cwv uses URL field categories only",
      generated_at: $ts,
      tool: "score",
      url: $url,
      components: {
        pixel_coverage: $s_pixels,
        cwv: $s_cwv,
        consent: $s_consent,
        structured_data: $s_sd,
        security_headers: $s_sec,
        ads_txt: $s_ads
      },
      weights: {
        pixel_coverage: 25,
        cwv: 20,
        consent: 20,
        structured_data: 15,
        security_headers: 15,
        ads_txt: 5
      },
      overall_score: $s_overall,
      overall_grade: $grade,
      evidence: {
        performance: $crux,
        pixels: $pixels,
        consent: $consent,
        structured_data: $structured_data,
        security_headers: $security_headers,
        ads_txt: $ads_txt
      }
    }'
}
