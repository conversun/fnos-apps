# Kavita for fnOS

每日自动同步 [Kavita 官方](https://github.com/Kareadita/Kavita) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=kavita) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:5000`

## 说明

- Kavita 是一款开源的漫画、轻小说和电子书阅读服务器
- 支持 Manga、Comic、EPUB、PDF 等多种格式
- 内置阅读器，支持在线阅读和书库管理
- 数据存储在应用数据目录中，书库通过共享文件夹访问

## 本地构建

```bash
cd apps/kavita && bash ../../scripts/build-fpk.sh . app.tgz
```

## Credits

- [Kavita](https://github.com/Kareadita/Kavita) - A fast, feature rich, cross platform reading server
