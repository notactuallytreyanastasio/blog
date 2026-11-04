# write-ticket: what was verified, against what

Two adapters ship. Neither was run against a real tracker from this
machine: JIRA because there is no instance, GitHub Projects because the
`gh` token here has no `read:project` scope. What each *was* run against,
and what that does and does not prove, is below. Reproduce with the
commands shown; the mocks are in `mock/`.

## Contract check: both adapters, same arguments

```
bash file.sh <title-file> <body-file> [labels]
```

`file.sh` reads `adapter` from `tracker.local.toml` or `tracker.toml`
(`TRACKER_CONFIG` overrides) and execs `adapters/<adapter>.sh <config>
<title-file> <body-file> <labels>`. Both adapters below were driven through
`file.sh`, not called directly, so the dispatch is part of what was run.

## JIRA: verified against a mock, not a real instance

Request shape checked against Atlassian's REST v3 reference for `POST
/rest/api/3/issue` (the `createIssue` operation in the page's embedded
OpenAPI document, fetched 2026-10-14): `fields.project.key`,
`fields.summary`, `fields.issuetype.{name|id}`, `fields.labels[]`, and
`fields.description` as an Atlassian Document Format object (`{"type":
"doc", "version": 1, "content": [...]}`). The documented 201 body is
`{"id": "10000", "key": "ED-24", "self": "https://your-domain.atlassian.net/rest/api/3/issue/10000", ...}`.
The adapter reads `key` and prints `<base_url>/browse/<key>`.

`mock/jira_mock.py` accepts that path, rejects a non-ADF description with
Jira's `ErrorCollection` shape, records the request, and answers 201 with
the documented body. Run:

```bash
python3 -I mock/jira_mock.py 8765 /tmp/jira-record.json &
cat > /tmp/tracker.toml <<'EOF'
adapter = "jira"
[jira]
base_url = "http://127.0.0.1:8765"
project_key = "BLOG"
issue_type = "Task"
email_env = "JIRA_EMAIL"
token_env = "JIRA_API_TOKEN"
EOF
TRACKER_CONFIG=/tmp/tracker.toml bash file.sh title.txt body.md bug
```

Output without the token set (no request is made; the mock recorded
nothing):

```
file.sh: adapter=jira config=/tmp/tracker.toml
jira.sh: $JIRA_API_TOKEN is not set; no request made
exit=2
```

With `JIRA_EMAIL=me@example.com JIRA_API_TOKEN=fake-token`:

```
file.sh: adapter=jira config=/tmp/tracker.toml
http://127.0.0.1:8765/browse/X-1
exit=0
```

What the mock recorded (body abridged to the shape; the full ADF for a
body with a quote, a bullet list, an Elixir code block and two `##`
headings was 11 content nodes):

```json
{
  "method": "POST",
  "path": "/rest/api/3/issue",
  "authorization": "Basic ...",
  "content_type": "application/json",
  "body": {
    "fields": {
      "project": {"key": "BLOG"},
      "summary": "Admin login accepts an expired session cookie",
      "description": {
        "type": "doc", "version": 1,
        "content": [
          {"type": "paragraph", "content": [{"type": "text", "text": "The admin plug checks that a session cookie is present but never checks its expiry, ..."}]},
          {"type": "blockquote", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "write a ticket for the admin cookie thing"}]}]},
          {"type": "bulletList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "`lib/blog_web/plugs/admin_auth.ex` line 23 reads ..."}]}]}]},
          {"type": "codeBlock", "attrs": {"language": "elixir"}, "content": [{"type": "text", "text": "def call(conn, _opts) do\n  ...\nend"}]},
          {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Acceptance criteria"}]},
          {"type": "bulletList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "[ ] `mix test test/blog_web/plugs/admin_auth_test.exs` has a case for an expired cookie and it passes"}]}]}, "..."]},
          {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Out of scope"}]},
          "...",
          {"type": "paragraph", "content": [{"type": "text", "text": "Graph: 5b46d610"}]}
        ]
      },
      "issuetype": {"name": "Task"},
      "labels": ["bug", "auth"]
    }
  }
}
```

Not verified, because a mock cannot: that `issuetype.name = "Task"` exists
on the target project (Jira answers 400 `{"errors": {"issuetype": ...}}`
if not, and the adapter prints that body); that the account can create in
`project_key`; that ADF task lists would be accepted (the converter leaves
`[ ]` as text on purpose); that inline backticks render as anything but
backticks (they will not; ADF `code` marks are not emitted).

## GitHub Projects v2: schema verified live, flow verified against a mock gh

### Against the real API (read-only)

The user's projects could not be listed. The query from the brief, run
2026-10-14 with the `gh` token on this machine:

```
$ gh api graphql -f query='{ user(login:"notactuallytreyanastasio"){ projectsV2(first:10){ nodes{ id title number } } } }'
{"errors":[{"type":"INSUFFICIENT_SCOPES", ... "message":"Your token has not been granted the required scopes to execute this query. The 'id' field requires one of the following scopes: ['read:project'], but your token has only been granted the: ['admin:gpg_key', 'admin:public_key', 'gist', 'read:org', 'repo'] scopes. ..."}]}
```

`gh auth status` confirms the scopes: `'admin:gpg_key', 'admin:public_key',
'gist', 'read:org', 'repo'`. So whether any project exists, and what its
Status options are, is unknown from here. To get it: `gh auth refresh -s
read:project,project` (interactive), then the query above and, for the
field ids the adapter looks up,

```
gh api graphql -f query='{ user(login:"<owner>"){ projectV2(number:<n>){ id field(name:"Status"){ ... on ProjectV2SingleSelectField{ id options{ id name } } } } } }'
```

What *was* checked live, because schema introspection needs no extra
scope, is that every field and operation the adapter uses exists with the
argument names it uses:

```
$ gh api graphql -f query='{ __type(name:"ProjectV2"){ fields{ name args{ name } } } }'
field  [('name', 'String')]
fields [('after', ...), ('first', 'Int'), ...]

$ ... __type(name:"ProjectV2FieldConfiguration")
{"kind":"UNION","possibleTypes":[{"name":"ProjectV2Field"},{"name":"ProjectV2IterationField"},{"name":"ProjectV2MultiSelectField"},{"name":"ProjectV2SingleSelectField"}]}

$ ... __type(name:"ProjectV2SingleSelectField")
['createdAt', 'dataType', 'databaseId', 'id', 'isIssueField', 'issueField', 'name', 'options', 'project', 'updatedAt']
$ ... __type(name:"ProjectV2SingleSelectFieldOption")
['color', 'description', 'descriptionHTML', 'id', 'name', 'nameHTML']

$ ... __type(name:"Mutation")   (filtered)
['addProjectV2ItemById', 'createIssue', 'updateProjectV2ItemFieldValue']

$ ... __type(name:"AddProjectV2ItemByIdInput")
   projectId  NON_NULL ID
   contentId  NON_NULL ID
$ ... __type(name:"UpdateProjectV2ItemFieldValueInput")
   projectId NON_NULL ID / itemId NON_NULL ID / fieldId NON_NULL ID / value NON_NULL ProjectV2FieldValue
$ ... __type(name:"ProjectV2FieldValue")
   text String / number Float / date Date / singleSelectOptionId String / multiSelectOptionIds [String!] / iterationId String

$ ... __type(name:"CreateIssueInput")   (used fields)
   repositoryId ID / title String / body String / labelIds [ID!] / projectV2Ids [ID!]

User.projectV2(number)          exists
Organization.projectV2(number)  exists
```

And the repo lookup, which only needs `repo`, against the real repo:

```
$ gh api graphql -f query='{ repository(owner:"notactuallytreyanastasio", name:"blog"){ id nameWithOwner labels(first:5){ nodes{ id name } } } }'
{"data":{"repository":{"id":"R_kgDONy1zEw","nameWithOwner":"notactuallytreyanastasio/blog","labels":{"nodes":[{"id":"LA_kwDONy1zE88AAAAB4foMvA","name":"bug"},{"id":"LA_kwDONy1zE88AAAAB4foMvw","name":"documentation"},{"id":"LA_kwDONy1zE88AAAAB4foMwg","name":"duplicate"},{"id":"LA_kwDONy1zE88AAAAB4foMxg","name":"enhancement"},{"id":"LA_kwDONy1zE88AAAAB4foMzA","name":"good first issue"}]}}}}
```

`CreateIssueInput.projectV2Ids` exists, which means the issue could be
added to the project in the create call. The adapter does not use it: the
status still has to be set afterwards with the item id, which only
`addProjectV2ItemById` returns, so it would be one call saved and one
round trip of the same information.

No issue, project item or field value was created on any real repo.

### Against the mock

`mock/gh` answers `gh api graphql` with canned responses in the real
schema's shape (ids with GitHub's `R_`, `I_`, `PVT_`, `PVTSSF_`, `PVTI_`
prefixes) and records every query with its variables. Run:

```bash
chmod +x mock/gh
GH_MOCK_RECORD=/tmp/gh.jsonl PATH="$PWD/mock:$PATH" TRACKER_CONFIG=/tmp/tracker-gh.toml bash file.sh title.txt body.md bug
```

Output:

```
file.sh: adapter=github-projects config=/tmp/tracker-gh.toml
https://github.com/mock-owner/mock-repo/issues/42
exit=0
```

Recorded calls, in order, with the variables the adapter sent:

```
query($o:String!,$n:String!){ repository(owner:$o,name:$n){ id labels( ... | {"o": "mock-owner", "n": "mock-repo"}
mutation($r:ID!,$t:String!,$b:String!,$l:[ID!]){ createIssue(input:{re ... | {"r": "R_kgDOMOCK0001", "t": "Admin login accepts an expired session cookie", "b": "Body line one.\n\n- [ ] a criterion", "l": ["LA_kwDOMOCK0001", "LA_kwDOMOCK0002"]}
query($o:String!,$n:Int!,$f:String!){ user(login:$o){ projectV2(number ... | {"o": "mock-owner", "n": 3, "f": "Status"}
mutation($p:ID!,$c:ID!){ addProjectV2ItemById(input:{projectId:$p,cont ... | {"p": "PVT_kwHOMOCK0001", "c": "I_kwDOMOCK0042"}
mutation($p:ID!,$i:ID!,$f:ID!,$v:String!){ updateProjectV2ItemFieldVal ... | {"p": "PVT_kwHOMOCK0001", "i": "PVTI_lAHOMOCK0001", "f": "PVTSSF_lAHOMOCK0001", "v": "f75ad846"}
```

The label names (`bug,enhancement`) were mapped to ids before
`createIssue`, the status name `Todo` to its option id `f75ad846` after
the project lookup, and the item id from `addProjectV2ItemById` fed
`updateProjectV2ItemFieldValue`. With no labels the `l` variable is not
sent at all (it is nullable in the schema).

How the array is passed was checked live, because the first version got it
wrong and the mock did not notice. `gh api -F 'l=["id"]'` sends the JSON
text as one string:

```
$ gh api graphql -f query='query($ids:[ID!]!){ nodes(ids:$ids){ id } }' -F 'ids=["R_kgDONy1zEw"]'
gh: Could not resolve to a node with the global id of '["R_kgDONy1zEw"]'
```

gh's array syntax is a repeated `key[]=value`:

```
$ gh api graphql -f query='query($ids:[ID!]!){ nodes(ids:$ids){ id ... on Repository { nameWithOwner } } }' -f 'ids[]=R_kgDONy1zEw'
{"data":{"nodes":[{"id":"R_kgDONy1zEw","nameWithOwner":"notactuallytreyanastasio/blog"}]}}
```

The adapter now builds one `-f 'l[]=<id>'` per label and the mock `gh`
parses that syntax. Both adapters and `file.sh` were also run under
`/bin/bash` 3.2 (what macOS ships), which is where `"${empty_array[@]}"`
under `set -u` is an error; the `${arr[@]+"${arr[@]}"}` form is for that.

Failure paths, same mock:

```
$ ... bash file.sh title.txt body.md nope
github-projects.sh: labels not in repo: nope
exit=1                                   (no createIssue call was recorded)

$ ... status_value = "Backlog" ...
status option 'Backlog' not in ['Done', 'In Progress', 'Todo']
github-projects.sh: issue created at https://github.com/mock-owner/mock-repo/issues/42 but the status option was not found
https://github.com/mock-owner/mock-repo/issues/42
exit=1
```

The second one is the contract's "created but not finished" case: the URL
is still on stdout so the caller does not file it twice.

Not verified: that a token with `project` scope but not `read:project`
behaves as the error messages in the script assume; that
`createIssue` with `labelIds` succeeds when the token's owner cannot set
labels on the repo (GitHub may create the issue without them rather than
fail, in which case the adapter reports success with no labels applied).

## Adding an adapter

`adapters/README.md` is the contract. The two shipped adapters and the
two mocks are the templates.
