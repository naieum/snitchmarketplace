# lib/state_platform.sh — dispatcher to per-platform Marketing API helpers.
# Each platform helper lives in lib/platforms/<name>.sh and exports a single
# `platform_state` function with signature: platform_state [account-id]
#
# Exports: run_state_platform <name> [account-id]

run_state_platform() {
  local name="${1:-}"
  shift || true
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$name" ]]; then
    printf '{"error":"state platform requires a platform name","code":"E_USAGE","valid":["google","meta","microsoft","linkedin","tiktok","x","pinterest","reddit","snapchat","apple"],"remediation":"usage: state platform <name> [account-id]"}\n' >&2
    return 2
  fi

  case "$name" in
    google|meta|microsoft|linkedin|tiktok|x|pinterest|reddit|snapchat|apple)
      ;;
    *)
      printf '{"error":"unknown platform","code":"E_USAGE","got":"%s","valid":["google","meta","microsoft","linkedin","tiktok","x","pinterest","reddit","snapchat","apple"]}\n' "$name" >&2
      return 2 ;;
  esac

  local lib_path="${PLAT_DIR:-${LIB_DIR}/platforms}/${name}.sh"
  if [[ ! -f "$lib_path" ]]; then
    printf '{"error":"platform helper not installed","code":"E_PLATFORM_LIB","platform":"%s","path":"%s","remediation":"reinstall the skill or run ads-ready.sh refresh-docs"}\n' "$name" "$lib_path" >&2
    return 4
  fi

  # shellcheck source=/dev/null
  . "$lib_path"
  if ! declare -f platform_state >/dev/null 2>&1; then
    printf '{"error":"platform helper does not export platform_state","code":"E_PLATFORM_API","platform":"%s","path":"%s"}\n' "$name" "$lib_path" >&2
    return 4
  fi

  platform_state "$@"
}
