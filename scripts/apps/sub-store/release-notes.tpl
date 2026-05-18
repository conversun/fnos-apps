自动构建的 fnOS 安装包

- 基于 [Sub-Store ${VERSION}](https://github.com/sub-store-org/Sub-Store/releases/tag/${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 默认数据目录: `${TRIM_PKGVAR}/data`

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 即可使用
2. 数据存储在 `${TRIM_PKGVAR}/data`，包括订阅、自定义脚本、Gist 同步配置等
3. 高级配置 (定时任务、推送服务、备份恢复) 请参考 [上游 Docker Hub 文档](https://hub.docker.com/r/xream/sub-store)

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
