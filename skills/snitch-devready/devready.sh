#!/usr/bin/env bash
# snitch-devready: thin tool surface; the agent (via SKILL.md) orchestrates synthesis.
# Read-only tools emit JSON on stdout. No mutation happens here — the agent shows
# diffs and writes artifacts with Write/Edit so the user sees every change.
#
# Requires: jq. (Optional: git, for commit-depth classification.)

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SKILL_DIR/lib"
REF_DIR="$SKILL_DIR/references"
TPL_DIR="$SKILL_DIR/templates"
export SKILL_DIR LIB_DIR REF_DIR TPL_DIR

usage() {
  cat <<'EOF'
snitch-devready: bootstrap a repo for AI-assisted development. Thin tools; agent
orchestrates. Run `detect` first, then branch on `.mode`.

Read tools (JSON on stdout):
  detect                 classify cwd: greenfield | thin-greenfield | brownfield
                         + stacks, package_managers, ui, spec_files, git depth,
                         existing Claude artifacts
  standards              the repo's enforcement surface: defined standards
                         (linters, formatters, typecheck, tests) vs actual gates
                         (commit hooks, CI, Claude Code hooks) + the gaps
  perms [project_kind]   starter permissions allow/deny for settings.local.json
                         (kinds: node|python|rust|go|ruby|php|jvm|dotnet)
  template <name>        print a bundled template to stdout
                         (names: claude-md | standards-claude-md | settings |
                          settings-hooks | mcp-screenshot |
                          cmd-plan-then-build | cmd-build-feature |
                          cmd-commit-push-pr | cmd-what-did-i-ship | skill-md)

Utility:
  doctor                 check prerequisites (jq, git)
  help

Artifacts are written by the AGENT, not this script — see SKILL.md for the flow.
EOF
}

doctor_run() {
  local jq_ok="false" git_ok="false"
  command -v jq  >/dev/null 2>&1 && jq_ok="true"
  command -v git >/dev/null 2>&1 && git_ok="true"
  if [[ "$jq_ok" == "true" ]]; then
    jq -n --argjson jq "$jq_ok" --argjson git "$git_ok" \
      '{ jq: $jq, git: $git, ok: $jq }'
  else
    printf '{"jq":false,"git":%s,"ok":false,"error":"jq is required; install with: brew install jq"}\n' "$git_ok"
  fi
}

template_run() {
  local name="${1:-}"
  case "$name" in
    claude-md)            cat "$TPL_DIR/CLAUDE.md.tmpl" ;;
    standards-claude-md)  cat "$TPL_DIR/CLAUDE-standards.md.tmpl" ;;
    settings)             cat "$TPL_DIR/settings.local.json.tmpl" ;;
    settings-hooks)       cat "$TPL_DIR/settings.hooks.json.tmpl" ;;
    mcp-screenshot)       cat "$TPL_DIR/mcp.screenshot.json.tmpl" ;;
    cmd-plan-then-build)  cat "$TPL_DIR/commands/plan-then-build.md" ;;
    cmd-build-feature)    cat "$TPL_DIR/commands/build-feature.md" ;;
    cmd-commit-push-pr)   cat "$TPL_DIR/commands/commit-push-pr.md" ;;
    cmd-what-did-i-ship)  cat "$TPL_DIR/commands/what-did-i-ship.md" ;;
    skill-md)             cat "$TPL_DIR/SKILL.md.tmpl" ;;
    "")  printf 'error: template name required (see `help`)\n' >&2; return 2 ;;
    *)   printf 'error: unknown template "%s" (see `help`)\n' "$name" >&2; return 2 ;;
  esac
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    detect)    . "$LIB_DIR/detect.sh";    run_detect "$@" ;;
    standards) . "$LIB_DIR/standards.sh"; run_standards "$@" ;;
    perms)     . "$LIB_DIR/perms.sh";     run_perms "$@" ;;
    template) template_run "$@" ;;
    doctor)   doctor_run ;;
    help|-h|--help) usage ;;
    *) printf 'error: unknown command "%s"\n\n' "$cmd" >&2; usage; return 2 ;;
  esac
}

main "$@"
