# LX Music Player for fnOS

聚合多平台音乐搜索与在线播放的 Web 播放器，基于 [lxserver](https://github.com/XCQ0607/lxserver) 打包。

- **上游仓库**: https://github.com/XCQ0607/lxserver
- **打包仓库**: https://github.com/harbiu317/lxserver
- **默认端口**: 17000
- **架构**: 仅 x86（依赖 nodejs_v24 原生模块编译）

## 功能

- 多平台聚合搜索（网易云、QQ、酷狗、酷我、咪咕）
- 自定义音源管理
- 多音质选择（128k/320k/FLAC/Hi-Res）
- 歌词显示、音频可视化、缓存管理
- LX Music 客户端数据同步
- PWA 支持

## 特殊说明

本应用不走标准 `update_*.sh` 构建流程。因为需要 TypeScript 编译 + npm install（含原生模块），构建在 [harbiu317/lxserver](https://github.com/harbiu317/lxserver) 中完成，fpk 通过 GitHub Release 发布。

## 本地构建

参见 https://github.com/harbiu317/lxserver
