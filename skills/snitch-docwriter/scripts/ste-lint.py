#!/usr/bin/env python3
"""ste-lint.py — deterministic anti-slop scorer for snitch-docwriter.

Every check below is keyed to a rule ID in references/rules.md (W2, W4, W5, V1, V2, V4,
V5, S2, S3, P1, P2, T1) — see RULE_LABELS. rules.md's own "linted" column names exactly
which of its 21 rule IDs this script can check; the rest (W1, W3, W6, S1, S4, S5, V3, T2,
T3, listed in NOT_LINTED) need human judgment, not a regex.

Score = total violations per 100 words (length-normalized; noisy under ~50 words).
Target bands (see SKILL.md): strict <= 1.5/100w, flavored <= 2.5/100w. W4 and W5 hits are
"banned outright, both modes" in rules.md, so `banned_word_hits` must be zero in either
mode regardless of the score band. The bands were re-checked after the V1/V4 guards below
went in: eleven uncontrolled technical SKILL.md files in the family score 3.6-6.5/100w,
and the files written under this system score 0.0-0.8/100w. The bands still separate the
two, so they are unchanged.

Usage:
  python3 ste-lint.py file.md [more files or globs]    # per-file summary table, flavored
  python3 ste-lint.py --evidence file.md               # file:line + rule ID + sentence
  python3 ste-lint.py --mode strict file.md            # strict-mode thresholds
  python3 ste-lint.py --json file.md                   # full JSON per file, with evidence
  python3 ste-lint.py < draft.txt                      # JSON detail on stdin, flavored
  python3 ste-lint.py --mode strict < draft.txt        # JSON detail, strict thresholds

Every hit carries the 1-based line of the source file it came from, so an audit finding
can cite file:line with the exact sentence and the rule ID (SKILL.md's finding format).
A sentence that breaks one rule twice is counted twice and reported once.

Code fences and inline code spans are stripped before scoring — code is never linted. A
leading YAML frontmatter block (SKILL.md metadata), markdown table rows (any line
containing "|"), and blockquote lines (leading ">") are stripped too: none of that is
prose, and a substitution table like rules.md's own W2 table would otherwise score as a
pile of rule violations.
"""
import re, sys, json, glob, os

RULE_LABELS = {
    "W2": "short word wins (W2)", "W4": "marketing adjective (W4)", "W5": "filler frame (W5)",
    "V1": "passive voice (V1)", "V2": "nominalization (V2)", "V4": "-ing main verb (V4)",
    "V5": "phrasal verb (V5)", "S2": "sentence length cap (S2)", "S3": "contraction (S3)",
    "P1": "semicolon (P1)", "P2": "em dash (P2)", "T1": "paragraph length/topic (T1)",
}
# Rule IDs from references/rules.md that need human judgment — no check below covers them.
NOT_LINTED = ["W1", "W3", "W6", "S1", "S4", "S5", "V3", "T2", "T3"]

# W2 — the "Not" column of rules.md's substitution table (with plain inflections of the
# same words; never a word the table doesn't name).
W2_WORDS = ["begin", "begins", "began", "beginning", "commence", "commences", "commenced",
    "commencing", "initiate", "initiates", "initiated", "initiating", "utilize", "utilizes",
    "utilized", "utilizing", "leverage", "leverages", "leveraged", "leveraging", "facilitate",
    "facilitates", "facilitated", "facilitating", "ensure", "ensures", "ensured", "ensuring",
    "prior to", "subsequent to", "regarding", "concerning", "obtain", "obtains", "obtained",
    "obtaining", "acquire", "acquires", "acquired", "acquiring", "demonstrate", "demonstrates",
    "demonstrated", "demonstrating", "additionally", "furthermore", "moreover", "numerous",
    "myriad", "a plethora of", "in order to", "whilst", "amongst", "comprehensive",
    "comprehensively"]

# W4 — "Banned outright, both modes" marketing adjectives, verbatim from rules.md (plus
# plain inflections).
W4_MARKETING = ["seamless", "seamlessly", "robust", "powerful", "cutting-edge", "effortless",
    "effortlessly", "world-class", "next-generation", "revolutionary", "blazing",
    "lightning-fast", "elegant", "delightful", "turnkey", "best-in-class", "state-of-the-art",
    "game-changing", "first-class", "battle-tested", "enterprise-grade", "supercharge",
    "unlock", "unlocks", "unleash", "unleashes", "empower", "empowers"]

# W5 — "Banned outright, both modes" filler frames, verbatim from rules.md.
W5_FILLER = ["it is important to note", "it should be noted", "it is worth noting",
    "please note that", "due to the fact that", "in the event that", "a variety of",
    "aforementioned", "henceforth", "therein"]

# V2 — the verb phrases rules.md names, plus the "___tion of" pattern it also names.
V2_VERB_PHRASES = r"\b(?:perform(?:s|ed|ing)?|conduct(?:s|ed|ing)?|carry out|carries out|carried out|make use of|makes use of|made use of)\b"
V2_TION_OF = r"\b\w{4,}tion\s+of\b"

# V5 — the phrasal verbs rules.md names (plus plain inflections).
V5_PHRASAL = ["spin up", "spins up", "spun up", "spinning up", "reach out", "reaches out",
    "reached out", "reaching out", "dive into", "dives into", "dived into", "diving into",
    "kick off", "kicks off", "kicked off", "kicking off", "roll out", "rolls out",
    "rolled out", "rolling out", "tear down", "tears down", "tore down", "tearing down",
    "ramp up", "ramps up", "ramped up", "ramping up"]

BE = r"(?:am|is|are|was|were|be|been|being)"
PP_IRREG = r"(?:done|made|sent|read|built|kept|held|set|put|run|written|shown|given|taken|found|got|gotten|seen|known|thrown|drawn)"

# V1 — a form of "be" plus a word that ends in "ed" is not enough to make a passive. Two
# classes of false positive are excluded here: words that only look like participles ("the
# light is red"), and participles that work as a plain adjective after "be" ("the flag is
# enabled" states a condition, it does not report an action). A named actor overrides the
# list, because "the value is fixed by the migration" is a real passive.
ED_NOT_PASSIVE = {
    # not participles at all — nouns and adjectives that happen to end in "ed"
    "red", "bed", "wed", "fed", "led", "shed", "sled", "bred", "sacred", "hundred",
    "naked", "wicked", "aged", "indeed", "need", "seed", "feed", "deed", "speed",
    "breed", "greed", "creed", "embed", "united",
    # participles that read as a plain adjective after a form of "be"
    "fixed", "closed", "limited", "required", "related", "detailed", "advanced",
    "complicated", "tired", "interested", "excited", "pleased", "concerned", "involved",
    "based", "dedicated", "experienced", "qualified", "skilled", "prepared", "supposed",
    "satisfied", "worried", "surprised", "confused", "connected", "enabled", "disabled",
    "deprecated", "expected", "supported", "unchanged", "unused",
}

# V4 — same problem in the other direction. A form of "be" plus a word that ends in "ing"
# is a progressive verb only when the word is a verb. "There is nothing here" and "the
# file is missing" are a pronoun and an adjective.
ING_NOT_VERB = {
    # nouns and pronouns that end in "ing"
    "nothing", "something", "anything", "everything", "thing", "morning", "evening",
    "spring", "string", "ceiling", "king", "ring", "wing", "sibling", "offspring",
    "during", "sterling",
    # participles that read as a plain adjective after a form of "be"
    "missing", "interesting", "exciting", "willing", "pending", "outstanding",
    "confusing", "misleading", "surprising", "promising", "existing", "remaining",
    "corresponding", "ongoing", "boring", "amazing", "encouraging", "disappointing",
    "conflicting", "binding",
}

V1_CANDIDATE = re.compile(rf"\b{BE}\s+(\w+ed|{PP_IRREG})\b(\s+by\b)?", re.I)
V4_CANDIDATE = re.compile(rf"\b{BE}\s+(\w+ing)\b", re.I)

# S3 — a fixed list of actual contracted forms, not a generic "'s" suffix (which would
# also match a plain possessive like "the rule's scope" and false-positive).
CONTRACTIONS = r"\b(?:don't|doesn't|didn't|isn't|aren't|wasn't|weren't|can't|won't|wouldn't|" \
    r"couldn't|shouldn't|it's|that's|there's|here's|what's|who's|let's|" \
    r"[Ii]'m|you're|we're|they're|[Ii]'ve|you've|we've|they've|" \
    r"[Ii]'ll|you'll|we'll|they'll|he'll|she'll|it'll|" \
    r"[Ii]'d|you'd|we'd|they'd|he'd|she'd|it'd|he's|she's)\b"
CONTRACTIONS_RE = re.compile(CONTRACTIONS.replace("'", "['’]"), re.I)


def _blank_but_keep_lines(m):
    """Replacement that erases a match and keeps its newlines, so line numbers survive."""
    return "\n" * m.group(0).count("\n")


def strip_code(t):
    """Erase fenced blocks and inline code spans, one line number for one line."""
    t = re.sub(r"```.*?```", _blank_but_keep_lines, t, flags=re.S)
    t = re.sub(r"`[^`]*`", _blank_but_keep_lines, t)
    return t


def strip_frontmatter(t):
    """Blank a leading YAML frontmatter block — SKILL.md metadata, not prose."""
    m = re.match(r"^---\r?\n.*?\r?\n---\r?\n", t, flags=re.S)
    return _blank_but_keep_lines(m) + t[m.end():] if m else t


def prose_lines(text):
    """(line number, text) pairs for the prose lines only, 1-based.

    Markdown table rows and blockquotes are dropped, not blanked: a dropped row must not
    split the paragraph around it."""
    t = strip_frontmatter(strip_code(text))
    out = []
    for i, line in enumerate(t.split("\n"), start=1):
        s = line.strip()
        if "|" in s or s.startswith(">"):
            continue
        out.append((i, line))
    return out


def blocks(lines):
    """Group (line number, text) pairs into blocks. A blank line ends a block, and each
    list item (any nesting level) starts one. T2 already makes a list a vertical run of
    one-action items, not a T1 paragraph, so a 5-item list (nested sub-bullets included)
    must not fail T1's six-sentence cap as if it were one flowing paragraph."""
    out, cur = [], []
    for lineno, line in lines:
        if not line.strip():
            if cur:
                out.append(cur)
                cur = []
            continue
        if cur and re.match(r"^\s*(?:[-*+]|\d+[.)])\s", line):
            out.append(cur)
            cur = []
        cur.append((lineno, line))
    if cur:
        out.append(cur)
    return out


def _unwrap(block):
    """Join a block's soft-wrapped markdown lines into one flat string, after stripping
    the block's own leading heading/list marker. Markdown wraps prose at a fixed column,
    not at sentence boundaries, so scoring line-by-line would count each wrapped line as
    its own "sentence" and hide real long sentences and paragraphs. Returns the flat
    string and the (offset, line number) mark of every line inside it."""
    parts, marks, pos = [], [], 0
    for lineno, line in block:
        s = line.strip()
        if not s:
            continue
        if not parts:
            s = re.sub(r"^#{1,6}\s*", "", s)
            s = re.sub(r"^(?:[-*+]|\d+[.)])\s+", "", s)
            if not s:
                continue
        else:
            pos += 1  # the space that joins this line to the previous one
        marks.append((pos, lineno))
        parts.append(s)
        pos += len(s)
    return " ".join(parts), marks


SENTENCE_BREAK = r"(?<=[.!?:])\*{0,2}\s+(?=[A-Z0-9\"'\-*])"


def _line_at(marks, offset):
    """The source line a flat-string offset came from."""
    lineno = marks[0][1] if marks else 0
    for start, n in marks:
        if start > offset:
            break
        lineno = n
    return lineno


def _split_sentences(flat, marks):
    """(line number, sentence) pairs for one block."""
    out, start = [], 0
    for m in list(re.finditer(SENTENCE_BREAK, flat)) + [None]:
        end = m.start() if m else len(flat)
        seg = flat[start:end]
        lead = len(seg) - len(seg.lstrip())
        seg = seg.strip()
        if seg:
            out.append((_line_at(marks, start + lead), seg))
        start = m.end() if m else len(flat)
    return out


def sentences(text):
    """(line number, sentence) pairs for a whole document."""
    out = []
    for block in blocks(prose_lines(text)):
        flat, marks = _unwrap(block)
        if flat:
            out += _split_sentences(flat, marks)
    return out


def wc(s):
    return len([w for w in re.findall(r"[A-Za-z0-9][A-Za-z0-9'\-/]*", s)])


def count_ci(text, phrases):
    n = 0; hits = []
    low = text.lower()
    for ph in phrases:
        for m in re.finditer(r"(?<![a-z])" + re.escape(ph) + r"(?![a-z])", low):
            n += 1; hits.append(ph)
    return n, hits


def count_v1(text):
    """Passives, with the adjectival and look-alike forms in ED_NOT_PASSIVE excluded
    unless the sentence names the actor ("... is fixed by the migration")."""
    n = 0
    for m in V1_CANDIDATE.finditer(text):
        if m.group(2) or m.group(1).lower() not in ED_NOT_PASSIVE:
            n += 1
    return n


def count_v4(text):
    """Progressive main verbs, with the nouns and adjectives in ING_NOT_VERB excluded."""
    return sum(1 for m in V4_CANDIDATE.finditer(text) if m.group(1).lower() not in ING_NOT_VERB)


def lint(text, mode="flavored"):
    sents = sentences(text)
    words = sum(wc(s) for _, s in sents) or 1

    # S2 — rules.md caps instructions at 20 words and descriptive sentences at 25; a
    # script can't tell the two apart, so strict mode (procedures, error messages: mostly
    # instructions) uses the 20-word cap and flavored (mostly descriptive prose) uses 25.
    cap = 20 if mode == "strict" else 25

    v = {k: 0 for k in RULE_LABELS}
    evidence, w4h, w5h, longs = [], [], [], []

    def hit(rule, n, lineno, sentence):
        if n <= 0:
            return
        v[rule] += n
        evidence.append({"rule": rule, "line": lineno, "sentence": sentence})

    for lineno, s in sents:
        n = wc(s)
        if n > cap:
            longs.append(n)
            hit("S2", 1, lineno, s)
        hit("P1", s.count(";"), lineno, s)
        hit("P2", s.count("—"), lineno, s)  # em dash only — P2 does not ban the en dash
        hit("S3", len(CONTRACTIONS_RE.findall(s)), lineno, s)
        hit("V1", count_v1(s), lineno, s)
        hit("V4", count_v4(s), lineno, s)
        hit("V2", len(re.findall(V2_VERB_PHRASES, s, re.I)) + len(re.findall(V2_TION_OF, s, re.I)),
            lineno, s)
        hit("V5", count_ci(s, V5_PHRASAL)[0], lineno, s)
        hit("W2", count_ci(s, W2_WORDS)[0], lineno, s)
        c4, h4 = count_ci(s, W4_MARKETING); w4h += h4
        hit("W4", c4, lineno, s)
        c5, h5 = count_ci(s, W5_FILLER); w5h += h5
        hit("W5", c5, lineno, s)

    for block in blocks(prose_lines(text)):
        flat, marks = _unwrap(block)
        if flat and len(_split_sentences(flat, marks)) > 6:
            hit("T1", 1, block[0][0], flat[:120])

    total = sum(v.values())
    return {
        "mode": mode,
        "words": words, "sentences": len(sents),
        "violations": v, "rule_labels": RULE_LABELS, "not_linted": NOT_LINTED,
        "total": total, "total_per100w": round(total * 100.0 / words, 2),
        "banned_word_hits": v["W4"] + v["W5"],
        "longest_sentence_words": (max(longs) if longs else max((wc(s) for _, s in sents), default=0)),
        "sample_marketing": list(dict.fromkeys(w4h))[:6],
        "sample_filler": list(dict.fromkeys(w5h))[:6],
        "evidence": sorted(evidence, key=lambda e: (e["line"], e["rule"])),
    }


def summary_line(name, r):
    return (f"{name:32} words={r['words']:4d} total={r['total']:3d} "
            f"per100w={r['total_per100w']:6.2f} banned={r['banned_word_hits']:2d} "
            f"mode={r['mode']}")


if __name__ == "__main__":
    args = sys.argv[1:]
    mode = "flavored"
    if "--mode" in args:
        i = args.index("--mode")
        mode = args[i + 1] if i + 1 < len(args) else "flavored"
        del args[i:i + 2]
    show_evidence = "--evidence" in args
    as_json = "--json" in args
    files = [a for a in args if not a.startswith("--")]
    if not files:
        print(json.dumps(lint(sys.stdin.read(), mode), indent=2))
        sys.exit(0)
    exp = []
    for f in files:
        exp += sorted(glob.glob(f)) if any(c in f for c in "*?[") else [f]
    for f in exp:
        with open(f) as fh:
            r = lint(fh.read(), mode)
        if as_json:
            print(json.dumps({"file": f, **r}, indent=2))
            continue
        print(summary_line(os.path.basename(f), r))
        if show_evidence:
            for e in r["evidence"]:
                print(f"  {f}:{e['line']}  {RULE_LABELS[e['rule']]}  {e['sentence']}")
