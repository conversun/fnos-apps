#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="verysync"
APP_DISPLAY_NAME="Verysync"
APP_VERSION_VAR="VERYSYNC_VERSION"
APP_VERSION="${VERYSYNC_VERSION:-latest}"
APP_DEPS=(curl tar gzip)
APP_FPK_PREFIX="verysync"
APP_HELP_VERSION_EXAMPLE="2.21.3"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.21.3       # 指定版本，x86 架构
  $0 --arch arm 2.21.3       # 指定版本，ARM64 架构
  $0 2.21.3                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" != "latest" ]; then
        APP_VERSION="${APP_VERSION#v}"
        info "目标版本: $APP_VERSION"
        return
    fi

    local effective_url
    effective_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "https://www.verysync.com/download.php?platform=linux-amd64")
    APP_VERSION=$(printf '%s\n' "$effective_url" | sed -E 's|.*/verysync-linux-amd64-v([^/]+)\.tar\.gz$|\1|')

    if [ -z "$APP_VERSION" ] || [ "$APP_VERSION" = "$effective_url" ]; then
        error "无法获取版本信息，请手动指定: $0 2.21.3"
    fi

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://dl-cn.verysync.com/releases/v${APP_VERSION}/verysync-linux-${TARBALL_ARCH}-v${APP_VERSION}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    for attempt in 1 2 3 4 5; do
        curl -L -f --retry 3 --retry-delay 2 --retry-all-errors \
            -o "$WORK_DIR/verysync.tar.gz" "$download_url" || true
        if gzip -t "$WORK_DIR/verysync.tar.gz" 2>/dev/null; then
            break
        fi
        warn "第 ${attempt} 次下载损坏或失败，准备重试..."
        rm -f "$WORK_DIR/verysync.tar.gz"
        [ "$attempt" -eq 5 ] && error "下载失败"
        sleep 3
    done
    info "下载完成: $(du -h "$WORK_DIR/verysync.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 Verysync..."
    cd "$WORK_DIR"
    tar -xzf verysync.tar.gz

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    local verysync_bin
    verysync_bin=$(find . -path "*/verysync-linux-${TARBALL_ARCH}-*/verysync" -type f -size +1M -print -quit)
    [ -z "$verysync_bin" ] && error "在 tar.gz 中找不到 Verysync 二进制文件"

    cp "$verysync_bin" "$dst/verysync"
    chmod +x "$dst/verysync"

    cp "$PKG_DIR/bin/verysync-server" "$dst/bin/verysync-server"
    chmod +x "$dst/bin/verysync-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
