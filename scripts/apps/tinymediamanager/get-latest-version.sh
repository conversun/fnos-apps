#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # 从官方下载页面解析最新版本号
  VERSION=$(curl -sL "https://release.tinymediamanager.org" | \
    grep -oP 'tinyMediaManager-\K[0-9]+\.[0-9]+\.[0-9]+(?=-linux-amd64\.tar\.xz)' | \
    head -1)
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for tinyMediaManager" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
