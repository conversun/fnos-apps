自动构建的 fnOS 安装包

- 基于 [GAPS-2](https://github.com/primetime43/GAPS-2) 官方 Docker 镜像，固定上游版本
- 平台: fnOS（仅 x86；上游尚无可运行的 ARM 镜像）
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 数据目录持久化保存 config.enc 和 .config.key；备份与迁移时须同时保留
- 需要 Docker、可访问的 Plex/Jellyfin/Emby 服务及 TMDB 密钥；TheTVDB 密钥按功能选配
- 使用飞牛应用中心升级；未启用上游 Docker 更新助手
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
