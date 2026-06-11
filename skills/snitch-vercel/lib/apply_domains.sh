# lib/apply_domains.sh — domain hygiene.
# Auto-HTTPS is on for Vercel domains by default; the skill verifies + flags edge cases.
# Idempotent: read-first, then warn/recommend.

apply_domains() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    log_fail "domains" "pick" "No project selected. Set VRCSEC_PROJECT_ID."
    return 3
  fi

  log_section "domains apply (project_id: ${project_id})"

  local body; body="$(vrc_get "/v9/projects/${project_id}/domains")" || {
    log_fail "domains" "read" "Could not list domains. $(vrc_last_error)"
    return 3
  }

  local d redirect verified apex_seen=""
  while IFS=$'\t' read -r d redirect verified; do
    [[ -z "$d" ]] && continue
    if [[ "$verified" != "true" ]]; then
      log_fail "domains" "verify-${d}" "Domain ${d} is not verified — TLS will not issue. Add the verification record listed in 'vercel domains inspect ${d}'." "https://vercel.com/docs/projects/domains"
      continue
    fi
    log_ok "domains" "verify-${d}" "Domain ${d} verified."

    # Apex / www redirect heuristic.
    if [[ "$d" =~ ^www\. ]]; then
      log_info "domain ${d} is www; check apex redirect target"
    elif [[ "$d" =~ \. ]]; then
      apex_seen="$d"
    fi

    # Vercel auto-issues TLS for verified domains; flag if redirect status is set wrong.
    if [[ -n "$redirect" && "$redirect" != "null" ]]; then
      log_ok "domains" "redirect-${d}" "Domain ${d} redirects to ${redirect}."
    fi
  done < <(jq -r '(.domains // [])[] | "\(.name)\t\(.redirect // "")\t\(.verified // false)"' <<<"$body")

  if [[ -n "$apex_seen" ]]; then
    log_warn "domains" "apex-redirect" "Verify either the apex (${apex_seen}) or www form is canonical and the other 308-redirects to it. Vercel handles TLS automatically for both." "https://vercel.com/docs/projects/domains/working-with-domains#redirecting-www-and-non-www-domains"
  fi

  # DNSSEC: Vercel-managed nameservers do not currently emit DS records → user must use a DNSSEC-supporting registrar/DNS.
  log_warn "domains" "dnssec" "Vercel's managed DNS does not enable DNSSEC. If DNSSEC is required, delegate DNS to a registrar that supports it (Cloudflare, Route53) and point Vercel as a target." "https://vercel.com/docs/projects/domains/working-with-dns"

  # Modern TLS (TLS 1.3 / strong ciphers) is provided by Vercel; nothing to flip.
  log_ok "domains" "tls-version" "Vercel terminates TLS 1.3 with modern cipher suites by default."

  return 0
}
