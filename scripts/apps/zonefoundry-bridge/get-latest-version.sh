#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="${INPUT_VERSION#v}"
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/zonefoundry/bridge/tags/?page_size=100" | \
    jq -r '.results[].name' | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -V | tail -1)
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for zonefoundry-bridge" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
