飞牛影视反代原生 x86 安装包

- 从 [上游官方 OCI 镜像](https://hub.docker.com/r/544849412/fnysfd)提取未修改的 Go 二进制，不编译上游代码，运行时不需要 Docker。
- 仅支持 x86；上游 ARM 镜像实际包含 x86 二进制，暂不发布 ARM 包。
- 管理面板：`http://NAS_IP:28006`；反代端口：`28005`；默认目标：`http://127.0.0.1:8005`。
- 首次登录账号和密码均为 `admin`，请在管理面板修改。配置和日志保存在应用私有数据目录，升级时保留。
- 原生模式请先在飞牛应用访问权限中授权 STRM 目录，再在面板填写相同的主机路径和容器路径；无需容器映射。容器重启功能不适用于原生包，请通过飞牛应用中心启停。
- 包内 `upstream-image.txt` 记录实际 OCI 摘要和二进制 SHA256。上游 3.4.1 镜像内嵌版本仍显示 3.4.0，本包保持原样。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
