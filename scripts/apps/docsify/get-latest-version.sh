#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/nginxinc/nginx-unprivileged/tags?page_size=100" | \
    python3 -c 'import json, re, sys
data=json.load(sys.stdin)
versions=[]
for item in data.get("results", []):
    name=item.get("name", "")
    if re.fullmatch(r"\d+\.\d+\.\d+", name):
        versions.append(tuple(map(int, name.split("."))))
if not versions:
    raise SystemExit(1)
print(".".join(map(str, max(versions))))')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
