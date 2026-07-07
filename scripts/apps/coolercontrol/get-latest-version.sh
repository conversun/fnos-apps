#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://gitlab.com/api/v4/projects/coolercontrol%2Fcoolercontrol/releases/permalink/latest" | \
  jq -r '.tag_name')

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for coolercontrol" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
