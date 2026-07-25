## CATEGORY 33: Unused Dependencies, Dead Code & Package Bloat
> Type: posture · Groups: infra-supply-chain · CWE: CWE-1104

The "unused surface area" problem: every dep that installs and every line that ships is something an attacker can study, exploit, or compromise via supply chain — and reviewers don't audit dead code. Covers unused packages, dead files/exports, and package bloat.

### Detection
- Manifests: `package.json` (`dependencies` / `devDependencies`), `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `Gemfile`, `pom.xml`, `composer.json`, `*.csproj`, `go.mod`
- Source files that import or require packages (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.py`, `.go`, `.rs`, `.rb`, `.java`, `.kt`, `.php`, `.cs`)
- Entry-point conventions: `index.*`, `main.*`, files declared in `package.json` `main`/`bin`/`exports`, Python `__init__.py` / `__main__.py` / `setup.py`, Go `package main`, Rust `main.rs` / `lib.rs`

### Active Check Step
For each package listed under `dependencies` (not devDependencies), grep the entire codebase for any import or require of that package:

```
import ... from 'package-name'
require('package-name')
import('package-name')
```

If zero hits are found in source files (excluding `node_modules/`), the package is a candidate for removal. Apply the same declared-but-never-referenced check to other ecosystems' manifests.

### What to Search For
- **Unused dependencies**: manifest entries whose package name is never imported/required/`use`d anywhere in the source tree
- **Dead files**: source files with zero inbound imports and not in the entry-point set (treat tests as entry points — a file imported only by a test isn't "dead")
- **Dead exports**: top-level exported functions/classes/consts whose names appear nowhere else in the codebase (framework-convention exports excepted — see NOT Vulnerable)
- **Commented-out code blocks** left as "documentation" — they go stale, mislead readers, and may contain leaked secrets or vulnerable patterns
- **Vendored copies** of upstream packages in `vendor/` or `third_party/` no longer referenced by the build system
- Large packages with lightweight alternatives:
  - `moment` (330KB) → `date-fns`, `dayjs`, or native `Intl.DateTimeFormat`
  - `lodash` → individual `lodash/function` imports or native JS equivalents
  - `request` (deprecated) → `fetch` (built into Node 18+) or `axios`
  - `node-fetch` → native `fetch` (Node 18+ has it built in)
  - `bluebird` → native `Promise`
- Duplicate functionality packages (e.g., both `axios` AND `node-fetch` installed)
- Build/dev tools listed under `dependencies` instead of `devDependencies`: `eslint`, `prettier`, `typescript`, `jest`, `vitest`, `webpack`, `vite`, `esbuild`, `@types/*`, linting configs, test frameworks, build plugins

### Actually Vulnerable
- Package in `dependencies` with zero import hits in any source file — pure attack surface, zero benefit; especially dangerous when the unused package has known CVEs (cross-reference Category 27)
- Postinstall / preinstall hooks on unused packages — they still run on `npm install` even if never imported (see also Category 66)
- A file containing sensitive logic (auth, payment, crypto) no longer reachable from any entry point — it ships unaudited and is exploitable via a forgotten import path
- A vendored fork of a popular library, unmaintained and unreferenced — feeds dependency-confusion attacks if a name collision is later introduced
- Deprecated packages (`request`, `node-fetch` on Node 18+, `unirest`)
- Dev tools accidentally placed under `dependencies`
- Both `axios` and `node-fetch` (or similar duplicates) installed — pick one
- `moment` used for simple date formatting when native `Intl` would work; full-library `lodash` import for 1-2 functions

### NOT Vulnerable
- Packages legitimately imported somewhere in source code
- `devDependencies` that are build tools correctly placed; `peerDependencies` (declarative, not installed here)
- Packages used only in config files (e.g., `tailwindcss` required by `tailwind.config.js`) or npm scripts (e.g., `dotenv` via `node -r dotenv/config`) — flag only when a tool isn't in any config either
- Framework-convention entry points: Next.js pages/`getServerSideProps`, Django views/admin, Rails controllers, Spring beans — the framework imports them at runtime via path-based discovery
- Library projects' public-API exports intentionally exported for downstream consumers
- Files explicitly marked allowed: `// snitch-allow: dead-file` comment, or a path listed in `.snitch-ignore`

### Context Check
1. Search for `import` AND `require` of the package name across all non-node_modules source files
2. Check config files and npm scripts — some packages are loaded there, not in src
3. Is it a peer dependency required by another installed package?
4. Is `devDependencies` placement correct vs `dependencies`?
5. Are there dynamic imports (`import()`, `require(varName)`, `__import__`) static analysis can't follow? Those create false-positive dead files
6. Monorepo? Make sure the import graph crosses package boundaries before declaring something dead
7. Tree-shaking build step? Runtime impact of dead code is reduced, but the review concern (auditors skipping dead branches that still ship) remains

### Evidence Chain
- The manifest entry at file:line declaring the unused dependency (or the dead file/export path)
- The search actually performed: the import/require/dynamic-import patterns grepped across the source tree (excluding `node_modules/`), with zero hits stated
- Config files and npm scripts checked and confirmed absent (`tailwind.config.*`, `next.config.*`, `jest.config.*`, `vite.config.*`, the `scripts` block, `node -r` preloads)
- For dead files/exports: proof of zero inbound imports plus confirmation the file is not in the entry-point set or covered by a framework convention
- The impact link: why this entry is attack surface — known CVEs (Category 27), install hooks that still run (Category 66), or unaudited sensitive logic shipping in a dead file

### Confidence Scoring
- **High**: zero references after searching source files, config files, and npm scripts; no dynamic-import patterns or monorepo cross-package imports in play. Also High: a dev tool unambiguously listed under `dependencies`, or a deprecated/duplicate package visible in the manifest itself.
- **Medium**: zero source imports found, but framework path-based discovery or config-file loading could not be fully ruled out; large-package-with-lightweight-alternative findings (usage exists, replacement is judgment).
- **Low**: dynamic imports (`import()`, `require(varName)`, `__import__`), monorepo boundaries, or runtime plugin loading make the import graph unresolvable — tag `needs human verification`.

### Files to Check
- Every manifest listed under Detection (scan every entry under `dependencies`)
- `**/src/**/*.{ts,tsx,js,jsx}`, `**/app/**/*.{ts,tsx}`, `**/pages/**/*.{ts,tsx}`
- Config files: `tailwind.config.*`, `next.config.*`, `jest.config.*`, `vite.config.*`
- `vendor/**`, `third_party/**` (referenced by the build or dead weight?)

### Reference
Enumerate every manifest entry and grep the source for matching imports, grouping unused deps by ecosystem and dead files by directory. Precision is limited because framework conventions and dynamic imports cannot be resolved reliably this way — mark such findings Medium confidence or below. If the project already has a dedicated dead-code tool wired up (depcheck, knip, ts-prune, vulture), run it and prefer its output; an import-graph parser resolves cases grep cannot.
