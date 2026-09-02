# SARIF 2.1.0 Output Format

Generate `SECURITY_AUDIT_REPORT.sarif` in the project root.

## Schema
- `$schema`: `https://json.schemastore.org/sarif-2.1.0.json`
- `version`: `2.1.0` — the SARIF spec version, not the skill's
- `tool.driver.version`: read `metadata.version` from this skill's `SKILL.md` frontmatter and copy it
  verbatim. Never hardcode it here; a stale driver version makes every exported result look like it
  came from a build that no longer exists
- `tool.driver.informationUri`: `metadata.homepage` from the same frontmatter

## Structure

```json
{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [{
    "tool": {
      "driver": {
        "name": "snitch",
        "version": "<metadata.version from SKILL.md>",
        "informationUri": "https://snitchplugin.com",
        "rules": []
      }
    },
    "results": []
  }]
}
```

## Rule Mapping (tool.driver.rules)

Each unique CWE in the findings becomes a rule:

```json
{
  "id": "SNITCH-CWE-89",
  "shortDescription": { "text": "SQL Injection" },
  "fullDescription": { "text": "User input concatenated into SQL query without parameterization" },
  "help": { "text": "Use parameterized queries or prepared statements" },
  "properties": {
    "tags": ["security"],
    "security-severity": "8.5"
  }
}
```

## Result Mapping (results)

Each finding becomes a result:

```json
{
  "ruleId": "SNITCH-CWE-89",
  "level": "error",
  "message": { "text": "SQL Injection in getUserById -- user input concatenated into query" },
  "locations": [{
    "physicalLocation": {
      "artifactLocation": { "uri": "src/db/users.ts", "uriBaseId": "%SRCROOT%" },
      "region": { "startLine": 47 }
    }
  }],
  "partialFingerprints": {
    "primaryLocationLineHash": "src/db/users.ts:47:CWE-89"
  }
}
```

## Level Mapping

| Severity | SARIF level |
|----------|-------------|
| Critical | error |
| High | error |
| Medium | warning |
| Low | note |

## security-severity Mapping

Use the CVSS 4.0 score as a string: `"9.1"`, `"7.5"`, `"4.2"`, `"2.0"`

## File Name

Save as `SECURITY_AUDIT_REPORT.sarif` in the project root alongside the markdown report.

## GitHub Upload

After generating, the user can upload via:
```sh
gh api repos/{owner}/{repo}/code-scanning/sarifs -f sarif=@SECURITY_AUDIT_REPORT.sarif -f ref=refs/heads/main
```
