#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="amd64" ;;
  arm64) UPSTREAM_ARCH="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Glance ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "$WORK_DIR/glance.tar.gz" \
  "https://github.com/glanceapp/glance/releases/download/v${VERSION}/glance-linux-${UPSTREAM_ARCH}.tar.gz"
tar -xzf "$WORK_DIR/glance.tar.gz" -C "$WORK_DIR"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
mv "$WORK_DIR/glance" "$WORK_DIR/app_root/glance"
chmod +x "$WORK_DIR/app_root/glance"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/glance/fnos/bin/glance-server" "$WORK_DIR/app_root/bin/glance-server"
chmod +x "$WORK_DIR/app_root/bin/glance-server"
cp "${SCRIPT_DIR}/../../../apps/glance/fnos/glance.yml.template" "$WORK_DIR/app_root/glance.yml.template"
cp -a "${SCRIPT_DIR}/../../../apps/glance/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Glance ${VERSION}"
