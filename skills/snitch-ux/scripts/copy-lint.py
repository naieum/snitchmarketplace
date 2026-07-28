#!/usr/bin/env python3
"""Deterministic copy-mechanics linter for the snitch-ux writing system.

Implements exactly rules W1-W14 from references/writing-system.md and reports
weighted violations per 100 words. Reads a file or stdin, writes to stdout,
never writes files. Same input + same mode = byte-identical output.

Usage:
    python3 scripts/copy-lint.py [--mode strict|flavored] [--json] [--max-score N.N] [FILE | -]

Exit status: 0 normally; 1 only when --max-score is given and exceeded.
Python 3 stdlib only. All heuristics (sentence split, passive voice, proper-noun
detection) are documented next to their implementation.
"""

import argparse
import json
import re
import sys

EM_DASH = chr(0x2014)  # em dash, spelled as a code point to keep the source ASCII-safe

MAX_EXAMPLES = 3
EXCERPT_LEN = 72

COORDINATORS = re.compile(r"\b(and|but|or|nor|yet|so)\b", re.I)

# W3: be-verb + participle. Heuristic: regular -ed participles plus a fixed
# irregular list. Adjectival participles false-positive; the agent adjudicates.
IRREGULAR_PARTICIPLES = (
    "written|done|made|seen|given|taken|known|shown|found|held|kept|left|lost|"
    "met|paid|read|said|sent|set|sold|told|thought|built|bought|brought|caught|"
    "chosen|driven|drawn|eaten|felt|gotten|grown|heard|hidden|led|put|run|"
    "spoken|spent|understood|won|worn|broken|frozen|stolen|thrown"
)
PASSIVE = re.compile(
    r"\b(?:is|are|was|were|be|been|being)\s+(?:\w+ed|" + IRREGULAR_PARTICIPLES + r")\b",
    re.I,
)

HEDGES = re.compile(
    r"\b(?:may|might|could|perhaps|possibly|likely|somewhat|arguably|"
    r"appears?\s+to|seems?\s+to|tends?\s+to)\b",
    re.I,
)

NOMINALIZATIONS = [
    re.compile(p, re.I)
    for p in (
        r"\bmak\w*\s+(?:a|the)\s+decisions?\b",
        r"\b(?:perform|conduct)\w*\s+(?:an?|the)\s+analys\w+\b",
        r"\bprovid\w*\s+(?:a|the)\s+recommendations?\b",
        r"\b(?:come|came|coming|comes)\s+to\s+(?:a|the)\s+conclusions?\b",
        r"\btak\w*\s+into\s+consideration\b",
        r"\bmak\w*\s+(?:an|the)\s+assumptions?\b",
        r"\bgiv\w*\s+(?:an|the)\s+indications?\b",
        r"\bcarr\w*\s+out\s+(?:an?|the)\s+evaluations?\b",
    )
]

FILLERS = [
    re.compile(p, re.I)
    for p in (
        r"\bin\s+order\s+to\b",
        r"\butiliz\w+\b",
        r"\bleverag(?:e|es|ed|ing)\b",
        r"\bvery\b",
        r"\breally\b",
        r"\bsimply\b",
        r"\bbasically\b",
        r"\bactually\b",
        r"\bneedless\s+to\s+say\b",
        r"\bat\s+the\s+end\s+of\s+the\s+day\b",
        r"\b(?:it'?s\s+)?worth\s+noting\b",
    )
]

AI_TELLS = [
    re.compile(p, re.I)
    for p in (
        r"\bdelv\w+\b",
        r"\btapestry\s+of\b",
        r"\bin\s+today'?s\s+fast-?paced\s+world\b",
        r"\bit'?s\s+important\s+to\s+note\b",
        r"\bnavigat\w+\s+the\s+complexit\w+\b",
        r"\bharness\w*\s+the\s+power\b",
        r"\bunlock\w*\s+the\s+potential\b",
        r"\belevate\s+your\b",
        r"\bsupercharg\w+\b",
        r"\bseamlessly\b",
        r"\bgame-?chang\w+\b",
        r"\bin\s+the\s+ever-?evolving\b",
        r"\bdiv(?:e|ing)\s+into\b",
        r"\blook\s+no\s+further\b",
        r"\blet'?s\s+explore\b",
    )
]

# W8: game-changing is counted by W7 only, so one phrase never scores twice.
VAGUE_ADJECTIVES = re.compile(
    r"\b(?:powerful|seamless|robust|world-?class|best-?in-?class|cutting-?edge|"
    r"next-?gen|revolutionary|innovative|intuitive|user-?friendly|"
    r"enterprise-?grade|state-?of-?the-?art|frictionless|effortless|amazing|"
    r"premier|leading-?edge)\b",
    re.I,
)

SUPERLATIVE = re.compile(
    r"\b(?:the\s+(?:best|fastest|easiest|cheapest|only)|#1|number\s+one|leading)\s+\w+",
    re.I,
)

TRANSITION_OPENER = re.compile(r"^\s*(?:furthermore|additionally|moreover|however)\b", re.I)

ROUND_SOCIAL_PROOF = re.compile(
    r"\b(?:thousands\s+of|millions\s+of|countless)\b", re.I
)

WORD = re.compile(r"[A-Za-z0-9'’-]+")

# Sentence split: end at [.!?] followed by whitespace, unless the preceding
# token is a known abbreviation. Decimals never match (no whitespace after dot).
ABBREVS = {
    "e.g", "i.e", "vs", "etc", "no", "mr", "mrs", "ms", "dr", "st", "approx",
    "cf", "fig", "u.s", "a.m", "p.m", "min", "max",
}
SENT_END = re.compile(r"[.!?]+(?=\s|$)")


def mask(text):
    """Replace non-prose regions with spaces so offsets/line numbers survive."""

    def blank(m):
        return re.sub(r"[^\n]", " ", m.group(0))

    # YAML frontmatter at start of file
    text = re.sub(r"\A---\n.*?\n---[ \t]*\n", blank, text, flags=re.S)
    # Fenced code blocks (covers audit_metadata yaml blocks)
    text = re.sub(r"^```.*?^```[ \t]*$", blank, text, flags=re.S | re.M)
    # Inline code and URLs
    text = re.sub(r"`[^`\n]*`", blank, text)
    text = re.sub(r"https?://\S+", blank, text)
    # Markdown link targets: keep the [text], blank the (url) part
    text = re.sub(r"\]\([^)\n]*\)", lambda m: "]" + " " * (len(m.group(0)) - 1), text)
    # Structural markdown that would confuse sentence/word counts. Table pipes
    # and heading markers become spaces so cell/heading text stays countable.
    text = re.sub(r"^[ \t]*#{1,6}[ \t]", blank, text, flags=re.M)
    text = re.sub(r"^[ \t]*(?:[-*+]|\d+\.)[ \t]", blank, text, flags=re.M)
    text = re.sub(r"^[ \t]*>[ \t]?", blank, text, flags=re.M)
    text = text.replace("|", " ")
    text = re.sub(r"[*_]{1,3}(?=\S)|(?<=\S)[*_]{1,3}", " ", text)
    # Horizontal rules / table separators
    text = re.sub(r"^[ \t]*[-:=]{3,}[ \t]*$", blank, text, flags=re.M)
    return text


def line_of(text, offset):
    return text.count("\n", 0, offset) + 1


def excerpt(text, start, end):
    snippet = " ".join(text[start:end].split())
    if len(snippet) > EXCERPT_LEN:
        snippet = snippet[: EXCERPT_LEN - 3] + "..."
    return snippet


def sentences(text):
    """Yield (start, end) spans. Heuristic splitter, deterministic."""
    spans = []
    start = 0
    for m in SENT_END.finditer(text):
        before = text[max(0, m.start() - 12): m.start()]
        tok = re.search(r"([\w.]+)$", before)
        if tok and tok.group(1).lower().rstrip(".") in ABBREVS:
            continue
        seg = text[start: m.end()]
        if WORD.search(seg):
            spans.append((start, m.end()))
        start = m.end()
    tail = text[start:]
    if WORD.search(tail):
        spans.append((start, len(text)))
    return spans


class Rule:
    def __init__(self, rid, name, weight=1.0):
        self.rid = rid
        self.name = name
        self.weight = weight
        self.hits = []  # (offset, excerpt_start, excerpt_end)

    def add(self, offset, ex_start, ex_end):
        self.hits.append((offset, ex_start, ex_end))


def run(text, mode):
    masked = mask(text)
    words = WORD.findall(masked)
    n_words = len(words)
    spans = sentences(masked)

    strict = mode == "strict"
    rules = {
        "W1": Rule("W1", "sentence-length"),
        "W2": Rule("W2", "clause-pile-up"),
        "W3": Rule("W3", "passive-voice"),
        "W4": Rule("W4", "nominalization"),
        "W5": Rule("W5", "hedge-stacking"),
        "W6": Rule("W6", "filler"),
        "W7": Rule("W7", "ai-tell"),
        "W8": Rule("W8", "vague-adjective", weight=1.0 if strict else 0.5),
        "W9": Rule("W9", "unsupported-superlative"),
        "W10": Rule("W10", "em-dash-density"),
        "W11": Rule("W11", "transition-opener"),
        "W12": Rule("W12", "start-repetition"),
        "W13": Rule("W13", "exclamation"),
        "W14": Rule("W14", "round-social-proof"),
    }

    # --- per-sentence rules ---
    w1_cap = 24 if strict else 32
    first_words = []
    transition_hits = []
    for s_start, s_end in spans:
        sent = masked[s_start:s_end]
        n = len(WORD.findall(sent))
        if n > w1_cap:
            rules["W1"].add(s_start, s_start, s_end)
        if sent.count(";") >= 2 or (
            sent.count(",") >= 3 and COORDINATORS.search(sent)
        ):
            rules["W2"].add(s_start, s_start, s_end)
        if len(HEDGES.findall(sent)) >= 2:
            rules["W5"].add(s_start, s_start, s_end)
        if TRANSITION_OPENER.search(sent):
            transition_hits.append((s_start, s_end))
        fw = WORD.search(sent)
        first_words.append(fw.group(0).lower() if fw else "")

    # W11: only a violation when >=3 occurrences or >15% of sentences
    if transition_hits and (
        len(transition_hits) >= 3
        or (spans and len(transition_hits) / len(spans) > 0.15)
    ):
        for s_start, s_end in transition_hits:
            rules["W11"].add(s_start, s_start, s_end)

    # W12 (strict only): runs of 3+ sentences opening with the same word
    if strict:
        i = 0
        while i < len(first_words):
            j = i
            while (
                j + 1 < len(first_words)
                and first_words[j + 1] == first_words[i]
                and first_words[i]
            ):
                j += 1
            if j - i + 1 >= 3:
                s_start, s_end = spans[i]
                rules["W12"].add(s_start, s_start, spans[j][1])
            i = j + 1

    # --- density rules (budget = allowed hits for this word count) ---
    def budget_hits(rule, matches, per_100w):
        allowed = int(n_words * per_100w / 100)
        for m in matches[allowed:]:
            rule.add(m.start(), m.start(), m.end())

    passive_matches = list(PASSIVE.finditer(masked))
    budget_hits(rules["W3"], passive_matches, 1.0 if strict else 2.0)

    if strict:
        hedge_matches = list(HEDGES.finditer(masked))
        budget_hits(rules["W5"], hedge_matches, 2.0)

    dash_matches = [
        m
        for m in re.finditer(EM_DASH + r"|(?<=\w) -- (?=\w)", masked)
    ]
    allowed_dashes = int(n_words / 200)
    for m in dash_matches[allowed_dashes:]:
        rules["W10"].add(m.start(), max(0, m.start() - 30), m.end() + 30)

    bang_matches = list(re.finditer(r"!", masked))
    if strict:
        for m in bang_matches:
            rules["W13"].add(m.start(), max(0, m.start() - 40), m.end())
    else:
        allowed_bangs = int(n_words / 100)
        for m in bang_matches[allowed_bangs:]:
            rules["W13"].add(m.start(), max(0, m.start() - 40), m.end())

    # --- phrase rules ---
    for rid, patterns in (("W4", NOMINALIZATIONS), ("W6", FILLERS), ("W7", AI_TELLS)):
        for pat in patterns:
            for m in pat.finditer(masked):
                rules[rid].add(m.start(), m.start(), m.end())

    for m in VAGUE_ADJECTIVES.finditer(masked):
        rules["W8"].add(m.start(), m.start(), m.end())
    for m in ROUND_SOCIAL_PROOF.finditer(masked):
        rules["W14"].add(m.start(), m.start(), m.end())

    # W9: superlative with no digit / proper noun within 50 words either side.
    # Proper-noun heuristic: capitalized token whose predecessor does not end a
    # sentence (approximates "capitalized mid-sentence").
    for m in SUPERLATIVE.finditer(masked):
        w_before = list(WORD.finditer(masked, 0, m.start()))[-50:]
        w_after = list(WORD.finditer(masked, m.end()))[:50]
        window = w_before + w_after
        proven = False
        prev_end = None
        for wm in window:
            tok = wm.group(0)
            if any(c.isdigit() for c in tok):
                proven = True
                break
            gap = masked[prev_end: wm.start()] if prev_end is not None else "."
            sentence_initial = bool(re.search(r"[.!?\n]", gap))
            if (
                tok[0].isupper()
                and len(tok) > 2
                and tok[1:].islower()
                and not sentence_initial
            ):
                proven = True
                break
            prev_end = wm.end()
        if not proven:
            rules["W9"].add(m.start(), m.start(), m.end())

    # --- assemble ---
    for rule in rules.values():
        rule.hits.sort(key=lambda h: h[0])

    total = sum(len(r.hits) * r.weight for r in rules.values())
    score = round(total / n_words * 100, 1) if n_words else 0.0
    return rules, n_words, len(spans), total, score


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("path", nargs="?", default="-", help="input file, or - for stdin")
    ap.add_argument("--mode", choices=("strict", "flavored"), default="strict")
    ap.add_argument("--json", action="store_true", dest="as_json")
    ap.add_argument("--max-score", type=float, default=None)
    args = ap.parse_args()

    if args.path == "-":
        text = sys.stdin.read()
    else:
        with open(args.path, encoding="utf-8") as fh:
            text = fh.read()

    rules, n_words, n_sents, total, score = run(text, args.mode)

    if args.as_json:
        payload = {
            "mode": args.mode,
            "words": n_words,
            "sentences": n_sents,
            "violations_per_100_words": score,
            "weighted_total": round(total, 1),
            "rules": {
                r.rid: {
                    "name": r.name,
                    "count": len(r.hits),
                    "weight": r.weight,
                    "examples": [
                        {"line": line_of(text, off), "excerpt": excerpt(text, a, b)}
                        for off, a, b in r.hits[:MAX_EXAMPLES]
                    ],
                }
                for r in rules.values()
                if r.hits
            },
        }
        print(json.dumps(payload, indent=2))
    else:
        print(f"copy-lint  mode={args.mode}  words={n_words}  sentences={n_sents}")
        for r in rules.values():
            if not r.hits:
                continue
            print(f"  {r.rid:<4} {r.name:<24} x{len(r.hits)}  (weight {r.weight})")
            for off, a, b in r.hits[:MAX_EXAMPLES]:
                print(f"       L{line_of(text, off)}: {excerpt(text, a, b)}")
        print(
            f"score: {score} violations per 100 words "
            f"(weighted {round(total, 1)} over {n_words} words)"
        )

    if args.max_score is not None and score > args.max_score:
        sys.exit(1)


if __name__ == "__main__":
    main()
