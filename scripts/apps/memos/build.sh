#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Memos ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    MEMOS_ARCH="x86_64"
    ;;
  arm64|aarch64)
    MEMOS_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://github.com/memospot/memos-builds/releases/download/v${VERSION}/memos-v${VERSION}-linux-${MEMOS_ARCH}.tar.gz"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o memos.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root/bin app_root/ui
tar -xzf memos.tar.gz -C app_root

# Verify memos binary exists
[ -f "app_root/memos" ] || { echo "memos binary not found in tarball" >&2; exit 1; }
chmod +x app_root/memos

# Copy fnOS-specific files
cp apps/memos/fnos/bin/memos-server app_root/bin/memos-server
chmod +x app_root/bin/memos-server
cp -a apps/memos/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
