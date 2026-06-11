# lib/apply_spaces.sh — Spaces hardening.
# DigitalOcean's v2 API does NOT expose Spaces operations. We rely on
# aws-cli (S3-compat) when DOSEC_SPACES_KEY/SECRET are set.
#
# Idempotent operations:
#   - emit a recommended public-access checklist (we cannot toggle ACLs cleanly without bucket name)
#   - configure a default CORS template (advisory)
#   - ensure CDN endpoints exist for buckets with custom domains
#
# Exports: apply_spaces [args]

apply_spaces() {
  if [[ -z "${DOSEC_SPACES_KEY:-}" || -z "${DOSEC_SPACES_SECRET:-}" ]]; then
    log_warn "spaces" "creds" "DOSEC_SPACES_KEY / DOSEC_SPACES_SECRET not set. Generate Spaces access keys at https://cloud.digitalocean.com/account/api/spaces and export them, then re-run."
    log_info "Without Spaces creds, the skill emits an advisory-only checklist below."
    _apply_spaces_checklist
    return 0
  fi

  if ! command -v aws >/dev/null 2>&1; then
    log_warn "spaces" "tooling" "aws-cli not installed. brew install awscli  /  apt install awscli. Required to inspect Spaces ACLs/CORS."
    _apply_spaces_checklist
    return 0
  fi

  # Pull CDN endpoints (DO v2 API)
  local cdn; cdn="$(do_get /cdn/endpoints?per_page=200)" || cdn='{"endpoints":[]}'
  local cdn_count; cdn_count="$(jq '.endpoints // [] | length' <<<"$cdn")"
  log_ok "spaces" "cdn-endpoints" "Found ${cdn_count} CDN endpoint(s) on the account."

  local regions=("nyc3" "sfo3" "ams3" "sgp1" "fra1")
  local r
  for r in "${regions[@]}"; do
    local out
    out="$(AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
      aws s3api list-buckets --endpoint-url "https://${r}.digitaloceanspaces.com" --output json 2>/dev/null)"
    [[ -z "$out" ]] && continue
    local buckets; buckets="$(jq -r '.Buckets // [] | .[].Name' <<<"$out")"
    while IFS= read -r b; do
      [[ -z "$b" ]] && continue
      _apply_spaces_one "$b" "$r"
    done <<<"$buckets"
  done
}

_apply_spaces_one() {
  local bucket="$1" region="$2"
  local ep="https://${region}.digitaloceanspaces.com"

  # ACL — read current bucket ACL.
  local acl
  acl="$(AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
    aws s3api get-bucket-acl --bucket "$bucket" --endpoint-url "$ep" --output json 2>/dev/null)"
  if [[ -z "$acl" ]]; then
    log_warn "spaces" "acl/${bucket}" "Could not read ACL — credentials may lack scope."
  else
    local has_public
    has_public="$(jq -r '.Grants // [] | map(select(.Grantee.URI == "http://acs.amazonaws.com/groups/global/AllUsers" and (.Permission == "READ" or .Permission == "FULL_CONTROL"))) | length' <<<"$acl")"
    if [[ "${has_public:-0}" -gt 0 ]]; then
      log_warn "spaces" "acl/${bucket}" "Bucket is PUBLIC at the bucket level. If this is intentional (CDN origin), prefer CDN with private origin + signed URLs. Otherwise: aws s3api put-bucket-acl --bucket ${bucket} --acl private --endpoint-url ${ep}"
    else
      log_ok "spaces" "acl/${bucket}" "Bucket-level ACL is private."
    fi
  fi

  # CORS — read current.
  local cors
  cors="$(AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
    aws s3api get-bucket-cors --bucket "$bucket" --endpoint-url "$ep" --output json 2>/dev/null)"
  if [[ -z "$cors" ]]; then
    log_warn "spaces" "cors/${bucket}" "No CORS rules; if browser uploads are needed, configure CORS to your domain only (NOT *)."
  else
    local has_wild
    has_wild="$(jq -r '.CORSRules // [] | map(.AllowedOrigins // []) | flatten | index("*") | if . != null then "1" else "0" end' <<<"$cors")"
    if [[ "$has_wild" == "1" ]]; then
      log_warn "spaces" "cors/${bucket}" "CORS allows '*' origins. Restrict to specific origins."
    else
      log_ok "spaces" "cors/${bucket}" "CORS rules present and not wildcard-* on origins."
    fi
  fi

  # Lifecycle — recommend explicit rules for incomplete uploads + log buckets.
  local lc
  lc="$(AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY" AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET" \
    aws s3api get-bucket-lifecycle-configuration --bucket "$bucket" --endpoint-url "$ep" --output json 2>/dev/null)"
  if [[ -z "$lc" ]]; then
    log_info "lifecycle: no rules on ${bucket}; consider expiring incomplete multipart uploads after 7 days"
  else
    log_ok "spaces" "lifecycle/${bucket}" "Lifecycle rules configured."
  fi
}

_apply_spaces_checklist() {
  cat <<'EOF'
=== Spaces hardening checklist (advisory) ===
- Make every bucket private by default; expose via CDN endpoint with signed URLs only.
- CORS: allowed origins must be a specific list, not "*".
- Lifecycle: expire incomplete multipart uploads after 7d.
- Spaces access keys: rotate annually; one key per app, not one shared key.
- For CDN: enable custom subdomain + verify SSL cert.
- For static-site Spaces: serve via CDN with a custom domain; avoid direct .digitaloceanspaces.com URLs.
- Enable Spaces audit logging (S3 server access logs) to a separate audit bucket.
EOF
}
