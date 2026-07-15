# E-E-A-T assessment framework

A consolidated way to judge Experience, Expertise, Authoritativeness, and Trust — the signals
Google's Search Quality Rater Guidelines (QRG) describe and that AI answer engines lean on when
deciding which source to trust. Snitch already audits pieces of this across several cats; this
reference unifies them so a finding can name the specific E-E-A-T layer it strengthens.

Trustworthiness is the load-bearing layer. Per the QRG, Trust is weighted heaviest — a page can be
expert and authoritative and still fail if it isn't trustworthy. Order findings accordingly.

## When surfaced

Loaded when Cat 82 layer 3 (authority) runs, or when Cat 59 (AI-content tells), Cat 74 (social
proof), Cat 93 (Person/author schema), or Cat 111 (trust artifacts) needs to name which E-E-A-T
layer its finding maps to.

## The four layers (Trust first)

| Layer | Question | Observable signals (quote them) |
|---|---|---|
| **Trust** (heaviest) | Can a visitor verify who's behind this and that it's honest? | Reachable contact info / physical address, HTTPS, visible publish/update dates, transparent corrections, honest pricing, working privacy/terms, a real "about" |
| **Experience** | Has the author actually done the thing? | First-hand photos, original screenshots, case studies, "we tested/used" language with specifics |
| **Expertise** | Does the author know the subject? | Named author with credentials (Cat 93 Person schema), topical depth (Cat 57), correct terminology |
| **Authoritativeness** | Does the wider web treat this source as a reference? | External citations, brand mentions (`references/brand-authority-platforms.md`), Wikipedia entity, industry references |

## Who / How / Why heuristic

From Google's helpful-content guidance — apply to any page making claims:

- **Who** wrote it — is the author identifiable and credentialed?
- **How** was it produced — was anything tested/measured first-hand, or is it aggregation?
- **Why** does it exist — to help a reader, or primarily to rank/sell?

A page that can't answer Who/How/Why cleanly is the finding.

## How this changes findings

- A trust gap (no author, no dates, no contact) outranks an expertise gap in severity — surface it
  first.
- Pair an authority finding with the `brand-authority-platforms` sweep (on-site signals alone don't
  establish authoritativeness).
- An AI-content-tells finding (Cat 59) is an E-E-A-T problem when the slop erases the author's
  first-hand experience — name that linkage.

## Forbidden claims

- "Low E-E-A-T" as a bare verdict. Name the specific layer and quote the missing signal.
- Asserting a Trust failure without quoting the missing element (no visible date, contact 404, etc.).
- Treating E-E-A-T as a ranking number; it's a quality lens, not a score.

---

*Framework aligned to Google's Search Quality Rater Guidelines; consolidation approach adapted from
the MIT-licensed claude-seo project. Internal reference only; not surfaced in reports.*
