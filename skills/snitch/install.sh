#!/bin/sh
# Snitch Installer
# Installs the Snitch retail payload into supported AI coding tools.

set -e

AUTO_YES=false
NO_ANSI=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    --no-ansi) NO_ANSI=true ;;
    *)
      printf 'Unknown option: %s\n' "$arg" >&2
      printf 'Usage: ./install.sh [--yes|-y] [--no-ansi]\n' >&2
      exit 1
      ;;
  esac
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
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$dest/snitch-security.config.md"
  fi
}

copy_skill_dir() {
  dest="$1"
  mkdir -p "$dest"
  cp "$SKILL_FILE" "$dest/snitch-audit.md"
  [ -d "$dest/categories" ] && rm -rf "$dest/categories"
  cp -r "$CATEGORIES_DIR" "$dest/categories"
  copy_extras "$dest"
}

copy_manual_dir() {
  dest="$1"
  mkdir -p "$dest"
  cp "$SKILL_FILE" "$dest/SKILL.md"
  [ -d "$dest/categories" ] && rm -rf "$dest/categories"
  cp -r "$CATEGORIES_DIR" "$dest/categories"
  copy_extras "$dest"
}

append_skill_to_file() {
  target="$1"
  if [ -f "$target" ] && grep -qE "snitch\.live|snitchplugin\.com" "$target" 2>/dev/null; then
    printf 'already_installed'
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  if [ -f "$target" ]; then
    printf '\n\n' >> "$target"
  fi
  cat "$SKILL_FILE" >> "$target"
  target_dir="$(dirname "$target")"
  [ -d "$target_dir/categories" ] && rm -rf "$target_dir/categories"
  cp -r "$CATEGORIES_DIR" "$target_dir/categories"
  copy_extras "$target_dir"
  printf 'installed'
}

detect_tool() {
  case "$1" in
    claude_code)
      if has_cmd claude; then printf 'binary'
      elif has_dir "$HOME/.claude"; then printf '~/.claude/'
      fi
      ;;
    gemini)
      if has_cmd gemini; then printf 'binary'
      elif has_dir "$HOME/.gemini"; then printf '~/.gemini/'
      fi
      ;;
    codex)
      if has_cmd codex; then printf 'binary'
      elif has_dir "$HOME/.codex"; then printf '~/.codex/'
      fi
      ;;
    cursor)
      if [ -d "/Applications/Cursor.app" ]; then printf 'app'
      elif has_cmd cursor; then printf 'binary'
      fi
      ;;
    windsurf)
      if [ -d "/Applications/Windsurf.app" ]; then printf 'app'
      elif has_cmd windsurf; then printf 'binary'
      fi
      ;;
    cline)
      if has_vscode_ext "saoudrizwan.claude-dev"; then printf 'vscode ext'; fi
      ;;
    roo)
      if has_dir "$HOME/.roo"; then printf '~/.roo/'
      elif has_vscode_ext "rooveterinaryinc.roo-cline"; then printf 'vscode ext'
      fi
      ;;
    copilot)
      if has_vscode_ext "GitHub.copilot"; then printf 'vscode ext'; fi
      ;;
    aider)
      if has_cmd aider; then printf 'binary'; fi
      ;;
    continue)
      if has_dir "$HOME/.continue"; then printf '~/.continue/'
      elif has_vscode_ext "Continue.continue"; then printf 'vscode ext'
      fi
      ;;
    kilo)
      if has_vscode_ext "kilocode.kilo-code"; then printf 'vscode ext'; fi
      ;;
    zed)
      if [ -d "/Applications/Zed.app" ]; then printf 'app'
      elif has_cmd zed; then printf 'binary'
      fi
      ;;
    opencode)
      if has_cmd opencode; then printf 'binary'
      elif has_dir "$HOME/.config/opencode"; then printf '~/.config/opencode/'
      fi
      ;;
    antigravity)
      if has_cmd antigravity; then printf 'binary'
      elif [ -d "/Applications/Antigravity.app" ]; then printf 'app'
      fi
      ;;
  esac
}

tfield() { printf '%s' "$1" | cut -d'|' -f"$2"; }

NTOOL=14
T1="Claude Code|claude_code|global"
T2="Gemini CLI|gemini|global"
T3="Codex CLI|codex|perrun"
T4="Cursor|cursor|project"
T5="Windsurf|windsurf|project"
T6="Cline|cline|project"
T7="Roo Code|roo|project"
T8="GitHub Copilot|copilot|project"
T9="Aider|aider|perrun"
T10="Continue.dev|continue|project"
T11="Kilo Code|kilo|project"
T12="Zed|zed|project"
T13="OpenCode|opencode|global"
T14="Antigravity|antigravity|project"

header

section "[1/4] Detecting tools"
detected_count=0
i=1
while [ "$i" -le "$NTOOL" ]; do
  eval "entry=\$T$i"
  name=$(tfield "$entry" 1)
  key=$(tfield "$entry" 2)
  result=$(detect_tool "$key")
  if [ -n "$result" ]; then
    detected_count=$((detected_count + 1))
    eval "SEL_$i=1"
    eval "DET_$i=\$result"
    print_detected "$name" "$result"
  else
    eval "SEL_$i=0"
    eval "DET_$i="
    print_missing "$name"
  fi
  i=$((i + 1))
done

if [ "$detected_count" -eq 0 ]; then
  section "[2/4] Installed"
  printf '    %sNo supported tools were detected.%s\n' "$YELLOW" "$RESET"
  printf '    Inspect the payload here: %s%s%s\n' "$WHITE" "$SCRIPT_DIR" "$RESET"
  printf '\n'
  exit 0
fi

PICK_N=0
i=1
while [ "$i" -le "$NTOOL" ]; do
  eval "selected=\$SEL_$i"
  if [ "$selected" = "1" ]; then
    PICK_N=$((PICK_N + 1))
    eval "PICK_$PICK_N=$i"
  fi
  i=$((i + 1))
done

section "[2/4] Choose install targets"
if [ "$AUTO_YES" = "true" ]; then
  printf '    %sInstalling all %s detected target(s).%s\n' "$GREEN" "$PICK_N" "$RESET"
else
  printf '    [a] all detected\n'
  printf '    [c] custom path only\n'
  pi=1
  while [ "$pi" -le "$PICK_N" ]; do
    eval "tidx=\$PICK_$pi"
    eval "entry=\$T$tidx"
    name=$(tfield "$entry" 1)
    eval "result=\$DET_$tidx"
    printf '    [%s] %s (%s)\n' "$pi" "$name" "$result"
    pi=$((pi + 1))
  done
  printf '\n'
  read_tty "    choice [a]: "
  pick="$TTY_REPLY"
  case "$pick" in
    ''|a|A) ;;
    c|C)
      i=1
      while [ "$i" -le "$NTOOL" ]; do
        eval "SEL_$i=0"
        i=$((i + 1))
      done
      ;;
    n|N|q|Q)
      printf '\n'
      exit 0
      ;;
    [0-9]|[0-9][0-9])
      eval "chosen=\$PICK_$pick"
      if [ -n "$chosen" ]; then
        i=1
        while [ "$i" -le "$NTOOL" ]; do
          eval "SEL_$i=0"
          i=$((i + 1))
        done
        eval "SEL_$chosen=1"
      else
        printf '\n    %sInvalid choice. Pick a number from the list above, or "a" for all.%s\n' "$RED" "$RESET" >&2
        exit 1
      fi
      ;;
    *)
      printf '\n    %sInvalid choice. Pick a number from the list above, or "a" for all.%s\n' "$RED" "$RESET" >&2
      exit 1
      ;;
  esac
fi

DETECTED=''
DETECTED_PROJECT=''
i=1
while [ "$i" -le "$NTOOL" ]; do
  eval "selected=\$SEL_$i"
  if [ "$selected" = "1" ]; then
    eval "entry=\$T$i"
    key=$(tfield "$entry" 2)
    kind=$(tfield "$entry" 3)
    case "$kind" in
      global|perrun) DETECTED="$DETECTED $key" ;;
      project) DETECTED_PROJECT="$DETECTED_PROJECT $key" ;;
    esac
  fi
  i=$((i + 1))
done

PROJECT_DIR=''
if [ -n "$(printf '%s' "$DETECTED_PROJECT" | tr -d ' ')" ]; then
  printf '\n    Project-level targets need a project path.\n'
  if [ "$AUTO_YES" != "true" ]; then
    read_tty "    path (Enter to skip): "
    PROJECT_DIR=$(expand_user_path "$TTY_REPLY")
  fi

  if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
    printf '    %sSkipping project-level targets: path not found.%s\n' "$YELLOW" "$RESET"
    PROJECT_DIR=''
  fi
fi

section "[3/4] Installing"
installed_count=0
already_count=0
manual_count=0
skipped_count=0

for tool in $DETECTED; do
  case "$tool" in
    claude_code)
      dest="$HOME/.claude/skills/snitch"
      print_action "Claude Code" "copying payload to ~/.claude/skills/snitch/"
      mkdir -p "$dest"
      cp "$SKILL_FILE" "$dest/SKILL.md"
      [ -d "$dest/categories" ] && rm -rf "$dest/categories"
      cp -r "$CATEGORIES_DIR" "$dest/categories"
      copy_extras "$dest"
      installed_count=$((installed_count + 1))
      print_result "$GREEN" "ok" "Claude Code" "~/.claude/skills/snitch/"
      ;;
    gemini)
      print_action "Gemini CLI" "appending instructions in ~/.gemini/instructions.md"
      result=$(append_skill_to_file "$HOME/.gemini/instructions.md")
      if [ "$result" = "already_installed" ]; then
        already_count=$((already_count + 1))
        print_result "$YELLOW" "--" "Gemini CLI" "already in ~/.gemini/instructions.md"
      else
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Gemini CLI" "~/.gemini/instructions.md"
      fi
      ;;
    codex)
      manual_count=$((manual_count + 1))
      print_result "$CYAN" "->" "Codex CLI" "manual setup: codex --instructions $SKILL_FILE"
      ;;
    aider)
      manual_count=$((manual_count + 1))
      print_result "$CYAN" "->" "Aider" "manual setup: aider --read $SKILL_FILE"
      ;;
    opencode)
      dest="$HOME/.config/opencode/commands"
      print_action "OpenCode" "copying payload to ~/.config/opencode/commands/"
      mkdir -p "$dest"
      cp "$SKILL_FILE" "$dest/snitch-audit.md"
      [ -d "$dest/categories" ] && rm -rf "$dest/categories"
      cp -r "$CATEGORIES_DIR" "$dest/categories"
      copy_extras "$dest"
      installed_count=$((installed_count + 1))
      print_result "$GREEN" "ok" "OpenCode" "~/.config/opencode/commands/snitch-audit.md"
      ;;
  esac
done

if [ -n "$PROJECT_DIR" ]; then
  for tool in $DETECTED_PROJECT; do
    case "$tool" in
      cursor)
        print_action "Cursor" "copying payload to $PROJECT_DIR/.cursor/rules/"
        copy_skill_dir "$PROJECT_DIR/.cursor/rules"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Cursor" "$PROJECT_DIR/.cursor/rules/"
        ;;
      windsurf)
        print_action "Windsurf" "appending instructions in $PROJECT_DIR/.windsurfrules"
        result=$(append_skill_to_file "$PROJECT_DIR/.windsurfrules")
        if [ "$result" = "already_installed" ]; then
          already_count=$((already_count + 1))
          print_result "$YELLOW" "--" "Windsurf" "already in .windsurfrules"
        else
          installed_count=$((installed_count + 1))
          print_result "$GREEN" "ok" "Windsurf" ".windsurfrules"
        fi
        ;;
      cline)
        print_action "Cline" "appending instructions in $PROJECT_DIR/.cline/instructions.md"
        result=$(append_skill_to_file "$PROJECT_DIR/.cline/instructions.md")
        if [ "$result" = "already_installed" ]; then
          already_count=$((already_count + 1))
          print_result "$YELLOW" "--" "Cline" "already in .cline/instructions.md"
        else
          installed_count=$((installed_count + 1))
          print_result "$GREEN" "ok" "Cline" ".cline/instructions.md"
        fi
        ;;
      roo)
        print_action "Roo Code" "copying payload to $PROJECT_DIR/.roo/rules/"
        copy_skill_dir "$PROJECT_DIR/.roo/rules"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Roo Code" "$PROJECT_DIR/.roo/rules/"
        ;;
      copilot)
        print_action "GitHub Copilot" "appending instructions in $PROJECT_DIR/.github/copilot-instructions.md"
        result=$(append_skill_to_file "$PROJECT_DIR/.github/copilot-instructions.md")
        if [ "$result" = "already_installed" ]; then
          already_count=$((already_count + 1))
          print_result "$YELLOW" "--" "GitHub Copilot" "already in .github/copilot-instructions.md"
        else
          installed_count=$((installed_count + 1))
          print_result "$GREEN" "ok" "GitHub Copilot" ".github/copilot-instructions.md"
        fi
        ;;
      continue)
        print_action "Continue.dev" "copying payload to $PROJECT_DIR/.continue/"
        copy_skill_dir "$PROJECT_DIR/.continue"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Continue.dev" "$PROJECT_DIR/.continue/"
        ;;
      kilo)
        print_action "Kilo Code" "copying payload to $PROJECT_DIR/.kilocode/rules/"
        copy_skill_dir "$PROJECT_DIR/.kilocode/rules"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Kilo Code" "$PROJECT_DIR/.kilocode/rules/"
        ;;
      zed)
        print_action "Zed" "copying payload to $PROJECT_DIR/.rules/"
        copy_skill_dir "$PROJECT_DIR/.rules"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Zed" "$PROJECT_DIR/.rules/"
        ;;
      antigravity)
        print_action "Antigravity" "copying payload to $PROJECT_DIR/.antigravity/skills/"
        copy_skill_dir "$PROJECT_DIR/.antigravity/skills"
        installed_count=$((installed_count + 1))
        print_result "$GREEN" "ok" "Antigravity" "$PROJECT_DIR/.antigravity/skills/"
        ;;
    esac
  done
elif [ -n "$(printf '%s' "$DETECTED_PROJECT" | tr -d ' ')" ]; then
  skipped_count=$((skipped_count + 1))
  print_result "$YELLOW" "--" "Project targets" "skipped: no project path provided"
fi

if [ "$AUTO_YES" != "true" ]; then
  printf '\n'
  read_tty "    copy payload to another directory? (path or Enter to skip): "
  CUSTOM_DIR=$(expand_user_path "$TTY_REPLY")
  if [ -n "$CUSTOM_DIR" ]; then
    if [ ! -d "$CUSTOM_DIR" ]; then
      read_tty "    create directory? [Y/n]: "
      case "$TTY_REPLY" in
        n|N) CUSTOM_DIR='' ;;
        *) mkdir -p "$CUSTOM_DIR" ;;
      esac
    fi
    if [ -n "$CUSTOM_DIR" ]; then
      print_action "Custom copy" "copying payload to $CUSTOM_DIR/"
      copy_manual_dir "$CUSTOM_DIR"
      installed_count=$((installed_count + 1))
      print_result "$GREEN" "ok" "Custom copy" "$CUSTOM_DIR/"
    fi
  fi
fi

section "[4/4] Installed"
printf '    %sInstalled:%s %s\n' "$DARK" "$RESET" "$installed_count"
printf '    %sAlready present:%s %s\n' "$DARK" "$RESET" "$already_count"
printf '    %sManual setup notes:%s %s\n' "$DARK" "$RESET" "$manual_count"
printf '    %sSkipped:%s %s\n' "$DARK" "$RESET" "$skipped_count"
printf '    %sPayload source:%s %s\n' "$DARK" "$RESET" "$SCRIPT_DIR"
printf '\n'
