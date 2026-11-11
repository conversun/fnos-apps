Dynv6 管家官方 fnOS 安装包直通发布

- 直接采用 [Dynv6 管家](https://github.com/wabisabi926/dynv6) 上游官方 FPK，未修改二进制或安装脚本。
- 原生 DDNS 更新与 ACME 证书管理，支持 x86 和 ARM。
- 服务监听 8092，由飞牛网关反向代理，无需端口映射。
- 首次使用须创建本地管理员，非回环来源需一次性初始化令牌；网关身份仅用于显示。
- 域名、HTTP Token、证书与通知设置在应用内配置。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
