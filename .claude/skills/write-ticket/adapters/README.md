# Adapter contract

An adapter is one executable file in this directory, `<name>.sh`, selected by
`adapter = "<name>"` in `tracker.toml`. Adding a tracker (Linear, Shortcut,
Trello) is adding that one file and a `[<name>]` table to `tracker.toml`.
Nothing else changes: `file.sh` and `SKILL.md` do not know the adapter names.

## Arguments

```
bash adapters/<name>.sh <config.toml> <title-file> <body-file> [labels]
```

| Argument      | What it is                                                      |
| ------------- | --------------------------------------------------------------- |
| `config.toml` | The resolved config file. Read your own `[<name>]` table from it with `python3 -I adapters/toml-get.py <file> <name>.<key> [default]`. |
| `title-file`  | A file whose content is the title. One line. Trailing newline is not part of it. |
| `body-file`   | A file whose content is the body, Markdown as this repo writes it. Convert it if the tracker needs another format (`adf.py` does Jira's). |
| `labels`      | Optional. Comma-separated label names, possibly empty. Map them to whatever the tracker calls them; if one does not exist, fail before creating anything and name it. |

## Output

- **stdout**: exactly one line, the URL of the created ticket, and nothing
  else. `file.sh` passes stdout through, and the skill reads the URL from it.
- **stderr**: progress, warnings, errors.
- **exit code**: 0 when the ticket exists at the printed URL. Non-zero
  otherwise. If the ticket was created but a later step failed (added to a
  board but the status did not set), say so on stderr, still print the URL
  on stdout, and exit 1: the caller must know the ticket exists so it does
  not file it twice.

## Rules

1. **Secrets come from the environment.** The config names the variable
   (`token_env = "JIRA_API_TOKEN"`); the adapter reads `${!token_env}`.
   Never a token in a file, never on a command line where `ps` can see it
   (curl `-u` and `-H` are command line; the mitigation for a shared
   machine is a `--config`/`-K` file, which no adapter here does yet).
2. **Stop before the first request if config is missing**, and name the
   key. A placeholder value (`your-domain`, `your-login`) counts as missing.
3. **Do not retry creates.** A create that timed out may have succeeded.
   Report and exit; the person decides.
4. **Run from anywhere.** Resolve paths from `$(dirname "$0")`, take the
   config as an argument, never `cd` into something a user supplied.
5. **No dependencies beyond** `bash`, `curl`, `python3` (3.11+, for
   `tomllib`) and, for GitHub, `gh`. A tracker whose API needs more than
   that documents it at the top of its adapter.

## Writing one

Copy `jira.sh` for a REST tracker or `github-projects.sh` for a GraphQL one.
Before claiming it works, run it against a mock that records the request and
returns the documented success body (`../mock/jira_mock.py` is a template),
put the recorded request and the printed URL in `../README.md`, and say
whether it was also run against the real tracker.
