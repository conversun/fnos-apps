#!/bin/bash
set -euo pipefail

VERSION="${1:-}"
DEB_ARCH="${2:-}"
CODENAME="${3:-bookworm}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "${DEB_ARCH}" ] && { echo "DEB_ARCH is required" >&2; exit 1; }

echo "==> Building Nginx ${VERSION} (${DEB_ARCH})"
curl -L -o nginx.deb "https://nginx.org/packages/debian/pool/nginx/n/nginx/nginx_${VERSION}-1~${CODENAME}_${DEB_ARCH}.deb"
ar -x nginx.deb
mkdir -p extracted

if [ -f data.tar.zst ]; then
  apt-get update -qq && apt-get install -y -qq zstd >/dev/null 2>&1
  tar --zstd -xf data.tar.zst -C extracted
elif [ -f data.tar.xz ]; then
  tar -xf data.tar.xz -C extracted
elif [ -f data.tar.gz ]; then
  tar -xf data.tar.gz -C extracted
else
  echo "Unsupported nginx package format" >&2
  exit 1
fi

dst=app_root
mkdir -p "$dst/sbin" "$dst/conf" "$dst/html" "$dst/lib" "$dst/bin" "$dst/ui/images"
cp extracted/usr/sbin/nginx "$dst/sbin/"
chmod +x "$dst/sbin/nginx"
cp -a extracted/etc/nginx/* "$dst/conf/" 2>/dev/null || true
find "$dst/conf/" -type l -delete
sed -i 's/^user[[:space:]]\+nginx;/#user  nginx;/' "$dst/conf/nginx.conf" 2>/dev/null || true
cp -a extracted/usr/share/nginx/html/* "$dst/html/" 2>/dev/null || true
[ -d extracted/usr/lib ] && cp -a extracted/usr/lib/* "$dst/lib/" 2>/dev/null || true
cp apps/nginx/fnos/bin/nginx-server "$dst/bin/nginx-server"
chmod +x "$dst/bin/nginx-server"
cp -a apps/nginx/fnos/ui/* "$dst/ui/" 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
