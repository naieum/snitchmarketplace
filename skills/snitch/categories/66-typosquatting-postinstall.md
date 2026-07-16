## CATEGORY 66: Typosquatting & Malicious Install Scripts
> Type: posture · Groups: infra-supply-chain · CWE: CWE-1357

Category 27 (Dependencies) handles known-CVE audit against the package database. This category catches supply-chain risk BEFORE a CVE is published: typosquatted names, dependency confusion, and lifecycle scripts that run on install.

### Detection
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`
- `requirements.txt`, `Pipfile`, `pyproject.toml`, `poetry.lock`, `uv.lock`
- `Gemfile`, `Gemfile.lock`, `composer.json`, `go.mod`, `Cargo.toml`

### What to Search For
- Package names that are one-edit-distance off a popular package (`reqeusts` vs `requests`, `expres` vs `express`, `crossenv` vs `cross-env`, `axois` vs `axios`, `lodahs` vs `lodash`)
- Packages matching the name of a known internal/scoped package but installed from the public registry (dependency confusion — `@yourorg/foo` expected, bare `foo` present)
- Scoped packages with a scope the organization does not own
- Packages with suspicious naming signals: single-character differences from top-1000 packages, homoglyphs (`rn` vs `m`, Cyrillic lookalikes), trailing digits (`express2`, `react-dom-util`)
- `package.json` lifecycle scripts that do anything beyond a build step: `preinstall`, `install`, `postinstall`, `prepare`, `prepublish`, `prepublishOnly` executing network fetches, shell pipelines, or base64/hex-decoded payloads
- Python packages with `setup.py` that runs code at install time (any non-trivial logic in `setup.py` is a red flag vs `pyproject.toml`)
- Git-URL dependencies (`"pkg": "git+https://github.com/..."`) pointing to forks or unverified accounts

### Actually Vulnerable
- Typo-close name with no prior install history in this repo's git log
- A direct dependency whose latest version added a `postinstall` step that was not present in prior versions
- A scoped namespace used in code but not claimed on the public registry (attacker can publish `@yourorg/foo` if the scope is unclaimed)
- Install script that runs `curl | sh`, writes to `~/.ssh`, reads env vars and POSTs them, or decodes obfuscated strings

### NOT Vulnerable
- Canonical/widely-used package, name exactly matches the popular one
- Install script is a clearly legitimate build task (compile native module, generate bindings)
- Private registry or internal mirror configured as the default, with public registry blocked or scope-pinned
- Lockfile pinned to a specific integrity hash that hasn't changed

### Context Check
1. Does the package name exactly match the popular one, or is it a near-miss?
2. When was this dependency added? (Recent adds are higher risk — check `git log` for the lockfile.)
3. Does the install script do anything beyond build? If so, what and why?
4. For scoped packages: does your org actually own that scope on the registry?
5. Is there a private registry / scope-pinning / `.npmrc` config preventing dependency confusion?

### Evidence Chain
- The suspicious package entry quoted from the manifest/lockfile at file:line (name, version, and resolved registry URL where the lockfile records it)
- Why the name is suspect, stated explicitly: the popular package it shadows, the edit distance or homoglyph, or the unclaimed scope
- For install scripts: the lifecycle script quoted verbatim from `package.json` / `setup.py` at file:line, with what it executes (network fetch, shell pipeline, decoded payload)
- Reachability/impact link: whether the package actually installs (direct vs dev vs transitive dependency; lockfile presence) and which host executes the script (developer machine, CI runner)
- Registry configuration checked and quoted or shown absent: `.npmrc` / `.yarnrc` scope pinning, private-registry default, integrity hashes in the lockfile

### Confidence Scoring
- **High**: exact typosquat of a top package, an unclaimed scope your code depends on, or an install script quoted verbatim doing network fetch / credential access / obfuscated-payload execution
- **Medium**: near-miss name or unverifiable git-URL dependency, or an install script that does more than build but has a plausible legitimate purpose (native compile, codegen) that could not be confirmed
- **Low**: heuristic naming signal only (trailing digits, unusual scope, recent add) with no corroborating registry or script evidence — tag `needs human verification`

### Files to Check
- `package.json` (all — root and in every workspace)
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`
- `.npmrc`, `.yarnrc`, `.yarnrc.yml` (registry + scope config)
- `setup.py`, `pyproject.toml` (for Python install-time code)
- `Gemfile`, `composer.json`, `go.mod`, `Cargo.toml`

### Reference
- CWE-1357: Reliance on Insufficiently Trustworthy Component
- CWE-1395: Dependency on Vulnerable Third-Party Component
- OWASP Top 10:2025 — A03 Software Supply Chain Failures
- CVSS 4.0: typically Critical if install script executes (AV:L/N, AC:L, RCE on dev/CI host)
