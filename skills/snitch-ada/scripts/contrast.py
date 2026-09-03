#!/usr/bin/env python3
"""WCAG relative-luminance contrast ratio between two colors.

Usage:
    contrast.py <foreground> <background>
    contrast.py --json <foreground> <background>
    contrast.py --selftest

Each color is one of:
    #rgb            #f0a
    #rrggbb         #ff00aa
    #rrggbbaa       #ff00aa80   (alpha composited over the other color; a warning is printed)
    rgb(r, g, b)    rgb(255, 0, 170)
    <named>         one of the 148 CSS named colors

Prints the ratio to two decimals and pass/fail against 4.5:1 (normal text, AA),
3:1 (large text and non-text UI, AA) and 7:1 (AAA, advisory only).

Exit codes: 0 on valid input, 2 on a usage or parse error.
Stdlib only. Read-only: this script never writes a file.
"""

import json
import re
import sys

# The 148 CSS named colors (CSS Color Module Level 4), including the two spellings
# of grey/gray and the "transparent" keyword handled separately.
NAMED = {
    "aliceblue": "#f0f8ff", "antiquewhite": "#faebd7", "aqua": "#00ffff",
    "aquamarine": "#7fffd4", "azure": "#f0ffff", "beige": "#f5f5dc",
    "bisque": "#ffe4c4", "black": "#000000", "blanchedalmond": "#ffebcd",
    "blue": "#0000ff", "blueviolet": "#8a2be2", "brown": "#a52a2a",
    "burlywood": "#deb887", "cadetblue": "#5f9ea0", "chartreuse": "#7fff00",
    "chocolate": "#d2691e", "coral": "#ff7f50", "cornflowerblue": "#6495ed",
    "cornsilk": "#fff8dc", "crimson": "#dc143c", "cyan": "#00ffff",
    "darkblue": "#00008b", "darkcyan": "#008b8b", "darkgoldenrod": "#b8860b",
    "darkgray": "#a9a9a9", "darkgreen": "#006400", "darkgrey": "#a9a9a9",
    "darkkhaki": "#bdb76b", "darkmagenta": "#8b008b", "darkolivegreen": "#556b2f",
    "darkorange": "#ff8c00", "darkorchid": "#9932cc", "darkred": "#8b0000",
    "darksalmon": "#e9967a", "darkseagreen": "#8fbc8f", "darkslateblue": "#483d8b",
    "darkslategray": "#2f4f4f", "darkslategrey": "#2f4f4f", "darkturquoise": "#00ced1",
    "darkviolet": "#9400d3", "deeppink": "#ff1493", "deepskyblue": "#00bfff",
    "dimgray": "#696969", "dimgrey": "#696969", "dodgerblue": "#1e90ff",
    "firebrick": "#b22222", "floralwhite": "#fffaf0", "forestgreen": "#228b22",
    "fuchsia": "#ff00ff", "gainsboro": "#dcdcdc", "ghostwhite": "#f8f8ff",
    "gold": "#ffd700", "goldenrod": "#daa520", "gray": "#808080",
    "green": "#008000", "greenyellow": "#adff2f", "grey": "#808080",
    "honeydew": "#f0fff0", "hotpink": "#ff69b4", "indianred": "#cd5c5c",
    "indigo": "#4b0082", "ivory": "#fffff0", "khaki": "#f0e68c",
    "lavender": "#e6e6fa", "lavenderblush": "#fff0f5", "lawngreen": "#7cfc00",
    "lemonchiffon": "#fffacd", "lightblue": "#add8e6", "lightcoral": "#f08080",
    "lightcyan": "#e0ffff", "lightgoldenrodyellow": "#fafad2", "lightgray": "#d3d3d3",
    "lightgreen": "#90ee90", "lightgrey": "#d3d3d3", "lightpink": "#ffb6c1",
    "lightsalmon": "#ffa07a", "lightseagreen": "#20b2aa", "lightskyblue": "#87cefa",
    "lightslategray": "#778899", "lightslategrey": "#778899", "lightsteelblue": "#b0c4de",
    "lightyellow": "#ffffe0", "lime": "#00ff00", "limegreen": "#32cd32",
    "linen": "#faf0e6", "magenta": "#ff00ff", "maroon": "#800000",
    "mediumaquamarine": "#66cdaa", "mediumblue": "#0000cd", "mediumorchid": "#ba55d3",
    "mediumpurple": "#9370db", "mediumseagreen": "#3cb371", "mediumslateblue": "#7b68ee",
    "mediumspringgreen": "#00fa9a", "mediumturquoise": "#48d1cc",
    "mediumvioletred": "#c71585", "midnightblue": "#191970", "mintcream": "#f5fffa",
    "mistyrose": "#ffe4e1", "moccasin": "#ffe4b5", "navajowhite": "#ffdead",
    "navy": "#000080", "oldlace": "#fdf5e6", "olive": "#808000",
    "olivedrab": "#6b8e23", "orange": "#ffa500", "orangered": "#ff4500",
    "orchid": "#da70d6", "palegoldenrod": "#eee8aa", "palegreen": "#98fb98",
    "paleturquoise": "#afeeee", "palevioletred": "#db7093", "papayawhip": "#ffefd5",
    "peachpuff": "#ffdab9", "peru": "#cd853f", "pink": "#ffc0cb",
    "plum": "#dda0dd", "powderblue": "#b0e0e6", "purple": "#800080",
    "rebeccapurple": "#663399", "red": "#ff0000", "rosybrown": "#bc8f8f",
    "royalblue": "#4169e1", "saddlebrown": "#8b4513", "salmon": "#fa8072",
    "sandybrown": "#f4a460", "seagreen": "#2e8b57", "seashell": "#fff5ee",
    "sienna": "#a0522d", "silver": "#c0c0c0", "skyblue": "#87ceeb",
    "slateblue": "#6a5acd", "slategray": "#708090", "slategrey": "#708090",
    "snow": "#fffafa", "springgreen": "#00ff7f", "steelblue": "#4682b4",
    "tan": "#d2b48c", "teal": "#008080", "thistle": "#d8bfd8",
    "tomato": "#ff6347", "turquoise": "#40e0d0", "violet": "#ee82ee",
    "wheat": "#f5deb3", "white": "#ffffff", "whitesmoke": "#f5f5f5",
    "yellow": "#ffff00", "yellowgreen": "#9acd32",
}

RGB_FUNC = re.compile(
    r"^rgba?\(\s*(-?[\d.]+)\s*[,\s]\s*(-?[\d.]+)\s*[,\s]\s*(-?[\d.]+)"
    r"(?:\s*[,/]\s*(-?[\d.]+%?)\s*)?\)$",
    re.IGNORECASE,
)


class ColorError(ValueError):
    """Raised when a color string cannot be parsed."""


def _clamp8(value):
    return max(0, min(255, int(round(value))))


def parse_color(text):
    """Return (r, g, b, alpha) with r/g/b as 0-255 ints and alpha as a 0.0-1.0 float."""
    if text is None:
        raise ColorError("empty color")
    s = text.strip().lower()
    if not s:
        raise ColorError("empty color")

    if s in NAMED:
        s = NAMED[s]

    if s.startswith("#"):
        h = s[1:]
        if not re.fullmatch(r"[0-9a-f]+", h):
            raise ColorError("'%s' is not a hex color" % text)
        if len(h) == 3:
            r, g, b = (int(c * 2, 16) for c in h)
            return r, g, b, 1.0
        if len(h) == 4:
            r, g, b, a = (int(c * 2, 16) for c in h)
            return r, g, b, a / 255.0
        if len(h) == 6:
            return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 1.0
        if len(h) == 8:
            return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16),
                    int(h[6:8], 16) / 255.0)
        raise ColorError("'%s' has %d hex digits; expected 3, 4, 6 or 8" % (text, len(h)))

    m = RGB_FUNC.match(s)
    if m:
        r, g, b = (_clamp8(float(m.group(i))) for i in (1, 2, 3))
        alpha_raw = m.group(4)
        if alpha_raw is None:
            alpha = 1.0
        elif alpha_raw.endswith("%"):
            alpha = float(alpha_raw[:-1]) / 100.0
        else:
            alpha = float(alpha_raw)
        return r, g, b, max(0.0, min(1.0, alpha))

    raise ColorError(
        "'%s' is not a supported color (use #rgb, #rrggbb, #rrggbbaa, "
        "rgb(r,g,b) or a CSS named color)" % text
    )


def composite(fg, bg):
    """Alpha-composite fg over bg. Both are (r, g, b, a); returns (r, g, b)."""
    fr, fg_, fb, fa = fg
    br, bg_, bb, _ = bg
    return (
        _clamp8(fr * fa + br * (1.0 - fa)),
        _clamp8(fg_ * fa + bg_ * (1.0 - fa)),
        _clamp8(fb * fa + bb * (1.0 - fa)),
    )


def relative_luminance(rgb):
    """WCAG relative luminance for an (r, g, b) triple of 0-255 ints."""
    channels = []
    for value in rgb:
        c = value / 255.0
        channels.append(c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4)
    r, g, b = channels
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(rgb_a, rgb_b):
    la = relative_luminance(rgb_a)
    lb = relative_luminance(rgb_b)
    lighter, darker = (la, lb) if la >= lb else (lb, la)
    return (lighter + 0.05) / (darker + 0.05)


def evaluate(fg_text, bg_text):
    """Parse both colors, composite any alpha, and return a result dict plus warnings."""
    fg = parse_color(fg_text)
    bg = parse_color(bg_text)
    warnings = []

    if bg[3] < 1.0:
        warnings.append(
            "background alpha %.3f composited over opaque white; the real backdrop "
            "may differ, so confirm the rendered value" % bg[3]
        )
        bg_rgb = composite(bg, (255, 255, 255, 1.0))
    else:
        bg_rgb = bg[:3]

    if fg[3] < 1.0:
        warnings.append(
            "foreground alpha %.3f composited over the background color; the "
            "resolved cascade may differ" % fg[3]
        )
        fg_rgb = composite(fg, (bg_rgb[0], bg_rgb[1], bg_rgb[2], 1.0))
    else:
        fg_rgb = fg[:3]

    ratio = contrast_ratio(fg_rgb, bg_rgb)
    rounded = round(ratio, 2)
    return {
        "foreground": fg_text,
        "background": bg_text,
        "foreground_resolved": "#%02x%02x%02x" % fg_rgb,
        "background_resolved": "#%02x%02x%02x" % bg_rgb,
        "ratio": rounded,
        "thresholds": {
            "normal_text_aa_4.5": rounded >= 4.5,
            "large_text_and_non_text_aa_3.0": rounded >= 3.0,
            "enhanced_aaa_7.0_advisory": rounded >= 7.0,
        },
        "warnings": warnings,
    }, warnings


def _fmt(passed):
    return "pass" if passed else "FAIL"


def render_text(result):
    lines = [
        "%s on %s  ->  %.2f:1"
        % (result["foreground_resolved"], result["background_resolved"], result["ratio"]),
        "  4.5:1  normal text (AA)                  %s" % _fmt(
            result["thresholds"]["normal_text_aa_4.5"]),
        "  3.0:1  large text / non-text UI (AA)     %s" % _fmt(
            result["thresholds"]["large_text_and_non_text_aa_3.0"]),
        "  7.0:1  enhanced (AAA, advisory only)     %s" % _fmt(
            result["thresholds"]["enhanced_aaa_7.0_advisory"]),
    ]
    for w in result["warnings"]:
        lines.append("  warning: %s" % w)
    return "\n".join(lines)


USAGE = (
    "usage: contrast.py [--json] <foreground> <background>\n"
    "       contrast.py --selftest\n"
    "colors: #rgb | #rrggbb | #rrggbbaa | rgb(r,g,b) | CSS named color"
)


def selftest():
    checks = []

    r, _ = evaluate("#000000", "#ffffff")
    checks.append(("black on white is 21.00", abs(r["ratio"] - 21.00) < 0.005, r["ratio"]))

    r, _ = evaluate("#767676", "#ffffff")
    checks.append(("#767676 on white is ~4.54", abs(r["ratio"] - 4.54) < 0.01, r["ratio"]))

    r, _ = evaluate("#ffffff", "#ffffff")
    checks.append(("white on white is 1.00", abs(r["ratio"] - 1.00) < 0.005, r["ratio"]))

    r, _ = evaluate("white", "black")
    checks.append(("named colors resolve", abs(r["ratio"] - 21.00) < 0.005, r["ratio"]))

    r, _ = evaluate("rgb(118, 118, 118)", "#fff")
    checks.append(("rgb() and #rgb resolve", abs(r["ratio"] - 4.54) < 0.01, r["ratio"]))

    r, w = evaluate("#00000080", "#ffffff")
    checks.append(("alpha composites and warns", len(w) == 1 and r["ratio"] > 1.0, r["ratio"]))

    r, _ = evaluate("#767676", "#ffffff")
    checks.append((
        "thresholds: 4.5 pass, 3.0 pass, 7.0 fail",
        r["thresholds"]["normal_text_aa_4.5"]
        and r["thresholds"]["large_text_and_non_text_aa_3.0"]
        and not r["thresholds"]["enhanced_aaa_7.0_advisory"],
        r["ratio"],
    ))

    bad = 0
    for value in ("#gg0000", "not-a-color", "#12345", "rgb(1,2)"):
        try:
            parse_color(value)
        except ColorError:
            bad += 1
    checks.append(("bad input raises ColorError", bad == 4, bad))

    ok = True
    for label, passed, observed in checks:
        print("%-42s %s (%s)" % (label, "ok" if passed else "FAILED", observed))
        ok = ok and passed
    print("selftest: %s (%d checks)" % ("PASS" if ok else "FAIL", len(checks)))
    return 0 if ok else 1


def main(argv):
    args = list(argv[1:])
    if "--selftest" in args:
        return selftest()

    as_json = False
    if "--json" in args:
        as_json = True
        args.remove("--json")

    if len(args) != 2:
        print(USAGE, file=sys.stderr)
        return 2

    try:
        result, _ = evaluate(args[0], args[1])
    except ColorError as exc:
        print("error: %s" % exc, file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2

    if as_json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(render_text(result))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
