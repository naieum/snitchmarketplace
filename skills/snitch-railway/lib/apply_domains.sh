# lib/apply_domains.sh — domain hardening: HTTPS auto-managed, redirect, custom domain status.
# Exports: apply_domains [project-id]

apply_domains() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      log_fail "domains" "pick" "could not resolve project id"
      return 3
    }
  fi
  log_section "domains hardening for project=${project_id}"

  . "$LIB_DIR/state_domains.sh"
  local digest
  digest="$(run_state_domains "$project_id" digest 2>/dev/null)"
  if [[ -z "$digest" ]] || ! jq -e '.domains_summary' >/dev/null 2>&1 <<<"$digest"; then
    log_fail "domains" "read" "could not read domains digest"
    return 3
  fi

  local custom_count unverified_count
  custom_count="$(jq '.domains_summary.custom_domain_count // 0' <<<"$digest")"
  unverified_count="$(jq '.domains_summary.custom_domain_unverified // [] | length' <<<"$digest")"

  if [[ "$custom_count" == "0" ]]; then
    log_warn "domains" "custom" "no custom domains attached. Production traffic over the *.up.railway.app subdomain prevents HSTS preload eligibility and brand control."
  else
    log_ok "domains" "custom" "${custom_count} custom domain(s) attached."
  fi

  if [[ "$unverified_count" == "0" ]]; then
    log_ok "domains" "verified" "all custom domains have status=active (TLS issued)."
  else
    log_fail "domains" "verified" "${unverified_count} custom domain(s) with non-active status — TLS likely pending. Verify CNAME/AAAA at the registrar." "https://docs.railway.com/guides/public-networking"
    jq -r '.domains_summary.custom_domain_unverified // [] | .[] | "  - \(.domain) status=\(.status)"' <<<"$digest" >&2
  fi

  log_info "Railway auto-manages TLS via Lets Encrypt and force-redirects HTTP→HTTPS by default. No further action for those."
  log_warn "domains" "hsts" "Railway does not set HSTS at the edge. Set 'Strict-Transport-Security: max-age=31536000; includeSubDomains; preload' in your application's response headers (middleware-level)." "https://hstspreload.org"
}
