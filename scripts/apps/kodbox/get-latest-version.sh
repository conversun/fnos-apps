#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/kodcloud/kodbox/tags/?page_size=10&ordering=last_updated" | \
    jq -r '.results[].name' | grep -E '^[0-9]+\.' | head -1)
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for kodbox" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
