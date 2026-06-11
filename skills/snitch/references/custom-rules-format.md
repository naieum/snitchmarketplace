# Custom Rules Format

Custom rule files follow the same structure as built-in category files.

## File Structure

```markdown
## CUSTOM: [Rule Name]

### Detection
- What imports, patterns, or file types indicate this rule applies
- Framework or library-specific indicators

### What to Search For
- Grep patterns (regex)
- Glob patterns for relevant files
- Specific function or variable names

### Actually Vulnerable
- Concrete examples of real issues
- What makes the pattern dangerous in your codebase

### NOT Vulnerable (False Positives)
- Common patterns that look similar but are safe
- Organization-specific exceptions

### Context Check
- Questions to verify before reporting
- Mitigations to look for

### Files to Check
- Glob patterns: `src/**/*.ts`, `api/**/*.py`, etc.
```

## Naming

Use descriptive names: `internal-api-auth.md`, `pii-handling.md`, `legacy-db-access.md`.
No category numbers -- custom rules are unnumbered.

## Location

Place files in `custom-rules/` next to this SKILL.md.
See `custom-rules/example-internal-api.md` for a working template.
