#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://api.github.com/repos/funchs/opensurge-fnos/releases/latest" | \
  jq -r '.tag_name')

# A rate-limited API call makes jq emit the literal string "null" (#306).
# Only the ambient query is guarded — an explicit INPUT_VERSION overrides it.
[ -z "$INPUT_VERSION" ] && [ "$TAG" = "null" ] && { echo "Failed to resolve version for opensurge (upstream returned null)" >&2; exit 1; }
if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for opensurge" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
