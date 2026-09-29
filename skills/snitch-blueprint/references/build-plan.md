# The build plan (`docs/PLAN.md`)

`BLUEPRINT.md` decides *what* to build and for whom. The build plan decides *how* to build it
and *how to prove it works*. It is written only when the user asks for it ("plan the build",
"how should we build this", "write the plan for a build loop"). Writing a plan does not
authorize building, installing, deploying or committing.

There is **no fixed layout**. A plan's shape comes from the project's risks. An encrypted sync
service spends most of its plan on key custody and authentication. A local bakery site spends
most of its plan on the booking flow and local search. A command-line tool spends most of its
plan on install friction and docs. Copying one project's plan structure onto another is the
mistake this reference exists to prevent.

## Relationship to the blueprint

- The plan cites the blueprint (`BLUEPRINT.md: Conversion action`) and never contradicts it.
- A planning finding that should change a product Decision goes back to the blueprint as a
  proposed diff for the user. The plan does not overrule the blueprint silently.
- No blueprint yet: record the product facts the plan depends on as Open questions, or run
  the interview first when the user wants it. Do not invent an audience or a conversion
  action to make the plan look complete.
- The plan uses the same four record types (Fact, Decision, Default, Open) and the same tags
  (Rejected, Settled, Resolved by) as `references/blueprint-doc.md`.

## The method

### 1. Record the current state

What exists today, as Facts with `file:line` evidence: stack, surfaces, data, integrations,
tests and how they run, deploy path. For greenfield work this is short. Also record what is
missing that the plan needs ("no accounts; no network code apart from the update check").
When the plan reverses an earlier recorded Decision, say so and list what still holds.

### 2. Find the hard parts

List the few things that could sink this project or would be expensive to change later.
Usually 2 to 6. Candidates:

- **Hard to reverse:** data model, identity and account model, URL structure, platform choice,
  anything customers or search engines will depend on once it ships.
- **Harm on failure:** money (checkout, billing), security (auth, secrets, tenant isolation),
  data loss (sync, migrations, backups), legal or store review.
- **Largest unknown:** a dependency never used before, a number nobody has measured (price,
  load, usage), a platform rule not yet checked.
- **Outside gate:** app store review, payment provider approval, a client sign-off, DNS or
  domain verification.

Each hard part becomes its own section of the plan. Everything else gets one line, usually in
a table (service, use, phase). Length follows risk: a weekend site can have one hard part and a
one-page plan; a product handling other people's money or secrets can run to hundreds of lines.

### 3. Compare real options for each hard part

For each hard part, pick the best course of action and write down why:

1. Name 2 or 3 real candidates. "Build it ourselves" and "use the platform's built-in" are
   often both on the list.
2. Check each against its **official documentation at the current version**. Record the
   version and the date checked (`checked 2026-09-24`). Search snippets and memory are not a
   source. If nothing can be looked up in this session, say so and mark the choice a Default
   pending that check.
3. Judge them against the blueprint's constraints: budget posture, who maintains it and how
   technical they are, timeline, refusals. The user's stated constraints outrank a
   technically better option.
4. Record the winner as a **Decision** (when the user chose) or a labeled **Default** (when
   the skill chose), with a **Rejected** line for each loser and its reason:
   `Default: sessions stored in the primary database. Rejected: key-value cache (eventually
   consistent, a revoked session could still work for a minute).`
5. Close call and easy to reverse: pick the simpler option and say it is reversible. Close
   call and hard to reverse: leave it Open for the user, stating both options and what each
   costs. Never settle an irreversible choice on the user's behalf without showing it.

### 4. Attack the draft before the user sees it

Run an adversarial review of every hard-part decision: a separate agent when the harness can
start one, otherwise a fresh pass written as a skeptical reviewer. It asks, per decision: how
does this fail in production, what did it assume without evidence, what cheaper option was
missed, what would an attacker or a confused user do.

Each finding either changes the plan or is answered in it, visibly:
`Review: device-reported usage can't be verified. Answer: bill it under a published fair-use
policy; tampering only lowers the tamperer's own bill.` Findings are never dropped silently.
A reviewer proposal that contradicts a **Settled** Decision is recorded as a tension, not
applied.

### 5. Write the spine, then the hard parts

Every plan has this spine, because a build (by hand or by an agent loop) needs it:

- **Current state:** step 1.
- **Hard parts:** one section each, decided per step 3, reviewed per step 4.
- **Phases:** each phase names the result a real person can use when it ships ("teams can
  share a vault", "visitors can book"), the phases it depends on, and the surfaces or parts it
  covers. Numbers nobody has measured yet (prices, limits) stay Open with a **Resolved by**
  that points at the phase or measurement that will produce them.
- **Verification:** how "done" is proven for each phase, as runnable checks. Reuse the
  blueprint's Done-when IDs for surfaces, and add checks for each hard part. Include what must
  be *refused*, not only what must work: a replayed login, a double booking, a live payment
  key in test config, a plaintext secret in a storage dump. Say where each check runs (unit,
  integration, staging, real device) and name any real-world proof that no test covers.
- **What stays human:** production deploys, spending money, legal pages, external security
  review, store submission, merging into the main branch.

Add other sections only when a hard part needs them: an architecture sketch with trust
boundaries, a data model, security rules, a migration path, the critical files to touch, a
cost estimate. Number the sections so tasks and reviews can cite them ("Plan §5").

## Optional: a task list for a build loop

When the user wants the plan built by an agent loop, export a work list beside it (for example
`tasks.json`, generated by a small script that stays the source of truth). Each task has:

- a stable id and its phase;
- a spec of a few sentences that cites plan and blueprint sections;
- the exact test file paths the test author must create, and the minimum number of test IDs;
- its dependencies, so the runner schedules with code, never with a model.

Size each task so one reviewer can read the whole diff. The Done-when IDs become the test IDs
the test author writes first and the builder may not edit. Running the loop, and the loop's
own gates, belong to the loop tooling, not to this skill.

## Done-when (for the plan)

- Every hard part has a Decision or labeled Default, its Rejected options with reasons, and
  the documentation version and date it was checked against, or is an Open question for the
  user with both options costed.
- Every review finding changed the plan or is answered in it.
- Every phase names a usable result and its verification, including at least one refusal
  check per hard part.
- No unlabeled guesses; every Open question has a Resolved by.
- The plan's length matches its risks: no section exists only because another project had it.
- The user has seen the plan. Approving it does not authorize building.

## Two shapes, same method

**A local bakery's order-ahead site (short plan, about one page).** Current state: a
hosted-platform site with a menu page. One hard part: taking orders the shop can actually
fulfill. Options: the platform's built-in ordering, a third-party ordering widget, a
phone-only call-to-order button. Default: built-in ordering with a daily cap, because the
maintainer already edits the platform; Rejected: the widget (monthly fee, second login for
staff). Phases: 1, customers can order ahead for pickup. Verification: an order past the daily
cap is refused with a message; a sold-out item cannot be added. Human: payment account setup,
going live.

**An end-to-end encrypted sync service added to a local-first desktop app (long plan).**
Hard parts: who holds the keys, ordering and conflicts in sync, authentication configuration,
billing on usage that devices report themselves. Each got its own section with the rejected
options (for example, a key-value store rejected for sessions because it is eventually
consistent). One design was marked Settled after discussion so review rounds stopped
reopening it. Verification listed attacks as well as features: a replayed sign-in assertion
and a substituted invitation key are rejected; a plaintext canary never appears in any storage
dump. Prices stayed Open, resolved by a first phase that measured real usage.
