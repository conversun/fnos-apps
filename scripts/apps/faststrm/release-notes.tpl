FastStrm 官方 fnOS 安装包直通发布

- 直接采用 [FastStrm](https://github.com/wabisabi926/faststrm) 上游官方 FPK，未修改二进制或安装脚本。
- 基于 115 生活事件生成 STRM，支持直链/代理路由和 Emby 通知。
- Web 端口固定为 8090；全新安装后通过 Web 创建管理员账号。
- Emby 反向代理默认关闭，可选监听端口 8097，启用前请确认无端口冲突。
- 支持 x86 和 ARM；网盘与媒体服务需自行配置。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
