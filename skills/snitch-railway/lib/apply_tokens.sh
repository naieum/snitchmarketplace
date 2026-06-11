# lib/apply_tokens.sh — token rotation + scope review.
# Exports: apply_tokens

apply_tokens() {
  log_section "tokens hardening"

  . "$LIB_DIR/state_tokens.sh"
  local digest
  digest="$(run_state_tokens digest 2>/dev/null)"
  if [[ -z "$digest" ]]; then
    log_fail "tokens" "read" "could not read tokens digest"
    return 3
  fi

  local total oldest
  total="$(jq '.project_tokens_summary.total // 0' <<<"$digest")"
  oldest="$(jq -r '.project_tokens_summary.oldest_created_at // "none"' <<<"$digest")"

  log_info "${total} project token(s) total; oldest created at ${oldest}"

  if [[ "$total" == "0" ]]; then
    log_ok "tokens" "count" "no project tokens. Account-level access only."
  else
    log_warn "tokens" "rotation" "Project tokens have no last-used timestamp in the public schema. Recommend a 90-day rotation policy. To rotate: dashboard → project → Settings → Tokens → revoke + recreate." "https://docs.railway.com/reference/public-api"
    jq -r '.project_tokens_summary.names // [] | .[] | "  - token: \(.)"' <<<"$digest" >&2
  fi

  log_warn "tokens" "scope" "Confirm each project token is scoped to a single environment (preview/staging vs production) — never share a production token across CI jobs." "https://docs.railway.com/reference/public-api"

  # Account token guidance.
  log_warn "tokens" "account-tokens" "Account-scope tokens (RAILWAY_API_TOKEN) are most powerful — keep these out of CI. Use project tokens for deploys; reserve account tokens for admin operations." "https://railway.com/account/tokens"
}
