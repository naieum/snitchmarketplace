# Triage + Suppression Workflow

Findings need to be actionable, not just present. This reference formalizes the mechanisms for triaging findings (accepted / false positive / confirmed), suppressing known-irrelevant findings going forward, and persisting state across audit runs.

## The four states of a finding

After the report is delivered, every finding moves into one of four states:

| State | Meaning | Persisted in |
|---|---|---|
| **Confirmed** | Real issue; team agrees; will be fixed | `.snitch-marketing-triage.json` |
| **Accepted** | Real issue; team chose not to fix (won't fix) — reason recorded | `.snitch-marketing-triage.json` |
| **False positive** | Audit was wrong about this; suppress on future runs | `.snitch-marketing-triage.json` + `.snitch-marketing-ignore` |
| **In-progress** | Being worked on; do not re-flag in subsequent runs while WIP | `.snitch-marketing-triage.json` |

## File: `.snitch-marketing-triage.json`

Lives at project root (source mode) or in the audit working directory (crawl mode). One JSON file.
Each entry is keyed by the finding **fingerprint** defined in `references/finding-identity.md`:
`hash(targetId + ruleId + anchor + instance)`. The anchor carries no line number and no concrete
URL, which is what lets triage state survive a line shift, a re-render, or a URL change. Never key
a triage entry on `file:line` or on a concrete URL.

Each entry also stores its `ruleId`, `anchor`, and `instance` in readable form, so a human can tell
what a fingerprint refers to without recomputing the hash.

### Schema

```json
{
  "version": 1,
  "lastAudit": "2026-04-30T14:22:11Z",
  "findings": {
    "f3a91c7e0b42": {
      "ruleId": "CAT-3.canonical-missing",
      "anchor": "src/routes/blog.tsx::Route",
      "state": "confirmed",
      "category": 3,
      "title": "Canonical missing",
      "evidence": "src/routes/blog.tsx:18 — head: () => ({}) without links: [{ rel: 'canonical', ... }]",
      "severity": "High",
      "triagedBy": "maintainer@example.com",
      "triagedAt": "2026-04-30T14:30:00Z",
      "note": "Will fix in next sprint; tracked in TICKET-1234"
    },
    "9d20b6114fae": {
      "ruleId": "CAT-25.alt-missing",
      "anchor": "src/routes/admin/dashboard.tsx::Dashboard",
      "state": "accepted",
      "category": 25,
      "title": "Image alt missing",
      "evidence": "src/routes/admin/dashboard.tsx:42 — <img src=... /> without alt",
      "severity": "Medium",
      "triagedBy": "maintainer@example.com",
      "triagedAt": "2026-04-30T14:32:00Z",
      "note": "Admin dashboard, noindex'd, internal-only — not a public SEO surface"
    },
    "5c7e88a0d331": {
      "ruleId": "CAT-9.title-too-long",
      "anchor": "src/routes/dev-preview.tsx::Route",
      "instance": "/dev-preview",
      "state": "false_positive",
      "category": 9,
      "title": "Title too long (>60 chars)",
      "evidence": "src/routes/dev-preview.tsx:9 — title: 'Internal preview tool — only available to staff users with admin role'",
      "severity": "Low",
      "triagedBy": "maintainer@example.com",
      "triagedAt": "2026-04-30T14:35:00Z",
      "note": "Dev preview route; should have been excluded by auto-exclude path rules"
    }
  }
}
```

Equal fingerprints across runs mean "very likely the same finding", not proof — re-read the
evidence before carrying a suppression forward (`references/finding-identity.md`).

### State transitions

- `pending` (initial) → any state via Post-Scan Action 4 (Triage findings) in SKILL.md
- `confirmed` → `completed` after fix shipped; can be auto-detected by re-running audit and finding the previous evidence absent
- `accepted` → re-evaluated periodically; team should review at quarterly cadence
- `false_positive` → mirrored into `.snitch-marketing-ignore` for permanent suppression

### Re-audit behavior

When an audit runs and triage state exists:

- **Confirmed findings**: re-detected → keep state; flag in report as "previously confirmed, still present, fix scheduled".
- **Accepted findings**: re-detected → suppress from main report; show in "Accepted (won't fix)" section.
- **False positives**: re-detected → suppress entirely (already in `.snitch-marketing-ignore`).
- **New findings (no triage entry)**: appear in main report as new.

## File: `.snitch-marketing-ignore`

Lives at project root (source mode) or in the audit working directory (crawl mode). Plain text file, one rule per line. Suppresses findings going forward without storing per-finding metadata.

### Format

```
# Comments start with #
# Format (source mode): <path>:<line>:<CAT-NN>
# Format (crawl mode):  <url>:<CAT-NN>
# Wildcards allowed in path (* matches segment; ** matches recursively)

# Suppress all findings on internal-only routes
src/routes/admin/**:*

# Suppress specific known-correct overrides
src/routes/dev-preview.tsx:9:CAT-9

# Suppress an entire category for a path range
src/routes/legacy/**:CAT-25
src/routes/legacy/**:CAT-32

# Crawl mode: suppress a specific URL+CAT combo
https://snitchplugin.com/admin/preview:CAT-3
```

### Wildcards

- `*` matches one path segment (e.g., `src/routes/*/index.tsx`)
- `**` matches recursively (e.g., `src/routes/admin/**`)
- `*` in CAT field matches all categories
- Line numbers can be specific (`42`), a range (`42-50`), or `*` (any)

### Best practices

- Add an inline comment per rule explaining WHY (not WHAT — the rule itself shows the what).
- Group rules by reason (admin routes, legacy routes, intentional patterns).
- Review `.snitch-marketing-ignore` quarterly; rules accumulate cruft as the codebase changes.

## Inline comment ignores

For one-off suppressions that belong with the code, use inline ignore comments. The audit recognizes these:

### HTML / MDX

```html
<!-- snitch-marketing-ignore-next-line CAT-25 -->
<img src="hero.png" />
```

### JSX / TSX

```jsx
{/* snitch-marketing-ignore CAT-25 */}
<img src="hero.png" />
```

### CSS

```css
/* snitch-marketing-ignore CAT-49 */
.subtle-text { color: #999; }  /* knowingly low-contrast on dark bg below */
```

### JS / TS

```ts
// snitch-marketing-ignore CAT-42
import 'some-third-party-script';
```

### Behavior

- Inline ignore suppresses the IMMEDIATE next finding for the named CAT only
- Multiple CATs supported: `<!-- snitch-marketing-ignore-next-line CAT-25,CAT-32 -->`
- The audit reports inline-suppressed counts in a "Suppressed (inline)" section

## Triage UX (Post-scan Action 4)

When the user picks Option 4 from the Post-scan menu in SKILL.md, the audit walks each finding interactively:

```
[3 of 47] CAT-3 Canonical missing
  src/routes/blog.tsx:18 — head: () => ({}) without canonical
  Severity: High

  [c]onfirm — real issue, will fix
  [a]ccept — real issue, won't fix (provide reason)
  [f]alse positive — audit is wrong here
  [s]kip — leave pending, decide later
  [q]uit — stop triaging

  > _
```

After all findings triaged:

- `.snitch-marketing-triage.json` is written / updated atomically
- `.snitch-marketing-ignore` is appended-to for false positives
- A summary is printed: `47 findings triaged: 32 confirmed, 8 accepted, 5 false positive, 2 skipped`

## Comparison + delta reports

When `.snitch-marketing-triage.json` exists from a prior audit, the next audit's report includes a `## Triage Delta` section:

```markdown
## Triage Delta vs previous audit (2026-04-15)

### Resolved
- src/routes/blog.tsx:18:CAT-3 — Canonical missing → fixed

### New since last audit
- src/routes/changelog.tsx:9:CAT-3 — Canonical missing
- src/routes/changelog.tsx:11:CAT-9 — Title too long

### Unchanged from previous audit (12 findings)
- 8 confirmed (still pending fix)
- 4 accepted (won't fix)
```

This delta is the team's progress signal — what's been fixed, what's been added, what's stuck.

## Cross-references

- SKILL.md STEP 5 (Post-scan Actions) — where triage lives in the user flow
- SKILL.md "False Positive Prevention" — auto-exclusions baked into the audit
- `category-groups.md` — preset to category mapping (triage works per-finding within categories)

## Maintenance

- `.snitch-marketing-ignore` rules quarterly review — drop rules for code that no longer exists; tighten rules that were too broad.
- `.snitch-marketing-triage.json` rolling cleanup — remove entries for findings that no longer surface (the underlying code changed; the original evidence no longer applies).
- Both files SHOULD be committed to source control. The triage history is part of the team's institutional knowledge.
