#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="vibenvr"
APP_DISPLAY_NAME="VibeNVR"
APP_VERSION_VAR="VIBENVR_VERSION"
APP_VERSION="${VIBENVR_VERSION:-latest}"
APP_DEPS=(curl jq sed tar)
APP_FPK_PREFIX="vibenvr"
APP_HELP_VERSION_EXAMPLE="1.30.12"

app_set_arch_vars() {
    case "$ARCH" in
        x86)
            TARBALL_ARCH="amd64"
            ;;
        arm)
            error "VibeNVR 上游 Docker 镜像当前仅支持 amd64，本应用不构建 arm64 包。"
            ;;
    esac
    info "目标架构: x86 (amd64 only)"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.30.12       # 指定版本，x86
  $0 1.30.12                  # 指定版本，自动检测 x86
EOF
}

app_show_help_extra() {
    cat << EOF

注意:
  VibeNVR 上游镜像仅发布 linux/amd64；--arch arm 会被拒绝。
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."
    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/spupuz/VibeNVR/releases/latest" | \
            jq -r '.tag_name' | sed 's/^v//')
    fi
    [ -z "$APP_VERSION" ] || [ "$APP_VERSION" = "null" ] && error "无法获取版本信息，请手动指定: $0 1.30.12"
    info "目标版本: $APP_VERSION"
}

app_download() {
    mkdir -p "$WORK_DIR"
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker, x86 only)..."
    export VERSION="$APP_VERSION"
    export TARBALL_ARCH="amd64"
    bash "$REPO_ROOT/scripts/apps/vibenvr/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
