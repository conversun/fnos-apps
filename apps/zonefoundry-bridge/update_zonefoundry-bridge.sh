#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="zonefoundry-bridge"
APP_DISPLAY_NAME="ZoneFoundry Bridge"
APP_VERSION_VAR="ZONEFOUNDRY_BRIDGE_VERSION"
APP_VERSION="${ZONEFOUNDRY_BRIDGE_VERSION:-latest}"
APP_DEPS=(curl)
APP_FPK_PREFIX="zonefoundry-bridge"
APP_HELP_VERSION_EXAMPLE="0.1.14"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 0.1.14                  # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/zonefoundry/bridge/tags/?page_size=100" | \
          grep -oE '"name":"[0-9]+\.[0-9]+\.[0-9]+"' | head -n1 | cut -d'"' -f4)
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.1.14"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/zonefoundry-bridge/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
