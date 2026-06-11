# lib/audit_delegated.sh — delegation pointers for MCP-backed audit lenses.
# Exports: run_audit_delegated <lens> [args...]
#   lens ∈ casb | dex | builds | browser | observability
#
# These lenses have no usable curl path (casb/dex/builds) or strongly prefer the
# MCP (browser/observability). The bash side computes no findings; it emits a
# small JSON pointer telling the agent which MCP recipe to run, plus an
# availability signal from the CFSEC_MCP_<LENS> env flag. When the flag is unset
# the doc carries locked:"mcp-absent" + an install hint, so `audit all` can render
# a clean N/A row instead of silently dropping the surface.

run_audit_delegated() {
  local lens="${1:-}"; shift || true
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local present=false recipe="" reference="" hint="" requires=""

  case "$lens" in
    casb)
      [[ -n "${CFSEC_MCP_CASB:-}" ]] && present=true
      recipe="references/32-mcp-surfaces.md#casb"
      reference="references/36-device-posture-casb.md"
      requires="Enterprise Zero Trust (CASB)"
      hint="install the Cloudflare CASB MCP (tools: mcp__cloudflare-casb__*), then export CFSEC_MCP_CASB=1" ;;
    dex)
      [[ -n "${CFSEC_MCP_DEX:-}" ]] && present=true
      recipe="references/32-mcp-surfaces.md#dex"
      reference="references/36-device-posture-casb.md"
      requires="Zero Trust / WARP (DEX)"
      hint="install the Cloudflare DEX MCP (tools: mcp__cloudflare-dex__*), then export CFSEC_MCP_DEX=1" ;;
    builds)
      [[ -n "${CFSEC_MCP_BUILDS:-}" ]] && present=true
      recipe="references/32-mcp-surfaces.md#builds"
      reference="references/35-cicd-builds-security.md"
      requires="Workers Builds (connected repo)"
      hint="install the Workers Builds MCP (tools: mcp__cloudflare-builds__*), then export CFSEC_MCP_BUILDS=1" ;;
    browser)
      [[ -n "${CFSEC_MCP_BROWSER:-}" ]] && present=true
      recipe="references/32-mcp-surfaces.md#browser"
      reference="references/16-page-shield-supply-chain.md"
      requires="none (curl header fallback via 'score')"
      hint="install the Browser Rendering MCP (tools: mcp__cloudflare-browser__*), then export CFSEC_MCP_BROWSER=1; without it, fall back to 'score' header checks" ;;
    observability)
      [[ -n "${CFSEC_MCP_OBSERVABILITY:-}" ]] && present=true
      recipe="references/32-mcp-surfaces.md#observability"
      reference="references/33-logging-observability.md"
      requires="Workers Logs / Observability enabled"
      hint="install the Observability MCP (tools: mcp__cloudflare-observability__*), then export CFSEC_MCP_OBSERVABILITY=1; without it, fall back to GraphQL workersInvocationsAdaptive counts" ;;
    *)
      printf '{"error":"unknown delegated lens","code":"E_USAGE","got":"%s","valid":["casb","dex","builds","browser","observability"]}\n' "$lens" >&2
      return 2 ;;
  esac

  local locked='null'
  [[ "$present" != "true" ]] && locked='"mcp-absent"'

  jq -n \
    --arg ts "$ts" --arg lens "$lens" \
    --argjson present "$present" --argjson locked "$locked" \
    --arg recipe "$recipe" --arg reference "$reference" \
    --arg requires "$requires" --arg hint "$hint" \
    '{ schema: "cfsec.audit-delegated", schema_version: 1, generated_at: $ts,
       tool: ("audit-" + $lens), lens: $lens, mode: "mcp",
       mcp_present: $present, locked: $locked, requires: $requires,
       recipe: $recipe, reference: $reference, install_hint: $hint }'
}
