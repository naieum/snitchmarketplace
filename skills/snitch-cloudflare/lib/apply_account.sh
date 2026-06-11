# lib/apply_account.sh — idempotent account-level fixes.
# Exposes:
#   apply_account [args]   — creates a baseline notification policy (tag:
#                            cloudflare-secure:default-alerts) for L7 DDoS +
#                            Universal SSL events if no matching policy exists.
# Side effects:
#   - Read-first: lists existing policies and skips if a tagged policy is found.
#   - Recommends 2FA / SSO; never enforces (UI flow).

# _baseline_alert_policy_payload <name_tag>
# Echoes the JSON for our baseline alert policy.
_baseline_alert_policy_payload() {
  local tag="$1"
  jq -n --arg tag "$tag" '{
    name: $tag,
    description: "snitch-cloudflare baseline alerts: L7 DDoS + Universal SSL",
    enabled: true,
    alert_type: "dos_attack_l7",
    mechanisms: { email: [] },
    filters: {}
  }'
}

# apply_account [args] — main entry.
apply_account() {
  local account_id
  account_id="$(api_pick_account)" || {
    log_fail "account" "pick" "No account selected. Set CFSEC_ACCOUNT_ID."
    return 3
  }

  local desc_tag="cloudflare-secure:default-alerts"
  local body
  body="$(cf_get "/accounts/${account_id}/alerting/v3/policies")" || {
    log_fail "account" "alerts-read" "Could not read existing notification policies. $(cf_last_error)"
    return 3
  }

  local existing
  existing="$(jq -r --arg t "$desc_tag" \
    '[.result[]? | select(.name==$t or .description==$t or (.description // "" | startswith($t)))] | length' \
    <<<"$body" 2>/dev/null)"
  if [[ "${existing:-0}" -gt 0 ]]; then
    log_ok "account" "alerts-baseline" "Baseline alert policy already exists (tag: ${desc_tag})."
  else
    # Check the account has at least one verified email contact; we can't verify here,
    # so we emit the call and surface what mechanisms field needs filling.
    log_warn "account" "alerts-baseline" "No baseline alert policy found. To create one, POST /accounts/${account_id}/alerting/v3/policies with mechanisms={email:[{id:'<destination_id>'}]}. See the dashboard for destination IDs." "https://developers.cloudflare.com/notifications/get-started/"
    # Attempt to detect a default destination so we can actually create the policy.
    local dests dest_id
    dests="$(cf_get "/accounts/${account_id}/alerting/v3/destinations/eligible")" || dests=""
    dest_id="$(jq -r '.result[]? | select(.type=="email") | .id // empty' <<<"$dests" 2>/dev/null | head -n1)"
    if [[ -n "$dest_id" ]]; then
      local payload
      payload="$(jq -n --arg tag "$desc_tag" --arg id "$dest_id" '{
        name: $tag,
        description: $tag,
        enabled: true,
        alert_type: "dos_attack_l7",
        mechanisms: { email: [{id:$id}] },
        filters: {}
      }')"
      cf_post "/accounts/${account_id}/alerting/v3/policies" "$payload" >/dev/null && \
        log_ok "account" "alerts-baseline" "Baseline L7 DDoS alert policy created (tag: ${desc_tag})." || \
        log_fail "account" "alerts-baseline" "POST policy failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
      # Universal SSL event policy as a sibling.
      local payload2
      payload2="$(jq -n --arg tag "${desc_tag}-ssl" --arg id "$dest_id" '{
        name: $tag,
        description: $tag,
        enabled: true,
        alert_type: "universal_ssl_event_type",
        mechanisms: { email: [{id:$id}] },
        filters: {}
      }')"
      cf_post "/accounts/${account_id}/alerting/v3/policies" "$payload2" >/dev/null && \
        log_ok "account" "alerts-ssl" "Baseline Universal SSL alert policy created." || \
        log_warn "account" "alerts-ssl" "POST SSL policy failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    else
      log_warn "account" "alerts-baseline" "No eligible email destination found; create one in the dashboard, then re-run."
    fi
  fi

  # 2FA / SSO are not API-enforceable for end users; surface as recommendations.
  log_warn "account" "2fa-recommend" "2FA cannot be enforced via the API. Enable account-wide 2FA enforcement in the dashboard." "https://developers.cloudflare.com/fundamentals/setup/account/account-security/2fa/"
  if requires_tier "account" "sso-recommend" "Enterprise: enforce SSO for all members." "enterprise" "https://developers.cloudflare.com/fundamentals/setup/account/account-security/sso/"; then
    log_warn "account" "sso-recommend" "Enable SSO enforcement (SAML/OIDC) in the dashboard for all account members."
  fi

  return 0
}
