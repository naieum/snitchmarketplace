#!/usr/bin/env bash
# ads-ready: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (ADSEC_*, per-platform auth env).

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SKILL_DIR/lib"
PLAT_DIR="$LIB_DIR/platforms"
REF_DIR="$SKILL_DIR/references"
TPL_DIR="$SKILL_DIR/templates"
# Runtime state lives outside the skill folder so a read-only install works and
# nothing the skill writes can land in the distributed directory.
STATE_DIR="${ADSEC_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/snitch-adsready}"
CACHE_DIR="$STATE_DIR/doc-cache"
mkdir -p "$STATE_DIR" 2>/dev/null || true
export SKILL_DIR LIB_DIR PLAT_DIR REF_DIR TPL_DIR STATE_DIR CACHE_DIR

# shellcheck source=lib/log.sh
. "$LIB_DIR/log.sh"
# shellcheck source=lib/api.sh
. "$LIB_DIR/api.sh"
# shellcheck source=lib/plan.sh
. "$LIB_DIR/plan.sh"

usage() {
  cat <<'EOF'
ads-ready: thin ad-platform tool surface. Agent orchestrates synthesis.

Read tools (JSON on stdout):
  doctor                              env health (curl, jq, lighthouse, PSI, per-platform auth)
  detect                              cwd signals: stacks, pixel libs, consent libs, verticals
  state site <url> [slice]            site fetch + parse for ALL 10 platforms.
                                      slices: digest|html|headers|pixels|consent|
                                              structured-data|robots|sitemap|ads-txt|
                                              lead-capture|full
  state crux <url> [mobile|desktop]   CrUX + Lighthouse cat scores via PSI
  state lighthouse <url>              lighthouse CLI JSON if installed; PSI fallback otherwise
  state platform <name> [account-id]  per-platform Marketing API state.
                                      <name>: google|meta|microsoft|linkedin|tiktok|x|
                                              pinterest|reddit|snapchat|apple
  state gsc [property]                Search Console state if GOOGLE_GSC_AUTH set
  analytics ga4 <property-id>         GA4 Data API report if GA4_AUTH set
  fit-matrix [stack]                  per-stack ads-readiness verdict
  stack-docs [stack]                  canonical doc URLs (for WebFetch)
  score <url>                         composite readiness score

Mutating (idempotent):
  fix <area> [platform]               apply one area (or all detected).
                                      areas: pixel-install consent-mode capi-stub ads-txt
                                             robots structured-data security-headers
                                             mobile-meta verification-meta all

Setup help:
  setup <area> [platform]             stepped JSON walkthrough plan
  recommend <area>                    tool catalog: cmp|gtm-server|capi-helpers|
                                      lighthouse-runner|cwv-monitoring
  prereqs                             local CLI / platform-account checklist

Utility: export | verify | refresh-docs | help

Env (all optional):
  PSI_API_KEY                  raises PSI quota
  GOOGLE_GSC_AUTH              Search Console refresh-token JSON
  GA4_AUTH                     GA4 Data API refresh-token JSON
  GOOGLE_ADS_*                 Google Ads API
  META_ACCESS_TOKEN, META_AD_ACCOUNT_ID  Meta Marketing API
  MICROSOFT_ADS_*              Microsoft Advertising API
  LINKEDIN_ADS_*               LinkedIn Marketing Developer Platform
  TIKTOK_ADS_*                 TikTok Marketing API
  X_ADS_*                      X Ads API
  PINTEREST_ADS_*              Pinterest API
  REDDIT_ADS_*                 Reddit Ads API
  SNAPCHAT_ADS_*               Snap Marketing API
  APPLE_SEARCH_ADS_*           Apple Search Ads API (JWT)
EOF
}

_refuse_legacy_global_key_json() {
  # No global / legacy "API_KEY" without a platform prefix. Each ad platform has a scoped key.
  if [[ -n "${API_KEY:-}" && -z "${ADSEC_ALLOW_GENERIC_API_KEY:-}" ]]; then
    printf '{"error":"generic API_KEY env detected","code":"E_AUTH","remediation":"every ad-platform credential must be platform-prefixed (GOOGLE_ADS_*, META_*, etc.). Unset API_KEY or scope it."}\n' >&2
    return 2
  fi
  return 0
}

dispatch_state() {
  _refuse_legacy_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    site)
      . "$LIB_DIR/state_site.sh"; run_state_site "$@" ;;
    crux)
      . "$LIB_DIR/state_crux.sh"; run_state_crux "$@" ;;
    lighthouse)
      . "$LIB_DIR/state_lighthouse.sh"; run_state_lighthouse "$@" ;;
    platform)
      . "$LIB_DIR/state_platform.sh"; run_state_platform "$@" ;;
    gsc)
      . "$LIB_DIR/state_gsc.sh"; run_state_gsc "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["site","crux","lighthouse","platform","gsc"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s","valid":["site","crux","lighthouse","platform","gsc"]}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_analytics() {
  _refuse_legacy_global_key_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    ga4)
      . "$LIB_DIR/analytics_ga4.sh"; run_analytics_ga4 "$@" ;;
    "")
      printf '{"error":"analytics requires a subscope","code":"E_USAGE","valid":["ga4"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown analytics subscope","code":"E_USAGE","got":"%s","valid":["ga4"]}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'ads-ready.sh help' for the list."
    return 2
  fi
  case "$area" in
    pixel-install)
      . "$LIB_DIR/apply_pixel.sh"; apply_pixel "$@" ;;
    consent-mode)
      . "$LIB_DIR/apply_consent.sh"; apply_consent "$@" ;;
    capi-stub)
      . "$LIB_DIR/apply_capi.sh"; apply_capi "$@" ;;
    ads-txt)
      . "$LIB_DIR/apply_ads_txt.sh"; apply_ads_txt "$@" ;;
    robots)
      . "$LIB_DIR/apply_robots.sh"; apply_robots "$@" ;;
    structured-data)
      . "$LIB_DIR/apply_structured_data.sh"; apply_structured_data "$@" ;;
    security-headers)
      . "$LIB_DIR/apply_headers.sh"; apply_headers "$@" ;;
    mobile-meta)
      . "$LIB_DIR/apply_mobile.sh"; apply_mobile "$@" ;;
    verification-meta)
      . "$LIB_DIR/apply_verification.sh"; apply_verification "$@" ;;
    all)
      . "$LIB_DIR/apply_consent.sh"
      . "$LIB_DIR/apply_pixel.sh"
      . "$LIB_DIR/apply_capi.sh"
      . "$LIB_DIR/apply_ads_txt.sh"
      . "$LIB_DIR/apply_robots.sh"
      . "$LIB_DIR/apply_structured_data.sh"
      . "$LIB_DIR/apply_headers.sh"
      . "$LIB_DIR/apply_mobile.sh"
      . "$LIB_DIR/apply_verification.sh"
      # Consent first: apply_pixel refuses to emit a pixel into a project with
      # no consent banner / CMP signal, so the banner has to land first.
      apply_consent "$@"
      apply_pixel "$@"
      apply_capi "$@"
      apply_ads_txt "$@"
      apply_robots "$@"
      apply_structured_data "$@"
      apply_headers "$@"
      apply_mobile "$@"
      apply_verification "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area. Valid: pixel-install consent-mode capi-stub ads-txt robots structured-data security-headers mobile-meta verification-meta all."
      return 2 ;;
  esac
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    doctor)
      doctor_run ;;
    detect)
      . "$LIB_DIR/detect.sh"; run_detect "$@" ;;
    state)
      dispatch_state "$@" ;;
    analytics)
      dispatch_analytics "$@" ;;
    fit-matrix)
      . "$LIB_DIR/fit_matrix.sh"; run_fit_matrix "$@" ;;
    stack-docs)
      . "$LIB_DIR/stack_docs.sh"; run_stack_docs "$@" ;;
    score)
      . "$LIB_DIR/score.sh"; run_score "$@" ;;
    setup)
      . "$LIB_DIR/setup.sh"; run_setup "$@" ;;
    recommend)
      . "$LIB_DIR/recommend.sh"; run_recommend "$@" ;;
    prereqs)
      . "$LIB_DIR/prereqs.sh"; run_prereqs "$@" ;;
    export)
      . "$LIB_DIR/export.sh"; run_export "$@" ;;
    verify)
      # Validate before the badge header, so a usage error is JSON on stderr
      # and nothing else — and so the remediation names `verify`, not the
      # `state site` call it delegates to.
      if [[ -z "${1:-}" ]]; then
        printf '{"error":"verify requires a URL","code":"E_USAGE","remediation":"usage: verify <url> [slice]"}\n' >&2
        return 2
      fi
      case "$1" in
        http://*|https://*) ;;
        *)
          printf '{"error":"URL must begin with http:// or https://","code":"E_URL","got":"%s","remediation":"usage: verify <url> [slice]"}\n' "$1" >&2
          return 2 ;;
      esac
      . "$LIB_DIR/state_site.sh"
      . "$LIB_DIR/drift.sh"
      log_section "verify"
      run_state_site "$@" >/dev/null || return $?
      drift_run
      snapshot_write ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    help|-h|--help|"")
      usage ;;
    *)
      log_fail "skill" "usage" "unknown subcommand: $cmd"
      usage
      return 2 ;;
  esac
}

main "$@"
