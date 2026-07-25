#!/bin/sh
# Snitch Installer
# Installs the Snitch retail payload into supported AI coding tools.

set -e

AUTO_YES=false
NO_ANSI=false
PROJECT_ARG=''

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) AUTO_YES=true ;;
    --no-ansi) NO_ANSI=true ;;
    --project) shift; PROJECT_ARG="$1" ;;
    --project=*) PROJECT_ARG="${1#--project=}" ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      printf 'Usage: ./install.sh [--yes|-y] [--no-ansi] [--project <path>]\n' >&2
      exit 1
      ;;
  esac
  shift
done

if [ -t 1 ] && [ "$NO_ANSI" != "true" ]; then
  BOLD="$(printf '\033[1m')"
  DIM="$(printf '\033[2m')"
  WHITE="$(printf '\033[38;5;255m')"
  GRAY="$(printf '\033[38;5;242m')"
  DARK="$(printf '\033[38;5;237m')"
  GREEN="$(printf '\033[38;5;114m')"
  RED="$(printf '\033[38;5;204m')"
  YELLOW="$(printf '\033[38;5;222m')"
  CYAN="$(printf '\033[38;5;117m')"
  ACCENT="$(printf '\033[38;5;75m')"
  RESET="$(printf '\033[0m')"
else
  BOLD=''
  DIM=''
  WHITE=''
  GRAY=''
  DARK=''
  GREEN=''
  RED=''
  YELLOW=''
  CYAN=''
  ACCENT=''
  RESET=''
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/SKILL.md"
CATEGORIES_DIR="$SCRIPT_DIR/categories"
REFS_DIR="$SCRIPT_DIR/references"
COMPLIANCE_DIR="$SCRIPT_DIR/compliance-templates"
CUSTOM_RULES_DIR="$SCRIPT_DIR/custom-rules"
HOOKS_DIR="$SCRIPT_DIR/hooks"
CONFIG_FILE="$SCRIPT_DIR/snitch-security.config.md"

[ -f "$SKILL_FILE" ] || {
  printf '\n%serror:%s SKILL.md not found in %s\n\n' "$RED" "$RESET" "$SCRIPT_DIR" >&2
  exit 1
}
[ -d "$CATEGORIES_DIR" ] || {
  printf '\n%serror:%s categories/ not found in %s\n\n' "$RED" "$RESET" "$SCRIPT_DIR" >&2
  exit 1
}

# Active-category count, sourced from the manifest (single source of truth) so
# it never drifts from what the skill actually scans. The raw *.md file count
# would over-report: it includes _index.md and merged-redirect stubs.
CAT_COUNT=$(sed -n 's/.*Active categories:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$CATEGORIES_DIR/_index.md" 2>/dev/null | head -1)
[ -n "$CAT_COUNT" ] || CAT_COUNT=$(find "$CATEGORIES_DIR" -maxdepth 1 -name '[0-9]*-*.md' 2>/dev/null | wc -l | tr -d ' ')

has_cmd() { command -v "$1" >/dev/null 2>&1; }
has_dir() { [ -d "$1" ]; }

has_vscode_ext() {
  for cli in code codium; do
    if has_cmd "$cli" && "$cli" --list-extensions 2>/dev/null | grep -qi "$1"; then
      return 0
    fi
  done
  return 1
}

hr() {
  printf '  %s------------------------------------------------------------%s\n' "$DARK" "$RESET"
}

header() {
  printf '\n'
  hr
  printf '  %s%sSnitch Installer%s\n' "$BOLD" "$WHITE" "$RESET"
  printf '  %sInstall Snitch into supported AI coding tools%s\n' "$GRAY" "$RESET"
  printf '  %sPayload:%s SKILL.md + %s%s%s categories' "$DARK" "$RESET" "$WHITE" "$CAT_COUNT" "$RESET"
  if [ -d "$REFS_DIR" ] || [ -d "$COMPLIANCE_DIR" ] || [ -d "$CUSTOM_RULES_DIR" ] || [ -f "$CONFIG_FILE" ]; then
    printf ' + extras'
  fi
  printf '\n'
  printf '  %ssnitchplugin.com%s\n' "$ACCENT" "$RESET"
  hr
}

section() {
  printf '\n  %s%s%s\n' "$BOLD" "$1" "$RESET"
}

print_detected() {
  printf '    %s%s%s %-17s %s%s%s\n' "$GREEN" "yes" "$RESET" "$1" "$GRAY" "$2" "$RESET"
}

print_missing() {
  printf '    %s%s%s %-17s\n' "$DARK" "no " "$RESET" "$1"
}

print_result() {
  printf '    %s%s%s %-17s %s%s%s\n' "$1" "$2" "$RESET" "$3" "$GRAY" "$4" "$RESET"
}

print_action() {
  printf '    %s..%s %-17s %s%s%s\n' "$CYAN" "$RESET" "$1" "$GRAY" "$2" "$RESET"
}

read_tty() {
  prompt="$1"
  printf '%s' "$prompt" >&2
  TTY_REPLY=""
  if [ -c /dev/tty ]; then
    read -r TTY_REPLY </dev/tty 2>/dev/null || true
  elif [ -t 0 ]; then
    read -r TTY_REPLY || true
  fi
  # Strip control chars, whitespace, carriage returns
  TTY_REPLY=$(printf '%s' "$TTY_REPLY" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
}

expand_user_path() {
  case "$1" in
    "~/"*) printf '%s/%s' "$HOME" "${1#\~/}" ;;
    "~") printf '%s' "$HOME" ;;
    *) printf '%s' "$1" ;;
  esac
}

copy_extras() {
  dest="$1"
  if [ -d "$REFS_DIR" ]; then
    [ -d "$dest/references" ] && rm -rf "$dest/references"
    cp -r "$REFS_DIR" "$dest/references"
  fi
  if [ -d "$COMPLIANCE_DIR" ]; then
    [ -d "$dest/compliance-templates" ] && rm -rf "$dest/compliance-templates"
    cp -r "$COMPLIANCE_DIR" "$dest/compliance-templates"
  fi
  if [ -d "$CUSTOM_RULES_DIR" ]; then
    [ -d "$dest/custom-rules" ] && rm -rf "$dest/custom-rules"
    cp -r "$CUSTOM_RULES_DIR" "$dest/custom-rules"
  fi
  if [ -d "$HOOKS_DIR" ]; then
    [ -d "$dest/hooks" ] && rm -rf "$dest/hooks"
    cp -r "$HOOKS_DIR" "$dest/hooks"
    chmod +x "$dest/hooks/"*.sh 2>/dev/null || true
  fi
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$dest/snitch-security.config.md"
  fi
}


# Skill directory name, taken from the SKILL.md frontmatter so it can never drift
# from the skill's declared identity.
SKILL_SLUG=$(sed -n 's/^name:[[:space:]]*\([A-Za-z0-9_-]*\).*/\1/p' "$SKILL_FILE" 2>/dev/null | head -1)
[ -n "$SKILL_SLUG" ] || SKILL_SLUG=$(basename "$SCRIPT_DIR")

# Agent registry: Name|global skills dir|detection dir|detection binary
# Paths follow the open agent-skills convention (<agent>/skills/<skill-name>/).
# Regenerate from the ecosystem's published agent table when new agents appear.
AGENTS=$(cat <<'AGENTS_EOF'
AdaL|~/.adal/skills|~/.adal|
AiderDesk|~/.aider-desk/skills|~/.aider-desk|aider
Amp|~/.config/agents/skills|~/.config/agents|amp
Antigravity|~/.gemini/antigravity/skills|~/.gemini/antigravity|
Antigravity CLI|~/.gemini/antigravity-cli/skills|~/.gemini/antigravity-cli|
AstrBot|~/.astrbot/data/skills|~/.astrbot|
Augment|~/.augment/skills|~/.augment|
Autohand Code CLI|~/.autohand/skills|~/.autohand|
Claude Code|~/.claude/skills|~/.claude|claude
Cline|~/.agents/skills|~/.agents|
Code Studio|~/.codestudio/skills|~/.codestudio|
CodeArts Agent|~/.codeartsdoer/skills|~/.codeartsdoer|
CodeBuddy|~/.codebuddy/skills|~/.codebuddy|
Codemaker|~/.codemaker/skills|~/.codemaker|
Codex|~/.codex/skills|~/.codex|codex
Command Code|~/.commandcode/skills|~/.commandcode|
Continue|~/.continue/skills|~/.continue|
Cortex Code|~/.snowflake/cortex/skills|~/.snowflake/cortex|
Crush|~/.config/crush/skills|~/.config/crush|crush
Cursor|~/.cursor/skills|~/.cursor|cursor
Deep Agents|~/.deepagents/agent/skills|~/.deepagents|
Devin for Terminal|~/.config/devin/skills|~/.config/devin|devin
Dexto|~/.agents/skills|~/.agents|
Droid|~/.factory/skills|~/.factory|droid
Firebender|~/.firebender/skills|~/.firebender|
ForgeCode|~/.forge/skills|~/.forge|forge
Gemini CLI|~/.gemini/skills|~/.gemini|gemini
GitHub Copilot|~/.copilot/skills|~/.copilot|
Goose|~/.config/goose/skills|~/.config/goose|goose
Grok Build|~/.grok/skills|~/.grok|grok
Hermes Agent|~/.hermes/skills|~/.hermes|
IBM Bob|~/.bob/skills|~/.bob|
iFlow CLI|~/.iflow/skills|~/.iflow|iflow
inference.sh|~/.inferencesh/skills|~/.inferencesh|
Jazz|~/.jazz/skills|~/.jazz|
Junie|~/.junie/skills|~/.junie|
Kilo Code|~/.kilocode/skills|~/.kilocode|
Kimchi|~/.config/kimchi/harness/skills|~/.config/kimchi|
Kimi Code CLI|~/.agents/skills|~/.agents|
Kiro CLI|~/.kiro/skills|~/.kiro|kiro
Kode|~/.kode/skills|~/.kode|kode
Lingma|~/.lingma/skills|~/.lingma|
Loaf|~/.agents/skills|~/.agents|
MCPJam|~/.mcpjam/skills|~/.mcpjam|
Mistral Vibe|~/.vibe/skills|~/.vibe|
Moxby|~/.moxby/skills|~/.moxby|
Mux|~/.mux/skills|~/.mux|mux
Neovate|~/.neovate/skills|~/.neovate|
Ona|~/.ona/skills|~/.ona|ona
OpenClaw|~/.openclaw/skills|~/.openclaw|
OpenCode|~/.config/opencode/skills|~/.config/opencode|opencode
OpenHands|~/.openhands/skills|~/.openhands|openhands
Pi|~/.pi/agent/skills|~/.pi|pi
Pochi|~/.pochi/skills|~/.pochi|
Qoder|~/.qoder/skills|~/.qoder|
Qoder CN|~/.qoder-cn/skills|~/.qoder-cn|
Qwen Code|~/.qwen/skills|~/.qwen|qwen
Reasonix|~/.reasonix/skills|~/.reasonix|
Replit|~/.config/agents/skills|~/.config/agents|
Roo Code|~/.roo/skills|~/.roo|
Rovo Dev|~/.rovodev/skills|~/.rovodev|
Tabnine CLI|~/.tabnine/agent/skills|~/.tabnine|
Terramind|~/.terramind/skills|~/.terramind|
Tinycloud|~/.tinycloud/skills|~/.tinycloud|
Trae|~/.trae/skills|~/.trae|trae
Trae CN|~/.trae-cn/skills|~/.trae-cn|
Universal|~/.config/agents/skills|~/.config/agents|
Warp|~/.agents/skills|~/.agents|
Windsurf|~/.codeium/windsurf/skills|~/.codeium/windsurf|windsurf
ZCode|~/.zcode/skills|~/.zcode|
Zed|~/.agents/skills|~/.agents|zed
Zencoder|~/.zencoder/skills|~/.zencoder|
Zenflow|~/.zencoder/skills|~/.zencoder|
AGENTS_EOF
)

# Project-level universal path. Read by Cursor, Codex, Copilot, Gemini CLI, Cline,
# Zed, OpenCode, Antigravity and others, so one directory covers many agents.
UNIVERSAL_PROJECT_DIR=".agents/skills"

# Locations earlier versions of this installer wrote to. Never deleted — only
# reported, so an upgrading user knows where a stale copy still sits.
LEGACY_PATHS=".cursor/rules .roo/rules .kilocode/rules .windsurfrules .cline/instructions.md .github/copilot-instructions.md .rules"

install_payload() {
  dest="$1"
  mkdir -p "$dest"
  cp "$SKILL_FILE" "$dest/SKILL.md"
  [ -d "$dest/categories" ] && rm -rf "$dest/categories"
  cp -r "$CATEGORIES_DIR" "$dest/categories"
  copy_extras "$dest"
}

header

# ---------------------------------------------------------------- detect
section "[1/4] Detecting agents"

detected_count=0

TMP_DET=$(mktemp)
printf '%s\n' "$AGENTS" | while IFS='|' read -r name gdir ddir bin; do
  [ -n "$name" ] || continue
  probe=$(expand_user_path "$ddir")
  how=''
  if [ -n "$bin" ] && has_cmd "$bin"; then
    how='binary'
  elif has_dir "$probe"; then
    how="$ddir/"
  fi
  if [ -n "$how" ]; then
    printf '%s|%s|%s\n' "$name" "$gdir" "$how" >> "$TMP_DET"
  fi
done

if [ -s "$TMP_DET" ]; then
  while IFS='|' read -r name gdir how; do
    print_detected "$name" "$how"
  done < "$TMP_DET"
  detected_count=$(wc -l < "$TMP_DET" | tr -d ' ')
else
  printf '    %sNo supported agents detected on this machine.%s\n' "$GRAY" "$RESET"
fi

total_agents=$(printf '%s\n' "$AGENTS" | grep -c '|')
printf '\n    %s%s of %s known agents detected%s\n' "$GRAY" "$detected_count" "$total_agents" "$RESET"

# ---------------------------------------------------------------- project target
section "[2/4] Project-level install (optional)"

printf '    %sOne directory — .agents/skills/ — is read by Cursor, Codex, Copilot,%s\n' "$GRAY" "$RESET"
printf '    %sGemini CLI, Cline, Zed, OpenCode, Antigravity and more.%s\n' "$GRAY" "$RESET"

PROJECT_DIR=''
if [ -n "$PROJECT_ARG" ]; then
  PROJECT_DIR=$(expand_user_path "$PROJECT_ARG")
  if [ ! -d "$PROJECT_DIR" ]; then
    printf '    %sSkipping project install: path not found.%s\n' "$YELLOW" "$RESET"
    PROJECT_DIR=''
  fi
elif [ "$AUTO_YES" != "true" ]; then
  read_tty "    project path (Enter to skip): "
  PROJECT_DIR=$(expand_user_path "$TTY_REPLY")
  if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
    printf '    %sSkipping project install: path not found.%s\n' "$YELLOW" "$RESET"
    PROJECT_DIR=''
  fi
else
  printf '    %sskipped (--yes)%s\n' "$GRAY" "$RESET"
fi

# ---------------------------------------------------------------- install
section "[3/4] Installing"

installed_count=0
already_count=0
TMP_SEEN=$(mktemp)

if [ -s "$TMP_DET" ]; then
  while IFS='|' read -r name gdir how; do
    dest="$(expand_user_path "$gdir")/$SKILL_SLUG"
    # Several agents share one skills directory; install once per destination.
    if grep -Fxq "$dest" "$TMP_SEEN" 2>/dev/null; then
      print_result "$GRAY" "--" "$name" "shares a directory already installed"
      continue
    fi
    printf '%s\n' "$dest" >> "$TMP_SEEN"
    if [ -f "$dest/SKILL.md" ]; then
      print_action "$name" "updating $gdir/$SKILL_SLUG/"
      already_count=$((already_count + 1))
    else
      print_action "$name" "installing to $gdir/$SKILL_SLUG/"
      installed_count=$((installed_count + 1))
    fi
    install_payload "$dest"
    print_result "$GREEN" "ok" "$name" "$gdir/$SKILL_SLUG/"
  done < "$TMP_DET"
fi

if [ -n "$PROJECT_DIR" ]; then
  pdest="$PROJECT_DIR/$UNIVERSAL_PROJECT_DIR/$SKILL_SLUG"
  print_action "Project" "installing to $UNIVERSAL_PROJECT_DIR/$SKILL_SLUG/"
  install_payload "$pdest"
  print_result "$GREEN" "ok" "Project" "$UNIVERSAL_PROJECT_DIR/$SKILL_SLUG/"
  installed_count=$((installed_count + 1))
fi

if [ "$installed_count" -eq 0 ] && [ "$already_count" -eq 0 ]; then
  printf '    %snothing installed%s\n' "$GRAY" "$RESET"
fi

# ---------------------------------------------------------------- legacy check
if [ -n "$PROJECT_DIR" ]; then
  legacy_found=''
  for lp in $LEGACY_PATHS; do
    if [ -e "$PROJECT_DIR/$lp" ]; then
      legacy_found="$legacy_found $lp"
    fi
  done
  if [ -n "$legacy_found" ]; then
    printf '\n    %sEarlier versions installed into rules files. These still exist and may%s\n' "$YELLOW" "$RESET"
    printf '    %shold a stale copy of the skill — review and remove them yourself:%s\n' "$YELLOW" "$RESET"
    for lp in $legacy_found; do
      printf '      %s%s%s\n' "$GRAY" "$lp" "$RESET"
    done
  fi
fi

# ---------------------------------------------------------------- summary
section "[4/4] Installed"

printf '    %s%s%s agent director%s written  %s(%s new, %s updated)%s\n' \
  "$WHITE" "$((installed_count + already_count))" "$RESET" \
  "$([ $((installed_count + already_count)) -eq 1 ] && echo 'y' || echo 'ies')" \
  "$GRAY" "$installed_count" "$already_count" "$RESET"
printf '    %sPayload:%s SKILL.md + %s categories + references\n' "$DARK" "$RESET" "$CAT_COUNT"
printf '\n    %sAsk your agent for a security audit to start a scan.%s\n' "$GRAY" "$RESET"
printf '    %ssnitchplugin.com%s\n\n' "$ACCENT" "$RESET"

rm -f "$TMP_DET" "$TMP_SEEN"
