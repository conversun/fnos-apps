#!/bin/bash
set -euo pipefail

# CI downloads the official FPK selected by meta.env without repackaging.
echo "[ERROR] FnCal 使用上游官方 FPK 直通发布；本地请运行 apps/fncal/update_fncal.sh。" >&2
exit 1
