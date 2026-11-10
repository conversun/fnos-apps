#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VERSION="${VERSION:?必须设置 VERSION}"
TARGET_ARCH="${ARCH:-${DEB_ARCH:-$(uname -m)}}"
case "$TARGET_ARCH" in
    x86|amd64|x86_64) ;;
    *) echo "飞牛影视反代原生包仅支持 x86，不支持 ${TARGET_ARCH}。" >&2; exit 1 ;;
esac
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "无效的上游镜像版本：${VERSION}" >&2
    exit 1
}

OUTPUT_FILE="${PWD}/app.tgz"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fnysfd-build.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/app_root/bin"

IMAGE="544849412/fnysfd"
REGISTRY="https://registry-1.docker.io/v2/${IMAGE}"
TOKEN="$(curl -fsSL --connect-timeout 30 --max-time 60 \
    "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${IMAGE}:pull" \
    | jq -er '.token')"

registry_get() {
    curl -fsSL --connect-timeout 30 --max-time 180 \
        -H "Authorization: Bearer ${TOKEN}" \
        -H 'Accept: application/vnd.oci.image.index.v1+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v2+json' \
        "${REGISTRY}/$1" -o "$2"
}

verify_digest() {
    local digest="$1" path="$2"
    [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
        echo "无效的 OCI SHA256 摘要：${digest}" >&2
        exit 1
    }
    printf '%s  %s\n' "${digest#sha256:}" "$path" | shasum -a 256 -c -
}

registry_get "manifests/${VERSION}" "$WORK_DIR/index.json"
DIGEST="$(jq -er '[.manifests[] | select(.platform.os == "linux" and .platform.architecture == "amd64")] | if length == 1 then .[0].digest else error("missing or ambiguous linux/amd64 image") end' "$WORK_DIR/index.json")"
registry_get "manifests/${DIGEST}" "$WORK_DIR/manifest.json"
verify_digest "$DIGEST" "$WORK_DIR/manifest.json"
echo "上游镜像：docker.io/${IMAGE}:${VERSION}@${DIGEST}"

jq -er '.layers[].digest' "$WORK_DIR/manifest.json" > "$WORK_DIR/layers"
while IFS= read -r layer; do
    registry_get "blobs/${layer}" "$WORK_DIR/layer.tgz"
    verify_digest "$layer" "$WORK_DIR/layer.tgz"
    tar -tzf "$WORK_DIR/layer.tgz" > "$WORK_DIR/list"
    # UI templates are compiled into the Go binary. The other /app files are
    # the container-only entrypoint and empty config/log directories.
    awk '/^app\// {print "上游文件：" $0}' "$WORK_DIR/list"
    if grep -qx 'app/fnysfd' "$WORK_DIR/list"; then
        tar -xOzf "$WORK_DIR/layer.tgz" app/fnysfd > "$WORK_DIR/app_root/bin/fnysfd"
    fi
done < "$WORK_DIR/layers"

file "$WORK_DIR/app_root/bin/fnysfd"
file -b "$WORK_DIR/app_root/bin/fnysfd" | grep -q 'ELF 64-bit.*x86-64' || {
    echo "上游镜像未提供有效的 x86-64 ELF，拒绝打包。" >&2
    exit 1
}
chmod +x "$WORK_DIR/app_root/bin/fnysfd"
cp "$REPO_ROOT/apps/fnysfd/fnos/bin/fnysfd-server" "$WORK_DIR/app_root/bin/"
chmod +x "$WORK_DIR/app_root/bin/fnysfd-server"
cp -a "$REPO_ROOT/apps/fnysfd/fnos/ui" "$WORK_DIR/app_root/ui"
{
    printf 'image=docker.io/%s:%s\nmanifest=%s\n' "$IMAGE" "$VERSION" "$DIGEST"
    printf 'binary_sha256=%s\n' "$(shasum -a 256 "$WORK_DIR/app_root/bin/fnysfd" | cut -d' ' -f1)"
} > "$WORK_DIR/app_root/upstream-image.txt"
tar -czf "$OUTPUT_FILE" -C "$WORK_DIR/app_root" .
echo "已生成原生 x86 app.tgz：${OUTPUT_FILE}"
