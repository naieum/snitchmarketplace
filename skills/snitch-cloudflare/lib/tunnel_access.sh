# lib/tunnel_access.sh — Cloudflare Tunnel + Access walkthroughs.
# Exposes:
#   apply_tunnel_access <area>   — area is one of: tunnel | access.
# Side effects:
#   - tunnel: lists existing tunnels, then prints (does not run) the cloudflared
#     install + create + DNS-route commands tailored to account id + a domain.
#   - access: lists existing Access apps, prints the API call body for protecting
#     the user's first app with an email-allowlist policy.
# This lib never executes cloudflared (not on PATH inside the skill harness).

# _tunnel_walkthrough <account_id>
_tunnel_walkthrough() {
  local account_id="$1"
  local body
  body="$(cf_get "/accounts/${account_id}/cfd_tunnel?per_page=50")" || {
    log_warn "tunnel" "list" "Could not list tunnels (token scope 'Cloudflare Tunnel: Read' may be missing)."
  }
  if [[ -n "${body:-}" ]]; then
    local n
    n="$(jq -r '.result | length' <<<"$body" 2>/dev/null)"
    if [[ "${n:-0}" -gt 0 ]]; then
      log_ok "tunnel" "list" "${n} existing tunnel(s):"
      jq -r '.result[] | "  - \(.id)  \(.name)  status=\(.status // "?")"' <<<"$body" >&2
    else
      log_warn "tunnel" "list" "No tunnels yet for this account." "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/"
    fi
  fi

  printf '\n=== TUNNEL WALKTHROUGH ===\n'
  printf 'These commands run on the origin host (where your app listens). Replace <hostname> and <port> with your values.\n\n'
  printf '# 1. Install cloudflared (macOS):\n'
  printf '   brew install cloudflared\n'
  printf '# 1. Install cloudflared (Linux .deb):\n'
  printf '   curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb && sudo dpkg -i cloudflared.deb\n\n'
  printf '# 2. Authenticate cloudflared with this account:\n'
  printf '   cloudflared tunnel login\n\n'
  printf '# 3. Create the tunnel:\n'
  printf '   cloudflared tunnel create <tunnel-name>\n\n'
  printf '# 4. Route a hostname through it (replace <hostname> with the FQDN you want public):\n'
  printf '   cloudflared tunnel route dns <tunnel-name> <hostname>\n\n'
  printf '# 5. Run the tunnel locally (point it at your origin port):\n'
  printf '   cloudflared tunnel run --url http://localhost:<port> <tunnel-name>\n\n'
  printf '# 6. (Optional) install as a system service so it auto-starts:\n'
  printf '   sudo cloudflared service install\n'
  printf 'After the route resolves, your origin no longer needs a public IP — block inbound 80/443 at the origin firewall.\n'
  printf 'Account scope: %s\n' "$account_id"
  printf 'Docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/\n'
  printf '=== END ===\n'
}

# _access_walkthrough <account_id>
_access_walkthrough() {
  local account_id="$1"
  local body
  body="$(cf_get "/accounts/${account_id}/access/apps?per_page=50")" || {
    log_warn "access" "list" "Could not list Access apps (token scope 'Access: Apps and Policies: Read' may be missing)."
    return 0
  }
  local n
  n="$(jq -r '.result | length' <<<"$body" 2>/dev/null)"
  if [[ "${n:-0}" -gt 0 ]]; then
    log_ok "access" "list" "${n} existing Access app(s):"
    jq -r '.result[] | "  - \(.id)  \(.name)  domain=\(.domain // "?")"' <<<"$body" >&2
  else
    log_warn "access" "list" "No Access apps yet for this account." "https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/"
  fi

  printf '\n=== ACCESS WALKTHROUGH ===\n'
  printf 'Recipe: protect a staging / preview URL with an email-allowlist policy.\n\n'
  printf '1. Pick the URL to protect (e.g., staging.example.com or preview-*.example.com).\n'
  printf '2. POST the following to /accounts/%s/access/apps to create the app:\n\n' "$account_id"
  cat <<'EOF'
   {
     "name": "staging (snitch-cloudflare)",
     "domain": "staging.example.com",
     "type": "self_hosted",
     "session_duration": "24h",
     "auto_redirect_to_identity": false,
     "tags": ["snitch-cloudflare"]
   }
EOF
  printf '\n3. Capture the returned app id, then POST a policy to /accounts/%s/access/apps/<app-id>/policies:\n\n' "$account_id"
  cat <<'EOF'
   {
     "name": "allowlist (snitch-cloudflare)",
     "decision": "allow",
     "include": [
       {"email": {"email": "you@example.com"}},
       {"email_domain": {"domain": "example.com"}}
     ]
   }
EOF
  printf '\n4. Visit the protected URL to confirm Access challenges before passthrough.\n'
  printf 'Docs: https://developers.cloudflare.com/cloudflare-one/policies/access/\n'
  printf '=== END ===\n'
}

# apply_tunnel_access <area>
apply_tunnel_access() {
  local area="${1:-}"
  local account_id
  account_id="$(api_pick_account)" || {
    log_fail "${area:-tunnel-access}" "pick" "No account selected."
    return 3
  }
  case "$area" in
    tunnel) _tunnel_walkthrough "$account_id" ;;
    access) _access_walkthrough "$account_id" ;;
    *)
      log_fail "tunnel-access" "area" "Unknown apply_tunnel_access area: '${area}'. Valid: tunnel|access."
      return 2
      ;;
  esac
}
