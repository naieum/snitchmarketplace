## CATEGORY 02: Captions, transcripts and audio control

Video and audio carry information in a channel that not everyone receives. A deaf or hard-of-hearing
person needs the speech as text. A blind person needs the visual information spoken or written. A
screen-reader user needs autoplaying sound to stop, because it drowns out the voice they navigate
by. This category judges time-based media against **1.2.1 Audio-only and Video-only
(Prerecorded) (A)**, **1.2.2 Captions (Prerecorded) (A)**, **1.2.3 Audio Description or Media
Alternative (Prerecorded) (A)**, **1.2.4 Captions (Live) (AA)**, **1.2.5 Audio Description
(Prerecorded) (AA)** and **1.4.2 Audio Control (A)**.

Most of these rows cannot be closed from markup alone. Source and DOM tell you whether a caption
track is *declared*; they do not tell you whether the captions are accurate, synchronized, or a
machine transcript of the wrong language. This category therefore produces honest Skips as often as
findings. A declared track is a Pass on presence and a Skip on quality, stated as two outcomes.

**Boundary.** This category asks whether the medium meets the criterion. When the question is
whether an uncaptioned explainer **stops one person from understanding the offer** on their
decision path, call the Skill tool with "snitch-ux". When the judge is whether a transcript feeds
search and machine readability, call the Skill tool with "snitch-marketing". The autoplay row also
overlaps Cat 08: sound is judged here, movement is judged there.

### Pre-flight

Run when the surface carries any `<video>`, `<audio>`, media embed, podcast episode, webinar
recording, product demo, background hero video or live-stream page.

1. **The media inventory.** Every media element and embed, with its page, its type (prerecorded
   synchronized, prerecorded audio-only, prerecorded video-only, live), and whether it has audio.
   The type decides which rows apply; guessing it produces the wrong criterion.
2. **Whether a human or runner is available.** Caption accuracy, audio-description presence and
   live-caption behavior need one. Say up front which rows will Skip.
3. **Declared intent.** Read `BLUEPRINT.md` and `marketing/positioning.md` read-only. A `Decision`
   line does not excuse a Level A failure; it caps a contradicting best-practice fix at Medium.
   Neither file present is a Skip with that reason.

Skip the whole category with reason `no time-based media in scope` when the inventory is zero.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 1.2.1 Audio-only and Video-only (Prerecorded) | A | Prerecorded audio-only has a text transcript; prerecorded video-only has a text alternative or an audio track presenting the same information | podcast or episode page with an `<audio>` element and no transcript link or transcript block; silent looping product clip with no adjacent description | partial | High |
| 1.2.2 Captions (Prerecorded) | A | Prerecorded synchronized media carries synchronized captions | `<video>` with no `<track kind="captions">`; player embed with no caption configuration and no caption evidence on the page | partial | High |
| 1.2.3 Audio Description or Media Alternative (Prerecorded) | A | Prerecorded synchronized media has audio description of the visual content, or a full text alternative for the media | video whose visuals carry information with no descriptive transcript and no described track | yes | High |
| 1.2.4 Captions (Live) | AA | Live synchronized media carries captions | live-stream or webinar page with no caption service named and no caption control in the player | yes | High |
| 1.2.5 Audio Description (Prerecorded) | AA | Prerecorded synchronized media has audio description | no descriptive audio track declared and no described version offered | yes | Medium |
| 1.4.2 Audio Control | A | Audio that plays automatically for more than 3 seconds can be paused, stopped, or its volume controlled independently of the system | `<audio autoplay>` or `<video autoplay>` without `muted`; background hero video with an audio track; embed initialised with `autoplay=1` and sound; no pause, stop or mute control in the same view | partial | Critical |

**The 3-second threshold is the criterion's own.** Audio under 3 seconds does not trigger 1.4.2, so
never report a short notification sound as a 1.4.2 failure.

**Burned-in (open) captions count for 1.2.2 only when a human confirms them.** Text rendered into
the video frames satisfies the criterion, and no markup shows it. If nobody watched the file, the
row is `Skip — caption presence requires a human or runner; not run`, not a missing-`<track>`
finding.

**Machine-generated captions are not automatically a Pass.** Auto-captions with no review routinely
carry the wrong words for names, products and numbers. Accuracy is a separate outcome a human
closes.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted element at
`file:line` (source mode) or URL + selector (crawl mode), or a human's stated observation of the
played media.

**Source mode, cheapest first:**

1. `Grep` for `<video`, `<audio`, `<track`, `<source`, `poster=` and the media wrapper. Quote each
   element whole, including children.
2. For each `<video>` with audio, record whether a `<track kind="captions">` or
   `kind="descriptions"` child exists, and whether its `src` resolves to a real file.
3. `Grep` for `autoplay`, `muted`, `loop`, `playsinline` on the same elements. `autoplay` without
   `muted` is the 1.4.2 static signal.
4. `Grep` for `<iframe` and for player-embed script initialisers. Read each embed's query string
   and options object for `autoplay`, `mute`, `cc_load_policy`, `captions`, `subtitles` or the
   equivalent key. Describe embeds by shape (a third-party video-host iframe, an audio-player
   widget), not by asserting behavior the markup does not show.
5. `Grep` for `transcript`, `show notes`, `.vtt`, `.srt` and podcast or media routes. A linked
   `.vtt` file is evidence; the word "transcript" in a nav label is not. Read the page around each
   podcast or webinar entry for a transcript block or link.
6. Read the media component for its own controls: a mute, pause or volume control rendered in the
   same view as the autoplaying media.

**Crawl mode:**

1. `Fetch` each media page. Quote the media element or embed with its attributes and query string.
2. Look for a transcript in the rendered HTML and a caption control in the embed. Record URL +
   selector per finding.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade or the player's runtime state. A `muted` attribute can be removed by script, and a
caption track can be attached by the player's API with no markup trace. Say so when the source is
ambiguous, and verify the rendered behavior before asserting a failure.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Play each video and confirm captions exist, are synchronized, and match the speech.
2. Confirm whether the visual channel carries information not in the audio. Only a viewer can
   decide that, and it decides 1.2.3 and 1.2.5.
3. Load the page fresh: does sound start on its own, for how long, and is a control in reach?
4. Join a live surface and confirm the caption service produces captions.

With no runner or human, write
`Skip — caption accuracy and played-media behavior require a human or runner; not run`, and report
only the static rows. Never assert live behavior nobody observed.

### Forbidden claims

- "Videos may lack captions." Quote the element and the absent track, or Skip with the reason.
- "The captions are poor quality." Only a human who watched them can say so. Skip otherwise.
- "Audio plays automatically." Quote the `autoplay` attribute or the embed parameter, and say
  whether `muted` is present. Inferring sound from `autoplay` alone is not evidence.
- "This video has no audio description." Only a viewer can establish that.
- Never write **compliant**, **conformant** or **non-compliant** as a verdict. Write "fails SC 1.2.2
  at this element" and let the reader draw the line.
- A 1.2.2 finding against a video with burned-in captions nobody checked. Skip instead.
- A 1.4.2 finding against a sound shorter than 3 seconds. The criterion does not reach it.
- A 1.2.4 finding on a page hosting a recording. Live is 1.2.4; prerecorded is 1.2.2.

### Detection

Static read of media markup, player embeds and page content across the representative set, plus
human or runner observation of the played media where available. Presence resolves statically;
accuracy, audio-description need and live behavior do not.

### What to Search For

- `<video>` and `<audio>` elements, their `<source>` and `<track>` children
- `kind="captions"`, `kind="subtitles"`, `kind="descriptions"`, and whether the `src` resolves
- Third-party player iframes, their query strings and their JavaScript initialisation objects:
  autoplay, mute and caption flags
- Background and hero video components: does the asset carry an audio track
- `.vtt` and `.srt` files in the repository, and whether any element references them
- Podcast, webinar and press routes with no transcript; live pages naming no caption service
- Mute, pause and volume controls rendered in the same view as autoplaying media

### Actually Fails

- **Prerecorded video with audio and no caption track, where a human confirmed no burned-in
  captions.** Evidence: the element, its children, and the observation. 1.2.2, High.
- **Player embed with captions disabled and no caption source, confirmed by a viewer.** Evidence:
  the embed URL and the observation. 1.2.2, High.
- **Audio-only page with no transcript, or video-only content with no text alternative.**
  Evidence: the element and the absent transcript or description. 1.2.1, High.
- **Video whose visuals carry information absent from the audio, with no described track and no
  descriptive transcript, confirmed by a viewer.** Evidence: the observation plus the element.
  1.2.3, High; 1.2.5 is the AA row on the same media.
- **Live stream with no caption service and no caption control, confirmed live.** Evidence: the
  page and the observation. 1.2.4, High.
- **`<audio autoplay>` or `<video autoplay>` with sound over 3 seconds and no pause, stop or
  independent volume control in reach.** Evidence: the element, the absent `muted`, and the absent
  control. 1.4.2, Critical.
- **Background hero video with an audio track and no mute control, or an embed initialised with
  `autoplay=1` and sound enabled.** Evidence: the component or the embed URL. 1.4.2, Critical.

### NOT a Failure

- `<video autoplay muted loop playsinline>` with no audio track. Silent motion is Cat 08's judge
  (2.2.2), not a 1.4.2 failure.
- A notification sound under 3 seconds. Below the criterion's own threshold.
- Media clearly labelled as a media alternative for text. 1.2.1, 1.2.2 and 1.2.3 exempt it.
- A video with burned-in captions confirmed by a viewer and no `<track>`. The criterion asks for
  captions, not for a mechanism.
- Auto-generated captions that a human reviewed and corrected.
- Audio that starts only after a user activates a control. Automatic is the trigger word in 1.4.2.
- A video whose visuals are decorative and whose audio carries everything. 1.2.3 and 1.2.5 reach
  visual information, and there is none.
- Captions in the content's own language only. Multi-language subtitling is not an AA obligation.

### Context Check

1. What type is each medium: prerecorded synchronized, audio-only, video-only, or live? The type
   selects the row, and the wrong type produces the wrong criterion.
2. Does the video actually carry audio? A silent loop triggers neither 1.2.2 nor 1.4.2.
3. Do the visuals carry information the audio does not? That is 1.2.3 and 1.2.5, and it needs a
   viewer.
4. Is the media the primary way the product is explained? Then cross-file the conversion half.
5. Is the media user-generated? Then the obligation extends to the upload flow, and the fix is a
   caption requirement in the authoring path.
6. Which rows could not be checked, and why? A Skip with a reason is coverage evidence.

### Severity

- **Critical** — automatic audio over 3 seconds with no pause, stop or independent volume control
  (1.4.2). Sound that cannot be stopped makes a screen reader unusable, blocking every other task.
- **High** — prerecorded synchronized media with no captions (1.2.2); audio-only with no transcript
  and video-only with no text alternative (1.2.1); missing audio description or media alternative
  (1.2.3); live media with no captions (1.2.4).
- **Medium** — missing audio description under the AA row (1.2.5), where a media alternative or
  described version exists in part, or the visual information is secondary.
- **Low** — caption and transcript formatting advisories (no speaker labels, no sound-effect cues,
  no timestamps). Quality notes, not criterion failures; they carry no SC number.

### Fix guidance

Three fixes, in the order the criteria fail hardest.

**1. Stop the sound from starting.**

```html
<!-- Fails 1.4.2: sound starts on load with nothing to stop it -->
<video src="/media/hero.mp4" autoplay loop></video>

<!-- Passes: silent by default, and the control is in the same view -->
<video id="hero" src="/media/hero.mp4" autoplay muted loop playsinline></video>
<button type="button" aria-pressed="false" onclick="toggleSound()">Turn sound on</button>
```

A background video is decoration, and decoration does not get to talk over the page.

**2. Ship the caption track with the video, not as a follow-up ticket.**

```html
<!-- Fails 1.2.2: synchronized media, no captions -->
<video controls><source src="/media/demo.mp4" type="video/mp4"></video>

<!-- Passes presence: captions declared, default on, and the file exists -->
<video controls>
  <source src="/media/demo.mp4" type="video/mp4">
  <track kind="captions" src="/media/demo.en.vtt" srclang="en" label="English" default>
  <track kind="descriptions" src="/media/demo.desc.en.vtt" srclang="en" label="Descriptions">
</video>
```

A `.vtt` file is plain text. One transcription pass and one review pass buy the captions, the
transcript, a search index and a translation source at once.

**3. Publish the transcript next to the audio, not behind a request form.**

```html
<audio controls src="/media/ep-14.mp3"></audio>
<details>
  <summary>Transcript, episode 14</summary>
  <p><strong>Host:</strong> Welcome back...</p>
</details>
```

For a video whose visuals carry information the narration does not, the transcript becomes a
*descriptive* transcript: it names what is shown as well as what is said. That one artefact
satisfies the media-alternative half of 1.2.3 without a second audio mix. Nothing here touches a
color value or a brand token. Report first; apply nothing without confirmation.

### Reference

WCAG 2.2, SC 1.2.1 Audio-only and Video-only (Prerecorded), Level A:
https://www.w3.org/TR/WCAG22/#audio-only-and-video-only-prerecorded · SC 1.2.2 Captions
(Prerecorded), Level A: https://www.w3.org/TR/WCAG22/#captions-prerecorded · SC 1.2.3 Audio
Description or Media Alternative (Prerecorded), Level A:
https://www.w3.org/TR/WCAG22/#audio-description-or-media-alternative-prerecorded

SC 1.2.4 Captions (Live), Level AA: https://www.w3.org/TR/WCAG22/#captions-live ·
SC 1.2.5 Audio Description (Prerecorded), Level AA:
https://www.w3.org/TR/WCAG22/#audio-description-prerecorded · SC 1.4.2 Audio Control, Level A:
https://www.w3.org/TR/WCAG22/#audio-control

W3C making audio and video media accessible: https://www.w3.org/WAI/media/av/ · MDN, the `<track>`
element: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/track
