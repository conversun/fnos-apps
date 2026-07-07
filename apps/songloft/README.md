# Songloft for fnOS

Songloft 是面向个人用户的自托管音乐服务器，支持本地音乐库管理、Web 播放、JWT 认证与插件扩展。本 fnOS 包使用官方 Docker 镜像 `songloft/songloft`，默认端口 `58091`，数据目录持久化到应用数据区。

## Local Build

```bash
cd fnos-apps/apps/songloft
./update_songloft.sh
```

首次安装时可在安装向导中设置管理员账号和密码；音乐目录挂载到容器内 `/app/music`，数据目录挂载到 `/app/data`。
