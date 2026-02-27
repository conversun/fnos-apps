#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
DEB_ARCH="${DEB_ARCH:-amd64}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Nginx UI ${VERSION} (${DEB_ARCH})"

# Map DEB_ARCH to nginx-ui release asset suffix
case "$DEB_ARCH" in
  amd64)  NGINX_UI_ARCH="64" ;;
  arm64)  NGINX_UI_ARCH="arm64-v8a" ;;
  *)      echo "Unsupported architecture: $DEB_ARCH" >&2; exit 1 ;;
esac

# --- 1. Download nginx-ui binary ---
NGINX_UI_URL="https://github.com/0xJacky/nginx-ui/releases/download/v${VERSION}/nginx-ui-linux-${NGINX_UI_ARCH}.tar.gz"
echo "Downloading nginx-ui: $NGINX_UI_URL"
curl -fL -o nginx-ui.tar.gz "$NGINX_UI_URL"

# --- 2. Extract nginx-ui ---
mkdir -p nginx_ui_extracted
tar -xzf nginx-ui.tar.gz -C nginx_ui_extracted

# --- 3. Assemble app_root ---
dst=app_root
mkdir -p "$dst/bin" "$dst/ui/images"

# Nginx UI binary
NGINX_UI_BIN=$(find nginx_ui_extracted -name "nginx-ui" -type f | head -1)
[ -z "$NGINX_UI_BIN" ] && { echo "nginx-ui binary not found in tarball" >&2; exit 1; }
cp "$NGINX_UI_BIN" "$dst/nginx-ui"
chmod +x "$dst/nginx-ui"

# Startup wrapper + UI assets from fnos/
cp apps/nginx-ui/fnos/bin/nginx-ui-server "$dst/bin/nginx-ui-server"
chmod +x "$dst/bin/nginx-ui-server"
cp -a apps/nginx-ui/fnos/ui/* "$dst/ui/" 2>/dev/null || true

# --- 4. Package ---
cd app_root
tar -czf ../app.tgz .
