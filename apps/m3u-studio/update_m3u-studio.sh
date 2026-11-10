#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"
APP_NAME="m3u-studio"
APP_DISPLAY_NAME="M3U Studio"
APP_VERSION_VAR="APP_VERSION"
APP_VERSION="${APP_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="m3u-studio"
APP_HELP_VERSION_EXAMPLE="0.6.4"
app_get_latest_version() {
    local resolved
    if [ "$APP_VERSION" = latest ]; then
        resolved=$(bash "$REPO_ROOT/scripts/apps/m3u-studio/get-latest-version.sh")
    else
        resolved=$(bash "$REPO_ROOT/scripts/apps/m3u-studio/get-latest-version.sh" "$APP_VERSION")
    fi
    APP_VERSION="${resolved#VERSION=}"
}
app_download() {
    # Docker pulls the upstream image when fnOS creates the project.
    :
}
app_build_app_tgz() {
    (cd "$WORK_DIR" && VERSION="$APP_VERSION" bash "$REPO_ROOT/scripts/apps/m3u-studio/build.sh")
}
# shellcheck source=../../scripts/lib/update-common.sh
source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
