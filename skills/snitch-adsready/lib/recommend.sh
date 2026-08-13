# lib/recommend.sh — tool-option catalogs.
# Read-only. Emits JSON catalogs the agent presents as comparison tables.
# Source data: templates/recommendations.json.
#
# Exports:
#   run_recommend <area>
#
# Areas: cmp gtm-server capi-helpers lighthouse-runner cwv-monitoring listings

ADSSEC_RECOMMEND_AREAS=(cmp gtm-server capi-helpers lighthouse-runner cwv-monitoring listings)

# _recommend_emit_error <error> <code> <remediation>
_recommend_emit_error() {
  local err="$1" code="$2" rem="$3"
  jq -n \
    --arg err "$err" \
    --arg code "$code" \
    --arg rem "$rem" \
    --argjson valid "$(printf '%s\n' "${ADSSEC_RECOMMEND_AREAS[@]}" | jq -R . | jq -s .)" \
    '{error: $err, code: $code, remediation: $rem, valid: $valid}' >&2
}

# run_recommend <area>
run_recommend() {
  local area="${1:-}"
  local skill_dir="${ADSSEC_SKILL_DIR:-${HOME}/.claude/skills/ads-ready}"
  local catalog="${skill_dir}/templates/recommendations.json"

  if [[ -z "$area" ]]; then
    _recommend_emit_error "missing area argument" "E_USAGE" "Usage: recommend <area>. Valid areas: ${ADSSEC_RECOMMEND_AREAS[*]}."
    return 2
  fi
  if [[ ! -f "$catalog" ]]; then
    _recommend_emit_error "templates/recommendations.json not found at ${catalog}" "E_TEMPLATE" "Reinstall the skill or run refresh-docs."
    return 2
  fi

  local valid=0
  local v
  for v in "${ADSSEC_RECOMMEND_AREAS[@]}"; do
    [[ "$area" == "$v" ]] && valid=1 && break
  done
  if [[ "$valid" != "1" ]]; then
    _recommend_emit_error "unknown recommend area: ${area}" "E_USAGE" "Valid areas: ${ADSSEC_RECOMMEND_AREAS[*]}"
    return 2
  fi

  local options
  options="$(jq -c --arg key "$area" '.[$key] // null' "$catalog" 2>/dev/null)"
  if [[ -z "$options" || "$options" == "null" ]]; then
    _recommend_emit_error "no options found in catalog for area: ${area}" "E_TEMPLATE" "Check templates/recommendations.json keys."
    return 2
  fi

  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  jq -n \
    --arg ts "$ts" \
    --arg area "$area" \
    --argjson options "$options" \
    '{
      schema: "adssec.recommend",
      schema_version: 1,
      generated_at: $ts,
      tool: "recommend",
      area: $area,
      options: $options,
      note: "Agent: render as a comparison table; let the user pick; then call setup <area> to walk through the install for the chosen option."
    }'
}
