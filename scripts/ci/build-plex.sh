#!/bin/bash
set -euo pipefail

VERSION="${1:-}"
PLEX_BUILD="${2:-}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "${PLEX_BUILD}" ] && { echo "PLEX_BUILD is required" >&2; exit 1; }

echo "==> Building Plex ${VERSION} (${PLEX_BUILD})"
DOWNLOAD_URL=$(curl -sL "https://plex.tv/api/downloads/5.json" | \
  jq -r ".computer.Linux.releases[] | select(.build == \"$PLEX_BUILD\" and .distro == \"debian\") | .url")

curl -L -o plex.deb "$DOWNLOAD_URL"
ar -x plex.deb
mkdir -p extracted
tar -xf data.tar.xz -C extracted

mkdir -p app_root/lib app_root/bin app_root/ui/images
cp -a extracted/usr/lib/plexmediaserver/* app_root/
cp apps/plex/fnos/bin/plex-server app_root/bin/
chmod +x app_root/bin/plex-server
cp -a apps/plex/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
