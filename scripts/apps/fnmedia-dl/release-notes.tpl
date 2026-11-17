批量下载助手官方 fnOS 安装包直通发布

- 直接采用 [fnmedia-dl](https://github.com/maglcal/fnmedia-dl) 官方 FPK，保留完整生命周期、安装向导和离线依赖，不修改安装包。
- 批量解析磁力、thunder、直链和种子，支持迅雷远程、迅雷引擎与 aria2 通道；下载引擎需自行配置。
- 支持 x86 和 ARM，两个下载链接使用同一个 platform=all 安装包；需要 fnOS 1.2.0 或更新版本及 Python 3 环境。
- 无固定 TCP 端口，通过 fnOS 桌面 iframe 网关打开管理页；安装时需同意上游免责声明。
- 安装向导默认自动部署 Docker 版迅雷，需 Docker；不需要时请选择「不用迅雷下载引擎」。
- 应用内更新和商店升级由上游维护；配置与任务记录位于 repo/state，卸载行为沿用官方脚本。
- [个人非商业使用许可](https://github.com/maglcal/fnmedia-dl/blob/main/LICENSE)，Copyright (c) 2026 许诺；仅限个人、学习、研究等非商业用途，分发须保留完整许可与版权声明。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
