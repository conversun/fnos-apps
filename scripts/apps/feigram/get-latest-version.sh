#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://api.github.com/repos/g-star1024/Feigram-Public/releases/latest" | \
  jq -r '.tag_name')

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed -E 's/^Feigram//; s/^v//')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for feigram" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
