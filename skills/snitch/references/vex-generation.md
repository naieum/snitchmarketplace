# VEX (Vulnerability Exploitability eXchange) Generation

This reference describes how to generate VEX documents from Snitch dependency findings.

## Overview

VEX documents communicate the exploitability status of vulnerabilities in the context of the specific product being assessed. When Snitch identifies CVEs through dependency scanning (Category 27 (Dependencies)), a VEX document helps downstream consumers understand whether those vulnerabilities are actually exploitable in your application.

## Format

Use the CycloneDX VEX JSON format. The output file should be named `VEX.cdx.json`.

## Process

### 1. Collect Dependency Findings

Run `npm audit --json` (or the equivalent for your package manager) and collect all CVE identifiers from the output. Cross-reference these with Snitch Category 27 (Dependencies) findings.

### 2. Create VEX Entries

For each CVE found, create a VEX entry with the following fields:

- **vulnerability.id** -- The CVE identifier (e.g., `CVE-2024-12345`)
- **vulnerability.source** -- The source database (e.g., `NVD`, `GitHub Advisory`)
- **vulnerability.ratings** -- CVSS score and severity from the advisory
- **affected.ref** -- BOM reference to the affected component (package name and version)
- **analysis.state** -- One of:
  - `exploitable` -- The vulnerability is confirmed exploitable in this application
  - `not_affected` -- The vulnerability does not affect this application (e.g., the vulnerable code path is not reachable)
  - `under_investigation` -- The exploitability has not yet been determined
  - `resolved` -- The vulnerability has been remediated
  - `false_positive` -- The detection was incorrect
- **analysis.justification** -- Required when state is `not_affected`. One of:
  - `code_not_present` -- The vulnerable code is not present in the used version
  - `code_not_reachable` -- The vulnerable code path is not reachable from the application
  - `requires_configuration` -- The vulnerability requires a specific configuration not used
  - `requires_dependency` -- Exploiting requires another dependency not present
  - `requires_environment` -- The runtime environment prevents exploitation
  - `protected_by_mitigating_control` -- Another control prevents exploitation
- **analysis.detail** -- Free-text explanation of the analysis

### 3. Document Structure

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "version": 1,
  "metadata": {
    "timestamp": "<ISO-8601 timestamp>",
    "tools": [
      {
        "vendor": "Snitch",
        "name": "snitch-security-audit",
        "version": "<scan version>"
      }
    ]
  },
  "vulnerabilities": [
    {
      "id": "CVE-YYYY-NNNNN",
      "source": {
        "name": "NVD",
        "url": "https://nvd.nist.gov/vuln/detail/CVE-YYYY-NNNNN"
      },
      "ratings": [
        {
          "score": 7.5,
          "severity": "high",
          "method": "CVSSv31"
        }
      ],
      "affects": [
        {
          "ref": "pkg:npm/example-package@1.2.3"
        }
      ],
      "analysis": {
        "state": "not_affected",
        "justification": "code_not_reachable",
        "detail": "The vulnerable function is never called in our application."
      }
    }
  ]
}
```

### 4. Save the Output

Save the completed VEX document as `VEX.cdx.json` in the project root or the designated security artifacts directory.

## Integration with Compliance

VEX documents can be referenced in:
- **PCI-DSS Requirement 6.3** -- As evidence of vulnerability triage
- **SOC 2 CC7.1** -- As part of vulnerability management documentation
- **HIPAA 164.312(c)** -- As evidence of integrity controls over known vulnerabilities

## Maintenance

Re-generate the VEX document:
- After each Snitch scan that identifies new CVEs
- When dependency versions change
- When analysis states are updated (e.g., after investigation completes)
