# lib/apply_droplets.sh — idempotent Droplet hardening.
# Areas: enable backups (warn-only — paid feature), monitoring agent install,
# disable password auth (project-side: emit unified diff for cloud-init / SSH config).
#
# Exports: apply_droplets [args]

apply_droplets() {
  local body; body="$(do_get /droplets?per_page=200)" || {
    log_fail "droplets" "list" "Could not list droplets. $(do_last_error)"
    return 3
  }

  local total; total="$(jq -r '.droplets // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_ok "droplets" "list" "No droplets to harden."
    return 0
  fi

  local droplet_ids
  droplet_ids="$(jq -r '.droplets[]? | .id' <<<"$body")"

  while IFS= read -r did; do
    [[ -z "$did" ]] && continue
    _apply_droplet_one "$did" "$body"
  done <<<"$droplet_ids"
}

_apply_droplet_one() {
  local did="$1" body="$2"
  local d
  d="$(jq -c --argjson id "$did" '.droplets[] | select(.id == $id)' <<<"$body" 2>/dev/null)"
  local name; name="$(jq -r '.name' <<<"$d")"

  # Backups feature flag
  local has_backups
  has_backups="$(jq -r '.features // [] | index("backups") | if . != null then "1" else "0" end' <<<"$d")"
  if [[ "$has_backups" == "1" ]]; then
    log_ok "droplets" "backups/${name}" "Backups already enabled."
  else
    # POST /droplets/{id}/actions {"type":"enable_backups"}  -- this is paid (~20% of droplet price).
    local payload='{"type":"enable_backups"}'
    if do_post "/droplets/${did}/actions" "$payload" >/dev/null; then
      log_ok "droplets" "backups/${name}" "Backups enabled (~20% droplet price)."
    else
      log_warn "droplets" "backups/${name}" "Could not enable backups (status ${DOSEC_LAST_STATUS}). Enable manually if intentional. $(do_last_error)" "https://docs.digitalocean.com/products/droplets/how-to/back-up/"
    fi
  fi

  # Monitoring agent
  local has_monitoring
  has_monitoring="$(jq -r '.features // [] | index("monitoring") | if . != null then "1" else "0" end' <<<"$d")"
  if [[ "$has_monitoring" == "1" ]]; then
    log_ok "droplets" "monitoring/${name}" "Monitoring agent enabled."
  else
    if do_post "/droplets/${did}/actions" '{"type":"enable_monitoring"}' >/dev/null; then
      log_ok "droplets" "monitoring/${name}" "Monitoring agent enabled."
    else
      log_warn "droplets" "monitoring/${name}" "Could not enable monitoring (status ${DOSEC_LAST_STATUS}). $(do_last_error)" "https://docs.digitalocean.com/products/monitoring/"
    fi
  fi

  # IPv6
  local has_ipv6
  has_ipv6="$(jq -r '.features // [] | index("ipv6") | if . != null then "1" else "0" end' <<<"$d")"
  if [[ "$has_ipv6" == "1" ]]; then
    log_ok "droplets" "ipv6/${name}" "IPv6 enabled."
  else
    log_info "ipv6 not enabled on ${name}; consider POST /droplets/${did}/actions {type:enable_ipv6}"
  fi

  # SSH password auth — cannot be inspected via DO API. Emit project-side guidance.
  log_warn "droplets" "password-auth/${name}" "DigitalOcean API cannot inspect SSH password-auth state. SSH into ${name} and ensure /etc/ssh/sshd_config has 'PasswordAuthentication no' and 'PermitRootLogin prohibit-password'." "https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/"
}
