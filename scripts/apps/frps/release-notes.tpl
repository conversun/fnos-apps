自动构建的 fnOS 安装包

- 基于 [frp v${VERSION}](https://github.com/fatedier/frp/releases/tag/v${VERSION})（仅打包 frps 服务端；配置文件位于应用数据目录 frps.toml，面板初始密码见应用日志）
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}（面板 7500）${REVISION_NOTE}
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
