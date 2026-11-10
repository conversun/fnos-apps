#!/bin/bash
# Shared portable FFmpeg pin for CI and local builds; FFMPEG_PIN overrides the filename.
FFMPEG_FILE="${FFMPEG_PIN:-jellyfin-ffmpeg_7.1.4-3_portable_${PORTABLE_SUFFIX}-gpl.tar.xz}"
FFMPEG_VERSION="${FFMPEG_FILE#jellyfin-ffmpeg_}"
FFMPEG_VERSION="${FFMPEG_VERSION%%_portable_*}"
FFMPEG_URL="https://repo.jellyfin.org/files/ffmpeg/linux/7.x/${FFMPEG_VERSION}/${TARBALL_ARCH}/${FFMPEG_FILE}"
