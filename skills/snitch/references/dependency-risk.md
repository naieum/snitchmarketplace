# Dependency Risk Scoring

This reference describes how to score the risk level of each project dependency based on maintenance status, known vulnerabilities, and other health indicators.

## Overview

Not all dependencies carry the same risk. A well-maintained package with no known CVEs is far less risky than an abandoned package with unpatched vulnerabilities. This scoring system helps prioritize remediation efforts and provides actionable data for dependency management decisions.

## Risk Factors

### Factor 1: Last Publish Date

Evaluate how recently the package was updated:

- **Active** -- Published within the last 12 months
- **Stale** -- Published 12-24 months ago
- **Unmaintained** -- Not published in over 24 months

### Factor 2: Known CVEs

Check for known vulnerabilities:

- **Clean** -- No known CVEs affecting the installed version
- **Low-severity CVEs** -- Only low/informational CVEs
- **High-severity CVEs** -- One or more high/critical CVEs

### Factor 3: Maintenance Status

Assess the overall health of the project:

- **Healthy** -- Active commits, responsive to issues, multiple maintainers
- **Minimal** -- Sporadic commits, slow issue response
- **Abandoned** -- No commits in 24+ months, archived repository, or maintainer has stated end-of-life

### Factor 4: Dependency Depth

Consider the transitive dependency footprint:

- **Shallow** -- Few or no transitive dependencies
- **Moderate** -- 10-50 transitive dependencies
- **Deep** -- 50+ transitive dependencies (larger attack surface)

## Scoring Matrix

### High Risk

A dependency is scored **High** if ANY of the following are true:
- Unmaintained (no publish in 24+ months) AND has known CVEs of any severity
- Has one or more critical/high-severity CVEs regardless of maintenance status
- Abandoned with a deep transitive dependency tree

### Medium Risk

A dependency is scored **Medium** if ANY of the following are true (and none of the High criteria are met):
- Unmaintained but no known CVEs
- Active but has low-severity CVEs
- Stale with a deep transitive dependency tree
- Missing or unclear license (cross-reference with license-scan.md)

### Low Risk

A dependency is scored **Low** if ALL of the following are true:
- Active (published within 12 months)
- No known CVEs
- Healthy maintenance indicators
- Permissive license

## Process

### 1. Gather Data for Each Dependency

For each direct and transitive dependency, collect:

| Field | Source |
|-------|--------|
| Package name | Lockfile |
| Installed version | Lockfile |
| Latest version | Registry API |
| Last publish date | Registry API (e.g., `npm view <pkg> time`) |
| Known CVEs | `npm audit`, OSV.dev, or GitHub Advisory Database |
| Maintenance status | Repository activity, contributor count |
| Transitive dependency count | Dependency tree analysis |

### 2. Apply Scoring

Evaluate each dependency against the scoring matrix and assign High, Medium, or Low.

### 3. Add Risk Column to Findings Table

Augment the Snitch Category 27 (Dependencies) findings table with a risk column:

| Package | Version | CVEs | Last Published | Maintenance | Risk Score |
|---------|---------|------|----------------|-------------|------------|
| example-lib | 1.2.3 | CVE-2024-1234 | 2023-01-15 | Unmaintained | High |
| helper-pkg | 4.5.6 | None | 2025-11-01 | Active | Low |
| old-util | 0.9.1 | None | 2022-06-30 | Abandoned | Medium |

### 4. Recommend Actions

For each risk level, suggest actions:

- **High** -- Replace immediately. Identify alternative packages or inline the needed functionality.
- **Medium** -- Plan replacement. Monitor for new CVEs. Consider pinning versions.
- **Low** -- No immediate action. Include in regular dependency update cycles.

## Integration with Compliance

Dependency risk scores support:
- **PCI-DSS Requirement 6.2** -- Demonstrating secure development practices for third-party components
- **SOC 2 CC7.1** -- Vulnerability management evidence
- **SOX Section 404** -- Internal controls over software supply chain

## Automation

Run dependency risk scoring:
- As part of every Snitch audit
- On pull requests that modify dependency files
- On a scheduled basis (weekly or monthly) to catch newly disclosed CVEs
