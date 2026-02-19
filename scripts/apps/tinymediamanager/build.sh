#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"
TARBALL_ARCH="${TARBALL_ARCH:-amd64}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building tinyMediaManager ${VERSION} for ${TARBALL_ARCH} (Docker-based)"

dst=app_root
mkdir -p "$dst/docker"

cp apps/tinymediamanager/fnos/docker/docker-compose.yaml "$dst/docker/"
sed -i "s/\${VERSION}/${VERSION}/g" "$dst/docker/docker-compose.yaml"

cp -a apps/tinymediamanager/fnos/ui "$dst/ui"

cd app_root
tar -czf ../app.tgz .
