自动构建的 fnOS 安装包

- 基于 [VibeNVR v${VERSION}](https://github.com/spupuz/VibeNVR/releases/tag/v${VERSION})
- 上游镜像: `spupuz/vibenvr-frontend:${VERSION}`、`spupuz/vibenvr-backend:${VERSION}`、`spupuz/vibenvr-engine:${VERSION}`、`postgres:15-alpine`
- 平台: fnOS / x86 (amd64) only（上游镜像当前仅发布 amd64）
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 硬件加速: engine 容器使用 privileged + `/dev/dri` 以支持 VAAPI
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${VERSION}_x86.fpk)
