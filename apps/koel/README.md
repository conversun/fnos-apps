# Koel for fnOS

每日自动同步 [Koel 官方](https://koel.dev/) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=koel) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:8060`

**默认账号**: admin@koel.dev
**默认密码**: KoelIsCool

## 说明

- Koel 是个人音乐流媒体服务器，支持在线播放本地音乐库
- Spotify 风格的现代化 UI
- 内置 SQLite 数据库，无需额外配置
- 支持 MP3、FLAC、AAC 等常见音频格式
- 首次登录后请立即修改密码

## 本地构建

```bash
cd apps/koel && bash ../../scripts/build-fpk.sh . app.tgz
```

## 版本标签

- `koel/v8.3.0` — 首次发布
- `koel/v8.3.0-r2` — 同版本打包修订

## Credits

- [Koel](https://koel.dev/) - A personal music streaming server that works
