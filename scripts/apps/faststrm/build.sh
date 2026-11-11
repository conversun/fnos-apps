#!/bin/bash
set -euo pipefail

# CI uses the official FPK assets declared in meta.env, without repackaging.
echo "[ERROR] FastStrm 使用上游官方 FPK 直通发布，不支持本地重打包。" >&2
exit 1
