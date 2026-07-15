## CATEGORY 129: AI-image provenance & licensing metadata (IPTC/XMP)

As AI-generated imagery spreads across product and marketing pages, two metadata signals
embedded in the image file itself are moving from nice-to-have to expected. The first is
**provenance**: the IPTC Photo Metadata Standard defines a `DigitalSourceType` field that
declares how an image was made, for example `trainedAlgorithmicMedia` for a fully
AI-generated image, `compositeSynthetic` for an AI-assisted composite, or `digitalCapture`
for a real photograph. Google Merchant Center and Google Images read this signal as a
transparency disclosure, and policy expectations around labeling synthetic media are
tightening. The second is **licensing and attribution**: IPTC `Creator`, `CreditLine`,
`CopyrightNotice`, and `WebStatement` fields, together with Google's image-license metadata,
clarify who owns an image and feed the Licensable badge in Google Images. This category
audits whether the brand's images carry provenance and licensing metadata appropriate to how
the images are actually used.

Scope note: this is the metadata embedded IN the image binary (IPTC/XMP) plus the
image-license signal. It is distinct from Cat 25/26 (image alt presence and quality, the
accessible text), Cat 27 (image format and weight), and Cat 34 (Product schema in the page's
JSON-LD). Those audit text and page markup. This one audits the bytes inside the file.

### Pre-flight: relevance check

Skip with reason `not applicable` for brands with no Google Images or Merchant Center stake
and no AI imagery in the pipeline (note it as low-priority rather than a finding). Required
when any of these hold: AI-generated images appear on product pages that feed a Shopping or
Merchant Center surface; AI image tools are in the asset pipeline for marketing imagery; the
brand wants its photography eligible for the Licensable badge in Google Images. Borderline
(a content site with stock or licensed photography but no commerce): run it scoped to the
licensing fields only, since provenance carries little weight without a commerce or synthetic
stake.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md`: has the brand indicated which images are AI-generated,
   and what AI image tools (if any) are in the pipeline? Provenance findings are grounded in
   what the brand has told you, not in a guess about any single image.
2. Inspect the image pipeline and asset directory. Locate the optimizer or build step that
   processes images (`next/image`, `sharp`, `imagemin`, a CDN transform, a Shopify/CMS upload
   path). `Grep` the config for metadata handling: many optimizers strip IPTC/XMP on resize
   by default. Quote the config option that controls metadata retention, or record its absence.
3. Check whether any metadata-injection step exists (a script that writes `Creator`,
   `CopyrightNotice`, or `DigitalSourceType` onto assets before publish). Quote it or record
   that no such step exists.

**Crawl mode, required tool calls (GATED):**

1. Fetch a small sample of image binaries actually served on product and key marketing pages.
2. Read the embedded IPTC/XMP, for example `Bash exiftool <downloaded-image>` or an equivalent
   metadata reader. Quote the relevant fields (`DigitalSourceType`, `Creator`, `CreditLine`,
   `CopyrightNotice`, `WebStatement`, license URL) or their documented absence.
3. If `exiftool` or an equivalent reader is unavailable, or the network blocks the binary
   fetch, mark the metadata-read portion **Skip** with reason `IPTC/XMP read needs an
   image-metadata tool not available in this run; recommend running exiftool locally on a
   sample`. Never infer field contents you did not read.

### Forbidden claims

- "This image is AI-generated." Do not assert an image is synthetic from how it looks. Either
  the metadata says so, or the brand told you. Flag instead the ABSENCE of provenance metadata
  on images the brand has indicated are AI-generated, or recommend labeling when AI tools are
  known to be in the pipeline.
- "The brand is violating an image license." You cannot establish a rights violation from a
  crawl. Flag missing or empty licensing metadata, not infringement.
- "Metadata is stripped." Only after you read the optimizer config or read a served binary and
  found the fields gone. A theory about the build is not evidence.

### Detection

Pipeline inspection for metadata retention and injection (Source mode) plus a gated read of
served image binaries (Crawl mode), grounded in the context file's statement of which images
are AI-generated and which tools are in the pipeline.

### What to Search For

- An optimizer or CDN transform that strips IPTC/XMP on resize (metadata retention off or
  defaulted off)
- AI-generated product images on a Merchant Center / Shopping surface with no `DigitalSourceType`
- AI-generated marketing imagery site-wide with no provenance labeling anywhere in the pipeline
- Licensable photography the brand wants in Google Images carrying no `Creator`, `CreditLine`,
  `CopyrightNotice`, or license URL
- No metadata-injection step in the build, so whatever the source tool wrote (or omitted) ships
  as-is
- A mismatch between a stated AI pipeline and assets that carry `digitalCapture` or no source
  type at all

### Actually Hurts the Marketing Surface

- **AI-generated product images on a Merchant Center / Shopping surface with no `DigitalSourceType`.**
  The transparency signal Google expects for synthetic product imagery is absent, exposing the
  feed to policy risk and undermining trust on the highest-stakes commercial images.
  Evidence required: context file (or brand) confirming the images are AI-generated + the read
  binary or pipeline config showing `DigitalSourceType` absent on a Merchant Center asset.
- **AI marketing imagery site-wide with no provenance labeling in the pipeline.**
  As synthetic media disclosure expectations tighten, an entire surface of AI imagery carries no
  source-type signal and no plan to add one.
  Evidence required: pipeline confirmed to use AI tools + no injection step + sampled binaries
  with no `DigitalSourceType`.
- **Optimizer strips all metadata on build.**
  Even correctly tagged source assets lose their provenance and licensing fields at resize, so
  nothing reaches the served file.
  Evidence required: the optimizer config option set to drop metadata, or a source asset with
  fields that the served binary no longer carries.
- **Licensable photography with no creator/credit/copyright or license URL.**
  Photography the brand wants eligible for the Licensable badge ships without the fields that
  badge requires, so Google has nothing to surface.
  Evidence required: the read binary showing the license fields empty + brand intent to be in
  Google Images.

### NOT a Problem

- Purely decorative UI images (icons, backgrounds, dividers) with no licensing or commerce
  stake. No provenance or license metadata is expected.
- Real photography that already carries `Creator` and `CreditLine`. Confirm by reading the
  binary, then move on.
- A brand with no Google Images or Merchant Center stake and no AI imagery. Note it as
  low-priority, not a finding.
- Deliberate metadata stripping for privacy on user-uploaded content (removing camera GPS and
  device fields). That is a correct privacy choice, not a provenance gap.

### Context Check

1. Has the brand stated which images are AI-generated, and which AI tools are in the pipeline?
2. Do any AI-generated images feed a Merchant Center or Shopping surface, where a missing
   source type is a policy and transparency issue rather than a cosmetic one?
3. Does the build or CDN strip IPTC/XMP on optimization, and is that strip deliberate or a
   default no one chose?
4. Is there any step that injects `DigitalSourceType` for synthetic assets or `Creator`/credit
   for owned photography, or does whatever the source tool emitted ship unchanged?
5. Does the brand want photography eligible for the Licensable badge, and if so do the required
   fields survive to the served file?
6. Is a gap a true absence in the served binary, or could the metadata tool simply have been
   unavailable this run (Skip, not a finding)?

### Reference

IPTC Photo Metadata Standard, Digital Source Type:
https://www.iptc.org/std/photometadata/specification/IPTC-PhotoMetadata

Google Merchant Center image and product-imagery policies:
https://support.google.com/merchants/answer/6324350

Google Images image-license metadata and the Licensable badge:
https://developers.google.com/search/docs/appearance/structured-data/image-license-metadata

Cross-ref Cat 34 (Product schema in JSON-LD), Cat 25/26 (image alt presence and quality),
Cat 27 (image format and weight).

**Severity tagging:**
- AI-generated product images feeding a Merchant Center / Shopping surface with no `DigitalSourceType` → High (policy + transparency).
- AI-generated marketing imagery site-wide with no provenance labeling → Medium.
- Optimizer strips all metadata, defeating any tagging at source → Medium.
- Missing creator/credit/license metadata on licensable photography the brand wants in Google Images → Medium/Low.
- Metadata read not possible this run (no tool / blocked fetch) → Skip with reason, not a finding.

**Fix voice:** `solutions-architect` (primary) | `analytics-engineer` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Treat this as a pipeline decision, not a per-image edit. The question is not "which picture
> looks AI-made," it is "where in the asset flow do provenance and licensing fields get written,
> and where do they get lost." Right now the answer is nowhere and at resize: the optimizer is
> dropping IPTC/XMP on its way to the served file, so even a correctly tagged source asset ships
> bare.
>
> Fix it where the boundary is clearest, in two explicit steps:
>
> 1. **Stop the strip.** In the image optimizer config, turn metadata retention on for the
>    fields that matter (`DigitalSourceType`, `Creator`, `CreditLine`, `CopyrightNotice`,
>    license URL) rather than carrying every camera and GPS field. This is a one-line config
>    change and it is reversible: if a downstream tool chokes, you revert the flag.
> 2. **Own the injection.** Add one build step that writes the fields before publish. For
>    AI-generated assets set `DigitalSourceType` to `trainedAlgorithmicMedia` (or
>    `compositeSynthetic` for AI-assisted composites); for owned photography set `Creator`,
>    `CreditLine`, `CopyrightNotice`, and the license URL. Drive it from the same asset record
>    that already knows whether a given image came from an AI tool, so the label tracks the
>    source of truth instead of a human remembering.
>
> Sequence by stake. Product images on the Merchant Center feed go first, because a missing
> source type there is a policy exposure, not a cosmetic one. Marketing imagery follows.
> Decorative UI assets are out of scope, so do not spend the step on them.
>
> Verify with the same reader you audited with: pull a served product binary and confirm the
> fields survived the optimizer to the file Google actually fetches. The operational risk here
> is drift, the served file disagreeing with what you tagged at source, so make the read part of
> the deploy check, not a one-time pass.
