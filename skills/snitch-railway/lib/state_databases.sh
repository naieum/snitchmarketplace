# lib/state_databases.sh — DB add-on inventory + version + EOL flags.
# Exports: run_state_databases [project-id] [slice]
#   slice ∈ digest (default) | full
#
# Heuristic: services whose source.image starts with one of these prefixes
# are treated as DB add-ons:
#   ghcr.io/railwayapp-templates/postgres-ssl
#   ghcr.io/railwayapp-templates/mysql
#   ghcr.io/railwayapp-templates/redis
#   ghcr.io/railwayapp-templates/mongo
#   docker.io/library/{postgres,mysql,redis,mongo}
#
# EOL data is hard-coded by version; refreshed via fix_databases.

run_state_databases() {
  local project_id="${1:-}"
  local slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
      return 3
    }
  fi

  case "$slice" in
    digest) _state_databases_digest "$project_id" "$ts" ;;
    full)   _state_databases_full   "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state databases slice","code":"E_USAGE","got":"%s"}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sdb_services() {
  local pid="$1"
  local body
  body="$(rw_gql 'query($id:String!){
    project(id:$id){
      services {
        edges {
          node {
            id name
            serviceInstances {
              edges {
                node {
                  source { image repo }
                }
              }
            }
          }
        }
      }
    }
  }' "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.services.edges // [])[].node | {
    id, name,
    image: ((.serviceInstances.edges // [])[0].node.source.image // null),
    repo:  ((.serviceInstances.edges // [])[0].node.source.repo  // null)
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

# _sdb_classify <image> -> echoes db kind + version, or empty.
# Output format: KIND<TAB>VERSION
_sdb_classify() {
  local image="${1:-}"
  [[ -z "$image" || "$image" == "null" ]] && return 0
  local kind="" version=""
  case "$image" in
    *postgres*|*postgis*) kind="postgres" ;;
    *mysql*|*mariadb*)    kind="mysql" ;;
    *redis*)              kind="redis" ;;
    *mongo*)              kind="mongo" ;;
    *)                    return 0 ;;
  esac
  # Extract :TAG
  if [[ "$image" =~ :([0-9]+(\.[0-9]+)*) ]]; then
    version="${BASH_REMATCH[1]}"
  elif [[ "$image" =~ :([a-zA-Z0-9._-]+) ]]; then
    version="${BASH_REMATCH[1]}"
  fi
  printf '%s\t%s\n' "$kind" "$version"
}

# _sdb_eol_flag <kind> <version> -> emits "supported|deprecated|eol|unknown"
_sdb_eol_flag() {
  local kind="$1" v="$2"
  local major; major="${v%%.*}"
  case "$kind" in
    postgres)
      case "$major" in
        17|16|15|14) printf 'supported' ;;
        13)          printf 'deprecated' ;;
        12|11|10|9)  printf 'eol' ;;
        *)           printf 'unknown' ;;
      esac ;;
    mysql)
      case "$major" in
        8) printf 'supported' ;;
        5) printf 'eol' ;;
        *) printf 'unknown' ;;
      esac ;;
    mariadb)
      case "$major" in
        11|10) printf 'supported' ;;
        *)     printf 'unknown' ;;
      esac ;;
    redis)
      case "$major" in
        7) printf 'supported' ;;
        6) printf 'deprecated' ;;
        5|4|3) printf 'eol' ;;
        *)  printf 'unknown' ;;
      esac ;;
    mongo)
      case "$major" in
        7|6) printf 'supported' ;;
        5)   printf 'deprecated' ;;
        4|3) printf 'eol' ;;
        *)   printf 'unknown' ;;
      esac ;;
    *) printf 'unknown' ;;
  esac
}

# Build classified DB list as JSON.
_sdb_classified_json() {
  local services_json="$1"
  # Iterate via jq's @tsv to avoid shell parsing of image strings.
  local out='[]'
  local row svc_id svc_name image kind version eol
  while IFS=$'\t' read -r svc_id svc_name image; do
    [[ -z "$svc_id" ]] && continue
    local cls; cls="$(_sdb_classify "$image")"
    [[ -z "$cls" ]] && continue
    kind="$(printf '%s' "$cls" | cut -f1)"
    version="$(printf '%s' "$cls" | cut -f2)"
    eol="$(_sdb_eol_flag "$kind" "$version")"
    row="$(jq -n \
      --arg sid "$svc_id" --arg sname "$svc_name" --arg image "$image" \
      --arg kind "$kind" --arg ver "$version" --arg eol "$eol" \
      '{service_id:$sid, service_name:$sname, image:$image, kind:$kind, version:$ver, eol_status:$eol}')"
    out="$(jq --argjson r "$row" '. + [$r]' <<<"$out")"
  done < <(jq -r '.[] | [.id, .name, (.image // "")] | @tsv' <<<"$services_json")
  printf '%s' "$out"
}

_state_databases_digest() {
  local pid="$1" ts="$2"
  local svcs dbs
  svcs="$(_sdb_services "$pid")"
  dbs="$(_sdb_classified_json "$svcs")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson dbs "$dbs" \
    '{
      schema: "rwsec.state-databases.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-databases",
      slice: "digest",
      project_id: $pid,
      databases_summary: {
        total: ($dbs | length),
        by_kind: ($dbs | group_by(.kind) | map({key: .[0].kind, value: length}) | from_entries),
        eol: ($dbs | map(select(.eol_status == "eol"))),
        deprecated: ($dbs | map(select(.eol_status == "deprecated"))),
        supported: ($dbs | map(select(.eol_status == "supported"))),
        backup_warning: "Railway does not provide a managed backup product; recommend logical dumps to R2/S3 on a schedule."
      },
      databases: $dbs,
      hint: "for full data, run: state databases <project-id> full"
    }'
}

_state_databases_full() {
  local pid="$1" ts="$2"
  local svcs dbs
  svcs="$(_sdb_services "$pid")"
  dbs="$(_sdb_classified_json "$svcs")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" \
    --argjson services "$svcs" \
    --argjson dbs "$dbs" \
    '{ schema:"rwsec.state-databases.full", schema_version:1, generated_at:$ts,
       tool:"state-databases", slice:"full", project_id:$pid,
       services_with_image: $services, databases:$dbs }'
}
