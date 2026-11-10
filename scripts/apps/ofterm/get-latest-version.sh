#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

if [ -n "${1:-}" ]; then
    VERSION="${1#v}"
else
    TAG="$(gh_latest_tag "melchior-voidwolf/ofterm")"
    VERSION="${TAG#v}"
fi

[ -n "$VERSION" ] && [ "$VERSION" != "null" ] || {
    echo "无法获取 OFTerm 版本" >&2
    exit 1
}

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
