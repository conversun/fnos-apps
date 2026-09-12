#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # Upstream publishes no per-version assets and the Docker tag is rolling
  # :latest, so VERSION is purely fpk metadata: a date-stamped sentinel gives
  # a unique CI release tag per build day (same pattern as transmission).
  VERSION="latest-$(date +%Y.%m.%d)"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for metube" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
