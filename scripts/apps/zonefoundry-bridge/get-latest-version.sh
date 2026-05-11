#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/zonefoundry/bridge/tags/?page_size=100" | \
    grep -oE '"name":"[0-9]+\.[0-9]+\.[0-9]+"' | head -n1 | cut -d'"' -f4)
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for zonefoundry-bridge" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
