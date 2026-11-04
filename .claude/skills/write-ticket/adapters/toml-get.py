"""Print one value from a TOML file.

    python3 -I toml-get.py <file.toml> <dotted.key> [default]

Strings print bare, numbers print as-is, booleans as "true"/"false", lists as
one item per line. A missing key prints the default when one is given and
exits 1 otherwise, so a shell `$(...)` fails loudly under `set -e`.
"""
import sys
import tomllib


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        return 2
    path, key = sys.argv[1], sys.argv[2]
    with open(path, "rb") as f:
        data = tomllib.load(f)
    node = data
    for part in key.split("."):
        if not isinstance(node, dict) or part not in node:
            if len(sys.argv) > 3:
                print(sys.argv[3])
                return 0
            print(f"toml-get: {key} not in {path}", file=sys.stderr)
            return 1
        node = node[part]
    if isinstance(node, bool):
        print("true" if node else "false")
    elif isinstance(node, list):
        for item in node:
            print(item)
    else:
        print(node)
    return 0


if __name__ == "__main__":
    sys.exit(main())
