#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
RAW_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

case "$RAW_ARCH" in
    x86|x86_64|amd64) TARBALL_ARCH="amd64" ;;
    arm|arm64|aarch64) TARBALL_ARCH="arm64" ;;
    *) echo "Unsupported arch: $RAW_ARCH" >&2; exit 1 ;;
esac

echo "==> Building MSF ${VERSION} for ${TARBALL_ARCH}"

DOWNLOAD_URL="https://github.com/scoltzero/msf/releases/download/v${VERSION}/msf-linux-${TARBALL_ARCH}.tar.gz"
curl -fL -o msf-linux.tar.gz "$DOWNLOAD_URL"

mkdir -p extracted
tar -xzf msf-linux.tar.gz -C extracted

MSF_BIN=$(find extracted -path "*/msf" -type f | head -1)
[ -z "$MSF_BIN" ] && { echo "msf binary not found in tarball" >&2; exit 1; }

mkdir -p app_root/bin app_root/ui
cp "$MSF_BIN" app_root/msf
chmod +x app_root/msf

cp apps/msf/fnos/bin/msf-server app_root/bin/msf-server
chmod +x app_root/bin/msf-server
cp -a apps/msf/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
