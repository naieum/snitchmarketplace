## CATEGORY 69: Vulnerable Dependencies (SCA)

Software composition analysis. Code reviews are necessary but not sufficient when 80–90% of a typical app's bytes come from third-party packages. This category targets the package manifests themselves: lockfiles and dependency lists for npm, PyPI, Go, Rust, Ruby, Maven, PHP, and NuGet. The Snitch CLI and GitHub Action perform this scan deterministically against the OSV.dev database; this category exists in the methodology so the Plugin and human reviewers know what signal to look for when running Snitch in pure-skill mode (no network).

### Detection
- Lockfiles: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `requirements.txt`, `poetry.lock`, `Pipfile.lock`, `uv.lock`, `Cargo.lock`, `go.sum`, `Gemfile.lock`, `composer.lock`, `packages.lock.json`, `gradle.lockfile`
- Manifests: `package.json`, `pyproject.toml`, `setup.py`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, `*.csproj`
- Project metadata files that pin transitive versions

### What to Search For
- Direct dependencies pinned to versions older than 2 years with no comment explaining why
- Transitive dependencies known to have published advisories (lodash <4.17.21, log4j <2.17.1, requests <2.32.0, urllib3 <2.0, axios <1.6.0, tar-fs old versions, postcss old versions, etc.)
- Wildcard or open-ended version ranges (`"lodash": "*"`, `requests>=2`, `serde = "*"`) that mean "give me whatever resolves at install time" — security regression risk
- Mixed lockfile + bare `package.json` — the lockfile is the source of truth at install time; if it's missing, transitive deps are uncontrolled
- Suspicious package names: typosquats of popular packages (`reqeusts`, `cross-fetch-cjs`, `lodahs`), packages claiming to be helpers for big-name projects but published by unknown maintainers
- Postinstall / preinstall hooks in untrusted dependencies (`scripts.postinstall` in package.json that runs a shell script — see also Category 66)
- Dev-only deps that ship to production by mistake (e.g., `devDependencies` referenced in production code)

### Actually Vulnerable
- A pinned version that matches a `CRITICAL` or `HIGH` OSV / GHSA / CVE advisory
- A pinned version older than 6 months in a high-vulnerability ecosystem (npm, Maven) with no upgrade path documented
- A `requirements.txt` with no constraints (e.g., `django` with no version) and no `--hash` pin — supply chain attack surface
- A `package.json` with `latest` or `*` ranges in production and no lockfile committed
- Transitive deps that resolve to known-malicious packages (npm has a registry of yanked-malicious entries; OSV surfaces them via `MAL-` prefixed advisories)
- A lockfile pinning a yanked or deprecated package with a successor available

### NOT Vulnerable
- Dependencies pinned to recent versions, with a recent (< 30 day) update commit
- Dependencies pinned to versions outside any OSV-published vulnerable range
- Internal / forked packages where the org maintains its own security review
- Lockfile-pinned transitive versions where the pin is intentional (e.g., overrides in `package.json` `overrides` or `resolutions`)

### Context Check
1. Is there a lockfile, and is it checked into git?
2. Are there any deps older than 2 years with no maintenance comment?
3. Does the project run `npm audit` / `pip-audit` / `cargo audit` / equivalent in CI?
4. Are version ranges constrained (`^1.2.3` or `~1.2.3` or pinned), or open-ended (`*`, `latest`)?
5. Are postinstall / build-time scripts on untrusted packages reviewed before they run?
6. For supply-chain risk: does the team review new transitive deps before they land?

### Reference
The Snitch CLI and GitHub Action automatically perform this scan against OSV.dev with no extra configuration. Run `snitch scan` (CLI) or push a PR (Action) and dependency findings appear inline with code findings, severity-bucketed, with CVE links and the affected version range. Plugin users running this category in chat-skill mode should ask the AI to enumerate every pinned dep in the project's lockfiles and flag anything visibly old or matching a known advisory pattern from training data; precision will be lower than the deterministic OSV path.
