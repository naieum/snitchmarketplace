# lib/tokens.sh — API token lifecycle audit + guided rotation.
# Exposes:
#   tokens_audit_run            — read-only audit; lists tokens, flags expiry / inactive / no-IP-allowlist.
#   tokens_fix [<subaction>]    — subactions: rotate <token-id> | audit | revoke <token-id> | help.
# Side effects:
#   - cf_get /user/tokens, cf_get /user/tokens/<id>.
#   - Never auto-creates / auto-revokes; rotation is dashboard-walked.

# _tokens_list -> JSON body of /user/tokens or empty on failure.
_tokens_list() {
  local body
  body="$(cf_get "/user/tokens?per_page=100")" || {
    log_warn "tokens" "list" "Could not list user tokens (need 'User API Tokens: Read'). $(cf_last_error)" "https://developers.cloudflare.com/fundamentals/api/get-started/create-token/"
    return 3
  }
  printf '%s\n' "$body"
}

# _tokens_days_until <iso8601> -> integer days from now (negative if past). Empty if no input.
_tokens_days_until() {
  local iso="$1"
  [[ -z "$iso" || "$iso" == "null" ]] && { printf ''; return 0; }
  local target now
  target="$(date -u -d "$iso" +%s 2>/dev/null \
    || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso" +%s 2>/dev/null \
    || printf '')"
  [[ -z "$target" ]] && { printf ''; return 0; }
  now="$(date -u +%s)"
  printf '%d' "$(( (target - now) / 86400 ))"
}

# tokens_audit_run — primary read-only audit. Standalone-callable.
tokens_audit_run() {
  log_section "tokens"
  local body
  body="$(_tokens_list)" || return 0

  local count
  count="$(jq -r '.result | length' <<<"$body" 2>/dev/null)"
  if [[ -z "$count" || "$count" == "null" ]]; then
    log_warn "tokens" "list" "Could not parse tokens list." "https://dash.cloudflare.com/profile/api-tokens"
    return 0
  fi
  log_ok "tokens" "list" "${count} API token(s) visible to this account."

  # Iterate token-by-token using jq -c.
  local row
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local id name status expires_on last_used not_before condition_count
    id="$(jq -r '.id // ""' <<<"$row")"
    name="$(jq -r '.name // "(unnamed)"' <<<"$row")"
    status="$(jq -r '.status // "unknown"' <<<"$row")"
    expires_on="$(jq -r '.expires_on // ""' <<<"$row")"
    last_used="$(jq -r '.last_used_on // ""' <<<"$row")"
    not_before="$(jq -r '.not_before // ""' <<<"$row")"
    condition_count="$(jq -r '
      ((.condition.request_ip.in // []) | length) +
      ((.condition.request_ip.not_in // []) | length)
    ' <<<"$row" 2>/dev/null)"

    log_subsection "token: ${name} (${id})"
    log_info "status=${status}  expires_on=${expires_on:-none}  last_used_on=${last_used:-never}  ip_conditions=${condition_count:-0}"

    case "$status" in
      active)
        log_ok "tokens" "status:${id}" "token '${name}' is active."
        ;;
      disabled|expired)
        log_fail "tokens" "status:${id}" "token '${name}' is ${status} but still visible (artifact). Delete in dashboard to reduce attack surface." "https://dash.cloudflare.com/profile/api-tokens"
        ;;
      *)
        log_warn "tokens" "status:${id}" "token '${name}' has unexpected status '${status}'."
        ;;
    esac

    if [[ -z "$expires_on" || "$expires_on" == "null" ]]; then
      log_warn "tokens" "expiry:${id}" "token '${name}' has no expiry. Set a TTL (1 year max) via 'tokens_fix rotate ${id}'." "https://developers.cloudflare.com/fundamentals/api/get-started/create-token/"
    else
      local days
      days="$(_tokens_days_until "$expires_on")"
      if [[ -n "$days" && "$days" -lt 0 ]]; then
        log_fail "tokens" "expiry:${id}" "token '${name}' expired ${days#-} day(s) ago. Delete it." "https://dash.cloudflare.com/profile/api-tokens"
      elif [[ -n "$days" && "$days" -le 30 ]]; then
        log_warn "tokens" "expiry:${id}" "token '${name}' expires in ${days} day(s). Rotate now." "https://dash.cloudflare.com/profile/api-tokens"
      else
        log_ok "tokens" "expiry:${id}" "token '${name}' expires on ${expires_on}."
      fi
    fi

    if [[ "${condition_count:-0}" -eq 0 ]]; then
      log_warn "tokens" "ip-allowlist:${id}" "token '${name}' has no IP allowlist condition. Tighten via dashboard if practical." "https://developers.cloudflare.com/fundamentals/api/how-to/secure-api-tokens-with-restricted-ips/"
    else
      log_ok "tokens" "ip-allowlist:${id}" "token '${name}' has ${condition_count} IP condition(s) set."
    fi

    if [[ -z "$last_used" || "$last_used" == "null" ]]; then
      log_warn "tokens" "last-used:${id}" "token '${name}' has never been used. Consider revoking via 'tokens_fix revoke ${id}'." "https://dash.cloudflare.com/profile/api-tokens"
    fi
  done < <(jq -c '.result[]?' <<<"$body" 2>/dev/null)
}

# tokens_fix [<subaction>] — guided rotation / audit / revoke.
tokens_fix() {
  local sub="${1:-help}"
  case "$sub" in
    audit)
      tokens_audit_run
      ;;
    rotate)
      local id="${2:-}"
      if [[ -z "$id" ]]; then
        log_fail "tokens" "rotate" "Usage: tokens_fix rotate <token-id>. Find the id with 'tokens_fix audit'."
        return 2
      fi
      _tokens_walk_rotate "$id"
      ;;
    revoke)
      local id="${2:-}"
      if [[ -z "$id" ]]; then
        log_fail "tokens" "revoke" "Usage: tokens_fix revoke <token-id>."
        return 2
      fi
      _tokens_walk_revoke "$id"
      ;;
    help|*)
      log_info "tokens_fix subactions:"
      log_info "  audit                 - re-run the audit (same as tokens_audit_run)"
      log_info "  rotate <token-id>     - walk through dashboard-side rotation with same scopes"
      log_info "  revoke <token-id>     - walk through revoking an unused / over-scoped token"
      ;;
  esac
}

# _tokens_walk_rotate <id> — read scopes for the existing token and emit dashboard instructions.
_tokens_walk_rotate() {
  local id="$1"
  local body
  body="$(cf_get "/user/tokens/${id}")" || {
    log_fail "tokens" "rotate:${id}" "Could not read token ${id}. $(cf_last_error)"
    return 3
  }
  local name expires_on
  name="$(jq -r '.result.name // "(unnamed)"' <<<"$body")"
  expires_on="$(jq -r '.result.expires_on // ""' <<<"$body")"

  log_subsection "rotate token: ${name} (${id})"
  log_info "Cloudflare's API does not allow programmatic token-create with arbitrary permission groups for"
  log_info "all permission shapes. The skill walks you through the dashboard instead — never logs the secret."
  printf '\n'
  printf '  1. Open https://dash.cloudflare.com/profile/api-tokens\n'
  printf '  2. Click "Create Token". Use the same permission groups as the existing token (printed below).\n'
  printf '  3. Set a 1-year TTL and the same IP allowlist (if any).\n'
  printf '  4. Copy the new secret ONCE into your secret manager. Do not paste it here.\n'
  printf '  5. Update CLOUDFLARE_API_TOKEN in your environment.\n'
  printf '  6. Run: bash snitch-cloudflare.sh check  (verify the new token works).\n'
  printf '  7. Then in the dashboard, delete the old token (id %s).\n\n' "$id"

  printf 'Existing scopes for token "%s" (copy into the new token form):\n' "$name"
  jq -r '.result.policies[]? | "  - effect=\(.effect)  resources=\(.resources | tojson)  permission_groups=[\([.permission_groups[]?.name] | join(", "))]"' <<<"$body"
  if [[ -n "$expires_on" && "$expires_on" != "null" ]]; then
    printf 'Existing expires_on: %s\n' "$expires_on"
  fi
}

# _tokens_walk_revoke <id> — show the dashboard URL + a confirmation prompt-friendly summary.
_tokens_walk_revoke() {
  local id="$1"
  local body
  body="$(cf_get "/user/tokens/${id}")" || {
    log_fail "tokens" "revoke:${id}" "Could not read token ${id}. $(cf_last_error)"
    return 3
  }
  local name last_used
  name="$(jq -r '.result.name // "(unnamed)"' <<<"$body")"
  last_used="$(jq -r '.result.last_used_on // "never"' <<<"$body")"
  log_subsection "revoke token: ${name} (${id})"
  log_info "last_used_on: ${last_used}"
  log_info "The skill never auto-revokes. To revoke:"
  printf '  1. Visit https://dash.cloudflare.com/profile/api-tokens\n'
  printf '  2. Locate token "%s" (id %s).\n' "$name" "$id"
  printf '  3. Click "..." → "Delete".\n'
  printf '  4. Re-run: tokens_fix audit  (verify it is gone).\n'
}
