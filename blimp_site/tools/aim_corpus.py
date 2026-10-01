#!/usr/bin/env python3
"""Build /aim's archive: every post, one per line.

    tools/aim_corpus.py TWEETS_JSONL... --bsky BSKY_JSONL --out aim-posts.tsv

TWEETS_JSONL are mlx chat-format training files (my_me_bot/training/*.jsonl,
cut from the 2024-11-12 Twitter archive): the post is the assistant turn.
They carry no dates. BSKY_JSONL is com.atproto.repo.listRecords output for
app.bsky.feed.post, one record per line.

Output columns, tab-separated:  source  date  text
  source      bsky | reply | twitter
  date        YYYY-MM-DD, or empty for a tweet
  text        tabs and newlines turned into " / " so a post is one line

Tweets first (older), then Bluesky oldest to newest. Every CHUNK posts
there is a line holding only a form feed. The server searches the archive
a chunk at a time: one native `contains` on a chunk's text says whether any
of its 256 posts can match, where a loop over every post costs ~3us a post
in the interpreter, ~200ms for the archive.

The output is personal data and the blog repo is public: it is written
outside the repo and shipped by deploy.sh, never committed.
"""
import argparse, json

p = argparse.ArgumentParser()
p.add_argument("tweets", nargs="+")
p.add_argument("--bsky", required=True)
p.add_argument("--out", required=True)
p.add_argument("--chunk", type=int, default=256, help="posts between form-feed lines")
a = p.parse_args()

def one_line(s):
    return " / ".join(part.strip() for part in s.replace("\t", " ").replace("\r", "").split("\n") if part.strip())

rows = []  # [source, date, text]
seen = set()
for f in a.tweets:
    for line in open(f):
        msgs = json.loads(line)["messages"]
        t = one_line(next(m["content"] for m in msgs if m["role"] == "assistant"))
        if t and t not in seen:
            seen.add(t)
            rows.append(["twitter", "", t])
for line in open(a.bsky):
    v = json.loads(line)["value"]
    t = one_line(v.get("text", ""))
    if not t:
        continue  # an image or a quote with no words of its own
    rows.append(["reply" if "reply" in v else "bsky", v["createdAt"][:10], t])

rows.sort(key=lambda r: (r[0] != "twitter", r[1]))
with open(a.out, "w") as out:
    for i, r in enumerate(rows):
        if i and i % a.chunk == 0:
            out.write("\f\n")
        out.write("\t".join(r) + "\n")
n = {s: sum(1 for r in rows if r[0] == s) for s in ("bsky", "reply", "twitter")}
print(f"{len(rows)} posts ({n})")
