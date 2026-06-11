# lib/apply_firewalls.sh — Cloud Firewall hardening.
# Idempotent: detects management ports (22, 3389, 5432, 3306, 27017, 6379)
# open to 0.0.0.0/0 ::/0, and recommends restricting to office IPs / a bastion tag.
# Does NOT auto-mutate to avoid locking the user out — emits the recommended
# fix as JSON the agent can apply via doctl after user confirmation.
#
# Exports: apply_firewalls [args]

apply_firewalls() {
  local body; body="$(do_get /firewalls?per_page=200)" || {
    log_fail "firewalls" "list" "Could not list firewalls. $(do_last_error)"
    return 3
  }

  local total; total="$(jq -r '.firewalls // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_warn "firewalls" "none" "No Cloud Firewall configured. Every Droplet that exposes any service should sit behind a firewall." "https://docs.digitalocean.com/products/networking/firewalls/"
    return 0
  fi

  local fw_ids; fw_ids="$(jq -r '.firewalls[]? | .id' <<<"$body")"
  while IFS= read -r fid; do
    [[ -z "$fid" ]] && continue
    _apply_firewall_one "$fid" "$body"
  done <<<"$fw_ids"
}

_apply_firewall_one() {
  local fid="$1" body="$2"
  local f; f="$(jq -c --arg id "$fid" '.firewalls[] | select(.id == $id)' <<<"$body")"
  local name; name="$(jq -r '.name' <<<"$f")"

  # Find world-open management ports.
  local mgmt_ports='["22","3389","5432","3306","27017","6379"]'
  local hits
  hits="$(jq -r --argjson mp "$mgmt_ports" \
    '.inbound_rules // [] | map(
      select(
        ((.ports // "") | tostring) as $p
        | ($mp | index($p)) != null
        and ((.sources.addresses // []) | map(. == "0.0.0.0/0" or . == "::/0") | any)
      )
    ) | .[] | "\(.protocol) \(.ports)"' <<<"$f" 2>/dev/null)"

  if [[ -n "$hits" ]]; then
    log_fail "firewalls" "mgmt-open/${name}" "Management ports world-open on firewall '${name}': $(printf '%s' "$hits" | tr '\n' ',' | sed 's/,$//'). Restrict to office IPs or a bastion-tag source." "https://docs.digitalocean.com/products/networking/firewalls/how-to/configure-rules/"
    cat <<EOF
=== FILE: hardening-${name}.sh ===
=== CONTENT ===
# Replace management-port rules with restricted sources.
# Edit OFFICE_CIDR to your IP range.
OFFICE_CIDR="203.0.113.0/24"
doctl compute firewall update ${fid} --name "${name}" \\
  --inbound-rules "protocol:tcp,ports:22,address:\${OFFICE_CIDR}" \\
  --outbound-rules "protocol:tcp,ports:1-65535,address:0.0.0.0/0,address:::/0"
=== END ===
EOF
  else
    log_ok "firewalls" "mgmt-closed/${name}" "No management ports world-open."
  fi

  # Confirm attached to droplets or a tag.
  local dcount tcount
  dcount="$(jq -r '.droplet_ids // [] | length' <<<"$f")"
  tcount="$(jq -r '.tags // [] | length' <<<"$f")"
  if [[ "${dcount:-0}" -eq 0 && "${tcount:-0}" -eq 0 ]]; then
    log_warn "firewalls" "unattached/${name}" "Firewall has no Droplet or tag attachments — rules don't apply to anything."
  fi
}
