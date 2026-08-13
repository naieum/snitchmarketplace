# lib/apply_robots.sh — ensures platform crawlers aren't disallowed in robots.txt.
# Idempotent: if cwd has no robots.txt, propose a permissive starter; if it
# exists and doesn't disallow the canonical bots, [OK]. If a Disallow rule
# blocks one of them, propose a targeted Allow override.
#
# Exports: apply_robots [platform...]

# Platform → user-agent string the crawler advertises.
_apply_robots_ua() {
  case "$1" in
    google)    printf 'Googlebot AdsBot-Google AdsBot-Google-Mobile' ;;
    meta)      printf 'facebookexternalhit meta-externalagent' ;;
    microsoft) printf 'bingbot AdIdxBot' ;;
    linkedin)  printf 'LinkedInBot' ;;
    tiktok)    printf 'Bytespider' ;;
    x)         printf 'Twitterbot' ;;
    pinterest) printf 'Pinterestbot' ;;
    reddit)    printf 'Redditbot' ;;
    snapchat)  printf 'Snap-URL-Preview-Service' ;;
    apple)     printf 'Applebot Applebot-Extended' ;;
    *)         printf '' ;;
  esac
}

apply_robots() {
  log_section "apply robots"

  local want_platforms=("$@")
  if [[ ${#want_platforms[@]} -eq 0 ]]; then
    want_platforms=(google meta microsoft linkedin tiktok x pinterest reddit snapchat apple)
  fi

  # Collect all expected UAs.
  local all_uas=""
  local p
  for p in "${want_platforms[@]}"; do
    local uas; uas="$(_apply_robots_ua "$p")"
    [[ -n "$uas" ]] && all_uas+="${uas} "
  done

  local existing=""
  if [[ -f "robots.txt" ]]; then
    existing="$(cat robots.txt)"
  fi

  # Find any Disallow that might block a needed UA.
  local blocked_uas=""
  if [[ -n "$existing" ]]; then
    local ua
    for ua in $all_uas; do
      # Look for "User-agent: <ua>" followed by a "Disallow: /" before any Allow.
      if printf '%s' "$existing" | awk -v ua="$ua" '
        BEGIN { hit=0 }
        /^[Uu]ser-agent:[[:space:]]*/ {
          gsub(/^[Uu]ser-agent:[[:space:]]*/,"")
          gsub(/[[:space:]]*$/,"")
          if ($0==ua || $0=="*") { in_block=1 } else { in_block=0 }
        }
        in_block==1 && /^[Dd]isallow:[[:space:]]*\/$/ { hit=1 }
        END { exit !hit }
      ' 2>/dev/null; then
        blocked_uas+="${ua} "
      fi
    done
  fi

  if [[ -z "$existing" ]]; then
    local proposed
    proposed=$'# robots.txt — ads-ready starter\n'
    proposed+=$'User-agent: *\n'
    proposed+=$'Allow: /\n\n'
    proposed+="Sitemap: https://example.com/sitemap.xml"$'\n'
    log_info "No robots.txt found; proposing a starter."
    printf '\n=== FILE: %s ===\n' "robots.txt"
    printf '=== DIFF ===\n(new file)\n'
    printf '=== CONTENT ===\n%s\n=== END ===\n' "$proposed"
    log_warn "robots" "apply" "Proposed robots.txt. Replace example.com sitemap URL before applying."
    return 0
  fi

  if [[ -z "$blocked_uas" ]]; then
    log_ok "robots" "apply" "robots.txt does not disallow any required platform UAs (${want_platforms[*]})."
    return 0
  fi

  local additions
  additions=$'\n# === added by ads-ready: ad-platform crawler allowances ===\n'
  local ua
  for ua in $blocked_uas; do
    additions+="User-agent: ${ua}"$'\n'
    additions+=$'Allow: /\n'
  done

  local merged="${existing}${additions}"
  log_info "Proposing robots.txt overrides for blocked UAs: ${blocked_uas}"

  printf '\n=== FILE: %s ===\n' "robots.txt"
  printf '=== DIFF ===\n'
  printf '(append per-UA Allow overrides)\n'
  printf '=== CONTENT ===\n'
  printf '%s' "$merged"
  printf '\n=== END ===\n'
  log_warn "robots" "apply" "Proposed robots.txt overrides for: ${blocked_uas}. User confirmation required before write."
}
