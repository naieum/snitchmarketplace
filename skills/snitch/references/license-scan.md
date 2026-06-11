# License Compliance Deep Scanning

This reference describes how to perform license compliance scanning on project dependencies and generate a license report.

## Overview

License compliance scanning identifies the licenses used by all direct and transitive dependencies. This is critical for projects that must avoid copyleft licenses (GPL, AGPL) in proprietary codebases, or that need to track license obligations for legal review.

## Process

### 1. Parse Dependencies from Lockfile

Extract all dependencies (direct and transitive) from the project lockfile:

- **npm/Node.js** -- Parse `package-lock.json` or `yarn.lock`
- **Python** -- Parse `requirements.txt`, `Pipfile.lock`, or `poetry.lock`
- **Go** -- Parse `go.sum`
- **Rust** -- Parse `Cargo.lock`
- **Java** -- Parse `pom.xml` or `build.gradle.lockfile`

For each dependency, record:
- Package name
- Version
- Registry source

### 2. Check License Field

For each dependency, determine the declared license:

- **npm packages** -- Read the `license` field from the package's `package.json` (available via `npm info <package> license`)
- **Python packages** -- Check the `License` classifier in package metadata
- **Go modules** -- Check the LICENSE file in the module source
- **General** -- Look for LICENSE, LICENSE.md, LICENSE.txt, or COPYING files in the package source

Record the SPDX identifier when available (e.g., `MIT`, `Apache-2.0`, `GPL-3.0-only`).

### 3. Flag Problematic Licenses

Flag the following conditions:

**High Risk -- Copyleft in Proprietary Projects:**
- `GPL-2.0-only`, `GPL-2.0-or-later`, `GPL-3.0-only`, `GPL-3.0-or-later`
- `AGPL-3.0-only`, `AGPL-3.0-or-later`
- `LGPL-2.1-only`, `LGPL-3.0-only` (when statically linked)
- `EUPL-1.2`, `MPL-2.0` (context-dependent)

**Medium Risk -- Missing or Unclear:**
- No license field declared
- `UNLICENSED` or `UNKNOWN`
- Custom or non-standard license text
- Dual-licensed packages requiring choice

**Low Risk -- Permissive (Generally Safe):**
- `MIT`, `ISC`, `BSD-2-Clause`, `BSD-3-Clause`
- `Apache-2.0` (note: includes patent grant)
- `0BSD`, `CC0-1.0`, `Unlicense`

### 4. Generate LICENSE_REPORT.md

Produce a report with the following structure:

```markdown
# License Compliance Report

**Project:** <project name>
**Scan Date:** <date>
**Total Dependencies:** <count>

## Summary

| Risk Level | Count |
|------------|-------|
| High       | <n>   |
| Medium     | <n>   |
| Low        | <n>   |

## High-Risk Findings

| Package | Version | License | Risk | Notes |
|---------|---------|---------|------|-------|
| example | 1.0.0   | GPL-3.0 | High | Copyleft in proprietary project |

## Medium-Risk Findings

| Package | Version | License | Risk | Notes |
|---------|---------|---------|------|-------|
| unknown-pkg | 2.1.0 | UNLICENSED | Medium | No license declared |

## Full Dependency License Table

| Package | Version | License | Risk |
|---------|---------|---------|------|
| ...     | ...     | ...     | ...  |
```

Save as `LICENSE_REPORT.md` in the project root or the designated security artifacts directory.

## Integration with Compliance

License scanning results support:
- **SOC 2 CC8.1** -- Change management (tracking third-party components)
- **PCI-DSS Requirement 6.2** -- Secure development (knowing what is in your software)
- **GDPR Article 25** -- Data protection by design (ensuring dependencies handle data appropriately)

## Automation

Consider running license scans:
- On every pull request that modifies dependency files
- Before each release
- As part of the Snitch audit workflow alongside Category 27 (Dependencies)
