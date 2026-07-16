# Finding identity + fingerprint

A finding needs a stable identity so the same issue can be recognized across re-scans, diffed
between runs, deduplicated against external findings, and tracked through remediation — even after
the code moves. Line numbers alone can't do this: a finding on line 47 becomes a "new" finding the
moment someone adds an import above it. This reference defines the stable-identity scheme snitch
attaches to every finding.

## When surfaced

Every finding in the report carries an identity block (rendered per `references/report-template.md`).
Loaded whenever findings are reconciled across runs: delta reports, diff-mode scans
(`references/scan-planning.md`), re-scan after fixes (post-scan menu), and triage/dedup against
SARIF/CVE inputs (`references/fp-handling.md`, `references/ticketing.md`).

## The three parts

1. **`ruleId`** — the stable vulnerability *family*, in dotted form: `<class>.<specific>`, e.g.
   `sql-injection.query-builder`, `path-traversal.archive-extraction`, `xss.dangerously-set-html`,
   `ssrf.constructed-url`, `secret.hardcoded-key`. Derived from the CWE/category, not the file. Two
   findings of the same kind share a `ruleId` regardless of where they are.
2. **`anchor`** — a *semantic* location that survives refactors: the smallest stable named
   construct enclosing the sink — `path::symbol`, e.g. `src/db/users.ts::getUserByEmail`,
   `app/api/upload/route.ts::POST`. **No line numbers in the anchor.** If there's no named
   enclosure, use the nearest stable structural path (route pattern, exported const). Line/column
   still appear in the *evidence* (Rule 1 needs them) — they just aren't part of identity.
3. **`instance`** — disambiguates independently-attackable siblings that share `ruleId` + `anchor`
   (e.g., two distinct tainted args into the same query builder in one function). A short stable
   discriminator (the sink variable name or argument position). Omit when there's only one.

## Fingerprint

`fingerprint = hash(targetId + ruleId + anchor + instance)` where `targetId` is the repo/project
identifier. It's a **reconciliation signal, not proof of equivalence**: equal fingerprints across
runs mean "very likely the same finding" → carry forward triage state (confirmed / accepted-risk /
false-positive from `.snitch-ignore`); they do not by themselves prove the code is unchanged.
Confirm with the evidence before auto-suppressing.

## How identity is used

- **Re-scan / delta** — match by fingerprint to label each finding `new` / `unchanged` / `resolved`
  since the last report. Resolved = a prior fingerprint with no match this run (verify the sink is
  actually gone, not just moved — re-derive the anchor).
- **Diff mode** — sibling instances introduced by a changed shared helper each get their own
  `instance` so they're addressable, not collapsed (`references/scan-planning.md`).
- **Triage carry-forward** — `.snitch-ignore` entries key on fingerprint (+ CWE) so an accepted
  finding stays suppressed across runs unless its anchor/evidence changes.
- **Dedup of external findings** — when ingesting SARIF/scanner output, map to `ruleId` + `anchor`
  to detect duplicates of snitch's own findings.

## Forbidden claims

- An `anchor` that contains a line number, or that changes when unrelated code is added above —
  that's not a stable anchor.
- Treating equal fingerprints as proof two findings are identical without checking the evidence
  (it's a signal; re-verify before auto-suppressing).
- Collapsing distinct attackable siblings into one finding to make the count smaller — give each an
  `instance`.

---

*Stable-identity scheme (ruleId + semantic anchor + instance + fingerprint) informed by OpenAI's
codex-security finding model, reimplemented under snitch's evidence-first rules. Internal reference;
the identity block it specifies IS customer-facing.*
