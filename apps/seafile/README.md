# Seafile for fnOS

每日自动同步 [Seafile Docker](https://github.com/haiwen/seafile-docker) / `seafileltd/seafile-mc` 最新版本并构建 `.fpk` 安装包。

Seafile 是开源文件同步与共享平台。本 fnOS 包按官方 Docker Compose 的核心服务部署 3 个容器：Seafile Server、MariaDB 和 Memcached。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=seafile) 下载最新的 `.fpk` 文件。

## 安装

1. 下载 `seafile_<version>_x86.fpk` 或 `seafile_<version>_arm.fpk`
2. fnOS 应用管理 → 手动安装 → 上传
3. 根据向导设置管理员邮箱/密码、访问域名或 NAS-IP:8002、数据库密码和 JWT 私钥

**访问地址**: `http://<NAS-IP>:8002`

## 重要说明

- **双架构支持**：`seafileltd/seafile-mc:13.0-latest` 当前提供 `linux/amd64` 和 `linux/arm64` manifest，本应用构建 x86 与 arm 包。
- **默认端口 8002**：只发布 Seafile Web 端口到主机；MariaDB 和 Memcached 仅在 Docker 内部网络通信。
- **数据持久化**：Seafile 数据和 MariaDB 数据分别存储在 `${TRIM_PKGVAR}/seafile-data` 与 `${TRIM_PKGVAR}/mysql`。
- **密钥注入**：管理员账号、数据库密码和 JWT 私钥均通过 fnOS 向导变量直接注入 compose environment，避免容器创建后再写 `.env` 的时序问题。

## Local Build

```bash
cd fnos-apps/apps/seafile
./update_seafile.sh
```

## Credits

- [Seafile](https://www.seafile.com/)
- [Seafile Docker](https://github.com/haiwen/seafile-docker)
- 图标来自 [Dashboard Icons](https://dashboardicons.com/)
