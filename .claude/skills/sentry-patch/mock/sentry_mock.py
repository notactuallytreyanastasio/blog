"""A Sentry stand-in serving issues in the documented response shape.

    python3 -I sentry_mock.py <port>

Serves, for org "mock-org" and project "blog":

    GET /api/0/projects/mock-org/blog/issues/                         three issues
    GET /api/0/organizations/mock-org/issues/<id>/events/?full=true   that issue's events
    GET /api/0/organizations/mock-org/issues/<id>/events/latest/      the first of them

Without an `Authorization: Bearer` header every path answers 401 with
Sentry's `{"detail": "Authentication credentials were not provided."}`.

The three issues exercise the rule's clauses:

    BLOG-1  ArgumentError in Blog.Posts.get_post_by_slug!/1, three events,
            same culprit, same top in-app frame             -> candidate
    BLOG-2  DBConnection.ConnectionError "tcp recv (idle): timeout",
            two events                                      -> rejected, clause 2
    BLOG-3  MatchError in Blog.Feeds.refresh/0, two events whose top
            in-app frame is a different line                -> rejected, clause 1

Field names follow the API reference examples (issue: id, shortId, title,
culprit, permalink, count, userCount, firstSeen, lastSeen, level, status,
type, metadata, project; event: eventID, id, groupID, title, culprit,
dateCreated, platform, tags, metadata, entries[].type == "exception" with
data.values[].{type,value,module,mechanism,stacktrace.frames[]} and frame
fields filename, absPath, module, function, lineNo, colNo, inApp, context,
vars). Values are invented; shapes are not.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

ORG, PROJECT = "mock-org", "blog"


def frame(filename, function, line_no, in_app, context, vars_=None, module=None):
    return {
        "filename": filename,
        "absPath": f"/app/{filename}",
        "module": module or filename.removeprefix("lib/").removesuffix(".ex").replace("/", "."),
        "package": None,
        "platform": None,
        "instructionAddr": None,
        "symbolAddr": None,
        "function": function,
        "rawFunction": None,
        "symbol": None,
        "context": context,
        "lineNo": line_no,
        "colNo": None,
        "inApp": in_app,
        "trust": None,
        "errors": None,
        "vars": vars_,
    }


def event(event_id, group_id, title, culprit, date, exc_type, exc_value, frames, tags):
    return {
        "eventID": event_id,
        "id": event_id,
        "groupID": group_id,
        "title": title,
        "culprit": culprit,
        "dateCreated": date,
        "dateReceived": date,
        "platform": "elixir",
        "message": "",
        "type": "error",
        "metadata": {"type": exc_type, "value": exc_value},
        "tags": [{"key": k, "value": v} for k, v in tags.items()],
        "user": None,
        "contexts": {},
        "context": {},
        "entries": [
            {
                "type": "exception",
                "data": {
                    "values": [
                        {
                            "type": exc_type,
                            "value": exc_value,
                            "module": None,
                            "threadId": None,
                            "mechanism": {"type": "generic", "handled": False},
                            "stacktrace": {
                                "frames": frames,
                                "framesOmitted": None,
                                "registers": None,
                                "hasSystemFrames": True,
                            },
                            "rawStacktrace": None,
                        }
                    ],
                    "hasSystemFrames": True,
                    "excOmitted": None,
                },
            }
        ],
    }


PLUG = frame("lib/plug/conn.ex", "Plug.Conn.call/2", 25, False, [[25, "    conn"]], module="Plug.Conn")
LIVE = frame(
    "lib/blog_web/live/post_live.ex", "BlogWeb.PostLive.handle_params/3", 42, True,
    [[40, '  def handle_params(%{"slug" => slug}, _uri, socket) do'],
     [41, "    post = Posts.get_post_by_slug!(slug)"],
     [42, "    {:noreply, assign(socket, post: post)}"]],
    vars_={"slug": '""'},
)
POSTS_118 = frame(
    "lib/blog/posts.ex", "Blog.Posts.get_post_by_slug!/1", 118, True,
    [[116, "  def get_post_by_slug!(slug) when is_binary(slug) do"],
     [117, '    [year, rest] = String.split(slug, "-", parts: 2)'],
     [118, "    Repo.get_by!(Post, year: String.to_integer(year), slug: rest)"]],
    vars_={"slug": '""', "year": '""', "rest": "nil"},
)


def blog1_events():
    tags = {"environment": "prod", "level": "error", "handled": "no", "url": "https://bobbby.online/posts/"}
    return [
        event("a1" * 16, "1001", "ArgumentError: errors were found at the given arguments", "Blog.Posts.get_post_by_slug!/1",
              "2026-10-14T09:12:01.000000Z", "ArgumentError",
              'errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n',
              [PLUG, LIVE, POSTS_118], tags),
        event("a2" * 16, "1001", "ArgumentError: errors were found at the given arguments", "Blog.Posts.get_post_by_slug!/1",
              "2026-10-13T22:40:17.000000Z", "ArgumentError",
              'errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n',
              [PLUG, LIVE, POSTS_118], tags),
        event("a3" * 16, "1001", "ArgumentError: errors were found at the given arguments", "Blog.Posts.get_post_by_slug!/1",
              "2026-10-12T04:03:55.000000Z", "ArgumentError",
              'errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n',
              [PLUG, LIVE, POSTS_118], tags),
    ]


REPO_ALL = frame("lib/blog/repo.ex", "Blog.Repo.all/2", 3, True, [[3, "  use Ecto.Repo, otp_app: :blog"]])
REPO_ALL_CALLER = frame("lib/blog/posts.ex", "Blog.Posts.list_posts/0", 31, True,
                        [[31, "    Repo.all(from p in Post, order_by: [desc: p.inserted_at])"]])


def blog2_events():
    tags = {"environment": "prod", "level": "error", "handled": "no"}
    v = "tcp recv (idle): timeout"
    return [
        event("b1" * 16, "1002", "DBConnection.ConnectionError: tcp recv (idle): timeout", "Blog.Repo.all/2",
              "2026-10-14T03:00:12.000000Z", "DBConnection.ConnectionError", v, [REPO_ALL_CALLER, REPO_ALL], tags),
        event("b2" * 16, "1002", "DBConnection.ConnectionError: tcp recv (idle): timeout", "Blog.Repo.all/2",
              "2026-10-13T03:00:09.000000Z", "DBConnection.ConnectionError", v, [REPO_ALL_CALLER, REPO_ALL], tags),
    ]


FEEDS_30 = frame("lib/blog/feeds.ex", "Blog.Feeds.refresh/0", 30, True,
                 [[30, '    {:ok, %{status: 200, body: body}} = Req.get(url)']])
FEEDS_57 = frame("lib/blog/feeds.ex", "Blog.Feeds.parse/1", 57, True,
                 [[57, '    [_, title] = Regex.run(~r/<title>(.*)<\\/title>/, item)']])


def blog3_events():
    tags = {"environment": "prod", "level": "error", "handled": "no"}
    return [
        event("c1" * 16, "1003", "MatchError: no match of right hand side value", "Blog.Feeds.refresh/0",
              "2026-10-14T06:00:00.000000Z", "MatchError", "no match of right hand side value: {:ok, %{status: 503}}",
              [FEEDS_30], tags),
        event("c2" * 16, "1003", "MatchError: no match of right hand side value", "Blog.Feeds.refresh/0",
              "2026-10-11T06:00:00.000000Z", "MatchError", "no match of right hand side value: nil",
              [FEEDS_30, FEEDS_57], tags),
    ]


EVENTS = {"1001": blog1_events(), "1002": blog2_events(), "1003": blog3_events()}


def issue(id_, short, title, culprit, evs, exc_type, exc_value, filename, function):
    return {
        "id": id_,
        "shortId": short,
        "shareId": None,
        "title": title,
        "culprit": culprit,
        "permalink": f"https://mock-org.sentry.io/issues/{id_}/",
        "logger": None,
        "level": "error",
        "status": "unresolved",
        "statusDetails": {},
        "isPublic": False,
        "platform": "elixir",
        "project": {"id": "2", "name": "blog", "slug": "blog", "platform": "elixir"},
        "type": "error",
        "metadata": {"type": exc_type, "value": exc_value, "filename": filename, "function": function},
        "numComments": 0,
        "assignedTo": None,
        "isBookmarked": False,
        "isSubscribed": False,
        "subscriptionDetails": None,
        "hasSeen": True,
        "annotations": [],
        "isUnhandled": True,
        "count": str(len(evs) * 7),
        "userCount": 3,
        "firstSeen": evs[-1]["dateCreated"],
        "lastSeen": evs[0]["dateCreated"],
        "stats": {"24h": []},
    }


ISSUES = [
    issue("1001", "BLOG-1", "ArgumentError: errors were found at the given arguments", "Blog.Posts.get_post_by_slug!/1",
          EVENTS["1001"], "ArgumentError", "errors were found at the given arguments", "lib/blog/posts.ex", "Blog.Posts.get_post_by_slug!/1"),
    issue("1002", "BLOG-2", "DBConnection.ConnectionError: tcp recv (idle): timeout", "Blog.Repo.all/2",
          EVENTS["1002"], "DBConnection.ConnectionError", "tcp recv (idle): timeout", "lib/blog/repo.ex", "Blog.Repo.all/2"),
    issue("1003", "BLOG-3", "MatchError: no match of right hand side value", "Blog.Feeds.refresh/0",
          EVENTS["1003"], "MatchError", "no match of right hand side value", "lib/blog/feeds.ex", "Blog.Feeds.refresh/0"),
]


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f"mock: {self.command} {self.path}", file=sys.stderr)

    def _send(self, code, obj):
        data = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if not self.headers.get("Authorization", "").startswith("Bearer "):
            self._send(401, {"detail": "Authentication credentials were not provided."})
            return
        path = urlparse(self.path).path
        if path == f"/api/0/projects/{ORG}/{PROJECT}/issues/":
            self._send(200, ISSUES)
            return
        parts = path.strip("/").split("/")
        # api/0/organizations/<org>/issues/<id>/events/[latest/]
        if len(parts) >= 6 and parts[2] == "organizations" and parts[3] == ORG and parts[4] == "issues" and parts[6:7] == ["events"]:
            evs = EVENTS.get(parts[5])
            if evs is None:
                self._send(404, {"detail": "The requested resource does not exist"})
            elif parts[7:8] == ["latest"]:
                self._send(200, evs[0])
            else:
                self._send(200, evs)
            return
        self._send(404, {"detail": "The requested resource does not exist"})


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    HTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
