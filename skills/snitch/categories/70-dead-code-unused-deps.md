## CATEGORY 70: Dead Code and Unused Dependencies

Code that ships but isn't reachable, and packages that get installed but never imported. This category covers the "unused surface area" problem: every line that ships and every dep that installs is something an attacker can study, exploit, or compromise via supply chain. The Snitch CLI and GitHub Action perform this scan deterministically (parsers + import graph + cross-reference); this category exists so the Plugin (no network, no toolchain) can prompt the AI to do a heuristic version of the same review.

### Detection
- **Manifests**: `package.json`, `pyproject.toml`, `requirements.txt` (top), `Cargo.toml`, `Gemfile`, `pom.xml`, `composer.json`, `*.csproj`, `go.mod`
- **Source files** in every supported language (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.py`, `.go`, `.rs`, `.rb`, `.java`, `.kt`, `.php`, `.cs`)
- Entry-point conventions: `index.*`, `main.*`, files declared in `package.json` `main`/`bin`/`exports`, Python `__init__.py` / `__main__.py` / `setup.py`, Go `package main`, Rust `main.rs` / `lib.rs`

### What to Search For
- **Unused dependencies**: Top-level entries in a manifest's "dependencies" / "devDependencies" / "require" / "[dependencies]" block where the package name is never `import`ed / `require`d / `use`d / referenced anywhere in the source tree. Include both runtime and dev deps.
- **Dead files**: source files with zero inbound imports and not in the entry-point set. Treat tests as entry points (so a file imported only by a test isn't "dead").
- **Dead exports**: top-level exported functions / classes / consts whose names appear nowhere else in the codebase. Be cautious with frameworks: Next.js page exports (`getServerSideProps`, default exports of `pages/*`), Django admin classes, Rails controllers, etc. are entry points by convention even though static analysis can't see the inbound reference.
- **Commented-out code blocks** that are clearly old implementations left around as "documentation" — they get stale, can mislead readers, and may contain leaked secrets or vuln patterns.
- **Vendored copies** of upstream packages sitting in a `vendor/` or `third_party/` directory that are no longer referenced by the build system.

### Actually Vulnerable
- A direct `dependencies` entry that hasn't been imported in any source file in the last commit history — pure attack surface, zero benefit. Especially dangerous for packages with known CVEs (cross-reference Category 69).
- A file containing sensitive logic (auth, payment, crypto) that is no longer reachable from any entry point. Reviewers don't audit dead code; if it ships in the bundle and gets executed via a forgotten import path, it's exploitable.
- A vendored fork of a popular library that hasn't been updated in years and isn't used anywhere — feeds dependency confusion attacks if a name collision is later introduced.
- Postinstall / preinstall hooks on unused npm packages — they still run on `npm install` even if the package itself is never imported. See also Category 66 (typosquatting and postinstall).

### NOT Vulnerable
- Packages declared in `peerDependencies` (not actually installed at this site, just declarative).
- Test runners and build tools (`vitest`, `webpack`, `tsc`, `pytest`, `pylint`) — referenced by configuration files (vite.config.ts, package.json scripts, pytest.ini), not by source `import` statements. Most analyzers handle this; flag only when a tool ISN'T in any config either.
- Framework-convention entry points: Next.js pages, Django views/admin, Rails controllers, Spring beans. The framework imports them at runtime through path-based discovery, so static analysis flags them as "dead exports" but they're not actually dead.
- Files explicitly marked dead-code-allowed: `// snitch-allow: dead-file` comment, or path matching customer's `.snitch.yml` `dead-code-ignore` glob list.

### Context Check
1. Is there a build step (webpack, esbuild, Vite) that tree-shakes? If yes, the runtime impact of dead code is reduced — but the security review concern (auditors skipping dead branches that still ship) remains.
2. Are framework-convention entry points (Next.js pages, Django URLs) in the codebase? Make sure those are excluded from the dead-files check.
3. Is the project a library that publishes a public API? Then "unused exports" in the publish surface are intentionally exported for downstream consumers.
4. Is there a monorepo with cross-package imports? Make sure the import graph crosses package boundaries before declaring something dead.
5. Are there dynamic imports (`import()`, `require(varName)`, `__import__`) that static analysis can't follow? Those create false-positive dead files.

### Reference
The Snitch CLI and GitHub Action perform this scan automatically alongside the AI code review. Output groups unused dependencies by ecosystem and dead files by directory; the suggested fix is "remove the dep" or "delete the file (or wire it up correctly)." Plugin users running this category in chat-skill mode should ask the AI to enumerate every entry in the project's package manifests and grep the source for matching imports — anything declared but never referenced is a v1 unused-dep candidate. Precision is lower than the deterministic CLI / Action path because the AI can't reliably resolve framework conventions or dynamic imports.
