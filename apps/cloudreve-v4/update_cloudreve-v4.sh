#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"
APP_NAME="cloudreve-v4"
APP_DISPLAY_NAME="Cloudreve V4"
APP_VERSION_VAR="APP_VERSION"
APP_VERSION="${APP_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="cloudreve-v4"
APP_HELP_VERSION_EXAMPLE="4.19.1"
app_get_latest_version() {
    local resolved
    if [ "$APP_VERSION" = latest ]; then
        resolved=$(bash "$REPO_ROOT/scripts/apps/cloudreve-v4/get-latest-version.sh")
    else
        resolved=$(bash "$REPO_ROOT/scripts/apps/cloudreve-v4/get-latest-version.sh" "$APP_VERSION")
    fi
    APP_VERSION="${resolved#VERSION=}"
}
app_set_arch_vars() {
    case "$ARCH" in
        x86) ZIP_ARCH=amd64 ;;
        arm) ZIP_ARCH=arm64 ;;
    esac
}
app_download() {
    # The build contract downloads the unchanged upstream release binary.
    :
}
app_build_app_tgz() {
    (cd "$WORK_DIR" && VERSION="$APP_VERSION" ZIP_ARCH="$ZIP_ARCH" bash "$REPO_ROOT/scripts/apps/cloudreve-v4/build.sh")
}
# shellcheck source=../../scripts/lib/update-common.sh
source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
