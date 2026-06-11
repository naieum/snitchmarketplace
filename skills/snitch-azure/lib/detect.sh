# lib/detect.sh — single-call cwd JSON.
# Consolidates stack/database/storage/native-deps/AI-provider/vector-DB/headless-browser/IaC
# detection into one structured JSON document the agent can reason over.
#
# Exports:
#   run_detect — entrypoint. Emits one JSON document on stdout.

_det_grep_files() {
  local pattern="$1"; shift
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || continue
    if grep -E -q "$pattern" "$f" 2>/dev/null; then
      printf '1'; return 0
    fi
  done
  printf '0'
}

_det_pkg_has() {
  local pattern="$1"
  if [[ -f "package.json" ]] && grep -E -q "$pattern" package.json 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

_det_py_has() {
  local pattern="$1"
  if [[ -f "requirements.txt" ]] && grep -E -q "$pattern" requirements.txt 2>/dev/null; then
    printf '1'; return
  fi
  if [[ -f "pyproject.toml" ]] && grep -E -q "$pattern" pyproject.toml 2>/dev/null; then
    printf '1'; return
  fi
  printf '0'
}

_det_stacks() {
  local out=()
  compgen -G "next.config.*" >/dev/null 2>&1 && out+=("nextjs")
  compgen -G "astro.config.*" >/dev/null 2>&1 && out+=("astro")
  compgen -G "svelte.config.*" >/dev/null 2>&1 && out+=("sveltekit")
  compgen -G "remix.config.*" >/dev/null 2>&1 && out+=("remix")
  compgen -G "nuxt.config.*" >/dev/null 2>&1 && out+=("nuxt")
  [[ -f "vite.config.js" || -f "vite.config.ts" ]] && out+=("vite")
  [[ -f "wp-config.php" ]] && out+=("wordpress")
  [[ -f "artisan" ]] && out+=("laravel")
  [[ -f "Gemfile" && -f "config/routes.rb" ]] && out+=("rails")
  [[ -f "manage.py" ]] && out+=("django")
  if [[ -f "requirements.txt" ]] && grep -E -q '^Flask\b' requirements.txt 2>/dev/null; then out+=("flask"); fi
  if [[ -f "pyproject.toml" ]] && grep -E -q 'flask' pyproject.toml 2>/dev/null; then out+=("flask"); fi
  compgen -G "*.csproj" >/dev/null 2>&1 && out+=("dotnet")
  if [[ -f "pom.xml" ]] && grep -E -q 'spring-boot' pom.xml 2>/dev/null; then out+=("spring-boot"); fi
  [[ -f "config.toml" || -f "hugo.toml" || -f "hugo.yaml" ]] && out+=("hugo")
  [[ -f "_config.yml" ]] && out+=("jekyll")
  [[ -f ".eleventy.js" || -f "eleventy.config.js" ]] && out+=("eleventy")
  [[ -f "gatsby-config.js" || -f "gatsby-config.ts" ]] && out+=("gatsby")
  if [[ -f "package.json" ]]; then
    [[ "$(_det_pkg_has '"@?nestjs')" == "1" ]] && out+=("nestjs")
    [[ "$(_det_pkg_has '"fastify"')" == "1" ]] && out+=("fastify")
    [[ "$(_det_pkg_has '"express"')" == "1" ]] && out+=("express")
    [[ "$(_det_pkg_has '"hono"')" == "1" ]] && out+=("hono")
    [[ "$(_det_pkg_has '"@?blazor')" == "1" ]] && out+=("dotnet-blazor")
  fi
  # .NET Blazor signal
  if compgen -G "*.csproj" >/dev/null 2>&1; then
    if grep -l -E 'Microsoft\.AspNetCore\.Components|Blazor' ./*.csproj 2>/dev/null | head -n1 >/dev/null; then
      out+=("dotnet-blazor")
    fi
  fi
  if [[ ${#out[@]} -eq 0 && -f "index.html" ]]; then
    out+=("static")
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_databases() {
  local out=()
  local env_files=(.env .env.local .env.development .env.production .env.staging)
  local all_files=("${env_files[@]}" docker-compose.yml docker-compose.yaml prisma/schema.prisma config/database.yml \
    application.properties application.yml \
    src/main/resources/application.properties src/main/resources/application.yml)

  [[ "$(_det_grep_files 'mysql(\+[a-z]+)?://'   "${all_files[@]}")" == "1" ]] && out+=("mysql")
  [[ "$(_det_grep_files 'postgres(ql)?://'     "${all_files[@]}")" == "1" ]] && out+=("postgres")
  [[ "$(_det_grep_files 'mongodb(\+srv)?://'   "${all_files[@]}")" == "1" ]] && out+=("mongodb")
  [[ "$(_det_grep_files 'redis(s|\+[a-z]+)?://' "${all_files[@]}")" == "1" ]] && out+=("redis")
  [[ "$(_det_grep_files 'sqlite://'            "${all_files[@]}")" == "1" ]] && out+=("sqlite")
  [[ "$(_det_grep_files '(mssql|sqlserver)://' "${all_files[@]}")" == "1" ]] && out+=("mssql")

  [[ "$(_det_grep_files '^DB_CONNECTION=(mysql|mariadb)\b' "${env_files[@]}")" == "1" ]] && out+=("mysql")
  [[ "$(_det_grep_files '^DB_CONNECTION=pgsql\b'           "${env_files[@]}")" == "1" ]] && out+=("postgres")
  [[ "$(_det_grep_files '^DB_CONNECTION=sqlite\b'          "${env_files[@]}")" == "1" ]] && out+=("sqlite")
  [[ "$(_det_grep_files '^DB_CONNECTION=sqlsrv\b'          "${env_files[@]}")" == "1" ]] && out+=("mssql")

  if [[ -f "config/database.yml" ]]; then
    grep -E -q '^[[:space:]]*adapter:[[:space:]]*mysql2?\b'    config/database.yml 2>/dev/null && out+=("mysql")
    grep -E -q '^[[:space:]]*adapter:[[:space:]]*postgresql\b' config/database.yml 2>/dev/null && out+=("postgres")
    grep -E -q '^[[:space:]]*adapter:[[:space:]]*sqlite3?\b'   config/database.yml 2>/dev/null && out+=("sqlite")
    grep -E -q '^[[:space:]]*adapter:[[:space:]]*sqlserver\b'  config/database.yml 2>/dev/null && out+=("mssql")
  fi

  if [[ -f "manage.py" ]]; then
    grep -r -E -q "django\\.db\\.backends\\.mysql\\b"      --include='*.py' . 2>/dev/null && out+=("mysql")
    grep -r -E -q "django\\.db\\.backends\\.postgresql\\b" --include='*.py' . 2>/dev/null && out+=("postgres")
    grep -r -E -q "django\\.db\\.backends\\.sqlite3\\b"    --include='*.py' . 2>/dev/null && out+=("sqlite")
    grep -r -E -q "django\\.db\\.backends\\.oracle\\b"     --include='*.py' . 2>/dev/null && out+=("oracle")
  fi

  local spring_files=(application.properties application.yml \
    src/main/resources/application.properties src/main/resources/application.yml)
  [[ "$(_det_grep_files 'jdbc:mysql://'      "${spring_files[@]}")" == "1" ]] && out+=("mysql")
  [[ "$(_det_grep_files 'jdbc:postgresql://' "${spring_files[@]}")" == "1" ]] && out+=("postgres")
  [[ "$(_det_grep_files 'jdbc:sqlserver://'  "${spring_files[@]}")" == "1" ]] && out+=("mssql")
  [[ "$(_det_grep_files 'jdbc:oracle:'       "${spring_files[@]}")" == "1" ]] && out+=("oracle")

  [[ -f "wp-config.php" ]] && out+=("mysql")

  [[ "$(_det_grep_files '^(MYSQL|MARIADB)_(HOST|URL|DSN)=' "${env_files[@]}")" == "1" ]] && out+=("mysql")
  [[ "$(_det_grep_files '^POSTGRES_(HOST|URL|DSN)='        "${env_files[@]}")" == "1" ]] && out+=("postgres")
  [[ "$(_det_grep_files '^MONGO(DB)?_(URL|URI|HOST)='      "${env_files[@]}")" == "1" ]] && out+=("mongodb")
  [[ "$(_det_grep_files '^REDIS_(URL|HOST)='               "${env_files[@]}")" == "1" ]] && out+=("redis")
  [[ "$(_det_grep_files '^MSSQL_(HOST|URL)='               "${env_files[@]}")" == "1" ]] && out+=("mssql")

  # Azure-specific markers
  [[ "$(_det_grep_files 'cosmos\.azure\.com'                "${env_files[@]}")" == "1" ]] && out+=("cosmos")
  [[ "$(_det_grep_files 'database\.windows\.net'             "${env_files[@]}")" == "1" ]] && out+=("azure-sql")

  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_object_storage() {
  local out=()
  [[ "$(_det_pkg_has '"(aws-sdk|@aws-sdk/client-s3)"')" == "1" ]] && out+=("s3")
  [[ "$(_det_py_has '^boto3')"   == "1" ]] && out+=("s3")
  [[ "$(_det_py_has 'boto3')"    == "1" ]] && out+=("s3")
  [[ "$(_det_pkg_has '"@google-cloud/storage"')" == "1" ]] && out+=("gcs")
  [[ "$(_det_py_has 'google-cloud-storage')" == "1" ]] && out+=("gcs")
  [[ "$(_det_pkg_has '"@azure/storage-blob"')" == "1" ]] && out+=("azure-blob")
  [[ "$(_det_py_has 'azure-storage-blob')" == "1" ]] && out+=("azure-blob")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_native_deps() {
  local out=()
  [[ "$(_det_pkg_has '"sharp"')"      == "1" ]] && out+=("sharp")
  [[ "$(_det_pkg_has '"canvas"')"     == "1" ]] && out+=("canvas")
  [[ "$(_det_pkg_has '"bcrypt"')"     == "1" ]] && out+=("bcrypt")
  [[ "$(_det_pkg_has '"puppeteer"')"  == "1" ]] && out+=("puppeteer")
  [[ "$(_det_pkg_has '"playwright"')" == "1" ]] && out+=("playwright")
  [[ "$(_det_pkg_has '"ffmpeg')"      == "1" ]] && out+=("ffmpeg")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_background_workers() {
  local out=()
  [[ "$(_det_pkg_has '"(bullmq|bee-queue|kafkajs|@aws-sdk/client-sqs|@azure/service-bus)"')" == "1" ]] && out+=("queue-lib")
  [[ -f "Gemfile" ]] && grep -E -q 'sidekiq' Gemfile 2>/dev/null && out+=("sidekiq")
  [[ "$(_det_py_has 'celery')" == "1" ]] && out+=("celery")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_websockets() {
  if [[ "$(_det_pkg_has '"(socket\.io|ws|engine\.io|hocuspocus|@microsoft/signalr)"')" == "1" ]]; then
    printf 'true'; return
  fi
  printf 'false'
}

_det_ai_providers() {
  local out=()
  [[ "$(_det_pkg_has '"openai"')"               == "1" ]] && out+=("openai")
  [[ "$(_det_pkg_has '"@anthropic-ai/sdk"')"     == "1" ]] && out+=("anthropic")
  [[ "$(_det_pkg_has '"@google/generative-ai"')" == "1" ]] && out+=("google-gemini")
  [[ "$(_det_pkg_has '"cohere-ai"')"             == "1" ]] && out+=("cohere")
  [[ "$(_det_pkg_has '"replicate"')"             == "1" ]] && out+=("replicate")
  [[ "$(_det_pkg_has '"@huggingface/inference"')" == "1" ]] && out+=("huggingface")
  [[ "$(_det_pkg_has '"mistralai"')"             == "1" ]] && out+=("mistral")
  [[ "$(_det_pkg_has '"groq-sdk"')"              == "1" ]] && out+=("groq")
  [[ "$(_det_pkg_has '"@azure/openai"')"         == "1" ]] && out+=("azure-openai")
  [[ "$(_det_py_has 'openai')"      == "1" ]] && out+=("openai")
  [[ "$(_det_py_has 'anthropic')"   == "1" ]] && out+=("anthropic")
  [[ "$(_det_py_has 'cohere')"      == "1" ]] && out+=("cohere")
  [[ "$(_det_py_has 'mistralai')"   == "1" ]] && out+=("mistral")
  [[ "$(_det_py_has 'replicate')"   == "1" ]] && out+=("replicate")
  [[ "$(_det_py_has 'azure-ai-')"   == "1" ]] && out+=("azure-openai")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_vector_dbs() {
  local out=()
  [[ "$(_det_pkg_has '"@pinecone-database/pinecone"')" == "1" ]] && out+=("pinecone")
  [[ "$(_det_pkg_has '"weaviate-(ts-)?client"')"       == "1" ]] && out+=("weaviate")
  [[ "$(_det_pkg_has '"@qdrant/js-client-rest"')"      == "1" ]] && out+=("qdrant")
  [[ "$(_det_pkg_has '"chromadb"')"                    == "1" ]] && out+=("chroma")
  [[ "$(_det_pkg_has '"@upstash/vector"')"             == "1" ]] && out+=("upstash-vector")
  [[ "$(_det_pkg_has '"@azure/search-documents"')"     == "1" ]] && out+=("azure-ai-search")
  [[ "$(_det_py_has 'pinecone')"  == "1" ]] && out+=("pinecone")
  [[ "$(_det_py_has 'weaviate')"  == "1" ]] && out+=("weaviate")
  [[ "$(_det_py_has 'qdrant')"    == "1" ]] && out+=("qdrant")
  [[ "$(_det_py_has 'chromadb')"  == "1" ]] && out+=("chroma")
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_embedding_calls() {
  if grep -r -E -q '\.embeddings\.create\(|Embedding\.create\(|embed_query\(|embed_documents\(|getEmbeddings\(' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.mjs' --include='*.py' \
    . 2>/dev/null; then
    printf 'true'; return
  fi
  printf 'false'
}

_det_headless_browser() {
  if [[ "$(_det_pkg_has '"(puppeteer|playwright|@puppeteer/browsers)"')" == "1" ]]; then
    printf 'true'; return
  fi
  printf 'false'
}

# Azure-specific IaC signals
_det_iac_signals() {
  local out=()
  if compgen -G "*.bicep" >/dev/null 2>&1; then out+=("bicep"); fi
  if find . -maxdepth 4 -name '*.bicep' \
    \( -path '*/node_modules' -o -path '*/.git' \) -prune -o -type f -name '*.bicep' -print 2>/dev/null \
    | head -n1 | grep -q . 2>/dev/null; then
    out+=("bicep")
  fi
  if [[ -f "azuredeploy.json" ]]; then out+=("arm-template"); fi
  if compgen -G "*.parameters.json" >/dev/null 2>&1; then out+=("arm-parameters"); fi
  # ARM templates by schema URL
  if find . -maxdepth 3 -type f -name '*.json' \
    \( -path '*/node_modules' -o -path '*/.git' \) -prune -o -type f -name '*.json' -print 2>/dev/null \
    | xargs grep -l 'schema.management.azure.com' 2>/dev/null | head -n1 | grep -q . 2>/dev/null; then
    out+=("arm-template")
  fi
  if compgen -G "*.tf" >/dev/null 2>&1; then
    if grep -l -E 'azurerm|azuread|azapi' ./*.tf 2>/dev/null | head -n1 >/dev/null; then
      out+=("terraform-azurerm")
    fi
  fi
  if [[ -f "Pulumi.yaml" ]] && grep -E -q 'azure-native|azure' Pulumi.yaml 2>/dev/null; then
    out+=("pulumi-azure")
  fi
  if [[ -f "Azure.yml" || -f "azure-pipelines.yml" || -f ".azure-pipelines.yml" ]]; then
    out+=("azure-devops-pipeline")
  fi
  if [[ -f "staticwebapp.config.json" ]]; then
    out+=("static-web-apps")
  fi
  if [[ -f "host.json" && -f "local.settings.json" ]]; then
    out+=("azure-functions")
  fi
  if [[ -f "deployment-config.json" || -f ".azure" || -d ".azure" ]]; then
    out+=("azd")
  fi
  if find . -maxdepth 3 -type f -name 'azure.yaml' \
    \( -path '*/node_modules' -o -path '*/.git' \) -prune -o -type f -name 'azure.yaml' -print 2>/dev/null \
    | head -n1 | grep -q . 2>/dev/null; then
    out+=("azd")
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_project_kind() {
  if [[ -f "host.json" && -f "local.settings.json" ]]; then printf 'azure-functions'; return; fi
  if [[ -f "staticwebapp.config.json" ]]; then printf 'azure-static-web-apps'; return; fi
  if [[ -f "package.json" ]]; then printf 'node'; return; fi
  if [[ -f "composer.json" || -f "wp-config.php" ]]; then printf 'php'; return; fi
  if [[ -f "Gemfile" ]]; then printf 'ruby'; return; fi
  if [[ -f "manage.py" || -f "requirements.txt" || -f "pyproject.toml" ]]; then printf 'python'; return; fi
  if compgen -G "*.csproj" >/dev/null 2>&1; then printf 'dotnet'; return; fi
  if [[ -f "pom.xml" || -f "build.gradle" ]]; then printf 'jvm'; return; fi
  if [[ -f "go.mod" ]]; then printf 'go'; return; fi
  if [[ -f "Cargo.toml" ]]; then printf 'rust'; return; fi
  printf 'unknown'
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
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_current_host_provider() {
  if [[ -f "vercel.json" ]]; then printf '"vercel"'; return; fi
  if [[ -f "netlify.toml" || -f "netlify.yaml" ]]; then printf '"netlify"'; return; fi
  if [[ -f "fly.toml" ]]; then printf '"fly"'; return; fi
  if [[ -f "railway.json" || -f "railway.toml" ]]; then printf '"railway"'; return; fi
  if [[ -f "render.yaml" ]]; then printf '"render"'; return; fi
  if [[ -f "app.yaml" && -f "main.py" ]]; then printf '"gae"'; return; fi
  if [[ -f "Procfile" ]]; then printf '"heroku-style"'; return; fi
  if [[ -f "staticwebapp.config.json" || -f "host.json" ]]; then printf '"azure"'; return; fi
  printf 'null'
}

_det_hostnames() {
  local out=()
  if [[ -f "vercel.json" ]]; then
    while IFS= read -r line; do [[ -n "$line" ]] && out+=("$line"); done < <(jq -r '.alias // [] | .[]' vercel.json 2>/dev/null)
  fi
  if [[ -f "staticwebapp.config.json" ]]; then
    while IFS= read -r line; do [[ -n "$line" ]] && out+=("$line"); done < <(jq -r '.routes // [] | .[].route // empty' staticwebapp.config.json 2>/dev/null)
  fi
  printf '%s' "$(_det_dedupe_to_json "${out[@]+"${out[@]}"}")"
}

_det_to_json_array() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local s=""
  local i
  for i in "$@"; do
    [[ -n "$s" ]] && s+=","
    s+="\"${i//\"/\\\"}\""
  done
  printf '[%s]' "$s"
}

_det_dedupe_to_json() {
  if [[ $# -eq 0 ]]; then printf '[]'; return; fi
  local seen=""
  local out=()
  local i
  for i in "$@"; do
    case " $seen " in *" $i "*) continue ;; esac
    seen+=" $i"
    out+=("$i")
  done
  _det_to_json_array "${out[@]+"${out[@]}"}"
}

# run_detect — assemble and emit one JSON document.
run_detect() {
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local stacks dbs storage native bgworkers ws ai_providers vector_dbs embed headless project_kind pms host_provider hostnames iac

  stacks="$(_det_stacks)"
  dbs="$(_det_databases)"
  storage="$(_det_object_storage)"
  native="$(_det_native_deps)"
  bgworkers="$(_det_background_workers)"
  ws="$(_det_websockets)"
  ai_providers="$(_det_ai_providers)"
  vector_dbs="$(_det_vector_dbs)"
  embed="$(_det_embedding_calls)"
  headless="$(_det_headless_browser)"
  project_kind="$(_det_project_kind)"
  pms="$(_det_package_managers)"
  host_provider="$(_det_current_host_provider)"
  hostnames="$(_det_hostnames)"
  iac="$(_det_iac_signals)"

  jq -n \
    --arg ts "$ts" \
    --arg cwd "$(pwd)" \
    --arg project_kind "$project_kind" \
    --argjson stacks         "$stacks" \
    --argjson databases      "$dbs" \
    --argjson object_storage "$storage" \
    --argjson native_deps    "$native" \
    --argjson background_workers "$bgworkers" \
    --argjson websockets     "$ws" \
    --argjson ai_providers   "$ai_providers" \
    --argjson vector_dbs     "$vector_dbs" \
    --argjson embedding_calls "$embed" \
    --argjson headless_browser "$headless" \
    --argjson package_managers "$pms" \
    --argjson current_host_provider "$host_provider" \
    --argjson hostnames      "$hostnames" \
    --argjson iac_signals    "$iac" \
    '{
      schema: "azsec.detect",
      schema_version: 1,
      generated_at: $ts,
      tool: "detect",
      cwd: $cwd,
      project_kind: $project_kind,
      stacks: $stacks,
      iac_signals: $iac_signals,
      databases: $databases,
      object_storage: $object_storage,
      native_deps: $native_deps,
      background_workers: $background_workers,
      websockets: $websockets,
      ai_providers: $ai_providers,
      vector_dbs: $vector_dbs,
      embedding_calls: $embedding_calls,
      headless_browser: $headless_browser,
      package_managers: $package_managers,
      current_host_provider: $current_host_provider,
      hostnames: $hostnames
    }' \
    | tee "${STATE_DIR}/detect.json" 2>/dev/null
}
