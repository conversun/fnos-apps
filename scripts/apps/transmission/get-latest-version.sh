#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  TAG=$(curl -sL "https://api.github.com/repos/linuxserver/docker-transmission/releases/latest" | \
    jq -r '.tag_name')
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for transmission" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
