"""A Jira Cloud stand-in for testing adapters/jira.sh without an instance.

    python3 -I jira_mock.py <port> <record-file>

Accepts POST /rest/api/3/issue, writes the request (method, path, headers
that matter, parsed JSON body) to <record-file>, and answers 201 with the
documented CreatedIssue body:

    {"id": "10000", "key": "X-1", "self": "http://127.0.0.1:<port>/rest/api/3/issue/10000"}

Any other path answers 404. A body that is not JSON, or whose description is
not an ADF doc, answers 400 with Jira's ErrorCollection shape, so a broken
adapter fails the way it would against the real thing.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    record_file = ""

    def log_message(self, fmt, *args):  # quiet
        pass

    def _send(self, code: int, obj: dict):
        data = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self):
        if self.path != "/rest/api/3/issue":
            self._send(404, {"errorMessages": ["not found"], "errors": {}})
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            body = json.loads(raw)
        except json.JSONDecodeError:
            self._send(400, {"errorMessages": ["body is not JSON"], "errors": {}})
            return
        errors = {}
        fields = body.get("fields", {})
        for required in ("project", "summary", "issuetype"):
            if required not in fields:
                errors[required] = f"Field '{required}' is required"
        desc = fields.get("description")
        if not (isinstance(desc, dict) and desc.get("type") == "doc" and desc.get("version") == 1):
            errors["description"] = "Operation value must be an Atlassian Document (see the Atlassian Document Format)"
        if errors:
            self._send(400, {"errorMessages": [], "errors": errors})
            return
        record = {
            "method": "POST",
            "path": self.path,
            "authorization": self.headers.get("Authorization", "")[:6] + "...",
            "content_type": self.headers.get("Content-Type"),
            "body": body,
        }
        with open(self.record_file, "w", encoding="utf-8") as f:
            json.dump(record, f, indent=2)
        port = self.server.server_address[1]
        self._send(201, {
            "id": "10000",
            "key": "X-1",
            "self": f"http://127.0.0.1:{port}/rest/api/3/issue/10000",
        })


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    port = int(sys.argv[1])
    Handler.record_file = sys.argv[2]
    HTTPServer(("127.0.0.1", port), Handler).serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
