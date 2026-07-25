## CATEGORY 31: CI/CD Pipeline Security
> Type: posture · Groups: infra-supply-chain · CWE: CWE-250

> **Rule 7 applies to the injection sub-class of this category, despite `Type: posture`.**
> Expression injection is a taint flow: the source is a `github.event.*` field an outside
> contributor controls, and the sink is *shell-script generation*. Trace it like any other sink —
> the category's Type governs the posture checks (permissions, pins, runners), not this one.

### Detection
- GitHub Actions: `.github/workflows/*.{yml,yaml}` — **both extensions**; GitHub honours `.yaml`, and
  globbing only `*.yml` produces a silent zero-finding pass on a repository that uses it
- GitLab CI: `.gitlab-ci.yml`
- Other CI: `Jenkinsfile`, `.circleci/config.yml`, `azure-pipelines.yml`

> **Scope, stated plainly: the rules below are GitHub Actions-specific.** The concepts transfer —
> untrusted input interpolated into a shell step, a privileged pipeline running fork code,
> over-broad tokens, mutable action/orb/image refs, non-ephemeral runners — but the syntax,
> defaults, and trigger semantics do not. On a GitLab / Jenkins / CircleCI / Azure repo, scan for
> those concepts using the platform's own model, and **say in the report that this category's
> detailed rules did not apply.** A silent zero-finding pass on a non-Actions pipeline reads as
> "audited and clean" when it means "nothing here matched."

---

### The one rule that decides expression injection: **placement**

Both of these contain a `${{ github.event.* }}` expression on a step that has a `run:` key. One is
Critical, one is correct. The difference is not the field, the trigger, or the event — it is where
the expression lands.

| Placement | What happens | Disposition |
|---|---|---|
| Inside the `run:` string — `run: echo "Hi ${{ github.event.pull_request.title }}"` | Actions substitutes the value into the script **before** the shell parses it. A title consisting of shell metacharacters — a quote, a `;`, a pipe, a comment marker — becomes script syntax rather than data | **Finding** |
| In an `env:` mapping, dereferenced in the script — `env: TITLE: ${{ … }}` then `run: echo "$TITLE"` | The value is passed to the process as environment data and never enters script generation. Inert regardless of content | **Pass** |
| Passed as an `with:` input to a JavaScript/composite action that receives it as an argument | Same reason — argument, not generated script | **Pass** (but see the `ref:` carve-out below) |

GitHub documents the middle row as the preferred mitigation for inline scripts: the value "is stored
in memory and is used as a variable, and doesn't interact with the script generation process."

**Report the fix as a Pass, not a finding.** A scan that flags injection *and* flags the documented
remediation teaches users that this category is noise. If the expression is bound to `env:` and the
script dereferences it, say so in the Pass evidence and name both lines.

Quoting does not save an interpolated expression. `run: echo "${{ … }}"` is still substituted before
the shell parses the quotes; `"` in the payload closes them.

### Which contexts are attacker-controlled

Treat as tainted, in rough order of how often they are the real vector:
`github.event.*.title`, `*.body`, `*.head.ref` (branch name), `*.head.repo.*`, `github.event.comment.body`,
`github.event.issue.title`, `github.event.review.body`, `github.event.pages.*.page_name`,
`github.event.commits.*.message` / `head_commit.message` and `.author.email` / `.name`,
`github.head_ref`.

`github.event.head_commit.message` on a `push` to a protected branch is lower likelihood than a PR
title — anyone can open a PR; pushing requires write access — but it is the same sink and a
compromised or careless collaborator reaches it. Bind it to `env:` too.

**Naming a context here is not a finding.** This list says what to trace, not what to report. Every
one of these values is safe when bound to `env:`, and the placement table decides. Do not flag a
workflow because it references one.

### Who can trigger what

Attacker-reachability is a property of the event, and the file that matters may not say who can fire
it. Roughly, from most open to least:

| Event | Who can initiate |
|---|---|
| `issue_comment`, `issues`, `discussion_comment`, `fork`, `watch`, `gollum` | **anyone with a GitHub account** on a public repo — no permissions, no fork, no PR |
| `pull_request`, `pull_request_target` | anyone who can open a PR — i.e. anyone, via a fork |
| `workflow_run` | anyone who can trigger the upstream workflow |
| `push`, `create`, `delete`, `release` | requires write access — insider or compromised account |
| `schedule`, `workflow_dispatch` | maintainers, or nobody |

The first two rows are what "externally triggerable, zero prior access" means in the severity ladder.

---

### What to Search For
- Secrets hardcoded in workflow files (not using `${{ secrets.* }}`)
- Expression injection: any `${{ }}` interpolated into a `run:` block (see the placement table)
- A privileged trigger that then checks out and executes untrusted code (see chain below)
- Untrusted values written to `$GITHUB_ENV`, `$GITHUB_OUTPUT`, or `$GITHUB_PATH`
- `permissions:` widened past what the job needs — `write-all`, or write scopes it never uses
- **Any** action — first-party or third-party — pinned to a branch or tag instead of a commit SHA.
  `actions/checkout@v4` is GitHub's own and is still a mutable ref
- Self-hosted runners in any workflow reachable by an outside contributor — whether the untrusted
  input arrives as checked-out fork code *or* as an injected expression

### The privileged-trigger chain — report as one finding

Four links. A scanner that reports them separately produces four mediums for what is a
repository-takeover-class Critical.

1. **A trigger that grants base-repo privileges on attacker-initiated input.**
   `pull_request_target`, `workflow_run`, `issue_comment`, `issues`, `discussion_comment`. GitHub
   names the first two explicitly: they "expose the repository to security compromises" when used
   with checkout of an untrusted pull request. `workflow_run` has the same shape via a downloaded
   artifact from the untrusted run.
2. **Checkout of the untrusted revision.** `ref: ${{ github.event.pull_request.head.sha }}`,
   `head.ref`, `github.event.workflow_run.head_sha`, or a manual `git fetch` of the fork.

   **A checkout with no `ref:` is link 2 absent, and this is the single most common false positive
   in this category.** `actions/checkout` defaults `ref` to "the reference or SHA for that event,"
   and for `pull_request_target` that reference is *the base branch* — trusted code. For
   `issue_comment` and the other non-PR events it is the repository's default branch. So a bare
   `- uses: actions/checkout@<sha>` under a privileged trigger checks out **your** code, not the
   attacker's. Trigger + bare checkout + a build step is the normal, correct shape of a
   `pull_request_target` workflow; reporting it as a chain is wrong. The explicit `ref:` is what
   turns it into one.
3. **Something that executes it.** This link is usually the most ordinary-looking line in the file:
   - `npm install` / `npm ci` / `yarn` / `pnpm install` — runs `preinstall`/`postinstall` lifecycle
     scripts from the checked-out (attacker-authored) `package.json`
   - `pip install -e .` / `-r requirements.txt` with a local path — runs `setup.py`
   - any test runner, build script, `make`, `gradle`, `mvn` — executes checked-out code by definition
   - linters and formatters that load plugins or config from the tree (eslint, prettier plugins)
   - `uses: ./.github/actions/…` — a local composite action from the attacker's tree
4. **Something worth stealing in that step's reach.** `${{ secrets.* }}` in the step or job `env:`,
   a writable `GITHUB_TOKEN`, cloud credentials configured by an earlier step.

Links 1+2 alone are the documented anti-pattern and are reportable without link 3 if a plausible
execution step exists. Link 3 present makes it unambiguous. Link 4 sets the blast radius.

**Where secrets get reported — decide it here, once.** When links 1–3 are all visible, the secrets at
link 4 are *part of this finding*, not a second one: they are what sets its severity and blast
radius. Report a standalone credential-exposure finding (CWE-522) only when the execution step is
inferred rather than shown — that is, when you can see a privileged trigger, an untrusted checkout
and secrets in the job, but no line you can point at that runs the checked-out code.

**Untrusted execution does not require an untrusted checkout.** The chain above is the fork-checkout
route. Expression injection reaches the same place with links 2 and 3 absent entirely: the attacker's
code arrives *inside the `run:` string*. A workflow with no checkout at all, on a trigger anyone can
fire, that interpolates a comment body into a shell step, is remote code execution on the runner.
Score it on what the runner can reach, not on whether a chain was assembled.

**Mitigations that break the chain** — if any is present, this is a Pass, and name it:
`if: github.event.pull_request.head.repo.full_name == github.repository` (fork-only gate),
an `environment:` with required reviewers on the job that holds the secrets, a label/approval gate,
or a split design where `pull_request_target` only posts a comment and the untrusted code is built
by a separate unprivileged `pull_request` job.

### Environment-file writes

`echo "VALUE=${{ github.event.* }}" >> $GITHUB_ENV` (or `$GITHUB_OUTPUT`, `$GITHUB_PATH`) lets an
attacker-supplied value break out of the intended key by embedding a newline or the heredoc
delimiter, and set an arbitrary variable for every subsequent step — including ones that change what
later commands execute. GitHub's own note on the multiline form: "If the value is completely
arbitrary then you shouldn't use this format."

**The `env:`-binding Pass does not rescue this.** Writing untrusted data to one of these three files
is a finding regardless of how the value reached the script — `env: V: ${{ … }}` followed by
`echo "K=$V" >> $GITHUB_ENV` is still a breakout, because the danger is the write, not the
substitution. When one expression is both interpolated into the `run:` string *and* written to an
environment file, that is **one** finding at that line, not two.

### Permission scopes — what `write` means where

The `permissions:` block is not two-state. A scanner matching the token `write` inside it will flag
the most-recommended cloud-auth pattern in modern Actions.

| Scope | Grants | Disposition |
|---|---|---|
| `id-token: write` | **No repository access at all.** Only the ability to mint a short-lived OIDC token. GitHub: it "does not give the workflow permission to modify or write to any resources" | **Never a finding on its own.** It is required for keyless cloud auth — the thing that replaces the long-lived `AWS_SECRET_ACCESS_KEY` you *do* want flagged |
| `contents: read` | clone the repo | correct default |
| `contents: write` | push commits, tags, releases | finding only if the job never pushes |
| any other `: write` — `packages:`, `deployments:`, `actions:`, `issues:`, `pull-requests:` (everything except `id-token:`) | real mutation of that resource | finding if unused by any step in the job |
| `write-all` | every scope at once | finding — see below |
| no `permissions:` key | inherits repo/org/enterprise default | depends — see below |

**The default is read-only, not write-all.** Effective 2 February 2023 GitHub changed the default
`GITHUB_TOKEN` permission to read-only for new enterprises, new orgs not under an enterprise, and new
repos under a personal account; new orgs and repos under an existing enterprise or org inherit the
parent's setting. The change "will not impact any existing enterprises, organizations or
repositories," so an org created before that date may still default to read/write — which is exactly
why a missing `permissions:` key is *Medium and undeterminable from code*, not a High.

`write-all` and `read-all` are literal shorthand values for all scopes. `permissions: write-all` in a
workflow file is therefore a **deliberate maximal grant**, not an inherited default, and reads as
High regardless of when the org was created.

Prefer job-level `permissions:` to workflow-level. A workflow-level grant hands every job the
broadest scope any one of them needs. Note it as hygiene, not as a finding, when there is one job.

**Before calling a scope unused, check which action consumes it.** Scopes are usually spent by an
action rather than by a visible API call, so "no step obviously uses it" is not evidence. The common
consumers: `aws-actions/configure-aws-credentials`, `google-github-actions/auth`,
`azure/login`, and any OIDC exchange need **`id-token: write`**;
`actions/upload-pages-artifact` + `actions/deploy-pages` need `pages: write` and `id-token: write`;
`softprops/action-gh-release` and `gh release create` need `contents: write`;
`docker/login-action` against GHCR needs `packages: write`; commenting bots need
`pull-requests: write` or `issues: write`. If a scope's consumer is an action you cannot open, say so
and keep the finding at Low rather than asserting the scope is unused.

---

### Actually Vulnerable
- `${{ github.event.* }}` interpolated inside a `run:` string
- Untrusted `${{ }}` written to `$GITHUB_ENV` / `$GITHUB_OUTPUT` / `$GITHUB_PATH`
- A privileged trigger + an **explicit** untrusted `ref:` + an execution step (one chain, one finding)
- Secrets in the environment of a step that runs untrusted code — **syntactically correct
  `${{ secrets.* }}` and still an exposure**, because what matters is the process that reads them.
  Part of the chain finding when the execution step is visible; a standalone CWE-522 finding only
  when it is inferred
- API key or token as a plain literal in workflow YAML
- `permissions: write-all`, or write scopes no step in the job uses
- `uses: actions/checkout@main` / `@v4` — mutable ref; a branch moves and a tag can be re-pointed.
  First-party publishers are not exempt, they are only lower likelihood
- A self-hosted runner in a workflow an outside contributor can reach — by fork checkout *or* by
  expression injection. Runners are not ephemeral by default, so a compromise persists into later
  jobs on the same machine

### NOT Vulnerable
- `${{ }}` bound to an `env:` var and dereferenced as `$VAR` in the script — the documented fix
- `${{ }}` passed as a `with:` input to an action that consumes it as an argument.
  **Carve-out:** this exemption does *not* cover `ref:`, `repository:`, `path:`, or `token:` on a
  checkout action under a privileged trigger. Those are not data the action prints — they select what
  code lands on the runner, which is link 2 of the chain above.
- `${{ secrets.* }}` in a job that does **not** execute untrusted code. The syntax is correct; the
  condition is what the job runs.
- `id-token: write` (see the scope table)
- Explicit `permissions:` with the scopes the job actually uses
- Actions pinned to a full 40-hex commit SHA, with or without a `# v4.2.2` trailing comment
- `pull_request` **for the hosted-runner case**: for a PR from a fork it runs the *base* repository's
  workflow definition, `GITHUB_TOKEN` is read-only, and "with the exception of `GITHUB_TOKEN`,
  secrets are not passed to the runner." It does **not** run "in the fork's context," and it is not
  unconditionally safe — fork code still executes on the runner, so `pull_request` plus a
  **self-hosted** runner is a known compromise path and a finding.
- A role ARN, account ID, region, or registry hostname in plain text — identifiers, not credentials

### Context Check
1. Is the repository public or private? If it cannot be determined from the code, **assume public,
   state the assumption in the finding, and tag `needs human verification`** — assuming private
   silently downgrades every privileged-trigger finding to nothing.
2. For each `${{ }}`: does it land inside a `run:` string, in `env:`, or in a `with:` input?
3. Does any trigger grant base-repo privileges on attacker-initiated input, and does the checkout
   carry an **explicit** `ref:` selecting an attacker-controlled revision? A bare checkout does not.
4. Do any of the job's steps write to `$GITHUB_ENV`, `$GITHUB_OUTPUT`, or `$GITHUB_PATH`?
5. Which `permissions:` scopes does any step in the job actually use — including scopes consumed by
   an action rather than by a visible API call?
6. Is every action, first- or third-party, pinned to a full commit SHA?
7. Does any job specify a self-hosted runner? Look for `runs-on:` values that are not the
   `ubuntu-*` / `windows-*` / `macos-*` GitHub-hosted labels — a bare `self-hosted`, a list form
   like `[self-hosted, linux, x64]`, or a `group:` key. A custom label alone is ambiguous between a
   larger hosted runner and a self-hosted one; when it is ambiguous, say so and drop to Low.

### Evidence Chain
A finding's Evidence block must show:
- The workflow file:line of the misconfiguration
- For injection: the tainted context path, the `run:` line it is substituted into, and — explicitly —
  that it is **not** bound to an `env:` var
- For the privileged-trigger chain: all four links with their own file:line, and the absence of any
  gate (`if:`, `environment:`, approval)
- The trigger context that makes it attacker-reachable
- What protection is absent: no scoping, mutable pin, secret not referenced via `${{ secrets.* }}`
- Repository visibility, or the stated assumption when it cannot be determined

### CWE by finding class
The category-level `CWE-250` in `_index.md` is the default. Tag each finding with the one that fits:

| Finding | CWE |
|---|---|
| Expression injection into `run:` | CWE-94 (Code Injection); CWE-78 if it reaches a command |
| `$GITHUB_ENV` / `$GITHUB_OUTPUT` write injection | CWE-94 |
| Privileged trigger runs untrusted code | CWE-829 (Untrusted Functionality) + CWE-250 |
| Secrets reachable by untrusted code | CWE-522 (Insufficiently Protected Credentials) |
| `write-all` / unused write scopes | CWE-250 (Unnecessary Privileges) or CWE-269 |
| Unpinned action ref | CWE-1357 (Reliance on Insufficiently Trustworthy Component) |
| Plaintext secret in YAML | CWE-798 (Hardcoded Credentials) |

### Severity
- **Critical** — externally triggerable code execution on the runner: expression injection on an
  event an outside contributor can fire; the full privileged-trigger chain. **Secrets in reach raise
  the blast radius, they are not the bar.** Arbitrary execution on a runner is Critical on its own —
  on a self-hosted runner it is a foothold in the org's network, and on any runner it can reach the
  registry, the cloud role, or the next job. Do not downgrade to High merely because the compromised
  job happens to hold no `secrets.*`.
- **High** — the amplifiers and the unconditional exposures: `write-all`; secrets in an
  untrusted-code job where the execution step is inferred rather than shown; plaintext credential in
  YAML; a self-hosted runner reachable by an outside contributor where no injection or untrusted
  checkout is present (the exposure is the runner's persistence, not a demonstrated execution path).
- **Medium** — mutable action ref; missing `permissions:` key; workflow-level scoping that
  over-grants across jobs.
- **Low** — anything whose disposition turns on repo visibility, runner ownership, or org policy that
  the code does not state. Tag `needs human verification`.

**Mutable action refs, by publisher.** The severity is about who can move the ref and how likely
they are to be compromised, not about the syntax:

| Publisher | Example | Severity |
|---|---|---|
| GitHub first-party (`actions/*`, `github/*`) | `actions/checkout@v4` | Medium |
| Established vendor with a security track record (`docker/*`, `aws-actions/*`, `google-github-actions/*`) | `docker/login-action@v3` | Medium |
| Any other publisher — individual maintainers, small orgs, anything you cannot vouch for | `someone/deploy-action@main` | **High** — an account takeover on that repo executes in your pipeline on the next run |
| A branch ref rather than a tag, any publisher | `@main`, `@master` | one step up from the row above — no release process gates what runs |

Do not sum the chain's links into a total. One Critical for the chain, and the amplifier
(`write-all`) reported separately as High with a note that it widens the chain's impact.

### Confidence Scoring
- **High**: `${{ }}` textually inside a `run:` string; the four-link chain visible in one file;
  plaintext secret; `write-all` written explicitly
- **Medium**: pattern present, exploitability partial — missing `permissions:` key (depends on
  org/repo defaults created before Feb 2023), branch-pinned first-party action, execution step
  inferred rather than shown
- **Low**: repo visibility, runner ownership, or org policy undeterminable from the code — tag
  `needs human verification`

### Files to Check
- `.github/workflows/*.{yml,yaml}`
- `.github/actions/**/action.{yml,yaml}` — local composite actions run with the caller's privileges
- `.gitlab-ci.yml`, `Jenkinsfile`
- `.circleci/config.yml`
- CI/CD configuration in `package.json` scripts
