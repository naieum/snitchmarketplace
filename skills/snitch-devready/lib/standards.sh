# lib/standards.sh — enforcement-surface detection for snitch-devready.
# Answers: what coding standards does this repo DEFINE, and which of them are
# actually GATED (a tool that fails the build/edit/commit when violated)?
# A standard the repo doesn't gate is advice; the agent uses this JSON to build
# the enforcement-coverage table and the two-tier CLAUDE.md standards section.
#
# Exports:
#   run_standards — entrypoint. Emits one JSON document on stdout. Read-only.

_std_pkg_has() {
  local pattern="$1"
  if [[ -f "package.json" ]] && grep -E -q "$pattern" package.json 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

_std_pyproject_has() {
  local pattern="$1"
  if [[ -f "pyproject.toml" ]] && grep -E -q "$pattern" pyproject.toml 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

_std_json_arr() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local s="" i
  for i in "$@"; do
    [[ -n "$s" ]] && s+=","
    s+="\"${i//\"/\\\"}\""
  done
  printf '[%s]' "$s"
}

_std_linters() {
  local out=()
  { compgen -G ".eslintrc*" >/dev/null 2>&1 || compgen -G "eslint.config.*" >/dev/null 2>&1; } && out+=("eslint")
  compgen -G "biome.json*" >/dev/null 2>&1 && out+=("biome")
  [[ -f "ruff.toml" || -f ".ruff.toml" || "$(_std_pyproject_has '\[tool\.ruff')" == "1" ]] && out+=("ruff")
  [[ -f ".flake8" ]] && out+=("flake8")
  [[ -f ".pylintrc" ]] && out+=("pylint")
  { [[ -f ".golangci.yml" || -f ".golangci.yaml" ]]; } && out+=("golangci-lint")
  [[ -f "Cargo.toml" ]] && out+=("clippy")
  [[ -f ".rubocop.yml" ]] && out+=("rubocop")
  { [[ -f ".php-cs-fixer.php" || -f ".php-cs-fixer.dist.php" ]]; } && out+=("php-cs-fixer")
  { [[ -f "phpstan.neon" || -f "phpstan.neon.dist" ]]; } && out+=("phpstan")
  [[ -f ".swiftlint.yml" ]] && out+=("swiftlint")
  [[ -f "checkstyle.xml" || -f "config/checkstyle/checkstyle.xml" ]] && out+=("checkstyle")
  compgen -G ".stylelintrc*" >/dev/null 2>&1 && out+=("stylelint")
  _std_json_arr "${out[@]+"${out[@]}"}"
}

_std_formatters() {
  local out=()
  { compgen -G ".prettierrc*" >/dev/null 2>&1 || compgen -G "prettier.config.*" >/dev/null 2>&1 \
    || [[ "$(_std_pkg_has '"prettier"')" == "1" ]]; } && out+=("prettier")
  compgen -G "biome.json*" >/dev/null 2>&1 && out+=("biome")
  [[ "$(_std_pyproject_has '\[tool\.black')" == "1" ]] && out+=("black")
  [[ "$(_std_pyproject_has '\[tool\.ruff\.format')" == "1" ]] && out+=("ruff-format")
  [[ -f "rustfmt.toml" || -f ".rustfmt.toml" ]] && out+=("rustfmt")
  [[ -f "go.mod" ]] && out+=("gofmt")
  [[ -f ".editorconfig" ]] && out+=("editorconfig")
  _std_json_arr "${out[@]+"${out[@]}"}"
}

_std_typecheck() {
  local out=()
  [[ -f "tsconfig.json" ]] && out+=("tsc")
  { [[ -f "mypy.ini" || "$(_std_pyproject_has '\[tool\.mypy')" == "1" ]]; } && out+=("mypy")
  [[ -f "pyrightconfig.json" || "$(_std_pyproject_has '\[tool\.pyright')" == "1" ]] && out+=("pyright")
  _std_json_arr "${out[@]+"${out[@]}"}"
}

_std_tests() {
  local out=()
  compgen -G "jest.config.*" >/dev/null 2>&1 && out+=("jest")
  compgen -G "vitest.config.*" >/dev/null 2>&1 && out+=("vitest")
  compgen -G "playwright.config.*" >/dev/null 2>&1 && out+=("playwright")
  { [[ -f "pytest.ini" || "$(_std_pyproject_has '\[tool\.pytest')" == "1" ]]; } && out+=("pytest")
  [[ -f ".rspec" ]] && out+=("rspec")
  { [[ -f "phpunit.xml" || -f "phpunit.xml.dist" ]]; } && out+=("phpunit")
  [[ -f "go.mod" ]] && out+=("go-test")
  [[ -f "Cargo.toml" ]] && out+=("cargo-test")
  if [[ ${#out[@]} -eq 0 && "$(_std_pkg_has '"test":')" == "1" ]]; then out+=("npm-test-script"); fi
  _std_json_arr "${out[@]+"${out[@]}"}"
}

run_standards() {
  local linters formatters typecheck tests
  linters="$(_std_linters)"
  formatters="$(_std_formatters)"
  typecheck="$(_std_typecheck)"
  tests="$(_std_tests)"

  local husky="false"; [[ -d ".husky" ]] && husky="true"
  local lintstaged="false"
  { compgen -G ".lintstagedrc*" >/dev/null 2>&1 || [[ "$(_std_pkg_has '"lint-staged"')" == "1" ]]; } && lintstaged="true"
  local precommit="false"; [[ -f ".pre-commit-config.yaml" ]] && precommit="true"
  local lefthook="false"; { [[ -f "lefthook.yml" || -f "lefthook.yaml" ]]; } && lefthook="true"

  local ci_files=()
  if [[ -d ".github/workflows" ]]; then
    while IFS= read -r f; do ci_files+=("$f"); done \
      < <(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null)
  fi
  [[ -f ".gitlab-ci.yml" ]] && ci_files+=(".gitlab-ci.yml")
  [[ -f ".circleci/config.yml" ]] && ci_files+=(".circleci/config.yml")
  local ci_json; ci_json="$(_std_json_arr "${ci_files[@]+"${ci_files[@]}"}")"

  local claude_hooks="false"
  for f in .claude/settings.json .claude/settings.local.json; do
    [[ -f "$f" ]] && grep -q '"hooks"' "$f" 2>/dev/null && claude_hooks="true"
  done

  # Gaps: a defined-but-ungated standard, or an undefined layer. The agent
  # decides severity; this list just names the missing layers mechanically.
  local gaps=()
  [[ "$linters" == "[]" ]] && gaps+=("no-linter-config")
  [[ "$formatters" == "[]" ]] && gaps+=("no-formatter-config")
  [[ "$tests" == "[]" ]] && gaps+=("no-test-runner-detected")
  if [[ "$husky" == "false" && "$precommit" == "false" && "$lefthook" == "false" && "$lintstaged" == "false" ]]; then
    gaps+=("no-commit-gate")
  fi
  [[ "$ci_json" == "[]" ]] && gaps+=("no-ci-config")
  [[ "$claude_hooks" == "false" ]] && gaps+=("no-claude-code-hooks")
  local gaps_json; gaps_json="$(_std_json_arr "${gaps[@]+"${gaps[@]}"}")"

  jq -n \
    --argjson linters "$linters" \
    --argjson formatters "$formatters" \
    --argjson typecheck "$typecheck" \
    --argjson tests "$tests" \
    --argjson husky "$husky" \
    --argjson lintstaged "$lintstaged" \
    --argjson precommit "$precommit" \
    --argjson lefthook "$lefthook" \
    --argjson ci "$ci_json" \
    --argjson claude_hooks "$claude_hooks" \
    --argjson gaps "$gaps_json" \
    '{
      schema: "snitch-devready.standards",
      schema_version: 1,
      defined: {
        linters: $linters,
        formatters: $formatters,
        typecheck: $typecheck,
        tests: $tests
      },
      gates: {
        commit: { husky: $husky, lint_staged: $lintstaged, pre_commit: $precommit, lefthook: $lefthook },
        ci: $ci,
        claude_code_hooks: $claude_hooks
      },
      gaps: $gaps
    }'
}
