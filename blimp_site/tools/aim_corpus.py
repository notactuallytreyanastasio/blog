#!/usr/bin/env python3
"""Build /aim's archive: every post, one per line, and which ones the model
is always shown.

    tools/aim_corpus.py TWEETS_JSONL... --bsky BSKY_JSONL --out aim-posts.tsv

TWEETS_JSONL are mlx chat-format training files (my_me_bot/training/*.jsonl,
cut from the 2024-11-12 Twitter archive): the post is the assistant turn.
They carry no dates. BSKY_JSONL is com.atproto.repo.listRecords output for
app.bsky.feed.post, one record per line.

Output columns, tab-separated:  in_context  source  date  text
  in_context  1 if the post goes in the system prompt, else 0
  source      bsky | reply | twitter
  date        YYYY-MM-DD, or empty for a tweet
  text        tabs and newlines turned into " / " so a post is one line

Every CHUNK posts there is a line holding only a form feed. The server
searches the archive a chunk at a time: one native `contains` on a chunk's
text says whether any of its 256 posts can match, where a loop over every
post costs ~3us a post in the interpreter, ~200ms for the archive.

The archive is ~2.7M tokens and the model's window 1M, so the prompt holds
a fixed part of it (BUDGET characters, ~3.45 chars per token measured on
DeepSeek): every Bluesky original, then the newest replies, then tweets
picked by a hash of their text. The pick depends on the posts alone, so a
rebuild from the same files gives the same prompt, byte for byte, and
DeepSeek's prefix cache keeps answering it. Everything else is reachable
through the search_posts tool.

The output is personal data and the blog repo is public: it is written
outside the repo and shipped by deploy.sh, never committed.
"""
import argparse, hashlib, json, sys

p = argparse.ArgumentParser()
p.add_argument("tweets", nargs="+")
p.add_argument("--bsky", required=True)
p.add_argument("--out", required=True)
p.add_argument("--budget", type=int, default=2_800_000)
p.add_argument("--replies", type=int, default=250_000, help="characters of replies in the prompt")
p.add_argument("--chunk", type=int, default=256, help="posts between form-feed lines")
a = p.parse_args()

def one_line(s):
    return " / ".join(part.strip() for part in s.replace("\t", " ").replace("\r", "").split("\n") if part.strip())

rows = []  # [in_context, source, date, text]
seen = set()
for f in a.tweets:
    for line in open(f):
        msgs = json.loads(line)["messages"]
        t = one_line(next(m["content"] for m in msgs if m["role"] == "assistant"))
        if t and t not in seen:
            seen.add(t)
            rows.append([0, "twitter", "", t])
for line in open(a.bsky):
    v = json.loads(line)["value"]
    t = one_line(v.get("text", ""))
    if not t:
        continue  # an image or a quote with no words of its own
    rows.append([0, "reply" if "reply" in v else "bsky", v["createdAt"][:10], t])

def cost(r):
    # what the prompt line costs: "[bsky 2025-03-02] " + text + "\n"
    return len(r[1]) + len(r[2]) + 5 + len(r[3])

left = a.budget
for r in rows:
    if r[1] == "bsky":
        r[0] = 1; left -= cost(r)
replies = sorted((r for r in rows if r[1] == "reply"), key=lambda r: r[2], reverse=True)
room = min(a.replies, left)
for r in replies:
    if cost(r) > room:
        break
    r[0] = 1; room -= cost(r); left -= cost(r)
tweets = sorted((r for r in rows if r[1] == "twitter"), key=lambda r: hashlib.sha1(r[3].encode()).hexdigest())
for r in tweets:
    if cost(r) > left:
        break
    r[0] = 1; left -= cost(r)
if left < 0:
    sys.exit(f"the Bluesky originals alone are over the budget by {-left} characters")

# Twitter first (older), then Bluesky oldest to newest: the prompt reads as a timeline.
rows.sort(key=lambda r: (r[1] != "twitter", r[2]))
with open(a.out, "w") as out:
    for i, r in enumerate(rows):
        if i and i % a.chunk == 0:
            out.write("\f\n")
        out.write(f"{r[0]}\t{r[1]}\t{r[2]}\t{r[3]}\n")
n = {s: sum(1 for r in rows if r[1] == s) for s in ("bsky", "reply", "twitter")}
c = {s: sum(1 for r in rows if r[1] == s and r[0]) for s in ("bsky", "reply", "twitter")}
print(f"{len(rows)} posts ({n}); in the prompt {c}, {a.budget - left} characters")
