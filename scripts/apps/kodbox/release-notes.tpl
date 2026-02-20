自动构建的 fnOS 安装包

- 基于 [KodBox ${VERSION}](https://hub.docker.com/r/kodcloud/kodbox/tags)
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 进入初始化界面
2. 数据存储在 `${TRIM_PKGVAR}/data` 目录中

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
