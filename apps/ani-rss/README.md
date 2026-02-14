# ani-rss for fnOS

每日自动同步 [ani-rss](https://github.com/wushuo894/ani-rss) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=ani-rss) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**默认账号**: `admin` / `admin`
**访问地址**: `http://<NAS-IP>:7789`

## 说明

- 动漫 RSS 自动追番、订阅、下载和刮削工具
- 依赖 fnOS 系统 Java 17 运行环境 (`install_dep_apps=java-17-openjdk`)，安装时自动部署
- 支持自动识别季数集数和重命名
- 首次登录请及时修改默认密码

## 本地构建

```bash
./update_ani-rss.sh                       # 最新版本，自动检测架构
./update_ani-rss.sh --arch arm            # 指定架构
./update_ani-rss.sh --arch arm 2.5.2      # 指定版本
./update_ani-rss.sh --help                # 查看帮助
```

## 版本标签

- `ani-rss/v2.5.2` — 首次发布
- `ani-rss/v2.5.2-r2` — 同版本打包修订

## Credits

- [ani-rss](https://github.com/wushuo894/ani-rss) - Anime RSS Auto-Tracker
