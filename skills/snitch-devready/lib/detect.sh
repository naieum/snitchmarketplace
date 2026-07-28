# lib/detect.sh — single-call cwd JSON for snitch-devready.
# Classifies the working dir as greenfield | thin-greenfield | brownfield and
# surfaces the signals the agent needs to assemble context (stacks, package
# managers, UI?, spec files, git history depth, existing Claude artifacts).
#
# Exports:
#   run_detect — entrypoint. Emits one JSON document on stdout.
#
# Classification thresholds (documented so behaviour is predictable):
#   THIN_MAX_CODE_FILES = 12   # a fresh scaffold has a handful of files
# Rules:
#   greenfield      : code_files == 0 AND no recognized framework
#   thin-greenfield : (framework OR manifest present) AND code_files <= THIN_MAX
#                     AND git_commits <= 1
#   brownfield      : otherwise (real code, or >1 commit of history)

THIN_MAX_CODE_FILES=12

# --- JSON helpers -----------------------------------------------------------
_det_to_json_array() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local s="" i
  for i in "$@"; do
    [[ -n "$s" ]] && s+=","
    s+="\"${i//\"/\\\"}\""
  done
  printf '[%s]' "$s"
}

_det_dedupe_to_json() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local seen="" out=() i
  for i in "$@"; do
    case " $seen " in *" $i "*) continue ;; esac
    seen+=" $i"; out+=("$i")
  done
  _det_to_json_array "${out[@]+"${out[@]}"}"
}

_det_pkg_has() {
  local pattern="$1"
  if [[ -f "package.json" ]] && grep -E -q "$pattern" package.json 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

# --- signal collectors ------------------------------------------------------

# Count real source files, excluding dependency/build/vcs/scaffold dirs.
_det_code_file_count() {
  find . -maxdepth 6 \
    \( -name node_modules -o -name .git -o -name .claude -o -name dist \
       -o -name build -o -name .next -o -name .nuxt -o -name .svelte-kit \
       -o -name .astro -o -name out -o -name target -o -name vendor \
       -o -name __pycache__ -o -name .venv -o -name venv -o -name coverage \
       -o -name .cache \) -prune \
    -o -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
       -o -name '*.mjs' -o -name '*.cjs' -o -name '*.vue' -o -name '*.svelte' \
       -o -name '*.py' -o -name '*.rb' -o -name '*.go' -o -name '*.rs' \
       -o -name '*.java' -o -name '*.kt' -o -name '*.php' -o -name '*.swift' \
       -o -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \
       -o -name '*.hpp' -o -name '*.cs' \) -print 2>/dev/null \
    | grep -c . || printf '0'
}

_det_stacks() {
  local out=()
  compgen -G "next.config.*"   >/dev/null 2>&1 && out+=("nextjs")
  compgen -G "astro.config.*"  >/dev/null 2>&1 && out+=("astro")
  compgen -G "svelte.config.*" >/dev/null 2>&1 && out+=("sveltekit")
  compgen -G "remix.config.*"  >/dev/null 2>&1 && out+=("remix")
  compgen -G "nuxt.config.*"   >/dev/null 2>&1 && out+=("nuxt")
  [[ -f "vite.config.js" || -f "vite.config.ts" ]] && out+=("vite")
  compgen -G "gatsby-config.*" >/dev/null 2>&1 && out+=("gatsby")
  [[ -f "wp-config.php" ]] && out+=("wordpress")
  [[ -f "artisan" ]] && out+=("laravel")
  [[ -f "Gemfile" && -f "config/routes.rb" ]] && out+=("rails")
  [[ -f "manage.py" ]] && out+=("django")
  compgen -G "*.csproj" >/dev/null 2>&1 && out+=("dotnet")
  [[ -f "go.mod" ]] && out+=("go")
  [[ -f "Cargo.toml" ]] && out+=("rust")
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"@?nestjs')" == "1" ]] && out+=("nestjs")
    [[ "$(_det_pkg_has '"fastify"')" == "1" ]] && out+=("fastify")
    [[ "$(_det_pkg_has '"express"')" == "1" ]] && out+=("express")
    [[ "$(_det_pkg_has '"hono"')"    == "1" ]] && out+=("hono")
  fi
  if [[ ${#out[@]} -eq 0 && -f "index.html" ]]; then out+=("static"); fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

# Is this a UI/web project (→ wire a screenshot feedback loop)?
_det_ui() {
  compgen -G "next.config.*"   >/dev/null 2>&1 && { printf 'true'; return; }
  compgen -G "astro.config.*"  >/dev/null 2>&1 && { printf 'true'; return; }
  compgen -G "svelte.config.*" >/dev/null 2>&1 && { printf 'true'; return; }
  compgen -G "remix.config.*"  >/dev/null 2>&1 && { printf 'true'; return; }
  compgen -G "nuxt.config.*"   >/dev/null 2>&1 && { printf 'true'; return; }
  compgen -G "gatsby-config.*" >/dev/null 2>&1 && { printf 'true'; return; }
  [[ -f "vite.config.js" || -f "vite.config.ts" || -f "index.html" ]] && { printf 'true'; return; }
  [[ "$(_det_pkg_has '"(react|react-dom|vue|svelte|solid-js|@angular/core|preact)"')" == "1" ]] && { printf 'true'; return; }
  printf 'false'
}

_det_spec_files() {
  local out=() f
  for f in SPEC.md SPEC.markdown DESIGN.md ARCHITECTURE.md README.md README.markdown \
           docs/SPEC.md docs/DESIGN.md docs/architecture.md docs/PRD.md; do
    [[ -f "$f" ]] && out+=("$f")
  done
  for f in PRD*.md prd*.md design*.md spec*.md; do
    compgen -G "$f" >/dev/null 2>&1 && while IFS= read -r m; do out+=("$m"); done < <(compgen -G "$f")
  done
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_package_managers() {
  local out=()
  [[ -f "package-lock.json" ]] && out+=("npm")
  [[ -f "yarn.lock" ]] && out+=("yarn")
  [[ -f "pnpm-lock.yaml" ]] && out+=("pnpm")
  [[ -f "bun.lockb" || -f "bun.lock" ]] && out+=("bun")
  [[ -f "composer.lock" ]] && out+=("composer")
  [[ -f "Gemfile.lock" ]] && out+=("bundler")
  [[ -f "Pipfile.lock" || -f "uv.lock" || -f "poetry.lock" ]] && out+=("python")
  [[ -f "go.sum" ]] && out+=("go-modules")
  [[ -f "Cargo.lock" ]] && out+=("cargo")
  # Fall back to manifest presence when no lockfile yet (greenfield).
  if [[ ${#out[@]} -eq 0 ]]; then
    [[ -f "package.json" ]] && out+=("npm")
    [[ -f "Cargo.toml" ]] && out+=("cargo")
    [[ -f "go.mod" ]] && out+=("go-modules")
    { [[ -f "pyproject.toml" || -f "requirements.txt" ]]; } && out+=("python")
    [[ -f "Gemfile" ]] && out+=("bundler")
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_project_kind() {
  if [[ -f "package.json" ]]; then printf 'node'; return; fi
  if [[ -f "Cargo.toml" ]]; then printf 'rust'; return; fi
  if [[ -f "go.mod" ]]; then printf 'go'; return; fi
  if [[ -f "manage.py" || -f "pyproject.toml" || -f "requirements.txt" ]]; then printf 'python'; return; fi
  if [[ -f "Gemfile" ]]; then printf 'ruby'; return; fi
  if [[ -f "composer.json" || -f "wp-config.php" ]]; then printf 'php'; return; fi
  if compgen -G "*.csproj" >/dev/null 2>&1; then printf 'dotnet'; return; fi
  if [[ -f "pom.xml" || -f "build.gradle" ]]; then printf 'jvm'; return; fi
  printf 'unknown'
}

_det_has_manifest() {
  [[ -f "package.json" || -f "Cargo.toml" || -f "go.mod" || -f "pyproject.toml" \
     || -f "requirements.txt" || -f "Gemfile" || -f "composer.json" || -f "pom.xml" \
     || -f "build.gradle" ]] && { printf '1'; return; }
  printf '0'
}

_det_git_commits() {
  if [[ -d .git ]] && command -v git >/dev/null 2>&1; then
    git rev-list --count HEAD 2>/dev/null || printf '0'
  else
    printf '0'
  fi
}

_det_classify() {
  local code_files="$1" stacks_json="$2" has_manifest="$3" git_commits="$4"
  local has_framework="false"
  [[ "$stacks_json" != "[]" && -n "$stacks_json" ]] && has_framework="true"

  if [[ "$code_files" -eq 0 && "$has_framework" == "false" && "$has_manifest" == "0" ]]; then
    printf 'greenfield'; return
  fi
  if [[ "$code_files" -eq 0 && "$has_framework" == "false" && "$has_manifest" == "1" ]]; then
    # bare manifest (npm init / cargo new --bin without code) — still greenfield
    printf 'greenfield'; return
  fi
  if { [[ "$has_framework" == "true" || "$has_manifest" == "1" ]]; } \
     && [[ "$code_files" -le "$THIN_MAX_CODE_FILES" ]] \
     && [[ "$git_commits" -le 1 ]]; then
    printf 'thin-greenfield'; return
  fi
  printf 'brownfield'
}

# --- entrypoint -------------------------------------------------------------
run_detect() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || printf 'unknown')"
  local code_files stacks ui spec_files pms project_kind has_manifest git_commits mode
  code_files="$(_det_code_file_count | tr -d '[:space:]')"
  [[ -z "$code_files" ]] && code_files=0
  stacks="$(_det_stacks)"
  ui="$(_det_ui)"
  spec_files="$(_det_spec_files)"
  pms="$(_det_package_managers)"
  project_kind="$(_det_project_kind)"
  has_manifest="$(_det_has_manifest)"
  git_commits="$(_det_git_commits | tr -d '[:space:]')"
  [[ -z "$git_commits" ]] && git_commits=0
  mode="$(_det_classify "$code_files" "$stacks" "$has_manifest" "$git_commits")"

  local git_present="false"; [[ -d .git ]] && git_present="true"
  local has_claude_md="false"; [[ -f CLAUDE.md ]] && has_claude_md="true"
  local has_settings="false"; [[ -f .claude/settings.local.json || -f .claude/settings.json ]] && has_settings="true"
  local has_mcp="false"; [[ -f .mcp.json ]] && has_mcp="true"
  local has_commands="false"; [[ -d .claude/commands ]] && has_commands="true"

  jq -n \
    --arg ts "$ts" \
    --arg cwd "$(pwd)" \
    --arg mode "$mode" \
    --arg project_kind "$project_kind" \
    --argjson code_files "$code_files" \
    --argjson git_commits "$git_commits" \
    --argjson git_present "$git_present" \
    --argjson ui "$ui" \
    --argjson has_claude_md "$has_claude_md" \
    --argjson has_settings "$has_settings" \
    --argjson has_mcp "$has_mcp" \
    --argjson has_commands "$has_commands" \
    --argjson stacks "$stacks" \
    --argjson spec_files "$spec_files" \
    --argjson package_managers "$pms" \
    '{
      schema: "snitch-devready.detect",
      schema_version: 1,
      generated_at: $ts,
      cwd: $cwd,
      mode: $mode,
      project_kind: $project_kind,
      ui: $ui,
      stacks: $stacks,
      package_managers: $package_managers,
      spec_files: $spec_files,
      code_file_count: $code_files,
      git: { present: $git_present, commits: $git_commits },
      existing_artifacts: {
        claude_md: $has_claude_md,
        settings: $has_settings,
        mcp_json: $has_mcp,
        commands_dir: $has_commands
      }
    }'
}
