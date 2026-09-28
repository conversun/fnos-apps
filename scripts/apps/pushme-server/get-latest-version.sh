#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

INPUT_VERSION="${1:-}"

TAG=$(gh_latest_tag "yafoo/pushme-server") || { echo "Failed to resolve version for pushme-server" >&2; exit 1; }
URL="https://github.com/yafoo/pushme-server/releases/download/${TAG}/pushme-server.fpk"
# VERSION must be the fpk's INTERNAL manifest version: that is what the fnOS
# daemon registers, and anything else would keep the store offering a
# perpetual "update" that installs the same bytes.
# tr also strips CR: the upstream manifest has CRLF line endings and an
# invisible \r in VERSION once named an artifact ...1.0.0\r_arm.fpk, which
# the artifact upload rejected.
INTERNAL=$(curl -fsSL --retry 3 --retry-all-errors --connect-timeout 30 "$URL" \
  | tar xzO manifest 2>/dev/null \
  | sed -n 's/^version[[:space:]]*= *//p' | head -1 | tr -d '"\r' || true)

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION="$INTERNAL"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for pushme-server (internal fpk version unreadable from $URL)" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=$TAG" >> "$GITHUB_OUTPUT"
fi
