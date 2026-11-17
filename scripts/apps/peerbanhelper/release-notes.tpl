自动构建的 fnOS 安装包

- 基于 [PeerBanHelper](https://github.com/PBH-BTN/PeerBanHelper) 官方 Docker 镜像，固定上游版本
- 平台: fnOS（x86 / ARM）
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 使用 host 网络，数据保存在应用数据目录 data/
- 首次访问 Web UI 完成初始化；Docker 下载器也需使用 host 网络，以获取真实 Peer IP
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
