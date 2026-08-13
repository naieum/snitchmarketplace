# lib/apply_verification.sh — site-verification meta tags per platform.
# Per-platform meta names:
#   - google      → google-site-verification
#   - meta        → facebook-domain-verification
#   - microsoft   → msvalidate.01
#   - pinterest   → p:domain_verify
#   - apple       → apple-app-site-association (filename, not meta — emits stub)
# (LinkedIn / TikTok / X / Reddit / Snapchat use file-based verification rather than meta.)
#
# Exports: apply_verification [platform...]

apply_verification() {
  log_section "apply verification-meta"

  local want=("$@")
  if [[ ${#want[@]} -eq 0 ]]; then
    want=(google meta microsoft pinterest apple)
  fi

  local meta_lines=""
  local apple_aasa=""
  local p
  for p in "${want[@]}"; do
    case "$p" in
      google)
        meta_lines+=$'<meta name="google-site-verification" content="REPLACE_WITH_TOKEN_FROM_https://search.google.com/search-console">\n'
        ;;
      meta)
        meta_lines+=$'<meta name="facebook-domain-verification" content="REPLACE_WITH_TOKEN_FROM_https://business.facebook.com/settings/owned-domains">\n'
        ;;
      microsoft)
        meta_lines+=$'<meta name="msvalidate.01" content="REPLACE_WITH_TOKEN_FROM_https://www.bing.com/webmasters">\n'
        ;;
      pinterest)
        meta_lines+=$'<meta name="p:domain_verify" content="REPLACE_WITH_TOKEN_FROM_https://www.pinterest.com/business/claim/">\n'
        ;;
      apple)
        apple_aasa=$'{\n  "applinks": {\n    "apps": [],\n    "details": [\n      {\n        "appID": "TEAMID.bundle.identifier",\n        "paths": ["*"]\n      }\n    ]\n  }\n}\n'
        ;;
      linkedin|tiktok|x|reddit|snapchat)
        log_info "${p} uses file-based verification (TXT record or file upload), not a meta tag. Visit the platform dashboard to download/configure."
        ;;
      *)
        log_warn "verification-meta" "platform" "unknown platform: ${p}. Supported: google meta microsoft pinterest apple."
        ;;
    esac
  done

  if [[ -n "$meta_lines" ]]; then
    local rel_path="src/components/verification-meta.html"
    log_info "Proposing verification meta block."
    printf '\n=== FILE: %s ===\n' "$rel_path"
    printf '=== DIFF ===\n(new file)\n'
    printf '=== CONTENT ===\n'
    printf '<!-- site verification meta tags — managed by ads-ready -->\n'
    printf '%s' "$meta_lines"
    printf '\n=== END ===\n'
    log_warn "verification-meta" "apply" "Proposed verification meta tags. Replace each REPLACE_WITH_TOKEN placeholder with the token from the platform dashboard."
  fi

  if [[ -n "$apple_aasa" ]]; then
    log_info "Proposing Apple Universal Links / Search Ads attribution file."
    printf '\n=== FILE: %s ===\n' ".well-known/apple-app-site-association"
    printf '=== DIFF ===\n(new file; no extension; serve as application/json)\n'
    printf '=== CONTENT ===\n%s\n=== END ===\n' "$apple_aasa"
    log_warn "verification-meta" "apply-apple" "Proposed apple-app-site-association. Update TEAMID and bundle identifier; serve as application/json with no caching."
  fi

  if [[ -z "$meta_lines" && -z "$apple_aasa" ]]; then
    log_ok "verification-meta" "apply" "No platforms in scope require meta-tag verification. (LinkedIn/TikTok/X/Reddit/Snapchat use file-based verification — see platform dashboard.)"
  fi
}
