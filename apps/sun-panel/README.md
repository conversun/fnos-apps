# Sun-Panel for fnOS

每日自动同步 [Sun-Panel 官方](https://doc.sun-panel.top/zh_cn) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=sun-panel) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:3002`

**默认账号**: admin@sun.cc  
**默认密码**: 12345678

## 说明

- Sun-Panel 是一个 NAS/服务器导航面板
- 支持多账户管理和 Docker 容器管理
- 内置小窗口功能，支持浏览器扩展
- 配置文件存储在应用数据目录的 `conf/` 子目录中

## 本地构建

```bash
./update_sun-panel.sh                        # 最新版本，自动检测架构
./update_sun-panel.sh --arch arm             # 指定架构
./update_sun-panel.sh --arch arm 1.8.1       # 指定版本
./update_sun-panel.sh --help                 # 查看帮助
```

## 版本标签

- `sun-panel/v1.8.1` — 首次发布
- `sun-panel/v1.8.1-r2` — 同版本打包修订

## Credits

- [Sun-Panel](https://doc.sun-panel.top/zh_cn) - NAS导航面板
