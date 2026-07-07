#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"
DASHBOARD_REPO="conversun/fnos-mihomo-dashboard"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

# Resolve dashboard version: env > meta.env pinned > GH API latest
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "${DASHBOARD_VERSION:-}" ] && [ -f "$SCRIPT_DIR/meta.env" ]; then
    DASHBOARD_VERSION=$(grep '^DASHBOARD_VERSION=' "$SCRIPT_DIR/meta.env" | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" || true)
fi
if [ -z "${DASHBOARD_VERSION:-}" ]; then
    DASHBOARD_VERSION=$(curl -sL "https://api.github.com/repos/${DASHBOARD_REPO}/releases/latest" | \
        grep '"tag_name":' | sed -E 's/.*"(v?[^"]+)".*/\1/')
fi
[ -z "$DASHBOARD_VERSION" ] && { echo "Failed to resolve fnos-mihomo-dashboard version" >&2; exit 1; }

echo "==> Building Mihomo ${VERSION} for ${TARBALL_ARCH}"
echo "    fnos-mihomo-dashboard ${DASHBOARD_VERSION}"

# mihomo binary — x86-64 uses the `compatible` (GOAMD64=v1) build so it runs on ALL
# x86-64 CPUs, incl. older NAS/J-series chips without v3 microarch support (issue #174).
MIHOMO_ASSET="mihomo-linux-${TARBALL_ARCH}-v${VERSION}"
[ "${TARBALL_ARCH}" = "amd64" ] && MIHOMO_ASSET="mihomo-linux-amd64-compatible-v${VERSION}"
curl -fL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/v${VERSION}/${MIHOMO_ASSET}.gz"

# metacubexd static (advanced-user escape hatch)
curl -fL -o metacubexd.zip "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# fnos-mihomo-dashboard (main UI + supervisor)
curl -fL -o fnos-mihomo-dashboard "https://github.com/${DASHBOARD_REPO}/releases/download/${DASHBOARD_VERSION}/fnos-mihomo-dashboard-linux-${TARBALL_ARCH}"
chmod +x fnos-mihomo-dashboard

# Assemble app_root
mkdir -p app_root/bin app_root/ui app_root/metacubexd

gunzip -c mihomo.gz > app_root/mihomo
chmod +x app_root/mihomo

cp fnos-mihomo-dashboard app_root/fnos-mihomo-dashboard
chmod +x app_root/fnos-mihomo-dashboard

unzip -q metacubexd.zip
[ ! -d "metacubexd-gh-pages" ] && { echo "metacubexd-gh-pages not found" >&2; exit 1; }
cp -a metacubexd-gh-pages/. app_root/metacubexd/

cp apps/mihomo/fnos/bin/mihomo-server app_root/bin/mihomo-server
chmod +x app_root/bin/mihomo-server
cp -a apps/mihomo/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
echo "==> app.tgz built: $(du -h ../app.tgz | cut -f1)"
