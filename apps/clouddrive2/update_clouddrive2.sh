#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="clouddrive2"
APP_DISPLAY_NAME="CloudDrive2"
APP_VERSION_VAR="CLOUDDRIVE2_VERSION"
APP_VERSION="${CLOUDDRIVE2_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="clouddrive2"
APP_HELP_VERSION_EXAMPLE="0.9.22"

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 0.9.22       # 指定版本，x86 架构
  $0 0.9.22                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -fsSL "https://hub.docker.com/v2/repositories/cloudnas/clouddrive2/tags/?page_size=100&ordering=last_updated" | \
        jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.9.22"
    info "目标版本: $APP_VERSION"
}

app_download() {
    info "准备 Docker 模式资源 ($ARCH)..."
    mkdir -p "$WORK_DIR"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/docker" "$dst/ui"

    cp "$PKG_DIR/docker/docker-compose.yaml" "$dst/docker/docker-compose.yaml"
    sed -i.bak "s/\${VERSION}/${APP_VERSION}/g" "$dst/docker/docker-compose.yaml"
    rm -f "$dst/docker/docker-compose.yaml.bak"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
