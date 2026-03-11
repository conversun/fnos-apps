#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

VERSION="${VERSION:-}"
ARCH="${ARCH:-x86_64}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building OpenClaw ${VERSION} for ${ARCH}"

# Node.js 22 LTS version
NODE_VERSION="22.14.0"
NODE_TARBALL="node-v${NODE_VERSION}-linux-x64.tar.xz"
NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TARBALL}"

echo "==> Downloading Node.js ${NODE_VERSION}..."
curl -fL -o "${NODE_TARBALL}" "${NODE_URL}"

echo "==> Extracting Node.js..."
tar -xf "${NODE_TARBALL}"
mv "node-v${NODE_VERSION}-linux-x64" node

echo "==> Installing openclaw ${VERSION}..."
export PATH="$(pwd)/node/bin:${PATH}"
# Prevent playwright from downloading browser binaries (~300MB)
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
npm install -g --prefix ./openclaw_global "openclaw@${VERSION}" \
  --omit=dev --no-audit --no-fund

echo "==> Size before optimization: $(du -sh ./openclaw_global | cut -f1)"

OC_MODULES="./openclaw_global/lib/node_modules"

# 1) Remove sharp prebuilt binaries for non-linux-x64 platforms
echo "==> Removing non-linux-x64 sharp prebuilds..."
find "${OC_MODULES}" -path "*/@img/sharp-*" -maxdepth 4 -type d \
  ! -name "*linux-x64*" -exec rm -rf {} + 2>/dev/null || true

# 2) Remove TypeScript declarations, source maps, and documentation
echo "==> Removing unnecessary files (.d.ts, .map, docs)..."
find "${OC_MODULES}" -type f \( \
  -name "*.d.ts" -o -name "*.d.mts" -o -name "*.d.cts" \
  -o -name "*.map" \
  -o -name "*.md" -o -name "*.markdown" \
  -o -name "LICENSE*" -o -name "LICENCE*" \
  -o -name "CHANGELOG*" -o -name "HISTORY*" -o -name "CHANGES*" -o -name "AUTHORS*" \
  -o -name "Makefile" -o -name "Gruntfile*" -o -name "Gulpfile*" \
  -o -name ".npmignore" -o -name ".eslintrc*" -o -name ".prettierrc*" \
  -o -name ".editorconfig" -o -name ".gitattributes" \
  -o -name "tsconfig*.json" -o -name "tslint.json" -o -name ".tsbuildinfo" \
\) -delete 2>/dev/null || true

# 3) Remove test, docs, example, and CI directories
# yaml dist/doc/ is functional source, not documentation (https://github.com/eemeli/yaml/issues/384)
echo "==> Removing test/docs/example directories..."
find "${OC_MODULES}" -type d \( \
  -name "test" -o -name "tests" -o -name "__tests__" \
  -o -name "spec" -o -name "specs" \
  -o -name "docs" -o -name "doc" -o -name "documentation" \
  -o -name "examples" -o -name "example" -o -name "samples" \
  -o -name ".github" -o -name ".vscode" -o -name ".idea" \
  -o -name "coverage" -o -name ".nyc_output" \
  -o -name "benchmark" -o -name "benchmarks" \
  -o -name "man" \
\) ! -path "*/dist/doc" ! -path "*/openclaw/docs" -exec rm -rf {} + 2>/dev/null || true

echo "==> Size after optimization: $(du -sh ./openclaw_global | cut -f1)"

echo "==> Building app.tgz..."
mkdir -p app_root/server app_root/ui

# Copy Node.js runtime (binary only, npm not needed at runtime)
mkdir -p app_root/server/node/bin
cp node/bin/node app_root/server/node/bin/
cp node/LICENSE app_root/server/node/

# Copy openclaw npm package
cp -r openclaw_global app_root/server/

# Copy iframe-proxy.js
if [ -f "${REPO_ROOT}/apps/openclaw/server/iframe-proxy.js" ]; then
  cp "${REPO_ROOT}/apps/openclaw/server/iframe-proxy.js" app_root/server/
fi

# Copy UI files
if [ -d "${REPO_ROOT}/apps/openclaw/fnos/ui" ]; then
  cp -r "${REPO_ROOT}/apps/openclaw/fnos/ui/"* app_root/ui/
fi

cd app_root
tar -czf ../app.tgz .
cd ..

echo "==> Build complete: app.tgz ($(du -h app.tgz | cut -f1))"
