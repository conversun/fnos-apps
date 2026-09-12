#!/bin/bash
set -euo pipefail


INPUT_VERSION="${1:-}"

# Resolve the version from the image repository itself, NOT from the
# tailscale GitHub tags: the official Docker image lags GitHub by hours-to-days
# (GH had v1.102.4 while Hub stopped at v1.102.3), so a GitHub-sourced pin can
# reference a nonexistent image tag and every install dies at the pull.
# Only stable "vX.Y.Z" Hub tags qualify — unstable-* is a different channel.
if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/tailscale/tailscale/tags/?page_size=100" \
    | jq -r '[.results[].name | select(test("^v[0-9]+(\\.[0-9]+)*$")) | sub("^v"; "")]
             | sort_by(split(".") | map(tonumber)) | last // empty')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for tailscale" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
