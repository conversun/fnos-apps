#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAME="zerotier"
APP_DISPLAY_NAME="ZeroTier"
APP_VERSION_VAR="ZEROTIER_VERSION"
APP_VERSION="${ZEROTIER_VERSION:-latest}"
APP_DEPS=(curl jq)
APP_FPK_PREFIX="zerotier"
APP_HELP_VERSION_EXAMPLE="0.8.0"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 0.8.0                   # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/sinamics/ztnet/releases/latest" | \
          jq -r '.tag_name' | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.8.0"
    [ "$APP_VERSION" = "null" ] && error "无法获取版本信息，请手动指定: $0 0.8.0"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/zerotier/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
