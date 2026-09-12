#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ASSET="homebox_Linux_x86_64.tar.gz" ;;
  arm64) UPSTREAM_ASSET="homebox_Linux_arm64.tar.gz" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Homebox ${VERSION}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "$WORK_DIR/homebox.tar.gz" \
  "https://github.com/sysadminsmedia/homebox/releases/download/v${VERSION}/${UPSTREAM_ASSET}"
tar -xzf "$WORK_DIR/homebox.tar.gz" -C "$WORK_DIR"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
mv "$WORK_DIR/homebox" "$WORK_DIR/app_root/homebox"
chmod +x "$WORK_DIR/app_root/homebox"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/homebox/fnos/bin/homebox-server" "$WORK_DIR/app_root/bin/homebox-server"
chmod +x "$WORK_DIR/app_root/bin/homebox-server"
cp -a "${SCRIPT_DIR}/../../../apps/homebox/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Homebox ${VERSION}"
