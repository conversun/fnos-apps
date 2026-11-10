#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

if [ -n "${1:-}" ] && [ "$1" != latest ]; then
    VERSION="${1#v}"
else
    TAG="$(gh_latest_tag "544849412/fnysfd")"
    VERSION="${TAG#v}"
fi

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "无法获取有效的飞牛影视反代版本：${VERSION}" >&2
    exit 1
}

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
