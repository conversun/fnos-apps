官方 fpk 直通发布的 fnOS 安装包

- 直接采用 [nginx-web](https://github.com/chenpingonline/nginx-web-fnos) 上游官方打包(standard 标准版),字节一致、未做任何修改
- fnOS 桌面可视化管理 HTTP/HTTPS 反代、TCP/UDP 转发、SSL 证书与访问统计
- 需要监听 1024 以下低端口时,请从上游 Release 下载 full-ports 变体(两者不可并装)
- 平台: fnOS(micro-app,经飞牛桌面访问)${REVISION_NOTE}
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
