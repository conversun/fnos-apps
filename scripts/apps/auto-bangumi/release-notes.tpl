自动构建的 fnOS 安装包

- 基于 [AutoBangumi ${VERSION}](https://github.com/EstrellaXD/Auto_Bangumi/releases/tag/${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 默认数据目录: `${TRIM_PKGVAR}/config` 和 `${TRIM_PKGVAR}/data`

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 进入管理界面
2. 默认账号: `admin` / `adminadmin`，登录后请立即修改密码
3. 需要配合 qBittorrent 使用，请确保已安装并配置 qBittorrent

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
