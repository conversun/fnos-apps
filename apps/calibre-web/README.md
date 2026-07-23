# Calibre-Web for fnOS

Calibre-Web 是用于浏览、管理和在线阅读 Calibre 电子书库的轻量 Web 应用。

## 使用说明

- 访问地址：`http://<fnOS-IP>:8083`
- 默认账号：`admin`
- 默认密码：`admin123`（首次登录后请立即修改）
- 书库目录映射为容器内的 `/books`。请在 `Calibre-WebBooks` 数据共享中放置或迁移现有 Calibre 书库，并在应用中选择包含 `metadata.db` 的 `/books` 目录。

## 电子书转换

电子书格式转换需要可选的 Docker Mod：`DOCKER_MODS=linuxserver/mods:universal-calibre`。该 Mod 仅支持 x86_64，且不会默认写入 Docker Compose 配置；需要时请自行在 Docker 环境中配置。

## 本地构建

```bash
cd apps/calibre-web && ./update_calibre-web.sh
```
