#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Navidrome ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    TARBALL_ARCH="amd64"
    ;;
  arm64|aarch64)
    TARBALL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://github.com/navidrome/navidrome/releases/download/v${VERSION}/navidrome_${VERSION}_linux_${TARBALL_ARCH}.tar.gz"
echo "Downloading: $DOWNLOAD_URL"
curl -L -o navidrome.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root/bin app_root/ui
tar -xzf navidrome.tar.gz -C app_root

# Verify navidrome binary exists
[ -f "app_root/navidrome" ] || { echo "navidrome binary not found in tarball" >&2; exit 1; }
chmod +x app_root/navidrome

# Copy fnOS-specific files
cp apps/navidrome/fnos/bin/navidrome-server app_root/bin/navidrome-server
chmod +x app_root/bin/navidrome-server
cp -a apps/navidrome/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
