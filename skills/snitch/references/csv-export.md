# CSV Export Format

Generate `findings.csv` in the project root.

## Columns

```
Severity,Priority,CWE,OWASP,File,Line,Title,Confidence,BlastRadius,Status
```

## Formatting Rules

- Quote all string values containing commas
- Escape internal quotes with double-quotes
- UTF-8 encoding
- First row is the header
- One row per finding (ungrouped -- expand grouped findings into individual rows)
- BlastRadius: leave empty for Medium/Low findings
- Status: "Open" for all findings, "Suppressed" for .snitch-ignore entries

## Example Row

```
Critical,P1 (Quick Win),CWE-798,A07:2025,src/config.ts,12,"Hardcoded Stripe API key",High,"Public API, payment data",Open
```
