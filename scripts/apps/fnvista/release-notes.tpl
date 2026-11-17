飞牛视野 FnVista 官方 fnOS 安装包直通发布

- 直接采用 [FnVista](https://github.com/mclhm8182/FnVista) 上游官方 FPK，保留完整生命周期、安装与卸载向导，不修改安装包。
- 每日 Bing 壁纸、本地照片、壁纸轮换与屏保；无独立 TCP 端口，通过 fnOS 桌面 CGI 页面打开。
- 支持 x86 和 ARM，两个下载链接使用同一个 platform=all 安装包。
- 系统应用以 root 安装，需要 ffmpeg、cron 及真实 fnOS 桌面环境；沿用官方脚本对系统壁纸、数据库、前端资源和定时任务的管理。
- 数据与原始壁纸备份位于 /var/lib/fnos-wallpaper；停止会恢复原始壁纸，卸载向导默认恢复壁纸，保留缓存与备份。
- 保留上游应用标识 fnos-bing-wallpaper，支持已有官方安装的覆盖升级。
- [MIT License](https://github.com/mclhm8182/FnVista/blob/main/LICENSE)，Copyright (c) 2026 mclhm8182；上游致谢 pmxwxhn/fnos-bing-wallpaper（MIT，Copyright (c) 2026 pmxwxhn）。Bing 图片版权归原作者所有。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
