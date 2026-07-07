# ZeroTier for fnOS

ZeroTier 是开源的虚拟局域网与 Mesh VPN 工具。本 fnOS 包使用 Docker 模式部署官方社区常用的 ZTNET 管理栈：

- `sinamics/ztnet`：ZeroTier Controller Web UI，Web 端口映射到 fnOS 服务端口 `3008`
- `postgres:15.2-alpine`：ZTNET 数据库
- `zyclonite/zerotier:1.14.2`：`zerotier-one` 控制器/daemon，持久化 `/var/lib/zerotier-one`

## 安装说明

安装向导会要求填写：

- `NEXTAUTH_URL`：浏览器访问 ZTNET 的完整地址，例如 `http://192.168.1.100:3008`
- `NEXTAUTH_SECRET`：会话密钥
- PostgreSQL 数据库密码
- 可选 ZeroTier 控制器 Token；留空时 ZTNET 会读取内置 `zerotier-one` 数据目录中的 `authtoken.secret`

首次注册的 ZTNET 用户会自动成为管理员。

## Local Build

```bash
cd apps/zerotier && ./update_zerotier.sh
```

## License Notes

ZeroTier core/agent is licensed under MPL-2.0 and is redistributable. This package also deploys ZTNET (`sinamics/ztnet`) as its own upstream project and a PostgreSQL database; review each upstream project's license before redistribution in other contexts.
