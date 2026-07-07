#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/ciuse99/suggestarr/tags/?page_size=200" | \
    jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for suggestarr" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
