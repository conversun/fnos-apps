#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://api.github.com/repos/s1t5/mail-archiver/releases/latest" | \
    jq -r '.tag_name' | sed 's/^v//')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for mail-archiver" >&2; exit 1; }
[ "$VERSION" = "null" ] && { echo "Failed to resolve version for mail-archiver" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
