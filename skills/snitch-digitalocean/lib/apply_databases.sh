# lib/apply_databases.sh — idempotent Managed Database hardening.
# Areas: TLS-only (advisory; sslmode handled client-side),
# trusted-source firewall (require non-empty), confirm backups enabled.
#
# Exports: apply_databases [args]

apply_databases() {
  local body; body="$(do_get /databases?per_page=200)" || {
    log_fail "databases" "list" "Could not list databases. $(do_last_error)"
    return 3
  }
  local total; total="$(jq -r '.databases // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_ok "databases" "list" "No managed databases to harden."
    return 0
  fi

  local cluster_ids; cluster_ids="$(jq -r '.databases[]? | .id' <<<"$body")"
  while IFS= read -r cid; do
    [[ -z "$cid" ]] && continue
    _apply_database_one "$cid" "$body"
  done <<<"$cluster_ids"
}

_apply_database_one() {
  local cid="$1" body="$2"
  local d; d="$(jq -c --arg id "$cid" '.databases[] | select(.id == $id)' <<<"$body")"
  local name engine
  name="$(jq -r '.name' <<<"$d")"
  engine="$(jq -r '.engine' <<<"$d")"

  # Trusted sources / firewall rules
  local fw rcount
  fw="$(do_get "/databases/${cid}/firewall")" || {
    log_warn "databases" "firewall/${name}" "Could not read firewall rules (status ${DOSEC_LAST_STATUS}). $(do_last_error)"
    fw='{"rules":[]}'
  }
  rcount="$(jq '.rules // [] | length' <<<"$fw")"
  if [[ "${rcount:-0}" -gt 0 ]]; then
    log_ok "databases" "firewall/${name}" "Trusted sources configured (${rcount} rule(s))."
  else
    log_fail "databases" "firewall/${name}" "No trusted-source rules; cluster is reachable from any caller with credentials. Add Droplet/tag/IP/k8s rules." "https://docs.digitalocean.com/products/databases/postgresql/how-to/secure-cluster/"
  fi

  # Private network
  local private_uuid; private_uuid="$(jq -r '.private_network_uuid // empty' <<<"$d")"
  if [[ -n "$private_uuid" ]]; then
    log_ok "databases" "vpc/${name}" "Cluster attached to VPC ${private_uuid}."
  else
    log_warn "databases" "vpc/${name}" "Cluster has no VPC attachment; clients connect over public network. Move to a VPC for trusted-source-by-droplet." "https://docs.digitalocean.com/products/networking/vpc/"
  fi

  # TLS posture: clients must use sslmode=require (Postgres) or tls=true (MySQL/Mongo/Redis)
  log_warn "databases" "tls-client/${name}" "Verify clients connect with TLS enforced (Postgres: sslmode=require/verify-full; MySQL: --ssl-mode=REQUIRED; Redis: rediss://; Mongo: tls=true). The DO API does not expose client connection-string usage." "https://docs.digitalocean.com/products/databases/${engine}/how-to/connect/"

  # Backups: managed databases include daily backups; warn if retention should be increased.
  log_info "managed databases include automated daily backups; review retention windows in dashboard for ${name}"
}
