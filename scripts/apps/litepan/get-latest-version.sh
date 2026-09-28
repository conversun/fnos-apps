#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

INPUT_VERSION="${1:-}"

TAG=$(gh_latest_tag "qilin-zhu/LitePan-fpk") || { echo "Failed to resolve version for litepan" >&2; exit 1; }
# v0.5.6-fpk-76 -> 0.5.6 (fpk filenames use the bare base version)
BASE=$(echo "$TAG" | sed -e 's/^[vV]//' -e 's/-fpk-[0-9]*$//')

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION="$BASE"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for litepan" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=$TAG" >> "$GITHUB_OUTPUT"
fi
