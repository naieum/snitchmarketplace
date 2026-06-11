# lib/origin.sh — origin posture audit (read-only).
# Exposes:
#   origin_run     — for each in-scope zone, surface non-Cloudflare origin records and emit a hardening checklist.
# Side effects:
#   - cf_get /zones, /zones/{id}/dns_records.
#   - Reads ${TPL_DIR}/origin-hardening.checklist.md if available; falls back to inline content.

# _origin_zone_a_aaaa <zone_id> -> JSON array of {name,type,content,proxied} for A/AAAA records.
_origin_zone_a_aaaa() {
  local zone_id="$1"
  local body
  body="$(cf_get "/zones/${zone_id}/dns_records?per_page=500&type=A")" || { printf '[]'; return 3; }
  local arr1; arr1="$(jq -c '.result // []' <<<"$body")"
  body="$(cf_get "/zones/${zone_id}/dns_records?per_page=500&type=AAAA")" || { printf '%s' "$arr1"; return 0; }
  local arr2; arr2="$(jq -c '.result // []' <<<"$body")"
  jq -nc --argjson a "$arr1" --argjson b "$arr2" '$a + $b'
}

# _origin_is_cf_ip <ip> -> rc 0 if the IP is in known CF egress range (best-effort regex).
# CF v4 ranges include 173.245.48.0/20, 103.21.244.0/22, 103.22.200.0/22, 103.31.4.0/22, 141.101.64.0/18,
# 108.162.192.0/18, 190.93.240.0/20, 188.114.96.0/20, 197.234.240.0/22, 198.41.128.0/17, 162.158.0.0/15,
# 104.16.0.0/13, 104.24.0.0/14, 172.64.0.0/13, 131.0.72.0/22.
# We approximate via /16 prefix match; the live source-of-truth is https://www.cloudflare.com/ips-v4
_origin_is_cf_ip() {
  local ip="$1"
  case "$ip" in
    173.245.4[89].*|173.245.5[0-9].*|173.245.6[0-3].*) return 0 ;;
    103.21.244.*|103.21.245.*|103.21.246.*|103.21.247.*) return 0 ;;
    103.22.200.*|103.22.201.*|103.22.202.*|103.22.203.*) return 0 ;;
    103.31.4.*|103.31.5.*|103.31.6.*|103.31.7.*) return 0 ;;
    141.101.6[4-9].*|141.101.[7-9][0-9].*|141.101.1[0-1][0-9].*|141.101.12[0-7].*) return 0 ;;
    108.162.19[2-9].*|108.162.2[0-4][0-9].*|108.162.25[0-5].*) return 0 ;;
    190.93.24[0-9].*|190.93.25[0-5].*) return 0 ;;
    188.114.9[6-9].*|188.114.1[0-1][0-9].*) return 0 ;;
    198.41.12[8-9].*|198.41.1[3-9][0-9].*|198.41.2[0-5][0-9].*) return 0 ;;
    162.158.*) return 0 ;;
    104.1[6-9].*|104.2[0-3].*) return 0 ;;
    104.2[4-7].*) return 0 ;;
    172.6[4-9].*|172.7[0-1].*) return 0 ;;
    131.0.7[2-5].*) return 0 ;;
  esac
  return 1
}

# _origin_emit_checklist — print the hardening checklist (template if present, else inline).
_origin_emit_checklist() {
  local f="${TPL_DIR:-}/origin-hardening.checklist.md"
  if [[ -f "$f" ]]; then
    printf '\n--- origin hardening checklist (from %s) ---\n' "$f"
    cat "$f"
    return 0
  fi
  printf '\n--- origin hardening checklist (inline) ---\n'
  cat <<'EOF'
At your origin host (Cloudflare cannot verify these remotely):
  [ ] Allowlist Cloudflare egress IPs at the origin firewall (live source: https://www.cloudflare.com/ips/).
      Drop everything else. This makes orange-cloud bypass impossible.
  [ ] Close direct DB ports (5432 / 3306 / 6379 / 27017) to the public internet.
      Use Cloudflare Tunnel + Access for admin reach; Hyperdrive for app reach (no direct exposure).
  [ ] Install an Authenticated Origin Pulls (AOP) cert at the origin web server.
      mTLS between Cloudflare edge and your origin. Refuse non-CF TLS clients.
      Docs: https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/
  [ ] Configure X-Forwarded-For trust correctly. Trust ONLY the CF IP ranges above when
      reading the original client IP. Common pitfall: trusting any X-Forwarded-For lets attackers spoof.
      In Cloudflare specifically, prefer CF-Connecting-IP — it's set only by CF and not user-supplied.
  [ ] If you can move to Cloudflare Tunnel (cloudflared), do so. The origin then has no public IP,
      no inbound firewall hole, and the WAF cannot be bypassed.
EOF
}

origin_run() {
  log_section "origin posture"

  local zones_body
  zones_body="$(cf_get /zones)" || {
    log_warn "origin" "list" "Could not list zones for origin scan."
    return 0
  }
  local zone_count
  zone_count="$(jq -r '.result | length' <<<"$zones_body" 2>/dev/null)"
  if [[ -z "$zone_count" || "$zone_count" == "null" || "$zone_count" -eq 0 ]]; then
    log_info "no zones in scope; skipping origin scan."
    return 0
  fi

  local row
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local zid zname
    zid="$(jq -r '.id' <<<"$row")"
    zname="$(jq -r '.name' <<<"$row")"
    log_subsection "zone: ${zname} (${zid})"

    local recs; recs="$(_origin_zone_a_aaaa "$zid" 2>/dev/null)"
    [[ -z "$recs" ]] && recs='[]'
    local rec_count; rec_count="$(jq 'length' <<<"$recs" 2>/dev/null)"
    if [[ "${rec_count:-0}" -eq 0 ]]; then
      log_ok "origin" "no-a-aaaa:${zid}" "No A/AAAA records — likely all CNAME / Tunnel / Workers / Pages."
      continue
    fi

    local rrow
    while IFS= read -r rrow; do
      [[ -z "$rrow" ]] && continue
      local rname rtype rcontent rproxied
      rname="$(jq -r '.name' <<<"$rrow")"
      rtype="$(jq -r '.type' <<<"$rrow")"
      rcontent="$(jq -r '.content' <<<"$rrow")"
      rproxied="$(jq -r '.proxied' <<<"$rrow")"

      if [[ "$rproxied" != "true" ]]; then
        log_warn "origin" "unproxied:${rname}" "${rtype} ${rname} -> ${rcontent} is DNS-only (grey cloud). Origin is reachable directly. Consider proxying or moving to Tunnel." "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/"
      fi

      if [[ "$rtype" == "A" ]] && _origin_is_cf_ip "$rcontent"; then
        log_ok "origin" "cf-ip:${rname}" "${rname} -> ${rcontent} appears to be a Cloudflare-managed IP."
        continue
      fi

      log_warn "origin" "non-tunnel:${rname}" "${rtype} ${rname} -> ${rcontent} is a non-Cloudflare origin. Recommend Cloudflare Tunnel (no public origin IP, no firewall hole)." "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/"
    done < <(jq -c '.[]' <<<"$recs" 2>/dev/null)
  done < <(jq -c '.result[]?' <<<"$zones_body" 2>/dev/null)

  _origin_emit_checklist
  log_info "Skill cannot verify origin-side state. Treat the above as a manual checklist."
}
