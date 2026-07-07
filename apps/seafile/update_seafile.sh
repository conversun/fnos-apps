#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAME="seafile"
APP_DISPLAY_NAME="Seafile"
APP_VERSION_VAR="SEAFILE_VERSION"
APP_VERSION="${SEAFILE_VERSION:-latest}"
APP_DEPS=(curl jq sed tar)
APP_FPK_PREFIX="seafile"
APP_HELP_VERSION_EXAMPLE="13.0.24"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "目标架构: $ARCH ($TARBALL_ARCH)"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 13.0.24       # 指定版本，x86
  $0 --arch arm 13.0.24       # 指定版本，arm
  $0 13.0.24                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."
    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -fsSL "https://registry.hub.docker.com/v2/repositories/seafileltd/seafile-mc/tags?page_size=25" | \
            jq -r '.results[].name | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' | \
            sort -V | tail -1)
    fi
    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 13.0.24"
    info "目标版本: $APP_VERSION"
}

app_download() {
    mkdir -p "$WORK_DIR"
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/seafile/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
