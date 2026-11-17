#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

TAG="${1:-}"
if [ -z "$TAG" ]; then
    TAG="$(gh_latest_tag "mclhm8182/FnVista")"
fi
VERSION="${TAG#v}"
if ! [[ "$VERSION" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
    echo "无法获取飞牛视野版本: $TAG" >&2
    exit 1
fi

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
