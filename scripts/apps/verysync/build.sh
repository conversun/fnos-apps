#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

case "$TARBALL_ARCH" in
  amd64|arm64) ;;
  aarch64) TARBALL_ARCH="arm64" ;;
  *) echo "Unsupported Verysync tarball arch: $TARBALL_ARCH" >&2; exit 1 ;;
esac

echo "==> Building Verysync ${VERSION} for ${TARBALL_ARCH}"

DOWNLOAD_URL="https://dl-cn.verysync.com/releases/v${VERSION}/verysync-linux-${TARBALL_ARCH}-v${VERSION}.tar.gz"

for attempt in 1 2 3 4 5; do
  curl -fL --retry 3 --retry-delay 2 --retry-all-errors \
    -o verysync.tar.gz "$DOWNLOAD_URL"
  if gzip -t verysync.tar.gz 2>/dev/null; then
    break
  fi
  echo "  attempt ${attempt}: corrupt download ($(wc -c < verysync.tar.gz) bytes), retrying..." >&2
  rm -f verysync.tar.gz
  [ "$attempt" -eq 5 ] && { echo "ERROR: could not obtain a valid Verysync tarball after 5 attempts" >&2; exit 1; }
  sleep 3
done

tar -xzf verysync.tar.gz

mkdir -p app_root/bin app_root/ui
VERYSYNC_BIN=$(find . -path "*/verysync-linux-${TARBALL_ARCH}-*/verysync" -type f -size +1M -print -quit)
[ -z "$VERYSYNC_BIN" ] && { echo "verysync binary (>1MB) not found after extraction" >&2; exit 1; }

cp "$VERYSYNC_BIN" app_root/verysync
chmod +x app_root/verysync

cp apps/verysync/fnos/bin/verysync-server app_root/bin/verysync-server
chmod +x app_root/bin/verysync-server
cp -a apps/verysync/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
