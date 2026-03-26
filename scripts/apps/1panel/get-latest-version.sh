#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # 1Panel distributes binaries via their own CDN, not GitHub Releases
  CDN_VERSION=$(curl -sL "https://resource.1panel.pro/v2/stable/latest" 2>/dev/null)
  VERSION=$(echo "$CDN_VERSION" | sed 's/^v//')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for 1panel" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
