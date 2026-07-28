# lib/perms.sh — map a project_kind (or explicit stack list) to a starter
# permissions allowlist for .claude/settings.local.json.
#
# Boris' talk: "customize the set of allowed tools so you're not prompted every
# time." Greenfield lets us seed this from the CHOSEN stack before code exists.
#
# Exports:
#   run_perms [project_kind] — emit JSON {allow:[...], deny:[...], ask:[]}
#
# The deny list encodes Boris' "block dangerous commands" guidance.

_perms_base_allow() {
  cat <<'EOF'
Bash(git status)
Bash(git diff:*)
Bash(git log:*)
Bash(git add:*)
Bash(git commit:*)
Bash(git push:*)
Bash(git checkout:*)
Bash(git branch:*)
Bash(ls:*)
Bash(cat:*)
Bash(rg:*)
Bash(grep:*)
Bash(find:*)
EOF
}

_perms_for_kind() {
  case "$1" in
    node)
      cat <<'EOF'
Bash(npm install)
Bash(npm install:*)
Bash(npm run:*)
Bash(npm test:*)
Bash(npm ci)
Bash(npx:*)
Bash(node:*)
Bash(pnpm:*)
Bash(yarn:*)
Bash(bun:*)
EOF
      ;;
    python)
      cat <<'EOF'
Bash(python:*)
Bash(python3:*)
Bash(pip install:*)
Bash(pytest:*)
Bash(ruff:*)
Bash(uv:*)
Bash(poetry:*)
EOF
      ;;
    rust)
      cat <<'EOF'
Bash(cargo build:*)
Bash(cargo test:*)
Bash(cargo run:*)
Bash(cargo check:*)
Bash(cargo clippy:*)
Bash(cargo fmt:*)
EOF
      ;;
    go)
      cat <<'EOF'
Bash(go build:*)
Bash(go test:*)
Bash(go run:*)
Bash(go vet:*)
Bash(gofmt:*)
EOF
      ;;
    ruby)
      cat <<'EOF'
Bash(bundle install)
Bash(bundle exec:*)
Bash(rake:*)
Bash(rspec:*)
EOF
      ;;
    php)
      cat <<'EOF'
Bash(composer install)
Bash(composer:*)
Bash(php:*)
Bash(./vendor/bin/phpunit:*)
EOF
      ;;
    jvm)
      cat <<'EOF'
Bash(./gradlew:*)
Bash(mvn:*)
Bash(gradle:*)
EOF
      ;;
    dotnet)
      cat <<'EOF'
Bash(dotnet build:*)
Bash(dotnet test:*)
Bash(dotnet run:*)
EOF
      ;;
    *) : ;;
  esac
}

_perms_deny() {
  # Conservative blocklist — destructive / exfiltration-prone commands.
  cat <<'EOF'
Bash(rm -rf /:*)
Bash(git push --force:*)
Bash(git push -f:*)
Bash(curl:* | sh)
Bash(:(){ :|:& };:)
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
  local allow_json deny_json
  allow_json="$( { _perms_base_allow; _perms_for_kind "$kind"; } | _perms_lines_to_json_array)"
  deny_json="$(_perms_deny | _perms_lines_to_json_array)"
  jq -n \
    --argjson allow "$allow_json" \
    --argjson deny "$deny_json" \
    '{ permissions: { allow: $allow, deny: $deny, ask: [] } }'
}
