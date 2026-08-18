# Archetype: CLI / Library / API

Anything a developer installs or calls — command-line tools, packages, SDKs, APIs,
self-hosted services. The buying shape: a developer with a problem, a search, and about
ninety seconds of patience evaluates whether this tool is worth adopting. There is usually
no "site" at first — the README is the landing page, the install one-liner is the
conversion action, and the docs are the onboarding. This archetype often pairs with
snitch-devready (the repo itself is the product surface).

## Decisions this archetype forces (from the interview)

- **The distribution channel.** Which package channel / registry / install path the
  audience already uses — pick ONE primary now (more channels = more release surfaces to
  keep in sync; extras go DEFERRED with triggers). The channel decides the install
  one-liner, and the one-liner is the conversion action.
- **The 60-second proof.** The smallest real command-plus-output (or request-plus-response)
  that shows the tool doing its job. It goes at the top of the README, and it must be
  *reproducible by a stranger* — copy, paste, works. If the proof needs setup (keys,
  config, services), the setup burden is a design finding at blueprint time: shrink it
  before writing docs around it.
- **Versioning and breakage posture.** Semver commitment, what pre-1.0 means here, how
  breaking changes are announced. Recorded now because the first breaking release tests
  it — and the changelog discipline starts at the first release, not retroactively.
- **Telemetry: none or opt-in.** Default: none — trust is the currency of developer tools,
  and a surprise phone-home discovered in traffic logs costs more adoption than any usage
  dashboard earns. Opt-in telemetry, if chosen, is disclosed in the README and the claim
  inventory carries exactly what is collected.
- **License and name collision check** — the license is a distribution decision, and the
  name must be free on the chosen channel *before* the README brands it.

## Conversion action

**The install/first-call**, proxied by what the channel can measure (downloads, stars,
API signups — recorded with the honest caveat that download counts are noisy). The real
activation is the 60-second proof succeeding on the user's machine; issues opened with the
words "doesn't work" against the quickstart are the activation-failure signal, and the
blueprint records that triage as someone's job.

## Surface inventory and build order

1. **README** — specced like a landing page, because it is one: one sentence of wedge
   (what this does, for whom, unlike what — same interview answers as every archetype);
   the install one-liner; the 60-second proof with real output; a short honest feature
   list drawn from the claim inventory (no "blazingly fast" without a benchmark in the
   inventory); limits and non-goals stated plainly (the section that earns trust);
   license, versioning posture, and how to get help.
2. **The quickstart doc** — the proof expanded to the first real use case, tested end-to-end
   on a clean environment before publishing. Docs order after that follows user tasks, not
   code structure.
3. **The error-message surface** — errors are UI in this archetype and rank above long-tail
   docs: an error that names the fix ("X is missing — run Y") replaces a documentation
   page and a support thread. The blueprint records this as a standing spec for all code,
   not a page.
4. **Reference docs** — generated from source where the ecosystem supports it, so they
   can't drift.
5. **Changelog + release notes** — from the first release; the format is snitch-docwriter
   territory.
6. **DEFERRED by default:** a marketing website (trigger: the README demonstrably can't
   carry positioning anymore — most tools never hit it), logo/branding, comparison pages,
   a blog. When the site trigger fires, it's a secondary content/SaaS archetype with its
   own surfaces.

## Day-one wiring (beyond build-defaults.md — most web items don't apply until a site exists)

- CI running the quickstart against a clean environment — the conversion path, tested like
  one.
- Issue templates that capture version + environment; a SECURITY.md contact if the tool
  will hold anyone's data or secrets.
- Package metadata (description, keywords, repo link) written once, correctly — it is the
  channel's search surface, the archetype's equivalent of a meta description.
- For APIs: an OpenAPI (or equivalent) spec from day one — machine-readable truth the
  docs, SDKs, and the 60-second proof all derive from, instead of drifting independently.

## Handoffs

snitch-devready for the repo's agent-readiness (the natural same-day pairing);
snitch-docwriter for README/docs/error-message prose (this archetype's copy is technical
prose, not marketing voice — the one archetype where docwriter, not focusedcopy, owns the
words); snitch-cmo when launch posts and channel distribution are wanted; snitch-security
before publishing anything that handles credentials or user data.
