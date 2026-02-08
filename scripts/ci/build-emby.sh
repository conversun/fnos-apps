#!/bin/bash
set -euo pipefail

VERSION="${1:-}"
DEB_ARCH="${2:-}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "${DEB_ARCH}" ] && { echo "DEB_ARCH is required" >&2; exit 1; }

echo "==> Building Emby ${VERSION} (${DEB_ARCH})"
curl -L -o emby.deb "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-deb_${VERSION}_${DEB_ARCH}.deb"
ar -x emby.deb
mkdir -p extracted
tar -xf data.tar.xz -C extracted

src=extracted/opt/emby-server
dst=app_root
mkdir -p "$dst"
for dir in bin etc extra lib licenses share system; do
  [ -d "$src/$dir" ] && cp -r "$src/$dir" "$dst/"
done
mkdir -p "$dst/config" "$dst/ui/images"

cp apps/emby/fnos/EmbyServer.sc "$dst/"
cp apps/emby/fnos/config/* "$dst/config/"
cp -a apps/emby/fnos/ui/* "$dst/ui/"
cp apps/emby/fnos/bin/emby-server "$dst/bin/emby-server"
chmod +x "$dst/bin/emby-server"

cd app_root
tar -czf ../app.tgz .
