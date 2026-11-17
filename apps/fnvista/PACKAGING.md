# 飞牛视野 FnVista：官方 FPK 直通

对应 #356，上游：https://github.com/mclhm8182/FnVista 。

`scripts/apps/fnvista/meta.env` 使用现有 CI 官方 FPK 直通机制：
版本 `1.0.1` 对应标签 `v1.0.1`、资产 `FnVista-1.0.1.fpk`。
x86、ARM 均采用同一个 `platform=all` 包，保留上游生命周期、向导与桌面 CGI。
输出前缀和应用标识均为 `fnos-bing-wallpaper`，与官方安装一致，
目录名及发布标签命名空间仍是 `fnvista`。

本目录 `fnos/` 仅供元数据、图标与 L1 检查使用，其 `platform=x86`、
`service_port=0` 是本仓库元数据约定，不会写入下载的官方包。
`build.sh` 和 `service-setup` 明确拒绝重打包。

```bash
bash apps/fnvista/update_fnvista.sh --arch x86
bash apps/fnvista/update_fnvista.sh --arch arm v1.0.1
```

可通过 `OUTPUT_DIR` 指定输出目录，通过 `FNVISTA_VERSION` 指定版本。
上游是 MIT 许可，完整许可保存在本目录 `LICENSE`。
上游 README 同时保留 pmxwxhn/fnos-bing-wallpaper 的 MIT 署名；
发布说明保留作者与上游署名链接。官方 FPK 没有独立 LICENSE 文件，
本实现不修改官方包以注入文件。

## 已完成的检查（2026-11-17）

- 实际下载构建 x86、ARM 均成功，两个输出逐字节等于官方资产。
- SHA256 均为
  `1e9fb621c5deb50bb9bda13b85625956b4de40ac5e8f142123e115a0b2dab65d`，
  同时匹配 GitHub Release API digest 与官方 `SHA256SUMS`。
- 官方 manifest：`appname=fnos-bing-wallpaper`、`version=1.0.1`、
  `platform=all`、`install_type=root`、`checkport=false`，
  无 service_port；`app.tgz` MD5 与 manifest 一致。
- L1 与 fnmedia-dl 合计 24 项通过；新脚本的 ShellCheck（跟随 source）通过。
  版本规范化、GITHUB_OUTPUT、非法版本/架构/选项拒绝、重打包拒绝通过。
- 官方生命周期脚本 bash 语法、向导 JSON、权限/资源 JSON 均通过，
  载荷为 shell/CGI，没有 ELF 架构绑定。
- 原样运行 L2 在两个输出上均返回 1：缺少本仓库要求的
  `cmd/common`、`cmd/installer`。官方包不依赖这些文件，不能通过修改安装包补齐。
  L2 在此提前退出，后续步骤未运行；版本、平台、checksum、生命周期和架构
  已单独核对。通用检查的平台/端口规则同样不适用于此桌面应用。
- 未访问 VM，未执行安装或浏览器验收；运行时结果仍待主执行者验证。

持久证据位于工作区父目录
`.evidence/issues-356-357-20261117/`，包括官方 Release JSON、许可、FPK、
SHA256SUMS、四个构建产物、L1/L2/构建日志、`identity.json`、
`architecture-audit.json`、`official-contracts.json`、`cli-checks.json`
以及 `inspection/` 中的官方生命周期与配置文件。

## 交给主执行者的 VM / 浏览器场景

1. 使用可还原的真实 fnOS 桌面测试环境、管理员登录会话；先记录原壁纸截图，
   备份用户壁纸偏好和相关系统资源。准备 curl、ffmpeg/ffprobe、Python 3、
   cron/systemd、zip/unzip、postgres 用户与可访问的 `trim_sac` 数据库，
   并确认 `/usr/trim/www/static/bg`、`/usr/trim/var/trim_sac/wallpaper`
   及系统前端资源存在。网络需能访问 Bing 图片接口。
   上游 manifest 未声明最低 fnOS 版本，不能仅凭打包结果声称某系统版本兼容。
2. 经应用中心上传 `builds/fnos-bing-wallpaper_1.0.1_x86.fpk`。
   确认以 root 安装；检查 `/usr/local/sbin/` 中官方脚本、
   `/etc/cron.d/fnos-bing-wallpaper`、`/var/lib/fnos-wallpaper/`、
   `/var/log/fnos-bing-wallpaper.log`。安装钩子还会调用
   `fnos-www-zip-patch.sh` 修改 `/usr/trim/share/.restore/www.zip`
   和相关前端文件，不能只按 README 的“桌面壁纸”描述验收。
3. 从桌面「飞牛视野」图标打开
   `/cgi/ThirdParty/fnos-bing-wallpaper/index.cgi/`，确认无需独立端口。
   记录页面与桌面截图，点击每日精选中的一张图片，确认桌面随即更新、
   浏览器会话不掉线。上传自有测试照片或选取 NAS 图片目录，确认加入壁纸池。
   开启 30 秒轮播，观察至少两次更换，启动屏保并退出；
   在桌面与手机宽度检查页面可操作。
4. 修改运行时间并重开页面确认保存；检查 cron 含每日任务、14:30/21:00 补抓、
   watchdog 与启用轮播时对应的任务。核对近期图片日期与去重，
   Bing 失败时记录网络错误，不能把安装成功视为壁纸功能成功。
5. 停止应用，确认 cron 删除、轮播进程结束、系统原壁纸恢复，
   包括前端资源还原情况；再次启动确认任务和桌面功能恢复。
   在可还原环境先装官方 `v1.0` 并保存照片、运行时间，
   再上传本次包覆盖升级，确认 1.0.1、原配置与照片保留且 cron 不重复。
6. 卸载向导保留默认“恢复飞牛系统原始壁纸”（`wizard_restore=true`），
   确认桌面与壁纸数据库指针恢复、cron/轮播进程/部署脚本清理，
   并核对 `www.zip` 及 live 前端恢复情况。上游默认保留
   `/var/lib/fnos-wallpaper` 缓存/备份和日志，记录为预期保留数据。
   不因“应用中心已卸载”就推断所有系统修改均已还原。
7. ARM 运行验证须另有真实 ARM fnOS 设备；x86 VM 不覆盖该场景。
   测试结束关闭浏览器测试会话、停止所有测试服务，并按工作区规则关闭 VM。
