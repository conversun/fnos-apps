#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAME="next-ai-draw-io"
APP_DISPLAY_NAME="Next AI Draw.io"
APP_VERSION_VAR="NEXT_AI_DRAW_IO_VERSION"
APP_VERSION="${NEXT_AI_DRAW_IO_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="next-ai-draw-io"
APP_HELP_VERSION_EXAMPLE="latest"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 latest                 # 使用 latest 镜像标签
EOF
}

app_get_latest_version() {
    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="latest"
    fi
    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 latest"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/next-ai-draw-io/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
