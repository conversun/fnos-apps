自动构建的 fnOS 安装包

- 基于 [Immich ${VERSION}](https://github.com/immich-app/immich/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 包含服务: immich-server, machine-learning, PostgreSQL (pgvector), Redis
- 支持 Intel QuickSync 硬件加速转码

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 创建管理员账户
2. 上传照片或配置手机客户端自动备份
3. 建议配置反向代理以启用 HTTPS

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
