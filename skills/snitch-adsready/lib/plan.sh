# lib/plan.sh — capability matrix and gating helper for ads-ready.
# Replaces the plan-tier model from cloud-secure with a capability model:
# each subcommand requires zero or more capabilities (env vars / installed CLIs).
# `requires_capability` mirrors `requires_tier` from cloud-secure.

# Mapping of subcommand area -> required capability names (space-separated).
# An empty value means: no capability required (works with curl + jq alone).
_plan_required_capabilities() {
  local area="$1"
  case "$area" in
    doctor)            printf '' ;;
    detect)            printf '' ;;
    state-site)        printf '' ;;
    state-crux)        printf '' ;;       # PSI works anon; PSI_API_KEY raises quota
    state-lighthouse)  printf 'lighthouse-or-psi' ;;
    state-gsc)         printf 'gsc-api' ;;
    state-platform-google)    printf 'google-api' ;;
    state-platform-meta)      printf 'meta-api' ;;
    state-platform-microsoft) printf 'microsoft-api' ;;
    state-platform-linkedin)  printf 'linkedin-api' ;;
    state-platform-tiktok)    printf 'tiktok-api' ;;
    state-platform-x)         printf 'x-api' ;;
    state-platform-pinterest) printf 'pinterest-api' ;;
    state-platform-reddit)    printf 'reddit-api' ;;
    state-platform-snapchat)  printf 'snapchat-api' ;;
    state-platform-apple)     printf 'apple-api' ;;
    analytics-ga4)     printf 'ga4-api' ;;
    fit-matrix)        printf '' ;;
    stack-docs)        printf '' ;;
    score)             printf '' ;;
    fix-pixel-install) printf '' ;;
    fix-consent-mode)  printf '' ;;
    fix-capi-stub)     printf '' ;;
    fix-ads-txt)       printf '' ;;
    fix-robots)        printf '' ;;
    fix-structured-data) printf '' ;;
    fix-security-headers) printf '' ;;
    fix-mobile-meta)   printf '' ;;
    fix-verification-meta) printf '' ;;
    setup)             printf '' ;;
    recommend)         printf '' ;;
    prereqs)           printf '' ;;
    *) printf '' ;;
  esac
}

# requires_capability <area> <key> <message> <capability> [docs_url]
# If capability is present, returns 0 (caller proceeds).
# Else logs a [N/A locked] entry and returns 1.
#
# Special capabilities:
#   - lighthouse-or-psi: ok if either lighthouse CLI or PSI works (PSI is always available)
requires_capability() {
  local area="$1" key="$2" msg="$3" cap="$4" url="${5:-}"
  case "$cap" in
    lighthouse-or-psi)
      # PSI works anonymously; this is effectively always available.
      return 0
      ;;
    *)
      if capability_present "$cap"; then
        return 0
      fi
      log_locked "$area" "$key" "$msg" "$cap" "$url"
      return 1
      ;;
  esac
}

# capability_matrix_json
# Echoes the area→capability mapping as JSON. Used by `prereqs` and `doctor`.
capability_matrix_json() {
  local areas=(
    doctor detect state-site state-crux state-lighthouse state-gsc
    state-platform-google state-platform-meta state-platform-microsoft
    state-platform-linkedin state-platform-tiktok state-platform-x
    state-platform-pinterest state-platform-reddit state-platform-snapchat
    state-platform-apple analytics-ga4 fit-matrix stack-docs score
    fix-pixel-install fix-consent-mode fix-capi-stub fix-ads-txt
    fix-robots fix-structured-data fix-security-headers fix-mobile-meta
    fix-verification-meta setup recommend prereqs
  )
  local a cap out='{'
  local first=1
  for a in "${areas[@]}"; do
    cap="$(_plan_required_capabilities "$a")"
    if [[ "$first" == "1" ]]; then
      first=0
    else
      out+=","
    fi
    if [[ -z "$cap" ]]; then
      out+="\"${a}\":[]"
    else
      out+="\"${a}\":[\"${cap}\"]"
    fi
  done
  out+='}'
  printf '%s' "$out"
}
