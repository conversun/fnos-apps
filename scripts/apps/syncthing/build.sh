#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Syncthing ${VERSION} for ${ZIP_ARCH}"

DOWNLOAD_URL="https://github.com/syncthing/syncthing/releases/download/v${VERSION}/syncthing-linux-${ZIP_ARCH}-v${VERSION}.tar.gz"
curl -L -o syncthing.tar.gz "$DOWNLOAD_URL"

tar -xzf syncthing.tar.gz

mkdir -p app_root
SYNCTHING_BIN=$(find . -path "*/syncthing-linux-*/syncthing" -type f | head -1)
[ -z "$SYNCTHING_BIN" ] && { echo "syncthing binary not found in tar.gz" >&2; exit 1; }

cp "$SYNCTHING_BIN" app_root/syncthing
chmod +x app_root/syncthing

cp apps/syncthing/fnos/bin/syncthing-server app_root/bin/syncthing-server 2>/dev/null || mkdir -p app_root/bin && cp apps/syncthing/fnos/bin/syncthing-server app_root/bin/syncthing-server
chmod +x app_root/bin/syncthing-server

cd app_root
tar -czf ../app.tgz .
