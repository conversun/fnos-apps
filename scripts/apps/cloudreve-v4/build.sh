#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${VERSION:?VERSION is required}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"
OUTPUT_DIR="$PWD"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
curl -fL --connect-timeout 30 --max-time 300 -o "$WORK_DIR/cloudreve.tar.gz" "https://github.com/cloudreve/cloudreve/releases/download/${VERSION}/cloudreve_${VERSION}_linux_${ZIP_ARCH}.tar.gz"
mkdir -p "$WORK_DIR/unpack" "$WORK_DIR/app/bin"
tar -xzf "$WORK_DIR/cloudreve.tar.gz" -C "$WORK_DIR/unpack"
cp "$WORK_DIR/unpack/cloudreve" "$WORK_DIR/app/cloudreve"
cp "$SCRIPT_DIR/../../../apps/cloudreve-v4/fnos/bin/cloudreve-v4-server" "$WORK_DIR/app/bin/"
chmod +x "$WORK_DIR/app/cloudreve" "$WORK_DIR/app/bin/cloudreve-v4-server"
cp -a "$SCRIPT_DIR/../../../apps/cloudreve-v4/fnos/ui" "$WORK_DIR/app/ui"
tar -czf "$OUTPUT_DIR/app.tgz" -C "$WORK_DIR/app" .
echo "已构建 Cloudreve V4 ${VERSION} ${ZIP_ARCH} app.tgz"
