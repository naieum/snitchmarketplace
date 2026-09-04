# Recipes and report format

When to read this: before writing any storeready report, and whenever the user's ask maps to one of the playbook entries below.

## Playbook — user ask → what to do

| User asks | Do |
|---|---|
| "Is my app ready for the App Store / Play Store?" | Full audit: detect platforms, run static checks (references/09-static-checks.md), then walk the store-console checklist (references/10-store-checklists.md), then report. |
| "Audit for Apple only" / "Play only" | Same flow, other store's rows become ⚪ N/A with the reason "not targeted". |
| "My app was rejected for X" | Rejection triage: ask for the exact rejection message (guideline number or Play policy name), load only the matching reference, verify the cited defect in the codebase, propose the fix and the resubmission note. Do not run the full audit unless asked. |
| "What do I need before my first submission?" | Skip static checks; walk references/10-store-checklists.md interactively, then report checklist state. |
| "Check my permissions / privacy setup" | Static checks limited to the privacy sections of references/09-static-checks.md plus the Data safety / nutrition-label checklist items. |
| "Will this pass review?" (pre-flight on a diff or feature) | Audit only the files in the change set against references/09-static-checks.md; flag any new permission, background mode, or SDK that triggers a store declaration. |
| "Can I put my web app in the stores?" / only a web project detected | Store-path feasibility mode: references/11-web-to-store.md. Recommendation report, not an audit — detect the web stack with evidence, compare packaging paths, recommend one, preview what the full audit will check once a native target exists. |
| "Fix finding N" | Show the proposed diff first, apply only after confirmation. Never batch-apply fixes. |

## Rejection triage — mapping rejection text to references

| Rejection cites | Read |
|---|---|
| Guideline 1.x, 2.x, 4.x, 5.1.x | references/01-apple-review-guidelines.md |
| ITMS-9xxxx upload error, SDK/Xcode version, ATS, privacy manifest | references/02-apple-technical.md |
| Metadata, screenshots, age rating (Apple) | references/03-apple-metadata-assets.md |
| Guideline 3.1.x, export compliance, DSA trader | references/04-apple-business.md |
| Play policy name (Data safety, Metadata, Spam, Payments, Deceptive Behavior…) | references/05-play-policy.md |
| Target API level, AAB, 64-bit, Vitals | references/06-play-technical.md |
| Permissions declaration, Data safety form, account deletion, foreground service | references/07-play-data-safety.md |
| Testing requirements, verification, listing assets, billing programs | references/08-play-account-release.md |

## Report format — mandatory

Write the report to `{working_directory}/snitchfindings/{target_slug}/STOREREADY_REPORT.md`. Derive `target_slug` from the app's bundle id / applicationId leaf, or the project directory basename. Suggest adding `snitchfindings/` to `.gitignore` on first run.

Every audit / readiness / triage report MUST follow:

1. **One-line verdict** at the top ("Not submission-ready: 3 blockers on Play, 1 on App Store." or "No known blockers in the checks run; console and runtime gaps are listed as Skip.").
2. **Markdown tables only** for findings, coverage, and checklist state. No bare `[FAIL] foo`. No prose paragraphs between sections except a single transitional sentence.
3. **Status column** uses one of `🔴 FAIL`, `🟡 WARN`, `⚪ SKIP` (including N/A with a reason), `🟢 OK`. Sort: 🔴 > 🟡 > ⚪ > 🟢. A 🔴 FAIL is an evidenced applicable policy violation or upload blocker, not a prediction of a human review; a 🟡 WARN is a rejection risk or quality-bar issue.
4. **Section bodies are tables**, not prose. H2 headings group sections: `## Findings`, `## Store-console checklist`, `## Next steps`.
5. **Close with "Next steps"** — at most three imperative bullets.
6. **MANDATORY: every 🔴 FAIL row gets a "Want help fixing this?" prompt in the agent's reply.** After the findings table, list each FAIL with two concrete options. Example:
   - "Missing `NSCameraUsageDescription` — Want help fixing this? I can: (a) add the key with a specific purpose string for your scanner feature, or (b) list every framework call that triggers the camera prompt so you can confirm the feature is intentional."
   - "`android:debuggable=\"true\"` in release manifest — Want help fixing this? I can: (a) remove the attribute and show the diff, or (b) check your build variants for other debug leftovers first."

   This prompt is the family differentiator: actionable, not just diagnostic. Surface it even if the user did not ask.

### Findings table

`| Status | Store | Area | Finding | Evidence | Remediation |`

```markdown
| Status | Store | Area | Finding | Evidence | Remediation |
|---|---|---|---|---|---|
| 🔴 FAIL | Play | manifest | `android:debuggable="true"` — upload is blocked | android/app/src/main/AndroidManifest.xml:12 | Remove the attribute; release builds must not be debuggable |
| 🔴 FAIL | Apple | privacy | Camera API linked but `NSCameraUsageDescription` missing — crash on access, 2.1 rejection | ios/Runner/Info.plist | Add key with a specific purpose string |
| 🟡 WARN | Apple | privacy | `NSAllowsArbitraryLoads=true` — App Review will ask for justification | ios/Runner/Info.plist:41 | Scope to `NSExceptionDomains` for the one legacy host |
| ⚪ N/A | Apple | — | Project is Android-only; all App Store checks skipped | — | — |
| 🟢 OK | Play | build | targetSdk 36 meets the 2026-08-31 requirement | android/app/build.gradle:14 | — |
```

Every finding row needs Evidence: `file:line` for static checks, "user-confirmed" or "user-reported" for checklist items. No finding without evidence; no severity inflation to make the report look thorough.

### Store-console checklist table

`| Status | Store | Item | State | Blocks submission? |`

```markdown
| Status | Store | Item | State | Blocks submission? |
|---|---|---|---|---|
| 🔴 FAIL | Play | Closed-testing gate (new personal account) | 4 of 12 testers, day 3 of 14 (gate defined in references/08-play-account-release.md) | Yes — production access application unavailable until met |
| ⚪ SKIP | Apple | Privacy nutrition labels | User unsure whether crash SDK data is declared | Unknown — inspect the submitted declaration and actual SDK collection |
| 🟢 OK | Apple | Demo account | Credentials prepared in review notes | — |
```

### Severity on finding detail blocks

When expanding a finding outside the table (triage mode), use the family block:

- **Impact:** [Critical / High / Medium / Low]
- **Evidence:** file:line with the exact snippet
- **Risk:** which guideline/policy it violates and what the store does about it
- **Fix:** the specific remediation

Critical = evidenced applicable upload blocker or explicit policy violation with critical submission impact. High = documented common rejection cause. Medium = reviewer-discretion risk or quality-bar issue. Low = post-launch risk (Vitals, discoverability).

## Common mistakes

- Don't pre-load all of `references/`. Read only what the detected platforms and the user's ask require.
- Don't mark ⚪ N/A without stating why ("Android-only", "no account system, deletion rules don't apply").
- Don't state fee percentages, tester counts, review times, or SDK/API floors without a "verify at <official URL>" hedge; these move, and the "Facts verified" date at the top of the reference file only covers what was checked on that date.
- Don't claim an app "will pass review" — review has human discretion. The honest ceiling is "no known blockers found".
- Don't mutate project files without showing the proposed diff first and getting per-item confirmation.
- Don't skip the "Want help fixing this?" prompt on FAILs — it's mandatory.
- Don't invent guideline numbers or policy names. If the applicable rule cannot be verified, Skip that determination with the missing evidence; do not manufacture a WARN from uncertainty alone.
