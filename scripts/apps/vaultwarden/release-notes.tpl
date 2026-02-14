自动构建的 fnOS 安装包

- 基于 [Vaultwarden ${VERSION}](https://github.com/dani-garcia/vaultwarden/releases/tag/${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 默认数据目录: `${TRIM_PKGVAR}/data`

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 创建账户
2. 建议启用 HTTPS 并配置反向代理
3. 数据存储在 SQLite 数据库中，自动创建于数据目录

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
