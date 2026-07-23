#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_NAME="obsidian"

cd "$REPO_ROOT"
VERSION="$(./scripts/apps/${APP_NAME}/get-latest-version.sh | awk -F= '/^VERSION=/{print $2}')"
VERSION="$VERSION" ./scripts/apps/${APP_NAME}/build.sh
./scripts/build-fpk.sh "apps/${APP_NAME}" app.tgz "$VERSION" "${ARCH:-}"

echo "Build completed: ${APP_NAME}"
