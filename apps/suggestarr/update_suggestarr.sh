#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="suggestarr"
APP_DISPLAY_NAME="SuggestArr"
APP_VERSION_VAR="SUGGESTARR_VERSION"
APP_VERSION="${SUGGESTARR_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="suggestarr"
APP_HELP_VERSION_EXAMPLE="v2.9.1"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 v2.9.1                 # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/ciuse99/suggestarr/tags/?page_size=200" | \
            jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 v2.9.1"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/suggestarr/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
