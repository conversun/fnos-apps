#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="msf"
APP_DISPLAY_NAME="MSF"
APP_VERSION_VAR="MSF_VERSION"
APP_VERSION="${MSF_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="msf"
APP_HELP_VERSION_EXAMPLE="0.3.9.2"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 0.3.9.2       # 指定版本，x86 架构
  $0 0.3.9.2                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."
    local tag
    tag=$(curl -sL "https://api.github.com/repos/scoltzero/msf/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.3.9.2"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/scoltzero/msf/releases/download/v${APP_VERSION}/msf-linux-${TARBALL_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/msf-linux.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/msf-linux.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 MSF..."
    cd "$WORK_DIR"
    mkdir -p extracted
    tar -xzf msf-linux.tar.gz -C extracted

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    local msf_bin
    msf_bin=$(find extracted -path "*/msf" -type f | head -1)
    [ -z "$msf_bin" ] && error "在 tarball 中找不到 msf 二进制文件"

    cp "$msf_bin" "$dst/msf"
    chmod +x "$dst/msf"

    cp "$PKG_DIR/bin/msf-server" "$dst/bin/msf-server"
    chmod +x "$dst/bin/msf-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
