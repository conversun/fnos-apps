#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }
if [[ ! "$VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Invalid store version: $VERSION" >&2
    exit 1
fi
major=$((10#${BASH_REMATCH[1]}))
minor=$((10#${BASH_REMATCH[2]}))
patch=$((10#${BASH_REMATCH[3]}))
if (( major < 1 || (major == 1 && minor < 9) || (major == 1 && minor == 9 && patch < 11) )); then
    echo "Native gateway packaging requires fnos-store >= 1.9.11; older binaries only serve TCP." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
APP_FNOS_DIR="$REPO_ROOT/apps/fnos-apps-store/fnos"

echo "==> Building fnos-apps-store ${VERSION} for ${TARBALL_ARCH}"

DOWNLOAD_URL="https://github.com/conversun/fnos-store/releases/download/v${VERSION}/store-server-linux-${TARBALL_ARCH}"
curl -fL -o store-server "$DOWNLOAD_URL"
chmod +x store-server

mkdir -p app_root
mv store-server app_root/store-server

# Include files that appcenter-cli extracts to /vol1/@appcenter/<app>/
# These register the gateway desktop entry and application resources.
cp -a "$APP_FNOS_DIR/ui" app_root/
cp -a "$APP_FNOS_DIR/config" app_root/

cd app_root
tar -czf ../app.tgz .
