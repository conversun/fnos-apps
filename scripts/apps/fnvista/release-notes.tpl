飞牛视野 FnVista：上游 1.0.1，本地卸载适配 r1

- 从 [FnVista](https://github.com/mclhm8182/FnVista) 官方 1.0.1 FPK 重打包为 1.0.1-r1，逐字节保留 app.tgz、图标、配置、向导及其他上游钩子；原卸载钩子改名保存，由本地适配器调用。
- 每日 Bing 壁纸、本地照片、壁纸轮换与屏保；无独立 TCP 端口，通过 fnOS 桌面 CGI 页面打开。
- 支持 x86 和 ARM，两个下载链接使用同一个 platform=all 安装包。
- 卸载先撤下 CGI 入口、删除 cron、终止应用写入进程及其子进程，再运行原始卸载。默认恢复时从 orig 直接复制两张 webp；只移除 live HTML 和 www.zip 中应用自己的 CSS/JS 块，避免系统再次展开旧补丁。
- wizard_restore=false 保留当前壁纸与数据库行为，仍撤除失效的 HTML 轮询补丁。缓存、照片、备份和日志按上游约定保留；停止行为仍沿用上游，不属于本次修复。
- 系统应用以 root 安装，需要 ffmpeg、cron、Python 3、ps、zip/unzip 及真实 fnOS 桌面环境。本次仅验证本地打包和隔离检查，真实安装/卸载由主执行者验收。
- 保留上游应用标识 fnos-bing-wallpaper，支持已有官方安装的覆盖升级。
- [MIT License](https://github.com/mclhm8182/FnVista/blob/main/LICENSE)，Copyright (c) 2026 mclhm8182；上游致谢 pmxwxhn/fnos-bing-wallpaper（MIT，Copyright (c) 2026 pmxwxhn）。Bing 图片版权归原作者所有。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
