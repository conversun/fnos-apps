#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAME="siyuan"
APP_DISPLAY_NAME="SiYuan"
APP_VERSION_VAR="SIYUAN_VERSION"
APP_VERSION="${SIYUAN_VERSION:-latest}"
APP_DEPS=(curl jq)
APP_FPK_PREFIX="siyuan"
APP_HELP_VERSION_EXAMPLE="3.8.3"

app_set_arch_vars() {
    info "Docker app — arch independent"
}

app_show_help_examples() {
    cat << EOF
  $0 3.8.3    # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."
    local tag
    tag=$(curl -sL "https://api.github.com/repos/siyuan-note/siyuan/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi
    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 3.8.3"
    info "目标版本: $APP_VERSION"
}

app_download() {
    info "Docker 应用无需下载上游二进制"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst"
    cp "$REPO_ROOT/apps/siyuan/fnos/docker/docker-compose.yaml" "$dst/docker-compose.yaml"
    sed -i.bak "s/\${VERSION}/${APP_VERSION}/g" "$dst/docker-compose.yaml"
    rm -f "$dst/docker-compose.yaml.bak"
    mkdir -p "$dst/ui"
    cp -a "$REPO_ROOT/apps/siyuan/fnos/ui/"* "$dst/ui/" 2>/dev/null || true

    (cd "$dst" && tar -czf "$WORK_DIR/app.tgz" .)
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
