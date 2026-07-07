#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="feigram"
APP_DISPLAY_NAME="Feigram"
APP_VERSION_VAR="FEIGRAM_VERSION"
APP_VERSION="${FEIGRAM_VERSION:-latest}"
APP_DEPS=(curl tar xz npm jq)
APP_FPK_PREFIX="feigram"
APP_HELP_VERSION_EXAMPLE="2.0.19"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Node/runtime arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.0.19      # 指定版本，x86 架构
  $0 --arch arm 2.0.19      # 指定版本，ARM 架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/g-star1024/Feigram-Public/releases/latest" 2>/dev/null | \
        jq -r '.tag_name' | sed -E 's/^Feigram//; s/^v//')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.0.19"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 Feigram app.tgz ($ARCH / $TARBALL_ARCH)..."
    export VERSION="$APP_VERSION"
    export TARBALL_ARCH
    bash "$REPO_ROOT/scripts/apps/feigram/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
