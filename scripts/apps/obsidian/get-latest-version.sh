#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# Resolve the version from the image repository itself, NOT from the Obsidian
# GitHub releases: linuxserver/obsidian lags upstream by days, so a fpk pinned
# to the GitHub release ships an image tag that does not exist yet and every
# install dies at "manifest unknown" across all mirrors (issues #288 #289).
# The newest bare "X.Y.Z" tag on Docker Hub is pullable by construction.
if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/linuxserver/obsidian/tags/?page_size=100" \
    | jq -r '[.results[].name | select(test("^[0-9]+(\\.[0-9]+)*$"))]
             | sort_by(split(".") | map(tonumber)) | last // empty')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for obsidian" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
