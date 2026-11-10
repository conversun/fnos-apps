#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"
TARBALL_ARCH="${2:-${TARBALL_ARCH:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "${TARBALL_ARCH}" ] && { echo "TARBALL_ARCH is required" >&2; exit 1; }

echo "==> Building Jellyfin ${VERSION} (${TARBALL_ARCH})"

# Map arch for portable FFmpeg filename
case "${TARBALL_ARCH}" in
    amd64) PORTABLE_SUFFIX="linux64" ;;
    arm64) PORTABLE_SUFFIX="linuxarm64" ;;
    *) echo "Unsupported arch: ${TARBALL_ARCH}" >&2; exit 1 ;;
esac

TARBALL_URL="https://repo.jellyfin.org/files/server/linux/latest-stable/${TARBALL_ARCH}/jellyfin_${VERSION}-${TARBALL_ARCH}.tar.gz"
# shellcheck source=scripts/apps/jellyfin/ffmpeg.sh
source "$(dirname "${BASH_SOURCE[0]}")/ffmpeg.sh"
echo "==> FFmpeg: $FFMPEG_FILE"

curl -fL -o jellyfin.tar.gz "$TARBALL_URL"
curl -fL -o "$FFMPEG_FILE" "$FFMPEG_URL"

tar -xzf jellyfin.tar.gz

mkdir -p ffmpeg_extract
tar -xf "$FFMPEG_FILE" -C ffmpeg_extract

dst=app_root
mkdir -p "$dst/bin" "$dst/config" "$dst/ui/images" "$dst/jellyfin-ffmpeg"

cp -a jellyfin/* "$dst/"

# Copy portable FFmpeg (handle both root-level and subdirectory layouts)
FFMPEG_BIN=$(find ffmpeg_extract -name ffmpeg -type f -print -quit)
[ -z "$FFMPEG_BIN" ] && { echo "Error: ffmpeg binary not found in portable package" >&2; exit 1; }
FFMPEG_SRC=$(dirname "$FFMPEG_BIN")
cp -a "$FFMPEG_SRC"/* "$dst/jellyfin-ffmpeg/"

# Validate FFmpeg binary exists and is executable
[ -x "$dst/jellyfin-ffmpeg/ffmpeg" ] || chmod +x "$dst/jellyfin-ffmpeg/ffmpeg"
[ -x "$dst/jellyfin-ffmpeg/ffprobe" ] || chmod +x "$dst/jellyfin-ffmpeg/ffprobe" 2>/dev/null || true
echo "==> FFmpeg validated: $(du -sh "$dst/jellyfin-ffmpeg" | cut -f1)"

cp apps/jellyfin/fnos/bin/jellyfin-server "$dst/bin/jellyfin-server"
chmod +x "$dst/bin/jellyfin-server"

cp -a apps/jellyfin/fnos/ui/* "$dst/ui/" 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
