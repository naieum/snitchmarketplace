# lib/apply_structured_data.sh — emits JSON-LD blocks for org/website/breadcrumb +
# vertical-specific (product/article/faq) per detected vertical.
# Reads templates/structured-data/*.starter.json.
#
# Exports: apply_structured_data [vertical...]

apply_structured_data() {
  log_section "apply structured-data"

  local td="${TPL_DIR}/structured-data"
  if [[ ! -d "$td" ]]; then
    log_fail "structured-data" "template" "structured-data templates dir missing at ${td}. Run ads-ready.sh refresh-docs or reinstall."
    return 4
  fi

  # Default templates to emit: organization, website, breadcrumb. Plus any
  # vertical the caller specified or detect.sh inferred.
  local emit=("organization" "website" "breadcrumb")
  local vert
  for vert in "$@"; do
    case "$vert" in
      ecommerce) emit+=("product") ;;
      blog|marketing) emit+=("article") ;;
      saas|faq) emit+=("faq") ;;
      *) ;;
    esac
  done

  # If no verticals passed, infer from detect.sh output.
  if [[ $# -eq 0 ]]; then
    if ! declare -f run_detect >/dev/null 2>&1; then
      . "$LIB_DIR/detect.sh"
    fi
    local detect_json; detect_json="$(run_detect 2>/dev/null)"
    local hints; hints="$(jq -r '.vertical_hints // [] | .[]' <<<"$detect_json" 2>/dev/null)"
    while IFS= read -r vert; do
      [[ -z "$vert" ]] && continue
      case "$vert" in
        ecommerce) emit+=("product") ;;
        blog|marketing) emit+=("article") ;;
        saas) emit+=("faq") ;;
      esac
    done <<<"$hints"
  fi

  # Dedupe.
  local seen="" final=()
  local e
  for e in "${emit[@]}"; do
    case " $seen " in *" $e "*) continue ;; esac
    seen+=" $e"
    final+=("$e")
  done

  local rel_path="src/components/structured-data.html"
  local body=""
  body+=$'<!-- Structured data starter — managed by ads-ready -->\n'
  for e in "${final[@]}"; do
    local f="${td}/${e}.starter.json"
    if [[ ! -f "$f" ]]; then
      log_warn "structured-data" "missing-template" "${e} template not found at ${f}; skipping."
      continue
    fi
    body+=$'<script type="application/ld+json">\n'
    body+="$(cat "$f")"
    body+=$'\n</script>\n'
  done

  if [[ -z "$body" ]]; then
    log_warn "structured-data" "apply" "No templates produced any output. Check templates/structured-data/."
    return 0
  fi

  log_info "Proposing structured-data block: ${final[*]}"

  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n(new file)\n'
  printf '=== CONTENT ===\n'
  printf '%s' "$body"
  printf '\n=== END ===\n'
  log_warn "structured-data" "apply" "Proposed JSON-LD blocks (${final[*]}). User confirmation required before write."
}
