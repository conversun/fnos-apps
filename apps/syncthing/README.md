# Syncthing for fnOS

每日自动同步 [Syncthing 官方](https://syncthing.net/) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=syncthing) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:8384`

## 说明

- Syncthing 是一款开源的文件同步工具，支持多设备间安全同步
- 内置 Web UI，无需额外配置
- 支持端到端加密，保护数据隐私
- 数据存储在应用数据目录中
- 同步端口: 22000 (TCP/UDP)

## 本地构建

```bash
./update_syncthing.sh                        # 最新版本，自动检测架构
./update_syncthing.sh --arch arm             # 指定架构
./update_syncthing.sh --arch arm 1.28.1      # 指定版本
./update_syncthing.sh --help                 # 查看帮助
```

## 版本标签

- `syncthing/v1.28.1` — 首次发布
- `syncthing/v1.28.1-r2` — 同版本打包修订

## Credits

- [Syncthing](https://syncthing.net/) - Open Source Continuous File Synchronization
