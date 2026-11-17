自动构建的 fnOS 安装包

- 基于 [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) 官方 Docker 镜像，固定上游版本
- 平台: fnOS（x86 / ARM）
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 提供 API，无管理界面；仅供可信网络访问，不要暴露到公网
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
