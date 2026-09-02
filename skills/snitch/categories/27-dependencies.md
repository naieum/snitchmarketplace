## CATEGORY 27: Dependency Vulnerabilities / Supply Chain
> Type: posture · Groups: infra-supply-chain · CWE: CWE-1395

Software composition analysis (SCA) plus supply-chain behavior checks. Code review is necessary but not sufficient when 80-90% of a typical app's bytes come from third-party packages: this category targets the manifests and lockfiles themselves, across npm, PyPI, Go, Rust, Ruby, Maven, PHP, and NuGet.

### Detection
- Manifests: `package.json`, `pyproject.toml`, `setup.py`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, `*.csproj`
- Lockfiles: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Pipfile.lock`, `uv.lock`, `Cargo.lock`, `go.sum`, `Gemfile.lock`, `composer.lock`, `packages.lock.json`, `gradle.lockfile`
- CI/CD dependency installation steps; project metadata that pins transitive versions

### Active Audit Step (REQUIRED)
Run the appropriate audit command for the project's package manager. This gives authoritative CVE data — do not skip it:

**If there is no lockfile, the audit fails with `ENOLOCK` — do not stop there, and do not recommend the step back to the user.** A dependency report whose conclusion is "run `npm audit`" has handed the work back and will miss everything; this is the single most common way this category fails in practice. Materialize a lockfile **outside the scan target** and audit that:

```
mkdir -p /tmp/snitch-audit && cp package.json /tmp/snitch-audit/
cd /tmp/snitch-audit && npm i --package-lock-only --ignore-scripts --no-audit
npm audit --json
```

**`--ignore-scripts` is not optional and `--package-lock-only` is not either.** npm's own `ENOLOCK` message suggests `npm i --package-lock-only`, and it is one keystroke from a plain `npm i` — which would execute the very `postinstall` hooks this category exists to inspect, and write `node_modules/` into the user's repository, breaking the read-only scan phase (SKILL.md Rule 6). Never run an install in the scan target. Python: `pip-audit -r requirements.txt`; Ruby: `bundle audit check --update` against the committed `Gemfile.lock`.

```
npm audit --json          # npm
pnpm audit --json         # pnpm
yarn audit --json         # Yarn 1.x (classic)
yarn npm audit --json     # Yarn Berry (2+); `yarn audit` does not exist there
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
- **Low/Moderate in devDependencies** — note but mark as lower priority
- **Critical or High in devDependencies** — still report at its severity. A dev-server or test-runner RCE executes on developer machines and in CI, which is where the credentials are. "It doesn't ship to production" bounds the blast radius, not the severity
- **`MAL-` prefixed OSV advisories** (known-malicious packages) — always Critical, regardless of scope. Note these come from `osv-scanner` or a direct OSV query; `npm audit` / `yarn audit` / `pip-audit` do not emit `MAL-` identifiers, so absence in their output is not evidence of absence

### What to Search For
- Missing lockfile entirely (non-deterministic installs); mixed lockfile + bare manifest where the lockfile is stale
- Wildcard or open-ended version ranges (`"lodash": "*"`, `requests>=2`, `serde = "*"`, `latest`) — "whatever resolves at install time" is a security regression risk
- `postinstall` scripts in dependencies doing suspicious things (network calls, file writes outside package)
- Typosquatting indicators (packages with names very similar to popular ones — `reqeusts`, `lodahs`, `cross-fetch-cjs`; helpers for big-name projects published by unknown maintainers)
- Pinned to very old versions of security-critical packages (e.g., `express` v3, `jsonwebtoken` v7); direct deps pinned more than 2 years old with no comment explaining why
- Dependencies with known CVEs in the locked version, and transitive deps with published advisories. **Resolve the affected range from the audit output or OSV — never from a version written here.** Packages worth checking first because they recur and are widely deployed: `lodash`, `log4j`, `requests`, `urllib3`, `axios`, `tar-fs`, `postcss`, `request`, `node-fetch`, `minimist`.
  Any threshold in this file would be a **false negative generator**: a stale "safe above X" reads as a Pass, and the scanner writes a confident clean result on an affected version. Four such thresholds previously written here were each checked against OSV and all four were wrong — every one named a "safe" version that had since acquired advisories. Names age well; numbers do not.
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
- **For an install-hook or supply-chain-behavior finding, the execution context**: the CI trigger (`on:`), the checkout ref, and whether the job holds secrets. An install hook is a Medium on its own and a Critical when a `pull_request_target` workflow checks out the PR head and installs — report that as one chained finding with both halves in the evidence, not as two separate items
- For behavior findings (typosquat, postinstall, obfuscation): the script or `package.json` snippet file:line showing the suspicious behavior

### Confidence Scoring
- **High**: audit command output matches a Critical/High advisory to the exact locked version; or a `MAL-` advisory / confirmed typosquat / postinstall script that downloads and executes remote code — especially when reachability is confirmed or the package is a production dependency
- **Medium**: version-heuristic finding without deterministic audit output (visibly old pin, open-ended range, missing lockfile), or an advisory match where reachability could not be established
- **Low**: name-similarity or package-age heuristics alone, or a transitive resolution that cannot be confirmed from the lockfile — tag `needs human verification`

### Files to Check
- All manifests and lockfiles listed under Detection
- `.github/workflows/*.yml` (check for audit steps)
- `.npmrc`, `.yarnrc.yml` (registry configuration)

### Reading the audit output

**npm rolls transitive severity up to the parent.** A top-level package can appear with `severity: high` and a version range while having **no advisory of its own** — the severity belongs to something in its tree. The tell is the `via` array: **advisory objects** mean the package itself is affected; **plain strings** name the dependency path and mean the finding belongs to a child. Report the child, name the parent as the path, and do not write "package X has CVE-Y" when `via` holds strings — that is a false positive generated by the authoritative step, and it survives Rules 1–4 because the tool output *is* the evidence.

Also: `fixAvailable` is either `false` or an object — never assume a shape. `false` on an EOL package means the fix is **removal or replacement**, not an upgrade; say so rather than recommending a version bump that does not exist.

**Advisory enrichment (Critical/High only).** The audit command gives the CVE/GHSA id, severity bucket, affected range, and patched version. For a Critical or High advisory, look the identifier up in the GitHub Advisory Database (`https://github.com/advisories?query=<CVE or GHSA id>`) to add exploit availability and the CVSS vector to the finding, then cite the advisory URL in the Evidence block. Cap this at five lookups per scan, highest severity first, and skip it entirely for Low and Moderate — the local audit output is already authoritative for those. Where the network is unavailable, say so in the finding rather than guessing the exploit status.

**Deprecation is registry metadata, not an advisory.** A deprecated package returns nothing from OSV and nothing from `npm audit`. Read the `deprecated` field on entries in the generated lockfile, or `npm view <pkg> deprecated`. Formally deprecated dependencies are durable findings that no advisory feed will ever surface.

### Reachability Analysis

After finding CVEs via the audit command, perform a reachability check to reduce noise. **It only ever downgrades on evidence you actually have.** If the project's source is not in scope, or the import graph cannot be resolved, reachability is **unknown** — keep the severity and record it as unknown per SKILL.md Rule 7, which caps un-traceable findings at Low *confidence* while keeping the finding. Do not treat "I could not check" as "not reachable": a manifest-only scan would otherwise downgrade every CVE in the project to Informational and report nothing.

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
- **Suspicious install scripts:** Flag `preinstall`/`postinstall` scripts that run network commands (`curl`, `wget`), download binaries, or execute encoded commands — **in the project's own `package.json` scripts block as well as in dependencies**. Read the project manifest first: a committed install hook is attacker-supplied to everyone who clones and runs in CI before any test, which makes it higher-signal than the same pattern in a third-party package. Standard build steps (`tsc`, `node-gyp`, `esbuild`) are NOT suspicious. When scoring one, check what the CI workflow runs it under — an install hook reached by `pull_request_target` with a PR-head checkout executes attacker-controlled content in a job holding repository secrets.
- **Obfuscated code:** Flag dependencies containing base64-encoded strings longer than 100 characters, dynamic code evaluation on decoded content, or hex-encoded payloads.
- **Package age:** Flag dependencies published less than 7 days ago with very few downloads — these may be newly-published malicious packages.
- **Permission overreach:** Flag packages that access filesystem, network, or child_process when their stated purpose does not require it (e.g., a "color formatting" library making HTTP requests).

### Reference
The Active Audit Step above is the authoritative path — the package manager's own audit command queries the live advisory database, so it returns severity buckets, CVE links, and affected ranges that no amount of version-guessing can reproduce. Run it. Where the network is unavailable, enumerate pinned deps in the lockfiles and flag anything visibly old or matching a known advisory pattern; precision drops sharply without advisory data, so mark version-heuristic findings Medium confidence or below and say in the finding that no advisory lookup was possible.
