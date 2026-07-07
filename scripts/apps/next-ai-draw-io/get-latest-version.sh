#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION="latest"
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for next-ai-draw-io" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
