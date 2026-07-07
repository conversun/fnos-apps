#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"
EFFECTIVE_URL=""

if [ -n "$INPUT_VERSION" ]; then
  VERSION="${INPUT_VERSION#v}"
else
  EFFECTIVE_URL=$(curl -Ls -o /dev/null -w '%{url_effective}' "https://www.verysync.com/download.php?platform=linux-amd64")
  VERSION=$(printf '%s\n' "$EFFECTIVE_URL" | sed -E 's|.*/verysync-linux-amd64-v([^/]+)\.tar\.gz$|\1|')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for verysync" >&2; exit 1; }
if [ -n "$EFFECTIVE_URL" ] && [ "$VERSION" = "$EFFECTIVE_URL" ]; then
  echo "Unexpected Verysync download URL: $EFFECTIVE_URL" >&2
  exit 1
fi

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
