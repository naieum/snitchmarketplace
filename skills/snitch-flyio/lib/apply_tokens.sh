# lib/apply_tokens.sh — token rotation / scope review.
# Exports: apply_tokens [org]
#
# Idempotent: read-only inspection of `fly tokens list` + emits the canonical
# `fly tokens revoke <id>` / `fly tokens create deploy --expiry 720h` lines.

apply_tokens() {
  local org="${1:-}"
  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null || printf '')"
  fi
  if [[ -z "$org" ]]; then
    log_warn "tokens" "no-org" "No org specified. Set FLYSEC_ORG or pass org slug."
    return 0
  fi

  log_section "tokens: ${org}"

  local body; body="$(fly_run_json tokens list --org "$org" 2>/dev/null || printf '[]')"
  local total; total="$(jq -r 'length' <<<"$body" 2>/dev/null || printf '0')"
  log_info "tokens: ${total}"

  if [[ "$total" == "0" ]]; then
    log_ok "tokens" "none" "No tokens issued at the org level."
    log_info "If you deploy from CI, create a scoped, time-limited token: fly tokens create deploy --expiry 720h --org ${org}"
    return 0
  fi

  # No-expiry tokens
  local no_exp; no_exp="$(jq -r '[ .[] | select((.ExpiresAt // .expires_at // null) == null) | "\(.ID // .id)\t\(.Name // .name)" ] | .[]' <<<"$body" 2>/dev/null)"
  if [[ -n "$no_exp" ]]; then
    log_fail "tokens" "no-expiry" "Tokens with no expiry detected. Rotate to time-limited tokens."
    while IFS=$'\t' read -r id name; do
      [[ -z "$id" ]] && continue
      printf '  fly tokens revoke %s    # %s\n' "$id" "$name"
    done <<<"$no_exp"
  else
    log_ok "tokens" "no-expiry" "All tokens have an expiry."
  fi

  # Already-expired tokens
  local now_iso; now_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local expired; expired="$(jq -r --arg now "$now_iso" '[ .[] | select((.ExpiresAt // .expires_at // "") != "" and (.ExpiresAt // .expires_at) < $now) | "\(.ID // .id)\t\(.Name // .name)" ] | .[]' <<<"$body" 2>/dev/null)"
  if [[ -n "$expired" ]]; then
    log_warn "tokens" "expired" "Expired tokens still listed (revoke for hygiene):"
    while IFS=$'\t' read -r id name; do
      [[ -z "$id" ]] && continue
      printf '  fly tokens revoke %s    # %s\n' "$id" "$name"
    done <<<"$expired"
  fi

  return 0
}
