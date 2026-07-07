自动构建的 fnOS 安装包

- 基于 [AstrBot v${VERSION}](https://github.com/AstrBotDevs/AstrBot/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 基于 Docker 容器运行，需要 fnOS Docker 环境
- 默认数据目录: `${TRIM_PKGVAR}/data`（挂载到容器 `/AstrBot/data`）
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
