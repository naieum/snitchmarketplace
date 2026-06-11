# lib/apply_tags.sh — required-tag policy guidance.

apply_tags() {
  local sub_id; sub_id="$(az_pick_subscription)" || return 3
  local resources; resources="$(az_run_json resource list --subscription "$sub_id" --query 'length(@)' 2>/dev/null || printf '0')"
  local untagged; untagged="$(az_run_json resource list --subscription "$sub_id" --query "length([?tags==null || keys(tags) == \`[]\`])" 2>/dev/null || printf '0')"
  if [[ "${untagged:-0}" -gt 0 ]]; then
    log_warn "tags" "coverage" "${untagged}/${resources} resources have no tags. Apply a built-in 'Require a tag and its value' initiative — see ${TPL_DIR}/azure-policy-builtin-pack.starter.json."
  else
    log_ok "tags" "coverage" "all ${resources} resources tagged."
  fi
}
