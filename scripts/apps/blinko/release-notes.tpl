自动构建的 fnOS 安装包

- 基于 [Blinko](https://github.com/blinko-space/blinko)（Docker 模式：blinko + PostgreSQL 14 双容器，数据保存在应用数据目录；升级前请先在应用内停止使用，数据库随数据目录保留）
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
