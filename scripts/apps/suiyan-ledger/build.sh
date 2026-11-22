#!/bin/bash
set -euo pipefail

# CI downloads OFFICIAL_FPK_ASSET_x86 directly; local repackaging is unsupported.
echo "[ERROR] 随言记账使用上游 FPK 直通发布，不支持通过本脚本重新打包。" >&2
exit 1
