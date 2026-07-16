## CATEGORY 27: Dependency Vulnerabilities / Supply Chain
> Type: posture · Groups: infra-supply-chain · CWE: CWE-1395

Software composition analysis (SCA) plus supply-chain behavior checks. Code review is necessary but not sufficient when 80-90% of a typical app's bytes come from third-party packages: this category targets the manifests and lockfiles themselves, across npm, PyPI, Go, Rust, Ruby, Maven, PHP, and NuGet.

### Detection
- Manifests: `package.json`, `pyproject.toml`, `setup.py`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, `*.csproj`
- Lockfiles: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Pipfile.lock`, `uv.lock`, `Cargo.lock`, `go.sum`, `Gemfile.lock`, `composer.lock`, `packages.lock.json`, `gradle.lockfile`
- CI/CD dependency installation steps; project metadata that pins transitive versions

### Active Audit Step (REQUIRED)
Run the appropriate audit command for the project's package manager. This gives authoritative CVE data — do not skip it:

```
npm audit --json          # npm
pnpm audit --json         # pnpm
yarn audit --json         # Yarn 1.x
pip-audit                 # Python
bundle audit              # Ruby
govulncheck ./...         # Go
cargo audit               # Rust
composer audit            # PHP
osv-scanner .             # any ecosystem, if installed
```

Parse the output and report:
- **Critical/High severity advisories** — flag immediately, include CVE ID and affected version range
- **Moderate severity** — flag if the package is in `dependencies` (production)
- **Low severity in devDependencies** — note but mark as lower priority
- **`MAL-` prefixed OSV advisories** (known-malicious packages) — always Critical, regardless of scope

### What to Search For
- Missing lockfile entirely (non-deterministic installs); mixed lockfile + bare manifest where the lockfile is stale
- Wildcard or open-ended version ranges (`"lodash": "*"`, `requests>=2`, `serde = "*"`, `latest`) — "whatever resolves at install time" is a security regression risk
- `postinstall` scripts in dependencies doing suspicious things (network calls, file writes outside package)
- Typosquatting indicators (packages with names very similar to popular ones — `reqeusts`, `lodahs`, `cross-fetch-cjs`; helpers for big-name projects published by unknown maintainers)
- Pinned to very old versions of security-critical packages (e.g., `express` v3, `jsonwebtoken` v7); direct deps pinned more than 2 years old with no comment explaining why
- Dependencies with known CVEs in the locked version; transitive deps with published advisories (lodash <4.17.21, log4j <2.17.1, requests <2.32.0, urllib3 <2.0, axios <1.6.0, old tar-fs / postcss, etc.)
- `requirements.txt` entries with no version constraint and no `--hash` pin
- Dev-only deps referenced in production code paths
- No `npm audit` / `pip-audit` / equivalent step in CI
- Recently-disclosed 0-days in commonly-used packages — pay particular attention to:
  - React / react-dom (XSS issues in certain render paths)
  - Next.js (path traversal, SSRF, and auth bypass CVEs in older versions)
  - Express (prototype pollution, RegEx DoS in old versions)
  - `jsonwebtoken` (algorithm confusion, none-algorithm bypass in v8 and below)
  - `lodash` (prototype pollution — CVE-2019-10744 and related)
  - `node-fetch` / `axios` (SSRF and header injection in older versions)
  - `multer` / `formidable` (path traversal in older versions)
  - Any package pinned to a version released more than 2 major versions ago

### Actually Vulnerable
- No lockfile committed (anyone running install gets potentially different versions)
- A pinned version matching a Critical or High OSV / GHSA / CVE advisory, with no override or resolution
- Package manager audit returns Critical or High advisories for production dependencies
- Transitive deps resolving to known-malicious packages (`MAL-` OSV advisories, yanked-malicious registry entries)
- Dependency with a `postinstall` script that downloads and executes remote code
- Package name one character off from a popular package (potential typosquat)
- Security-critical package pinned to an end-of-life major version
- Production manifest using `latest` or `*` ranges with no lockfile committed
- Unconstrained `requirements.txt` (bare package names, no `--hash`)
- A lockfile pinning a yanked or deprecated package with a successor available

### NOT Vulnerable
- Lockfile present and committed; versions outside any published vulnerable range
- `postinstall` scripts that run standard build steps (tsc, node-gyp, esbuild)
- Well-known packages from verified publishers, on current or recent major versions
- Vulnerabilities only in devDependencies not shipped to production
- Intentional transitive pins via `overrides` / `resolutions` in the manifest
- Internal / forked packages where the org maintains its own security review
- Package manager audit returns zero Critical/High findings

### Context Check
1. Is the lockfile committed to the repository?
2. Are suspicious postinstall scripts from trusted, well-known packages?
3. Is the outdated package a dev-only dependency or shipped to production?
4. Does the project run automated dependency auditing (`npm audit` / `pip-audit` / `cargo audit` / equivalent) in CI?
5. Are version ranges constrained (`^1.2.3`, `~1.2.3`, or pinned) or open-ended (`*`, `latest`)?
6. Does the audit command show any Critical or High advisories? Report the CVE ID and affected package.

### Evidence Chain
A finding's Evidence block must show:
- The manifest or lockfile entry file:line pinning the affected package and version
- The advisory identifier (CVE / GHSA / OSV, including `MAL-`) with its affected version range, and that the locked version falls inside it
- The source of the advisory: audit command output (Active Audit Step) or, in pure-skill mode, the lockfile inspection that matched it
- The reachability result: import/call site file:line for the vulnerable function, or an explicit "(unreachable)" note with downgraded severity
- Scope: whether the package is in `dependencies` (production) or `devDependencies`
- For behavior findings (typosquat, postinstall, obfuscation): the script or `package.json` snippet file:line showing the suspicious behavior

### Confidence Scoring
- **High**: audit command output matches a Critical/High advisory to the exact locked version; or a `MAL-` advisory / confirmed typosquat / postinstall script that downloads and executes remote code — especially when reachability is confirmed or the package is a production dependency
- **Medium**: version-heuristic finding without deterministic audit output (visibly old pin, open-ended range, missing lockfile), or an advisory match where reachability could not be established
- **Low**: name-similarity or package-age heuristics alone, or a transitive resolution that cannot be confirmed from the lockfile — tag `needs human verification`

### Files to Check
- All manifests and lockfiles listed under Detection
- `.github/workflows/*.yml` (check for audit steps)
- `.npmrc`, `.yarnrc.yml` (registry configuration)

### Reachability Analysis

After finding CVEs via the audit command, perform a reachability check to reduce noise:

1. **Read the advisory** to identify the vulnerable function/export in the affected package
2. **Search the project's imports** for that package (`import ... from 'package-name'` or `require('package-name')`)
3. **Trace whether the specific vulnerable function** is imported and called in the project
4. **If not reachable** → downgrade finding to Informational severity with note "(unreachable)"
5. **If reachable** → keep original severity and show the call chain

Example finding with reachability:
```
## Finding: CVE-2024-XXXXX in lodash@4.17.20
- **Vulnerable function:** lodash.template() (prototype pollution)
- **Reachable:** YES — imported in src/email/render.ts:3, called at line 47
- **Severity:** High (reachable)
```

vs:

```
## Finding: CVE-2024-YYYYY in axios@0.21.1
- **Vulnerable function:** axios.interceptors (SSRF via redirect)
- **Reachable:** NO — project imports axios but never uses interceptors
- **Severity:** Informational (unreachable)
```

### Supply Chain Behavior Analysis

In addition to CVE checks, analyze dependency behavior for supply chain threats:

- **Typosquatting detection:** Check for packages within edit-distance 1 of popular packages (e.g., `lodassh` instead of `lodash`, `expres` instead of `express`). Flag any suspiciously-named packages. (Deep typosquat/install-script analysis: see Category 66.)
- **Suspicious install scripts:** Flag `preinstall`/`postinstall` scripts in dependencies that run network commands (`curl`, `wget`), download binaries, or execute encoded commands. Standard build steps (`tsc`, `node-gyp`, `esbuild`) are NOT suspicious.
- **Obfuscated code:** Flag dependencies containing base64-encoded strings longer than 100 characters, dynamic code evaluation on decoded content, or hex-encoded payloads.
- **Package age:** Flag dependencies published less than 7 days ago with very few downloads — these may be newly-published malicious packages.
- **Permission overreach:** Flag packages that access filesystem, network, or child_process when their stated purpose does not require it (e.g., a "color formatting" library making HTTP requests).

### Reference
The Snitch CLI and GitHub Action perform this scan deterministically against the OSV.dev database (`snitch scan`, or push a PR with the Action) — findings appear severity-bucketed with CVE links and affected ranges. In pure-skill mode (no network), run the Active Audit Step above and additionally enumerate pinned deps in the lockfiles, flagging anything visibly old or matching a known advisory pattern; precision is lower than the deterministic OSV path, so mark version-heuristic findings Medium confidence or below.
