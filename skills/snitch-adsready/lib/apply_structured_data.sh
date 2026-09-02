# lib/apply_structured_data.sh — emits the Product/Offer JSON-LD block that a shopping /
# catalog feed crawl consumes. Ad-platform-consumed markup only; every other schema type
# is a search surface (snitch-marketing owns it).
# Reads templates/structured-data/product.starter.json.
#
# Exports: apply_structured_data [vertical...]

apply_structured_data() {
  log_section "apply structured-data"

  local td="${TPL_DIR}/structured-data"
  local starter="${td}/product.starter.json"
  if [[ ! -f "$starter" ]]; then
    log_fail "structured-data" "template" "product starter not found at ${starter}. Reinstall the skill — the templates/ directory beside ads-ready.sh is incomplete."
    return 4
  fi

  # This area only covers Product/Offer. A caller asking for another vertical gets told
  # where that work lives instead of a silently ignored argument.
  local vert has_catalog=0
  for vert in "$@"; do
    case "$vert" in
      ecommerce|product|shopping) has_catalog=1 ;;
      *)
        log_warn "structured-data" "out-of-scope" "'${vert}' schema is a search surface, not an ad-platform feed input. Call the Skill tool with \"snitch-marketing\" for it. This fix emits Product/Offer only."
        ;;
    esac
  done

  if [[ $# -gt 0 && "$has_catalog" != "1" ]]; then
    log_warn "structured-data" "not-applicable" "No catalog vertical among the arguments. This fix emits Product/Offer only; re-run as 'fix structured-data ecommerce' if a shopping or catalog feed exists."
    return 0
  fi

  # With no argument, infer from detect.sh: only a catalog signal justifies the block.
  if [[ $# -eq 0 ]]; then
    if ! declare -f run_detect >/dev/null 2>&1; then
      . "$LIB_DIR/detect.sh"
    fi
    local detect_json; detect_json="$(run_detect 2>/dev/null)"
    local hints; hints="$(jq -r '.vertical_hints // [] | .[]' <<<"$detect_json" 2>/dev/null)"
    while IFS= read -r vert; do
      [[ -z "$vert" ]] && continue
      case "$vert" in
        ecommerce) has_catalog=1 ;;
      esac
    done <<<"$hints"
    if [[ "$has_catalog" != "1" ]]; then
      log_warn "structured-data" "not-applicable" "No catalog signal in detect's vertical_hints. Product/Offer markup is a shopping-feed prerequisite; with no catalog there is nothing here to fix. Re-run as 'fix structured-data ecommerce' to emit it anyway."
      return 0
    fi
  fi

  local rel_path="src/components/product-jsonld.html"
  local body=""
  body+=$'<!-- Product/Offer JSON-LD — feed input, managed by ads-ready.\n'
  body+=$'     Bind every {{PLACEHOLDER}} to the product record at build or render time;\n'
  body+=$'     a literal price or availability drifts from the feed and gets the item disapproved. -->\n'
  body+=$'<script type="application/ld+json">\n'
  body+="$(cat "$starter")"
  body+=$'\n</script>\n'

  log_info "Proposing Product/Offer JSON-LD from product.starter.json"

  printf '\n=== FILE: %s ===\n' "$rel_path"
  printf '=== DIFF ===\n(new file)\n'
  printf '=== CONTENT ===\n'
  printf '%s' "$body"
  printf '\n=== END ===\n'
  log_warn "structured-data" "apply" "Proposed Product/Offer JSON-LD. Placeholders are unfilled by design — bind them to the product source. User confirmation required before write."
}
