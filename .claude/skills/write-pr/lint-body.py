"""Check a PR body against the house style before it is opened.

    python3 -I lint-body.py <body-file> <pr.toml>

Exit 1 with one line per problem on failures; warnings go to stderr and do
not fail. Checks:

  fail  last non-blank line is not the attribution line from pr.toml (one
        trailing https://claude.ai/code/session_... line after it is allowed,
        since the bodies already in .prs/ have one)
  fail  an emoji anywhere other than that line
  fail  the body opens with "This PR adds/This PR introduces/This change ..."
  fail  a marketing word (seamless, robust, powerful, comprehensive, leverage,
        cutting-edge, streamline, elegant, supercharge, game-changing, best-in-class)
  warn  no code block and no digit in the body: output was probably described
        rather than shown
  warn  body is one paragraph and over 600 characters: nothing is sectioned
"""
import re
import sys
import tomllib

MARKETING = [
    "seamless", "robust", "powerful", "comprehensive", "leverage", "cutting-edge",
    "streamline", "elegant", "supercharge", "game-changing", "best-in-class",
    "effortless", "blazing", "world-class",
]
SESSION_LINK = re.compile(r"^https://claude\.ai/code/session_\w+$")
OPENERS = re.compile(r"^\s*(this (pr|pull request|change|commit) (adds|introduces|implements|updates|improves|fixes))", re.I)
# Emoji and pictographs; the ranges that cover what people paste, without
# catching box-drawing, arrows or math.
EMOJI = re.compile("[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F000-\U0001F2FF]")


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    body_path, cfg_path = sys.argv[1], sys.argv[2]
    with open(cfg_path, "rb") as f:
        attribution = tomllib.load(f)["attribution"].strip()
    with open(body_path, encoding="utf-8") as f:
        text = f.read()
    lines = text.splitlines()
    problems: list[str] = []
    warnings: list[str] = []

    nonblank = [(i, l) for i, l in enumerate(lines, 1) if l.strip()]
    # The bodies already in .prs/ end with the attribution line and then a
    # claude.ai session link; that one trailing line is allowed after it.
    if nonblank and SESSION_LINK.match(nonblank[-1][1].strip()):
        nonblank = nonblank[:-1]
    if not nonblank:
        problems.append("body is empty")
    else:
        last_i, last = nonblank[-1]
        if last.strip() != attribution:
            problems.append(f"line {last_i}: last line must be the attribution line, got: {last.strip()[:60]!r}")
        for i, l in enumerate(lines, 1):
            if l.strip() == attribution:
                continue
            if EMOJI.search(l):
                problems.append(f"line {i}: emoji outside the attribution line")
        first_i, first = nonblank[0]
        if OPENERS.match(first):
            problems.append(f"line {first_i}: opens with a 'This PR adds' sentence; lead with the load-bearing fact")

    lowered = text.lower()
    for w in MARKETING:
        for m in re.finditer(r"\b" + re.escape(w) + r"\w*", lowered):
            line_no = text[: m.start()].count("\n") + 1
            problems.append(f"line {line_no}: marketing word {m.group(0)!r}")

    body_wo_attr = text.replace(attribution, "")
    if "```" not in body_wo_attr and not re.search(r"\d", body_wo_attr):
        warnings.append("no code block and no number: show real output rather than describing it")
    paragraphs = [p for p in re.split(r"\n\s*\n", body_wo_attr.strip()) if p.strip()]
    if len(paragraphs) == 1 and len(body_wo_attr) > 600:
        warnings.append("one long paragraph; split what changed from what does not work")

    for w in warnings:
        print(f"warn: {w}", file=sys.stderr)
    for p in problems:
        print(f"fail: {p}")
    if problems:
        return 1
    print(f"ok: {body_path} ({len(nonblank)} lines)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
