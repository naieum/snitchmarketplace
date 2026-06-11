# lib/apply_dns.sh — DNS hardening.
# DigitalOcean's managed DNS does NOT support DNSSEC — surface that loudly.
# Idempotent additions: CAA records (letsencrypt.org, pki.goog) for each managed domain.
#
# Exports: apply_dns [args]

apply_dns() {
  log_warn "dns" "dnssec-unsupported" "DigitalOcean managed DNS does NOT support DNSSEC. To enable DNSSEC: put Cloudflare DNS in front (orange-cloud), or use a registrar that signs the zone." "https://www.digitalocean.com/community/tutorials/an-introduction-to-dnssec"

  local body; body="$(do_get /domains?per_page=200)" || {
    log_fail "dns" "list" "Could not list domains. $(do_last_error)"
    return 3
  }
  local total; total="$(jq -r '.domains // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_ok "dns" "list" "No DigitalOcean-managed domains."
    return 0
  fi

  local domains; domains="$(jq -r '.domains[]? | .name' <<<"$body")"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    _apply_dns_one "$d"
  done <<<"$domains"
}

_apply_dns_one() {
  local domain="$1"
  local recs; recs="$(do_get "/domains/${domain}/records?per_page=500")" || {
    log_warn "dns" "records/${domain}" "Could not list records."
    return 0
  }

  # CAA records for letsencrypt.org and pki.goog
  local issuer
  for issuer in "letsencrypt.org" "pki.goog"; do
    local present
    present="$(jq -r --arg v "$issuer" '[.domain_records // [] | .[] | select(.type == "CAA") | select(.data | tostring | endswith($v))] | length' <<<"$recs" 2>/dev/null)"
    if [[ "${present:-0}" -gt 0 ]]; then
      log_ok "dns" "caa-${issuer}/${domain}" "CAA issue ${issuer} present."
      continue
    fi
    local payload
    payload="$(jq -n --arg name "@" --arg issuer "$issuer" \
      '{type:"CAA", name:$name, data:$issuer, flags:0, tag:"issue", ttl:3600}')"
    if do_post "/domains/${domain}/records" "$payload" >/dev/null; then
      log_ok "dns" "caa-${issuer}/${domain}" "CAA issue ${issuer} added."
    else
      log_warn "dns" "caa-${issuer}/${domain}" "Could not add CAA (status ${DOSEC_LAST_STATUS}). $(do_last_error)"
    fi
  done

  # SPF / DMARC / DKIM are email-config-specific; surface as recommendations.
  log_info "Verify SPF (v=spf1 ...), DKIM (selector._domainkey TXT), DMARC (_dmarc TXT) for ${domain} if it sends email."
}
