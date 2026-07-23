#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "${INPUT_VERSION}" ]; then
    UPSTREAM_TAG="${INPUT_VERSION}"
else
    UPSTREAM_TAG="$(curl -fsSL "https://api.github.com/repos/janeczku/calibre-web/releases/latest" | jq -r '.tag_name')"
fi

VERSION="${UPSTREAM_TAG#v}"
[ -n "${VERSION}" ] && [ "${VERSION}" != "null" ] || { echo "Failed to resolve Calibre-Web version" >&2; exit 1; }

echo "VERSION=${VERSION}"
echo "UPSTREAM_TAG=${UPSTREAM_TAG}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=${VERSION}" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=${UPSTREAM_TAG}" >> "$GITHUB_OUTPUT"
fi
