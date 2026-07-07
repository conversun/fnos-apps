#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="mihomo"
APP_DISPLAY_NAME="Mihomo"
APP_VERSION_VAR="MIHOMO_VERSION"
APP_VERSION="${MIHOMO_VERSION:-latest}"
APP_DEPS=(curl unzip gunzip tar)
APP_FPK_PREFIX="mihomo"
APP_HELP_VERSION_EXAMPLE="1.19.25"

# fnos-mihomo-dashboard release (independent versioning from mihomo)
DASHBOARD_REPO="conversun/fnos-mihomo-dashboard"
# Dashboard version priority: env > scripts/apps/mihomo/meta.env > GH API latest
if [ -z "${DASHBOARD_VERSION:-}" ]; then
    META_ENV="$REPO_ROOT/scripts/apps/mihomo/meta.env"
    if [ -f "$META_ENV" ]; then
        DASHBOARD_VERSION=$(grep '^DASHBOARD_VERSION=' "$META_ENV" | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" || true)
    fi
fi
DASHBOARD_VERSION="${DASHBOARD_VERSION:-latest}"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.19.25       # 指定 mihomo 版本，x86 架构
  $0 1.19.25                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."
    local tag
    tag=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi
    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.19.25"
    info "Mihomo 版本: $APP_VERSION"

    if [ "$DASHBOARD_VERSION" = "latest" ]; then
        DASHBOARD_VERSION=$(curl -sL "https://api.github.com/repos/${DASHBOARD_REPO}/releases/latest" 2>/dev/null | \
            grep '"tag_name":' | sed -E 's/.*"(v?[^"]+)".*/\1/')
        [ -z "$DASHBOARD_VERSION" ] && error "无法获取 fnos-mihomo-dashboard 版本"
    fi
    info "Dashboard 版本: $DASHBOARD_VERSION"
}

app_download() {
    mkdir -p "$WORK_DIR"

    # x86-64: use the `compatible` (GOAMD64=v1) build for universal CPU compat (issue #174)
    local mihomo_asset="mihomo-linux-${TARBALL_ARCH}-v${APP_VERSION}"
    [ "${TARBALL_ARCH}" = "amd64" ] && mihomo_asset="mihomo-linux-amd64-compatible-v${APP_VERSION}"
    local mihomo_url="https://github.com/MetaCubeX/mihomo/releases/download/v${APP_VERSION}/${mihomo_asset}.gz"
    info "下载 mihomo: $mihomo_url"
    curl -L -f -o "$WORK_DIR/mihomo.gz" "$mihomo_url" || error "下载 mihomo 失败"

    local metacubexd_url="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"
    info "下载 metacubexd: $metacubexd_url"
    curl -L -f -o "$WORK_DIR/metacubexd.zip" "$metacubexd_url" || error "下载 metacubexd 失败"

    local dashboard_url="https://github.com/${DASHBOARD_REPO}/releases/download/${DASHBOARD_VERSION}/fnos-mihomo-dashboard-linux-${TARBALL_ARCH}"
    info "下载 fnos-mihomo-dashboard: $dashboard_url"
    curl -L -f -o "$WORK_DIR/fnos-mihomo-dashboard" "$dashboard_url" || error "下载 fnos-mihomo-dashboard 失败"

    info "已下载:"
    info "  mihomo:                    $(du -h "$WORK_DIR/mihomo.gz" | cut -f1)"
    info "  metacubexd:                $(du -h "$WORK_DIR/metacubexd.zip" | cut -f1)"
    info "  fnos-mihomo-dashboard:     $(du -h "$WORK_DIR/fnos-mihomo-dashboard" | cut -f1)"
}

app_build_app_tgz() {
    info "解压制品..."
    cd "$WORK_DIR"

    gunzip -c mihomo.gz > mihomo
    chmod +x mihomo

    unzip -q metacubexd.zip
    [ ! -d "metacubexd-gh-pages" ] && error "未找到 metacubexd-gh-pages 目录"

    chmod +x fnos-mihomo-dashboard

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui" "$dst/metacubexd"

    cp "$WORK_DIR/mihomo" "$dst/mihomo"
    chmod +x "$dst/mihomo"

    cp "$WORK_DIR/fnos-mihomo-dashboard" "$dst/fnos-mihomo-dashboard"
    chmod +x "$dst/fnos-mihomo-dashboard"

    cp -a "$WORK_DIR/metacubexd-gh-pages/." "$dst/metacubexd/"

    cp "$PKG_DIR/bin/mihomo-server" "$dst/bin/mihomo-server"
    chmod +x "$dst/bin/mihomo-server"

    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
