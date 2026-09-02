# lib/apply_ads_txt.sh — merges platform-specific publisher lines into /ads.txt.
# Reads templates/ads-txt-entries.template.txt. which contains
# per-platform lines tagged with comments like "# google", "# meta", etc.
# Idempotent: if cwd already has ads.txt with all required lines, no-op.
#
# Exports: apply_ads_txt [platform...]

apply_ads_txt() {
  log_section "apply ads-txt"

  local tpl="${TPL_DIR}/ads-txt-entries.template.txt"
  if [[ ! -f "$tpl" ]]; then
    log_fail "ads-txt" "template" "ads-txt-entries template missing at ${tpl}. Reinstall the skill — the templates/ directory beside ads-ready.sh is incomplete."
    return 4
  fi

  # Filter platforms argument; default = all.
  local want_platforms=("$@")
  if [[ ${#want_platforms[@]} -eq 0 ]]; then
    want_platforms=(google meta microsoft linkedin tiktok x pinterest reddit snapchat apple)
  fi

  # Collect template lines for the requested platforms.
  local proposed=""
  local p
  for p in "${want_platforms[@]}"; do
    local section
    section="$(awk -v plat="$p" '
      /^# platform:/ { current=$3 }
      /^# platform:/ { next }
      current==plat && NF>0 && !/^#/ { print }
    ' "$tpl" 2>/dev/null)"
    if [[ -n "$section" ]]; then
      proposed+="${section}"$'\n'
    fi
  done

  if [[ -z "$proposed" ]]; then
    log_warn "ads-txt" "apply" "No template entries found for platforms: ${want_platforms[*]}. Check templates/ads-txt-entries.template.txt structure."
    return 0
  fi

  local existing=""
  if [[ -f "ads.txt" ]]; then
    existing="$(cat ads.txt)"
  fi

  # Compute which proposed lines are missing from existing ads.txt.
  local missing=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ -n "$existing" ]] && grep -F -q -x "$line" <<<"$existing" 2>/dev/null; then
      continue
    fi
    missing+="${line}"$'\n'
  done <<<"$proposed"

  if [[ -z "$missing" ]]; then
    log_ok "ads-txt" "apply" "ads.txt already contains all proposed lines for: ${want_platforms[*]}. No changes."
    return 0
  fi

  local merged
  if [[ -n "$existing" ]]; then
    merged="${existing}"$'\n'"# === added by snitch-adsready ($(date -u +%Y-%m-%d)) ==="$'\n'"${missing}"
  else
    merged="# ads.txt — managed by snitch-adsready ($(date -u +%Y-%m-%d))"$'\n'"${missing}"
  fi

  log_info "Proposing ads.txt update with $(printf '%s' "$missing" | grep -c '^[^[:space:]]') new line(s)."

  printf '\n=== FILE: %s ===\n' "ads.txt"
  printf '=== DIFF ===\n'
  if [[ -n "$existing" ]]; then
    printf '(append %d new line(s))\n' "$(printf '%s' "$missing" | grep -c '^[^[:space:]]')"
  else
    printf '(new file)\n'
  fi
  printf '=== CONTENT ===\n'
  printf '%s' "$merged"
  printf '\n=== END ===\n'

  log_warn "ads-txt" "apply" "Proposed ads.txt merge. User confirmation required before write."
}
