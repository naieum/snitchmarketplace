# lib/email.sh — email DNS posture (SPF / DKIM / DMARC / MTA-STS / BIMI / DNSSEC).
# Exposes:
#   email_run             — read-only audit of every apex zone the token sees.
#   email_fix [<args>]    — idempotent: adds missing SPF / DMARC / MTA-STS records via DNS API.
# Side effects:
#   - cf_get /zones, /zones/{id}/dns_records.
#   - cf_post for additions in email_fix; reads-first to be idempotent.

# _email_zone_records <zone_id> <type> <name> -> JSON array of matching records.
_email_zone_records() {
  local zone_id="$1" rtype="$2" rname="$3"
  local body
  body="$(cf_get "/zones/${zone_id}/dns_records?type=${rtype}&name=${rname}&per_page=50")" \
    || { printf '[]'; return 3; }
  jq -c '.result // []' <<<"$body"
}

# _email_provider_for_mx <mx_target> -> echoes the friendly provider name or "" if unknown.
_email_provider_for_mx() {
  local mx="$1"
  case "$mx" in
    *sendgrid.net*)        printf 'SendGrid' ;;
    *mailgun.org*|*mailgun.net*) printf 'Mailgun' ;;
    *aspmx.l.google.com*|*googlemail.com*) printf 'Google Workspace' ;;
    *outlook.com*|*protection.outlook.com*) printf 'Microsoft 365' ;;
    *zoho.com*|*zoho.eu*)  printf 'Zoho' ;;
    *amazonses.com*|*ses.amazonaws.com*|*inbound-smtp*) printf 'Amazon SES' ;;
    *postmarkapp.com*)     printf 'Postmark' ;;
    *mandrillapp.com*)     printf 'Mandrill' ;;
    *fastmail.com*|*messagingengine.com*) printf 'Fastmail' ;;
    *icloud.com*)          printf 'iCloud Mail' ;;
    *mxroute.com*)         printf 'MXroute' ;;
    *)                     printf '' ;;
  esac
}

# _email_audit_zone <zone_id> <zone_name>
_email_audit_zone() {
  local zid="$1" zname="$2"
  log_subsection "email: ${zname}"

  # MX records.
  local mx_body
  mx_body="$(cf_get "/zones/${zid}/dns_records?type=MX&per_page=50")" \
    || { log_warn "email" "mx-read:${zname}" "Could not read MX records."; return 0; }
  local mx_count; mx_count="$(jq -r '.result | length' <<<"$mx_body")"
  if [[ "${mx_count:-0}" -eq 0 ]]; then
    log_info "no MX records on ${zname} — email may not be configured here."
  else
    local mrow
    while IFS= read -r mrow; do
      [[ -z "$mrow" ]] && continue
      local mc; mc="$(jq -r '.content' <<<"$mrow")"
      local prov; prov="$(_email_provider_for_mx "$mc")"
      if [[ -n "$prov" ]]; then
        log_ok "email" "mx-provider:${zname}" "MX -> ${mc} (${prov})."
      else
        log_info "MX -> ${mc} (unknown provider)"
      fi
    done < <(jq -c '.result[]?' <<<"$mx_body")
  fi

  # SPF (TXT @ "v=spf1 ...")
  local spf_body
  spf_body="$(_email_zone_records "$zid" "TXT" "$zname")"
  local spf_record
  spf_record="$(jq -r '.[]?.content // empty' <<<"$spf_body" | grep -E '^"?v=spf1' | head -n1)"
  if [[ -z "$spf_record" ]]; then
    log_warn "email" "spf:${zname}" "No SPF record found at ${zname}. Add a 'v=spf1' TXT record." "https://developers.cloudflare.com/dns/manage-dns-records/reference/email-records/"
  else
    if printf '%s' "$spf_record" | grep -q '+all'; then
      log_fail "email" "spf-allow-all:${zname}" "SPF record contains '+all' (permits any sender). Use '-all' or '~all'." "https://developers.cloudflare.com/dns/manage-dns-records/reference/email-records/"
    else
      log_ok "email" "spf:${zname}" "SPF present: ${spf_record}"
    fi
  fi

  # DKIM — too many selectors to enumerate; informational.
  log_info "DKIM: verify selectors via your provider's docs (selectors live at <selector>._domainkey.${zname})."

  # DMARC.
  local dmarc_body
  dmarc_body="$(_email_zone_records "$zid" "TXT" "_dmarc.${zname}")"
  local dmarc
  dmarc="$(jq -r '.[]?.content // empty' <<<"$dmarc_body" | grep -E '^"?v=DMARC1' | head -n1)"
  if [[ -z "$dmarc" ]]; then
    log_fail "email" "dmarc:${zname}" "No DMARC record at _dmarc.${zname}. Add 'v=DMARC1; p=quarantine; rua=mailto:dmarc@${zname}'." "https://developers.cloudflare.com/dmarc-management/"
  else
    if printf '%s' "$dmarc" | grep -qE 'p=none'; then
      log_warn "email" "dmarc-p-none:${zname}" "DMARC policy is p=none (monitoring only). Move to p=quarantine or p=reject after a soak." "https://developers.cloudflare.com/dmarc-management/"
    else
      log_ok "email" "dmarc:${zname}" "DMARC present: ${dmarc}"
    fi
  fi

  # MTA-STS — TXT _mta-sts.<domain>
  local mtasts_body
  mtasts_body="$(_email_zone_records "$zid" "TXT" "_mta-sts.${zname}")"
  local mtasts
  mtasts="$(jq -r '.[]?.content // empty' <<<"$mtasts_body" | head -n1)"
  if [[ -z "$mtasts" ]]; then
    log_warn "email" "mta-sts:${zname}" "No MTA-STS TXT at _mta-sts.${zname}. Optional; recommended for stricter SMTP TLS enforcement." "https://datatracker.ietf.org/doc/html/rfc8461"
  else
    log_ok "email" "mta-sts:${zname}" "MTA-STS TXT present: ${mtasts}"
  fi

  # BIMI — informational.
  local bimi_body
  bimi_body="$(_email_zone_records "$zid" "TXT" "default._bimi.${zname}")"
  local bimi
  bimi="$(jq -r '.[]?.content // empty' <<<"$bimi_body" | head -n1)"
  if [[ -n "$bimi" ]]; then
    log_ok "email" "bimi:${zname}" "BIMI record present (informational)."
  else
    log_info "BIMI not configured at default._bimi.${zname} (optional, brand-logo display in inbox)."
  fi

  # DNSSEC — cross-check (audit_zone also covers this).
  local ds
  ds="$(cf_get "/zones/${zid}/dnssec")" || ds=""
  local ds_status; ds_status="$(jq -r '.result.status // "unknown"' <<<"$ds" 2>/dev/null)"
  if [[ "$ds_status" != "active" ]]; then
    log_warn "email" "dnssec:${zname}" "DNSSEC is '${ds_status:-unknown}' on ${zname}. Email auth records benefit from DNSSEC." "https://developers.cloudflare.com/dns/dnssec/"
  else
    log_ok "email" "dnssec:${zname}" "DNSSEC active on ${zname}."
  fi
}

email_run() {
  log_section "email"
  local zones_body
  zones_body="$(cf_get /zones)" || { log_warn "email" "zones" "Could not list zones."; return 0; }
  local row
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local zid zname
    zid="$(jq -r '.id' <<<"$row")"
    zname="$(jq -r '.name' <<<"$row")"
    _email_audit_zone "$zid" "$zname"
  done < <(jq -c '.result[]?' <<<"$zones_body" 2>/dev/null)
}

# _email_create_txt <zone_id> <name> <content> -> creates only if not already present (idempotent).
_email_create_txt() {
  local zid="$1" name="$2" content="$3"
  local existing
  existing="$(_email_zone_records "$zid" "TXT" "$name")"
  if jq -e --arg c "$content" '.[]? | select(.content == $c)' <<<"$existing" >/dev/null 2>&1; then
    log_ok "email" "fix-noop:${name}" "TXT ${name} already has the desired content."
    return 0
  fi
  # Also no-op if there is *any* matching policy-type record (avoid duplicating SPF / DMARC).
  local prefix; prefix="${content%% *}"
  if [[ "$prefix" == "v=spf1" || "$prefix" == "v=DMARC1" ]]; then
    if jq -e --arg p "$prefix" '.[]? | select(.content | test("^\"?" + $p))' <<<"$existing" >/dev/null 2>&1; then
      log_ok "email" "fix-noop:${name}" "${prefix} record already exists at ${name}; not duplicating."
      return 0
    fi
  fi
  local body
  body="$(jq -nc --arg n "$name" --arg c "$content" '{type:"TXT", name:$n, content:$c, ttl:1}')"
  if cf_post "/zones/${zid}/dns_records" "$body" >/dev/null; then
    log_ok "email" "fix-add:${name}" "Added TXT ${name} = ${content}"
  else
    log_fail "email" "fix-add:${name}" "Failed to add TXT ${name}. $(cf_last_error)"
    return 3
  fi
}

# email_fix [<args>] — adds baseline SPF / DMARC / MTA-STS records. Idempotent.
email_fix() {
  log_section "email fix"
  local zones_body
  zones_body="$(cf_get /zones)" || { log_warn "email" "zones" "Could not list zones."; return 0; }
  local row
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local zid zname
    zid="$(jq -r '.id' <<<"$row")"
    zname="$(jq -r '.name' <<<"$row")"
    log_subsection "email_fix: ${zname}"

    # Detect provider via MX to tailor SPF.
    local mx_body
    mx_body="$(cf_get "/zones/${zid}/dns_records?type=MX&per_page=50")" || mx_body='{"result":[]}'
    local detected_spf=""
    local mrow
    while IFS= read -r mrow; do
      [[ -z "$mrow" ]] && continue
      local mc; mc="$(jq -r '.content' <<<"$mrow")"
      case "$mc" in
        *aspmx.l.google.com*|*googlemail.com*) detected_spf="v=spf1 include:_spf.google.com -all" ;;
        *outlook.com*) detected_spf="v=spf1 include:spf.protection.outlook.com -all" ;;
        *sendgrid.net*) detected_spf="v=spf1 include:sendgrid.net -all" ;;
        *mailgun.org*|*mailgun.net*) detected_spf="v=spf1 include:mailgun.org -all" ;;
        *amazonses.com*) detected_spf="v=spf1 include:amazonses.com -all" ;;
        *postmarkapp.com*) detected_spf="v=spf1 include:spf.mtasv.net -all" ;;
        *zoho.com*|*zoho.eu*) detected_spf="v=spf1 include:zoho.com -all" ;;
      esac
      [[ -n "$detected_spf" ]] && break
    done < <(jq -c '.result[]?' <<<"$mx_body")
    [[ -z "$detected_spf" ]] && detected_spf="v=spf1 -all"

    _email_create_txt "$zid" "$zname" "$detected_spf"
    _email_create_txt "$zid" "_dmarc.${zname}" "v=DMARC1; p=quarantine; rua=mailto:dmarc@${zname}; fo=1"
    _email_create_txt "$zid" "_mta-sts.${zname}" "v=STSv1; id=$(date -u +%Y%m%d%H%M%S)"
  done < <(jq -c '.result[]?' <<<"$zones_body" 2>/dev/null)

  log_info "Note: MTA-STS also requires a policy file at https://mta-sts.${zname}/.well-known/mta-sts.txt — skill emits the TXT only."
}
