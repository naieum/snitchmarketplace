# lib/apply_kubernetes.sh — DOKS hardening.
# Idempotent: confirms autoscaler, surge upgrade, registry integration.
# Recommends NetworkPolicy template (does NOT apply — kubectl is the user's job).
#
# Exports: apply_kubernetes [args]

apply_kubernetes() {
  local body; body="$(do_get /kubernetes/clusters?per_page=200)" || {
    log_fail "kubernetes" "list" "Could not list clusters. $(do_last_error)"
    return 3
  }
  local total; total="$(jq -r '.kubernetes_clusters // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_ok "kubernetes" "list" "No DOKS clusters."
    return 0
  fi

  local cluster_ids; cluster_ids="$(jq -r '.kubernetes_clusters[]? | .id' <<<"$body")"
  while IFS= read -r cid; do
    [[ -z "$cid" ]] && continue
    _apply_doks_one "$cid" "$body"
  done <<<"$cluster_ids"
}

_apply_doks_one() {
  local cid="$1" body="$2"
  local c; c="$(jq -c --arg id "$cid" '.kubernetes_clusters[] | select(.id == $id)' <<<"$body")"
  local name; name="$(jq -r '.name' <<<"$c")"

  # Auto-upgrade
  local au; au="$(jq -r '.auto_upgrade // false' <<<"$c")"
  if [[ "$au" == "true" ]]; then
    log_ok "kubernetes" "auto-upgrade/${name}" "auto_upgrade enabled."
  else
    log_warn "kubernetes" "auto-upgrade/${name}" "auto_upgrade disabled. Enable to receive minor patch upgrades during the maintenance window." "https://docs.digitalocean.com/products/kubernetes/how-to/upgrade-cluster/"
  fi

  # Surge upgrade
  local su; su="$(jq -r '.surge_upgrade // false' <<<"$c")"
  if [[ "$su" == "true" ]]; then
    log_ok "kubernetes" "surge-upgrade/${name}" "surge_upgrade enabled."
  else
    log_warn "kubernetes" "surge-upgrade/${name}" "surge_upgrade disabled. Enable to keep capacity during upgrades."
  fi

  # HA control plane
  local ha; ha="$(jq -r '.ha // false' <<<"$c")"
  if [[ "$ha" == "true" ]]; then
    log_ok "kubernetes" "ha/${name}" "HA control plane enabled."
  else
    log_warn "kubernetes" "ha/${name}" "HA control plane disabled (\$40/mo extra). For production, enable it."
  fi

  # Autoscaler at node-pool level
  local pools_no_autoscale
  pools_no_autoscale="$(jq -r '[(.node_pools // [])[] | select(.auto_scale != true) | .name] | join(", ")' <<<"$c")"
  if [[ -n "$pools_no_autoscale" ]]; then
    log_warn "kubernetes" "autoscaler/${name}" "Node pools without auto_scale: ${pools_no_autoscale}."
  else
    log_ok "kubernetes" "autoscaler/${name}" "All node pools auto-scale."
  fi

  # Registry integration
  local reg_int; reg_int="$(jq -r '.registry_enabled // false' <<<"$c")"
  if [[ "$reg_int" == "true" ]]; then
    log_ok "kubernetes" "registry/${name}" "Registry integration enabled."
  else
    log_warn "kubernetes" "registry/${name}" "Container Registry not integrated. Enable for pull-secret-free deploys."
  fi

  # NetworkPolicy is cluster-internal — recommend the template.
  log_info "Apply NetworkPolicy + PodSecurity admission template from templates/doks-network-policy.yaml.tpl on ${name} (kubectl required)."
}
