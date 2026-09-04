# lib/perms.sh — map a project_kind (or explicit stack list) to a starter
# permissions allowlist for .claude/settings.local.json.
#
# The principle: "customize the set of allowed tools so you're not prompted every
# time." Greenfield lets us seed this from the CHOSEN stack before code exists.
#
# Exports:
#   run_perms [project_kind] — emit JSON {allow:[...], deny:[...], ask:[]}
#
# The deny list encodes the "block dangerous commands" guidance.

_perms_base_allow() {
  printf '%s\n' 'Bash(git status)' 'Bash(git diff)' 'Bash(git diff --staged)' 'Bash(git log --oneline -20)'
}

_perms_for_kind() {
  # Stack detection is not authorization to execute project code or install packages.
  # Keep the argument for compatibility; the agent proposes reviewed commands separately.
  :
}

_perms_deny() {
  # Illustrative deny list — real permission-matcher prefix rules only, not a
  # complete guard against destructive commands. Neither these patterns nor an
  # unverified hook substitute for the host sandbox and reviewed authorization.
  cat <<'EOF'
Bash(git push --force:*)
Bash(git push -f:*)
EOF
}

_perms_ask() {
  # Prefix rules broad enough to want a confirmation, not an outright block.
  cat <<'EOF'
Bash(rm -rf:*)
EOF
}

_perms_lines_to_json_array() {
  local lines=() l
  while IFS= read -r l; do
    [[ -z "$l" ]] && continue
    lines+=("$l")
  done
  if [[ ${#lines[@]} -eq 0 ]]; then printf '[]'; return; fi
  printf '%s\n' "${lines[@]}" | jq -R . | jq -s 'unique'
}

run_perms() {
  local kind="${1:-unknown}"
  local allow_json deny_json ask_json
  allow_json="$( { _perms_base_allow; _perms_for_kind "$kind"; } | _perms_lines_to_json_array)"
  deny_json="$(_perms_deny | _perms_lines_to_json_array)"
  ask_json="$(_perms_ask | _perms_lines_to_json_array)"
  jq -n \
    --argjson allow "$allow_json" \
    --argjson deny "$deny_json" \
    --argjson ask "$ask_json" \
    '{ permissions: { allow: $allow, deny: $deny, ask: $ask } }'
}
