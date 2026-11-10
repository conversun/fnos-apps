#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${VERSION:?VERSION is required}"
OUTPUT_DIR="$PWD"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/docker"
cp "$SCRIPT_DIR/../../../apps/twitchdropsminer/fnos/docker/docker-compose.yaml" "$WORK_DIR/docker/"
sed -i.bak "s/\${VERSION}/${VERSION}/g" "$WORK_DIR/docker/docker-compose.yaml"
rm -f "$WORK_DIR/docker/docker-compose.yaml.bak"
cp -a "$SCRIPT_DIR/../../../apps/twitchdropsminer/fnos/ui" "$WORK_DIR/ui"
tar -czf "$OUTPUT_DIR/app.tgz" -C "$WORK_DIR" docker ui
echo "已构建 TwitchDropsMiner ${VERSION} app.tgz"
