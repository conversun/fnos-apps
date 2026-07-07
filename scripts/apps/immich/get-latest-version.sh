#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # immich images on ghcr.io are tagged `vX.Y.Z` (WITH the leading `v`) and `release`.
  # The old resolver did `sed 's/^v//'` -> `X.Y.Z`, a tag that does NOT exist on
  # ghcr.io, so installs failed with `manifest unknown` (issue #175). docker-compose
  # now pins the rolling `:release` tag directly, so VERSION here is purely for fpk
  # metadata. Use a date-stamped sentinel for a unique CI release tag per day.
  VERSION="release-$(date +%Y.%m.%d)"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for immich" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
