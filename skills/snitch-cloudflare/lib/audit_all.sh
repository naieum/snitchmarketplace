# lib/audit_all.sh — master "toes-to-top" audit envelope (read-only).
# Exports: run_audit_all
#
# Thin orchestrator: resolves account+zone once, runs the five curl audit lenses,
# attaches the five MCP delegation pointers, and lists the existing tools the
# agent should also run per render section. It does NOT render markdown and does
# NOT run the slow `score` (SSL Labs) inline — the agent composes the final graded
# report from this envelope + `compose_also`, per references/30-recipes.md.
#
# Requires the lens libs to be sourced first (dispatch_audit 'all' does this).

run_audit_all() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    printf '{"error":"missing CLOUDFLARE_API_TOKEN","code":"E_AUTH","remediation":"export a scoped token from https://dash.cloudflare.com/profile/api-tokens"}\n' >&2
    return 2
  fi

  # Resolve ids once. api_pick_* can print warnings to stdout on ambiguity, so we
  # call them here (not inside captured lenses) and pass ids down explicitly.
  local account_id zone_id
  account_id="$(api_pick_account 2>/dev/null)" || account_id=""
  zone_id="$(api_pick_zone 2>/dev/null)" || zone_id=""

  local lenses='[]'
  # _aa_add <order> <lens> <scope-id> <runner> [args...]
  # scope-id "" → emit a synthetic resolve-error doc rather than letting the lens
  # re-resolve (which could print to stdout and corrupt the captured JSON).
  _aa_add() {
    local order="$1" lens="$2" scope_id="$3"; shift 3
    local doc rc status
    if [[ -z "$scope_id" ]]; then
      doc="$(jq -n --arg l "$lens" '{error:"unresolved scope id", code:"E_SCOPE", lens:$l}')"
      status="error"
    else
      doc="$("$@" "$scope_id" 2>/dev/null)"; rc=$?
      jq -e . <<<"$doc" >/dev/null 2>&1 || doc='{"error":"non-json output","code":"E_INTERNAL"}'
      if [[ "${rc:-1}" -eq 0 ]]; then
        if [[ "$(jq -r '.locked // "null"' <<<"$doc" 2>/dev/null)" != "null" ]]; then status="locked"; else status="ok"; fi
      else
        status="error"
      fi
    fi
    lenses="$(jq -n --argjson arr "$lenses" --argjson order "$order" \
                    --arg lens "$lens" --arg status "$status" --argjson doc "$doc" \
                    '$arr + [{order:$order, lens:$lens, status:$status, doc:$doc}]')"
  }

  # toes→top execution order across the new curl lenses.
  _aa_add 1 secevents   "$zone_id"    run_audit_secevents
  _aa_add 2 dns         "$zone_id"    run_audit_dns
  _aa_add 3 ai-gateway  "$account_id" run_audit_ai_gateway
  _aa_add 4 logpush     "$account_id" run_audit_logpush
  _aa_add 5 auditlog    "$account_id" run_audit_auditlog

  # MCP delegation pointers (no scope id needed).
  local delegated='[]' l doc
  for l in browser builds observability dex casb; do
    doc="$(run_audit_delegated "$l" 2>/dev/null)"
    jq -e . <<<"$doc" >/dev/null 2>&1 || doc="$(jq -n --arg l "$l" '{lens:$l, error:"delegation failed"}')"
    delegated="$(jq -n --argjson arr "$delegated" --argjson doc "$doc" '$arr + [$doc]')"
  done

  jq -n \
    --arg ts "$ts" \
    --arg account_id "$account_id" --arg zone_id "$zone_id" \
    --argjson lenses "$lenses" --argjson delegated "$delegated" \
    '{
      schema: "cfsec.audit-all", schema_version: 1, generated_at: $ts,
      tool: "audit-all",
      account_id: (if $account_id=="" then null else $account_id end),
      zone_id: (if $zone_id=="" then null else $zone_id end),
      render_order: [
        "edge/external","zone-dns-tls-waf","origin","workers/builds","storage",
        "ai","zero-trust","casb","logging/observability","account"
      ],
      lenses: $lenses,
      delegated: $delegated,
      compose_also: [
        {section:"edge/external", tool:"score [hosts]", why:"SSL Labs + MDN Observatory + local header grade + HSTS preload (slow; run separately)"},
        {section:"edge/external", tool:"audit browser [hosts]", why:"rendered DOM/CSP + 3rd-party origins (browser MCP; falls back to score)"},
        {section:"edge/external", tool:"analytics zone", why:"traffic/threat totals, top countries/ASNs/paths"},
        {section:"zone-dns-tls-waf", tool:"state zone", why:"SSL/TLS, HSTS, DNSSEC, WAF rulesets, firewall (digest)"},
        {section:"origin", tool:"state zone (origin fields)", why:"origin exposure / AOP / allowlist posture"},
        {section:"workers/builds", tool:"Developer Platform MCP workers_*", why:"Workers/Pages inventory + code"},
        {section:"storage", tool:"Developer Platform MCP d1/kv/r2/hyperdrive", why:"storage inventory + access scoping"},
        {section:"ai", tool:"fix ai (or lib ai_security)", why:"source-side AI surface checks complementing audit ai-gateway"},
        {section:"zero-trust", tool:"state tunnels / state access", why:"Tunnel + Access posture (DEX adds device posture)"},
        {section:"account", tool:"state account", why:"members/2FA, tokens, notifications, audit-log digest"}
      ],
      note: "Render per references/30-recipes.md#full-stack-audit. lenses[].status ok|locked|error; locked & mcp-absent render as ⚪️ N/A rows (do not penalize free/pro for absent Enterprise features). Run compose_also tools to fill the remaining sections."
    }'
}
