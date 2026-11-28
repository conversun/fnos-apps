#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

INPUT_VERSION="${1:-}"

TAG=$(gh_latest_tag "zhayujie/CowAgent") || { echo "Failed to resolve version for cowagent" >&2; exit 1; }

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for cowagent" >&2; exit 1; }

# cowagent's docker-compose pins the image to :${VERSION}, so VERSION has to be a
# tag that actually exists on Docker Hub. Upstream tags a GitHub release before
# pushing the image — 2.1.6 was released with no image behind it — and CI happily
# published cowagent/v2.1.6-r3, which then failed on every user's NAS with
#   Error response from daemon: manifest for zhayujie/chatgpt-on-wechat:2.1.6
#   not found: manifest unknown
# the same class of failure copaw hit in #140. Verify the tag, and fall back to
# the newest published image tag rather than shipping an uninstallable package.
DOCKER_IMAGE="zhayujie/cowagent"

docker_tag_exists() {
  curl -sSL --fail "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/$1/" >/dev/null 2>&1
}

if ! docker_tag_exists "$VERSION"; then
  if [ -n "$INPUT_VERSION" ]; then
    echo "No docker image ${DOCKER_IMAGE}:${VERSION} — refusing to build an uninstallable package" >&2
    exit 1
  fi
  FALLBACK=$(curl -s "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags?page_size=100" \
    | jq -r '[.results[].name | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))]
             | sort_by(split(".") | map(tonumber)) | last // empty')
  [ -n "$FALLBACK" ] || { echo "Failed to resolve any published docker tag for cowagent" >&2; exit 1; }
  echo "[WARN] upstream released ${VERSION} but published no docker image; using ${FALLBACK}" >&2
  VERSION="$FALLBACK"
fi

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
