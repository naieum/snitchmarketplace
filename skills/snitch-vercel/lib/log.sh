# lib/log.sh — consistent OK / WARN / FAIL / INFO output and structured findings.
# All other lib/*.sh source this. No flags; the format is fixed.
#
# Output rules:
#   - One finding per line, prefixed with the status badge.
#   - Append docs URL when relevant ("→ <url>").
#   - Append plan tier when feature is locked ("[locked: pro+]").
#   - log_section prints a single H2-ish separator.
#   - Stderr is for human chatter; stdout is the report.

VRCSEC_FINDINGS_FILE="${STATE_DIR:-/tmp}/findings.tsv"
: > "$VRCSEC_FINDINGS_FILE" 2>/dev/null || true

_color() {
  if [[ -t 1 ]]; then
    case "$1" in
      green)  printf '\033[32m' ;;
      yellow) printf '\033[33m' ;;
      red)    printf '\033[31m' ;;
      cyan)   printf '\033[36m' ;;
      bold)   printf '\033[1m'  ;;
      reset)  printf '\033[0m'  ;;
    esac
  fi
}

# log_ok   <area> <key> <message> [docs_url]
log_ok() {
  local area="$1" key="$2" msg="$3" url="${4:-}"
  printf '%s[OK]%s   [%s/%s] %s' "$(_color green)" "$(_color reset)" "$area" "$key" "$msg"
  [[ -n "$url" ]] && printf ' → %s' "$url"
  printf '\n'
  printf 'OK\t%s\t%s\t%s\t%s\n' "$area" "$key" "$msg" "$url" >> "$VRCSEC_FINDINGS_FILE" 2>/dev/null || true
}

# log_warn <area> <key> <message> [docs_url]
log_warn() {
  local area="$1" key="$2" msg="$3" url="${4:-}"
  printf '%s[WARN]%s [%s/%s] %s' "$(_color yellow)" "$(_color reset)" "$area" "$key" "$msg"
  [[ -n "$url" ]] && printf ' → %s' "$url"
  printf '\n'
  printf 'WARN\t%s\t%s\t%s\t%s\n' "$area" "$key" "$msg" "$url" >> "$VRCSEC_FINDINGS_FILE" 2>/dev/null || true
}

# log_fail <area> <key> <message> [docs_url]
log_fail() {
  local area="${1:-skill}" key="${2:-error}" msg="${3:-${1:-error}}" url="${4:-}"
  if [[ $# -lt 3 ]]; then
    msg="$1"; area="skill"; key="error"; url=""
  fi
  printf '%s[FAIL]%s [%s/%s] %s' "$(_color red)" "$(_color reset)" "$area" "$key" "$msg"
  [[ -n "$url" ]] && printf ' → %s' "$url"
  printf '\n' >&2
  printf 'FAIL\t%s\t%s\t%s\t%s\n' "$area" "$key" "$msg" "$url" >> "$VRCSEC_FINDINGS_FILE" 2>/dev/null || true
}

# log_info <message>
log_info() {
  printf '%s[INFO]%s %s\n' "$(_color cyan)" "$(_color reset)" "$*"
}

# log_locked <area> <key> <message> <required_tier> [docs_url]
log_locked() {
  local area="$1" key="$2" msg="$3" tier="$4" url="${5:-}"
  printf '%s[N/A]%s  [%s/%s] %s [locked: %s+]' "$(_color cyan)" "$(_color reset)" "$area" "$key" "$msg" "$tier"
  [[ -n "$url" ]] && printf ' → %s' "$url"
  printf '\n'
  printf 'LOCKED\t%s\t%s\t%s\t%s\t%s\n' "$area" "$key" "$msg" "$tier" "$url" >> "$VRCSEC_FINDINGS_FILE" 2>/dev/null || true
}

# log_section <title>
log_section() {
  printf '\n%s== %s ==%s\n' "$(_color bold)" "$1" "$(_color reset)"
}

# log_subsection <title>
log_subsection() {
  printf '%s-- %s --%s\n' "$(_color bold)" "$1" "$(_color reset)"
}

findings_count() {
  local kind="$1"
  [[ -f "$VRCSEC_FINDINGS_FILE" ]] || { printf '0'; return; }
  awk -F'\t' -v k="$kind" '$1==k{n++} END{print n+0}' "$VRCSEC_FINDINGS_FILE"
}

snapshot_write() {
  local ts; ts=$(date -u +%Y%m%dT%H%M%SZ)
  local out="${STATE_DIR}/snapshot-${ts}.tsv"
  cp "$VRCSEC_FINDINGS_FILE" "$out" 2>/dev/null || true
  ln -sfn "$(basename "$out")" "${STATE_DIR}/snapshot-latest.tsv" 2>/dev/null || true
  log_info "snapshot saved → ${out}"
}
