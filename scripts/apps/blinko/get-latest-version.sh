#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# Version = the newest semver tag on Docker Hub (blinkospace/blinko publishes
# versioned multi-arch images; the GitHub releases only carry desktop builds).
if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/blinkospace/blinko/tags/?page_size=100" \
    | jq -r '[.results[].name | select(test("^[0-9]+\\.[0-9]+(\\.[0-9]+)*$"))]
             | sort_by(split(".") | map(tonumber)) | last // empty')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for blinko" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
