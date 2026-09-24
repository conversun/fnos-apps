#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # Pin to the newest DATED Docker Hub tag (YYYY.MM.DD) instead of the rolling
  # :latest (follow-up hardening to #310): a rolling tag can be broken
  # upstream with no way to pin or roll back, and every fpk version silently
  # referenced whatever :latest happened to be that day. The dated tag the
  # fpk was built against is pullable by construction. Date strings sort
  # lexicographically = chronologically, so `max` picks the newest.
  VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/alexta69/metube/tags/?page_size=100" \
    | jq -r '[.results[].name | select(test("^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}$"))]
             | max // empty')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for metube" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
