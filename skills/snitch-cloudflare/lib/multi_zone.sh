# lib/multi_zone.sh — multi-zone batch + multi-account separation audit.
# Exposes:
#   multi_zone_run — read-only. Detects mixed prod/non-prod within an account, emits
#                    separation recommendation + migration sketch + per-zone batch invocations.

# _mz_classify_zone <zone_name> -> echoes prod | nonprod | unknown
_mz_classify_zone() {
  local n
  n="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$n" in
    staging.*|stg.*|*.staging.*|*-staging.*)         printf 'nonprod' ;;
    dev.*|*.dev.*|*-dev.*|develop.*)                 printf 'nonprod' ;;
    qa.*|*.qa.*|*-qa.*|test.*|*.test.*|*-test.*)     printf 'nonprod' ;;
    preview.*|*.preview.*|*-preview.*|pr-*.*)        printf 'nonprod' ;;
    sandbox.*|*.sandbox.*)                           printf 'nonprod' ;;
    *)                                               printf 'prod' ;;
  esac
}

# _mz_emit_migration_sketch
_mz_emit_migration_sketch() {
  cat <<MIG_EOF

Migration sketch (separation of prod / non-prod into different Cloudflare accounts):

  1. Create a new Cloudflare account at https://dash.cloudflare.com/sign-up.
     Use a separate billing email + invoice address so finance can split.

  2. In the new account, add each non-prod zone:
     - Add site -> select Free or Pro plan as appropriate.
     - Cloudflare provides nameservers; update them at the domain registrar.
     - DNS propagation: minutes to 48h.

     Note: there is no API for cross-account zone transfer. You move the zone
     by changing nameservers; nothing else automates this.

  3. After a non-prod zone activates in the new account:
     - Re-create DNS records (export from old account first via cf_get).
     - Re-create Workers / Pages projects (different account = different bindings).
     - Re-issue Cloudflare API tokens, scoped to ONLY the new account.
     - Update CI/CD secrets to use the new tokens.

  4. Once verified, remove the zone from the original (prod) account.

  5. Align IaC: separate Terraform workspaces per account; use distinct
     CLOUDFLARE_API_TOKEN env vars (TF_VAR_cf_token_prod / TF_VAR_cf_token_nonprod).

Why bother: a compromised non-prod token cannot reach production. This is
a meaningful blast-radius reduction — most often relevant at the 10k-100k
user plateau (cross-referenced from \`snitch-cloudflare.sh roadmap\`).
MIG_EOF
}

# _mz_emit_batch_invocations <area> <zone_id...>
_mz_emit_batch_invocations() {
  local area="$1"; shift
  printf '\nBatch invocation across zones (review each before applying):\n\n'
  local zid
  for zid in "$@"; do
    printf '  CFSEC_ZONE_ID=%s bash snitch-cloudflare.sh fix %s\n' "$zid" "$area"
  done
  printf '\n'
}

# multi_zone_run
multi_zone_run() {
  log_section "multi-zone batch + multi-account separation"

  local body
  body="$(cf_get /zones)" || {
    log_warn "multi-zone" "list" "Could not list zones."
    return 0
  }

  local zone_count
  zone_count="$(jq -r '.result | length' <<<"$body" 2>/dev/null || echo 0)"
  if [[ "$zone_count" -le 1 ]]; then
    log_ok "multi-zone" "single-zone" "Token sees ${zone_count} zone(s); multi-zone separation not applicable."
    return 0
  fi

  log_info "${zone_count} zone(s) visible; auditing for mixed prod/non-prod..."

  local prod_zones=() nonprod_zones=()
  local zid zname
  while IFS=$'\t' read -r zid zname; do
    [[ -z "$zid" ]] && continue
    local cls
    cls="$(_mz_classify_zone "$zname")"
    case "$cls" in
      prod)    prod_zones+=("${zid}|${zname}") ;;
      nonprod) nonprod_zones+=("${zid}|${zname}") ;;
    esac
  done < <(jq -r '.result[]? | [.id, .name] | @tsv' <<<"$body" 2>/dev/null)

  log_info "  prod-classified zones: ${#prod_zones[@]}"
  log_info "  non-prod-classified zones: ${#nonprod_zones[@]}"

  if [[ "${#prod_zones[@]}" -gt 0 && "${#nonprod_zones[@]}" -gt 0 ]]; then
    log_warn "multi-zone" "mixed-envs" \
      "Account has both prod (${#prod_zones[@]}) and non-prod (${#nonprod_zones[@]}) zones. Recommended: separate accounts for prod vs non-prod so a compromised non-prod token cannot reach prod." \
      "https://developers.cloudflare.com/fundamentals/account/account-security/"

    log_subsection "non-prod zones (candidates to move)"
    local entry zid zname
    for entry in "${nonprod_zones[@]}"; do
      zid="${entry%%|*}"
      zname="${entry##*|}"
      printf '  - %s  %s\n' "$zid" "$zname"
    done

    _mz_emit_migration_sketch
  else
    log_ok "multi-zone" "envs" "Account does not appear to mix prod with non-prod zones."
  fi

  # Batch helper output: list all zones with the standard fix invocations.
  log_subsection "batch fixes across all zones"
  printf 'To apply the same hardening across multiple zones, set CFSEC_ZONE_ID per zone.\n'
  printf 'Common batches:\n'

  local all_zone_ids=()
  while IFS=$'\t' read -r zid _; do
    [[ -z "$zid" ]] && continue
    all_zone_ids+=("$zid")
  done < <(jq -r '.result[]? | [.id, .name] | @tsv' <<<"$body" 2>/dev/null)

  if [[ "${#all_zone_ids[@]}" -gt 0 ]]; then
    local area
    for area in ssl hsts dnssec waf rules headers; do
      printf '\n  # fix %s on every zone:\n' "$area"
      _mz_emit_batch_invocations "$area" "${all_zone_ids[@]}"
    done
  fi

  log_info "fan-out batch mode is intentionally not automatic — review each zone before applying."
}
