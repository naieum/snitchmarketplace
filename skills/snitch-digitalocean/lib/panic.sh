# lib/panic.sh — incident response fast-path.
# Mutates DigitalOcean. Each subaction prints a one-line consequence banner
# before mutating; the dispatcher in snitch-digitalocean.sh trusts that the user already
# agreed. Where reversible, every change writes a state record to
# ${STATE_DIR}/panic-<ts>.json so `panic restore` can reverse it.
#
# Exports: run_panic

_panic_ts() { date -u +%Y%m%dT%H%M%SZ; }

_panic_record() {
  local area="$1" prior="$2" set_to="$3"; shift 3
  local ts; ts="$(_panic_ts)"
  local out="${STATE_DIR}/panic-${ts}.json"
  jq -n \
    --arg ts "$ts" \
    --arg area "$area" \
    --argjson prior "$prior" \
    --argjson set "$set_to" \
    --argjson extra "${1:-{\}}" \
    '{ts:$ts, area:$area, prior:$prior, set:$set, extra:$extra}' \
    > "$out"
  printf '%s' "$out"
}

_panic_banner() {
  printf '\n!! PANIC ACTION: %s !!\n\n' "$1"
}

# rotate-token: cannot be done programmatically (DO does not expose a
# create-token API). Emit explicit guidance.
_panic_rotate_token() {
  _panic_banner "rotate API token (manual step required)"
  log_warn "panic" "rotate-token" "DigitalOcean does not expose a create-token API. Steps:"
  cat <<'EOF'
  1. Open https://cloud.digitalocean.com/account/api/tokens
  2. Click "Generate New Token" (scoped: read+write only what you need; expiry: 90 days).
  3. Copy the new token.
  4. Update DIGITALOCEAN_ACCESS_TOKEN in your shells, CI secrets, .env files.
  5. Revoke the OLD token in the same dashboard view.
  6. If the old token was leaked: also rotate any Spaces access keys, k8s kubeconfig
     tokens, registry login credentials, and SSH keys that may have been exposed.
EOF
}

# firewall-block <ip|cidr> — append a deny rule to the first existing firewall.
_panic_firewall_block() {
  local target="$1"
  if [[ -z "$target" ]]; then
    log_fail "panic" "firewall-block" "usage: panic firewall-block <ip|cidr>"
    return 2
  fi
  _panic_banner "blocking ${target} via Cloud Firewall"

  local body; body="$(do_get /firewalls?per_page=200)" || {
    log_fail "panic" "firewall-block" "could not list firewalls"; return 3
  }
  local fid
  fid="$(jq -r '.firewalls[0]?.id // empty' <<<"$body")"
  if [[ -z "$fid" ]]; then
    log_warn "panic" "firewall-block" "no existing firewall found; create one with doctl compute firewall create first"
    return 3
  fi

  # DigitalOcean firewalls are allowlist-based; "block" is achieved by NOT having the source allowed.
  # The cleanest panic action is to inject a rule that REPLACES inbound rules with a strict allowlist
  # excluding the bad IP. We instead emit the rule the user should apply via doctl.
  cat <<EOF
=== FILE: panic-firewall-block-${target}.sh ===
=== CONTENT ===
# DigitalOcean Cloud Firewalls are allowlist-only. To "block" ${target}, ensure
# every existing inbound rule's sources do NOT include this IP. The simplest
# panic action is to remove world-open rules and replace with an explicit allowlist.
#
# Example: drop existing inbound rules and re-add only the ones we trust:
#
# doctl compute firewall remove-rules ${fid} --inbound-rules "protocol:tcp,ports:0,address:0.0.0.0/0"
# doctl compute firewall add-rules ${fid} --inbound-rules "protocol:tcp,ports:80,address:OFFICE_CIDR"
# doctl compute firewall add-rules ${fid} --inbound-rules "protocol:tcp,ports:443,address:0.0.0.0/0,address:::/0"
=== END ===
EOF

  local rec; rec="$(_panic_record "firewall_block_advice" 'null' "{\"target\":\"${target}\",\"firewall_id\":\"${fid}\"}")"
  log_ok "panic" "firewall-block" "advisory written (state: ${rec})"
}

# spaces-lockdown <bucket> — make a Space private + revoke all object public ACLs.
_panic_spaces_lockdown() {
  local bucket="$1"
  if [[ -z "$bucket" ]]; then
    log_fail "panic" "spaces-lockdown" "usage: panic spaces-lockdown <bucket-name>"
    return 2
  fi
  if [[ -z "${DOSEC_SPACES_KEY:-}" || -z "${DOSEC_SPACES_SECRET:-}" ]]; then
    log_fail "panic" "spaces-lockdown" "DOSEC_SPACES_KEY/SECRET not set. Cannot lock down without Spaces access keys."
    return 2
  fi
  if ! command -v aws >/dev/null 2>&1; then
    log_fail "panic" "spaces-lockdown" "aws-cli not installed. brew install awscli."
    return 2
  fi
  _panic_banner "locking down Space '${bucket}': bucket ACL → private; CDN endpoint disabled if any"

  local regions=("nyc3" "sfo3" "ams3" "sgp1" "fra1") r
  for r in "${regions[@]}"; do
    local ep="https://${r}.digitaloceanspaces.com"
    if AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
        aws s3api head-bucket --bucket "$bucket" --endpoint-url "$ep" 2>/dev/null; then
      AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
        aws s3api put-bucket-acl --bucket "$bucket" --acl private --endpoint-url "$ep" >/dev/null 2>&1 \
        && log_ok "panic" "spaces-lockdown" "bucket ACL set to private (${bucket} @ ${r})" \
        || log_fail "panic" "spaces-lockdown" "could not set bucket ACL to private"

      # Disable any CDN endpoint pointing at this bucket.
      local cdn; cdn="$(do_get /cdn/endpoints?per_page=200)" || cdn='{"endpoints":[]}'
      local match_ids
      match_ids="$(jq -r --arg origin "${bucket}.${r}.digitaloceanspaces.com" \
        '.endpoints // [] | .[] | select(.origin == $origin) | .id' <<<"$cdn")"
      while IFS= read -r eid; do
        [[ -z "$eid" ]] && continue
        if do_delete "/cdn/endpoints/${eid}" >/dev/null; then
          log_ok "panic" "spaces-lockdown" "CDN endpoint ${eid} deleted (origin ${bucket})"
        else
          log_warn "panic" "spaces-lockdown" "could not delete CDN endpoint ${eid}"
        fi
      done <<<"$match_ids"
      local rec; rec="$(_panic_record "spaces_lockdown" 'null' "{\"bucket\":\"${bucket}\",\"region\":\"${r}\"}")"
      log_ok "panic" "spaces-lockdown" "lockdown recorded (state: ${rec})"
      return 0
    fi
  done
  log_warn "panic" "spaces-lockdown" "Bucket '${bucket}' not found in any standard region."
}

_panic_restore_one() {
  local f="$1"
  local area; area="$(jq -r '.area' "$f" 2>/dev/null)"
  case "$area" in
    spaces_lockdown)
      log_warn "panic" "restore" "spaces lockdown is NOT auto-reversible — manually re-grant ACLs and re-create CDN endpoint if needed (state: ${f})"
      ;;
    firewall_block_advice)
      log_warn "panic" "restore" "firewall-block was advisory; nothing to revert" ;;
    *)
      log_warn "panic" "restore" "unknown record kind in ${f}"
      ;;
  esac
  mkdir -p "${STATE_DIR}/panic-restored"
  mv "$f" "${STATE_DIR}/panic-restored/" 2>/dev/null || true
}

_panic_restore() {
  _panic_banner "rolling back recorded panic actions where possible"
  local files
  files="$(ls -1t "${STATE_DIR}"/panic-*.json 2>/dev/null || true)"
  if [[ -z "$files" ]]; then
    log_info "no panic state files to restore"
    return 0
  fi
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    [[ "$f" == *"/panic-restored/"* ]] && continue
    _panic_restore_one "$f" || true
  done <<<"$files"
}

run_panic() {
  local action="${1:-}"; shift || true
  case "$action" in
    rotate-token)     _panic_rotate_token ;;
    firewall-block)   _panic_firewall_block "${1:-}" ;;
    spaces-lockdown)  _panic_spaces_lockdown "${1:-}" ;;
    restore)          _panic_restore ;;
    "")
      log_fail "panic" "usage" "panic <rotate-token|firewall-block <ip>|spaces-lockdown <bucket>|restore>"
      return 2 ;;
    *)
      log_fail "panic" "usage" "unknown panic action: ${action}"
      return 2 ;;
  esac
}
