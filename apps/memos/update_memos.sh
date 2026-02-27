#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="memos"
APP_DISPLAY_NAME="Memos"
APP_VERSION_VAR="MEMOS_VERSION"
APP_VERSION="${MEMOS_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="memos"
APP_HELP_VERSION_EXAMPLE="0.26.1"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TAR_ARCH="x86_64" ;;
        arm) TAR_ARCH="arm64" ;;
    esac
    info "Tar arch: $TAR_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 0.26.1      # 指定版本，x86 架构
  $0 0.26.1                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/memospot/memos-builds/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.26.1"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/memospot/memos-builds/releases/download/v${APP_VERSION}/memos-v${APP_VERSION}-linux-${TAR_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/memos.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/memos.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 memos..."
    cd "$WORK_DIR"
    mkdir -p extract
    tar -xzf memos.tar.gz -C extract

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    cp extract/memos "$dst/memos"
    chmod +x "$dst/memos"

    cp "$PKG_DIR/bin/memos-server" "$dst/bin/memos-server"
    chmod +x "$dst/bin/memos-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
