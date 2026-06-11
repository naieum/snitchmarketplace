# lib/plan.sh — feature gating by Azure SKU / plan / license.
# Azure features are gated by:
#   - Defender for Cloud plan (Free vs Standard) per workload
#   - Service SKU (App Service Basic vs Premium, Front Door Standard vs Premium, etc.)
#   - Entra license (Free / P1 / P2)
#   - Sentinel commitment tier
# We don't always know the user's license tier from `az` alone; some checks
# may need to log_warn rather than log_locked when license is unknown.

# detect_subscription_offer — echoes the offer (Free / PayG / EA / CSP / Enterprise / Sponsorship).
# Caches in ${STATE_DIR}/offer.txt.
detect_subscription_offer() {
  local cache="${STATE_DIR}/offer.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body
  body="$(az_run_json account show 2>/dev/null)" || { printf 'unknown' > "$cache"; printf 'unknown'; return 0; }
  local offer
  offer="$(jq -r '.subscriptionPolicies.quotaId // .quotaId // "unknown"' <<<"$body" 2>/dev/null)"
  printf '%s' "$offer" > "$cache"
  printf '%s' "$offer"
}

# detect_defender_plan <workload>
# Workloads: VirtualMachines, AppServices, StorageAccounts, SqlServers, KubernetesService,
# ContainerRegistry, KeyVaults, Dns, Arm, OpenSourceRelationalDatabases, CosmosDbs.
# Echoes 'Standard' or 'Free' or 'unknown'. Caches per-workload.
detect_defender_plan() {
  local workload="$1"
  local cache="${STATE_DIR}/defender-${workload}.txt"
  if [[ -f "$cache" && -n "$(cat "$cache" 2>/dev/null)" ]]; then
    cat "$cache"
    return 0
  fi
  local body
  body="$(az_run_json security pricing show -n "$workload" 2>/dev/null)" || { printf 'unknown' > "$cache"; printf 'unknown'; return 0; }
  local tier
  tier="$(jq -r '.pricingTier // "unknown"' <<<"$body" 2>/dev/null)"
  printf '%s' "$tier" > "$cache"
  printf '%s' "$tier"
}

# tier_at_least <required>
# Required tier values:
#   defender-standard   - Defender for Cloud Standard plan, per workload
#   entra-p1, entra-p2  - Entra license tier (license tier may not be detectable)
#   sentinel            - Microsoft Sentinel
#   appservice-premium  - App Service Premium SKU
#   frontdoor-premium   - Front Door Premium tier
#   appgw-waf-v2        - Application Gateway WAF v2 SKU
#   keyvault-premium    - Key Vault Premium SKU (HSM-backed keys)
# This function ALWAYS returns 0 by default — Azure plan-detection is
# resource-specific. The caller passes a workload-specific check separately.
# The convention is that requires_tier wraps this with a log_locked.
tier_at_least() {
  return 0
}

# requires_tier <area> <key> <message> <required_tier> <docs_url>
# Default behavior: log_locked + return 1 (caller skips the gated check).
# Override with AZSEC_FORCE_PAID=1 to bypass (e.g. for testing).
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  if [[ -n "${AZSEC_FORCE_PAID:-}" ]]; then
    return 0
  fi
  case "$req" in
    defender-standard)
      # Try to look up Defender plan for the implied workload (caller passes via key prefix).
      local workload="${key%%/*}"
      case "$workload" in
        vm|virtual-machine) workload="VirtualMachines" ;;
        appservice)         workload="AppServices" ;;
        storage)            workload="StorageAccounts" ;;
        sql)                workload="SqlServers" ;;
        aks|kubernetes)     workload="KubernetesService" ;;
        acr|registry)       workload="ContainerRegistry" ;;
        keyvault)           workload="KeyVaults" ;;
        dns)                workload="Dns" ;;
        arm|resource-manager) workload="Arm" ;;
        cosmos)             workload="CosmosDbs" ;;
        postgres|mysql)     workload="OpenSourceRelationalDatabases" ;;
        *)                  workload="" ;;
      esac
      if [[ -n "$workload" ]]; then
        local tier; tier="$(detect_defender_plan "$workload")"
        if [[ "$tier" == "Standard" ]]; then
          return 0
        fi
      fi
      log_locked "$area" "$key" "$msg" "$req" "$url"
      return 1
      ;;
    *)
      # All other tiers we cannot reliably detect from az alone — emit locked.
      log_locked "$area" "$key" "$msg" "$req" "$url"
      return 1
      ;;
  esac
}
