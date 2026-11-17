# 批量下载助手：官方 FPK 直通

对应 #357，上游：https://github.com/maglcal/fnmedia-dl 。

`scripts/apps/fnmedia-dl/meta.env` 驱动现有 CI 直通分支：
版本 `0.1.43` 对应标签 `main-v0.1.43`、资产
`fnmedia-dl-main-v0.1.43.fpk`。x86、ARM 均下载同一个 `platform=all`
安装包，完整保留上游内容，不经过 `build-fpk.sh`。本目录 `fnos/` 仅供目录元数据、
图标与 L1 检查使用，`platform=x86`、`service_port=0` 是本仓库元数据约定；
实际安装包没有 TCP 端口。`build.sh` 和 `service-setup` 明确拒绝重打包。

```bash
bash apps/fnmedia-dl/update_fnmedia-dl.sh --arch x86
bash apps/fnmedia-dl/update_fnmedia-dl.sh --arch arm main-v0.1.43
```

可通过 `OUTPUT_DIR` 指定输出目录，通过 `FNMEDIA_DL_VERSION` 指定版本。
个人非商业许可允许在非商业前提下分发完整原始副本；完整许可与版权保存在
本目录 `LICENSE`，官方 FPK 内的 `repo/LICENSE` 也完整保留。

## 已完成的检查（2026-11-17）

- 实际下载构建 x86、ARM 均成功，两个输出逐字节等于官方资产。
- SHA256 均为
  `a6bbb9852f0df325cea60bc0d84fa595a4e2a6032aac20fb656c12a751733511`，
  匹配 GitHub Release API 的资产 digest。上游同名 `.sha256` 文件实际是更新说明，
  没有校验和，不能用于校验。
- 官方 manifest：`appname=fnmedia-dl`、`version=0.1.43`、`platform=all`，
  `checkport=false`、`micro_app=true`、`os_min_version=1.2.0`；
  `app.tgz` MD5 与 manifest 一致。
- L1 与 FnVista 合计 24 项通过；新脚本的 ShellCheck（跟随 source）通过。
  版本规范化、GITHUB_OUTPUT、非法版本/架构/选项拒绝、重打包拒绝通过。
- 官方生命周期脚本 bash 语法、向导 JSON、资源与权限 JSON 均通过；
  wheelhouse 共 27 个 wheel，pydantic_core 覆盖 CPython 3.10–3.14 的
  x86_64/aarch64，10 个原生 wheel 内 ELF 架构均与 wheel 标签一致。
- 原样运行 L2 在两个输出上均返回 1：缺少 `cmd/common`、`cmd/installer`。
  这是通用检查对本仓库生命周期的要求；上游使用 `cmd/_common`，不应添加文件。
  L2 在此提前退出，未执行其后续检查；后续 checksum、版本、平台、
  生命周期与架构检查已单独完成。其平台/端口规则也不适用于此通用微应用。
- 原始静态交付未访问 VM；后续主执行者的实际运行结果见文末。

持久证据位于工作区父目录
`.evidence/issues-356-357-20261117/`：`upstream/` 保存 Release JSON、
许可、官方包；`builds/` 保存实际构建；`logs/` 保存 L1/L2/构建输出；
`identity.json`、`architecture-audit.json`、`official-contracts.json`、
`cli-checks.json` 保存核对结果，`inspection/` 保存官方元数据与生命周期。

## 交给主执行者的 VM / 浏览器场景

1. 使用可还原的 fnOS 1.2.0+ 测试环境及管理员桌面会话。准备 Python 3.10–3.14、
   venv/ensurepip、systemd 和可写应用卷；确认没有同名安装或先备份。
   本次不要求 Docker：安装向导明确选择「不用迅雷下载引擎」
   （`wizard_xunlei_docker=skip`），默认值会自动拉取并部署容器。
   首次测试保留网络，以便依赖引导需要时访问上游配置的 Python 镜像。
2. 从 `builds/fnmedia-dl_0.1.43_x86.fpk` 经应用中心上传，勾选免责声明，
   保留默认目录选项，安装完成确认 `systemctl is-active fnmedia-dl.service`。
   检查 unit 的用户与实际进程用户；上游 privilege 同时声明 root 和 username，
   能否完成需要系统权限的安装回调必须实测，不能由静态检查推断。
3. 从桌面图标进入 `/app/fnmedia-dl/`，应通过 `fnmedia-dl.sock` 网关正常显示，
   不应要求独立 TCP 端口；刷新、关闭重开均可用。未登录桌面的独立会话
   不应获得管理 API 访问权限。记录桌面、页面与浏览器网络请求证据。
4. 准备已启用 RPC 的 aria2 及一个自有 HTTP 小文件，配置地址、密钥与引擎可写目录，
   测试连通性；解析并派发该链接，验证任务状态、文件内容、暂停/继续/删除。
   保存一个不含秘密的配置标记和任务记录，停止应用确认 service/socket 清理，
   再启动确认网关与配置仍可用。
5. 在独立可还原测试环境，先安装官方 `main-v0.1.42` 并创建配置、任务记录，
   再上传本次 0.1.43 包覆盖升级。确认版本、登录与配置/记录保留，
   检查 `TRIM_PKGVAR/fnmedia-dl-app.log` 的备份/恢复信息，
   不在公开证据中保存凭据。应用内「关于→检查更新」单独记录结果；
   当前已是最新版时不把检查更新等同于完成了应用内升级。
6. 卸载并确认 service 停止、unit 与网关 socket 删除。上游卸载脚本默认不删除
   `repo/state`，但应用中心是否删除安装目录需记录实测结果；
   共享下载目录与任何已有下载文件不得当作应用残留清理。
   若另测 Docker 部署，单独记录 `fnmedia-dl-xunlei` 容器、卷与镜像，
   不把 service 卸载视为容器已自动删除。
7. ARM 运行验证须另有真实 ARM fnOS 设备；x86 VM 不能证明 ARM 运行正常。
   测试结束关闭浏览器测试会话、停止所有测试服务，并按工作区规则关闭 VM。

## 后续实际运行结果

fnOS 1.2.0505 x86 上通过桌面图标认证进入管理页，连接独立的真实
aria2 1.36.0，并派发自有 HTTP 小文件。任务页显示「已完成」、100.0%、
60 B，实际文件 SHA256 与源文件一致。迅雷账号通道与 Docker 通道未配置；
本次验收覆盖 aria2 通道。

0.1.43 原包存在已复现的任务删除限制：对已完成任务点「删除」返回
`aria2 HTTP 400`。原包 `repo/app/backends/aria2.py` 的 `delete`
先调用 `aria2.remove`，再调用 `aria2.forceRemove`；这两个方法用于活动、
等待或暂停的任务，已完成结果需要 `aria2.removeDownloadResult`。本轮通过后者清理了
唯一自建任务。该上游限制仍存在，分发保持官方原包直通。
